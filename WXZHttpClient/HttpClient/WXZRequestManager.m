//
//  WXZRequestManager.m
//  WXZHttpClient
//
//  Created by wangxiangzhao on 2020/12/17.
//

#import "WXZRequestManager.h"
#import "WXZNetWorkConfig.h"
#import "AFNetworking.h"
#import "WXZRequest.h"
#include <pthread.h>

@interface WXZRequestManager ()

//请求记录
@property (strong, nonatomic) NSMutableDictionary *requestsRecord;

//主要为了兼容 各种解析方式的拼接管理类  每次都生成的话会内存泄漏  所以构建过的都保存起来
@property (strong, nonatomic) NSMutableDictionary *sessionManagerDict;

@end

@implementation WXZRequestManager

static WXZRequestManager *shared = nil;

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[WXZRequestManager alloc] init];
    });
    return shared;
}

- (void)addRequest:(WXZRequest *)request {
    [self startRequest:request];
    [self addOperation:request];
}

- (void)cancelRequest:(WXZRequest *)request {
    [request.sessionTask cancel];
    [self removeOperation:request];
}

- (void)pauseRequest:(WXZRequest *)request {
    [request.sessionTask suspend];
}

- (void)restartRequest:(WXZRequest *)request {
    if (request.sessionTask.state == NSURLSessionTaskStateSuspended) {
        [request.sessionTask resume];
    }
}

- (void)cancelAllRequests {
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        WXZRequest *request = copyRecord[key];
        [request stop];
    }
}

- (void)pauseAllRequests {
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        WXZRequest *request = copyRecord[key];
        [request pause];
    }
}

- (void)restartAllRequests {
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        WXZRequest *request = copyRecord[key];
        [request restart];
    }
}

#pragma mark - 开始请求

- (void)startRequest:(WXZRequest *)request {
    AFHTTPSessionManager *manager = [self sessionManagerByRequest:request];
    NSString *url = [self urlForRequest:request];
    NSDictionary *params = [self paramsForRequest:request];
    NSDictionary *header = [self headerForRequest:request];
    for (id httpHeaderField in header.allKeys) {
        id value = header[httpHeaderField];
        if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
            [manager.requestSerializer setValue:(NSString *)value forHTTPHeaderField:(NSString *)httpHeaderField];
        }
    }
    request.session = manager.session;
    manager.requestSerializer.timeoutInterval = [request timeOutInterval];
    
    if ([request.delegate respondsToSelector:@selector(formDataForRequest:)]) {
        request.sessionTask = [manager POST:url parameters:params headers:header constructingBodyWithBlock:[request.delegate formDataForRequest:request] progress:^(NSProgress * _Nonnull uploadProgress) {
            if ([request.delegate respondsToSelector:@selector(request:inProgress:)]) {
                [request.delegate request:request inProgress:uploadProgress];
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self dealRequest:request resopnseObject:responseObject error:nil];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self dealRequest:request resopnseObject:nil error:error];
        }];
        return;
    }
    request.sessionTask = [manager dataTaskWithHTTPMethod:request.method URLString:url parameters:params headers:header uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        if ([request.delegate respondsToSelector:@selector(request:inProgress:)]) {
            [request.delegate request:request inProgress:uploadProgress];
        }
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        if ([request.delegate respondsToSelector:@selector(request:inProgress:)]) {
            [request.delegate request:request inProgress:downloadProgress];
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self dealRequest:request resopnseObject:responseObject error:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self dealRequest:request resopnseObject:nil error:error];
    }];
    [request.sessionTask resume];
}

#pragma mark - request 管理

- (void)clearRequest:(WXZRequest *)request {
    [self removeOperation:request];
}

- (void)addOperation:(WXZRequest *)request {
    if (request.sessionTask != nil) {
        NSString *key = [self requestHashKey:request.sessionTask];
        @synchronized(self) {
            _requestsRecord[key] = request;
        }
    }
}

- (void)removeOperation:(WXZRequest *)request {
    NSString *key = [self requestHashKey:request.sessionTask];
    @synchronized(self) {
        [_requestsRecord removeObjectForKey:key];
        [request cleared];
    }
}

- (NSString *)requestHashKey:(NSURLSessionTask *)task {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[task hash]];
    return key;
}

#pragma mark - 构建请求基础配置

//构建sessionManager
- (AFHTTPSessionManager *)sessionManagerByRequest:(WXZRequest *)request {
    NSString *key = [NSString stringWithFormat:@"%ld", (long)((request.requestSerializerType + 1) + (request.responseSerializerType + 1) * 10)];
    AFHTTPSessionManager *_manager = self.sessionManagerDict[key];
    if (!_manager || ![_manager isKindOfClass:[AFHTTPSessionManager class]]) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [self requestSerializerByRequest:request];
        manager.responseSerializer = [self responseSerializerByRequest:request];
        [self.sessionManagerDict setObject:manager forKey:key];
        return manager;
    }
    return _manager;
}

- (AFHTTPRequestSerializer *)requestSerializerByRequest:(WXZRequest *)request {
    AFHTTPRequestSerializer *requestSerializer = nil;
    if (request.requestSerializerType == WXZRequestSerializerTypeHttp) {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (request.requestSerializerType == WXZRequestSerializerTypeJson) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return requestSerializer;
}

- (AFHTTPResponseSerializer *)responseSerializerByRequest:(WXZRequest *)request {
    AFHTTPResponseSerializer *responseSerializer = nil;
    if (request.responseSerializerType == WXZResponseSerializerTypeHTTP) {
        responseSerializer = [AFHTTPResponseSerializer serializer];
    } else if (request.responseSerializerType == WXZResponseSerializerTypeJSON) {
        responseSerializer = [AFJSONResponseSerializer serializer];
    }
    if (!request.responseAcceptableContentTypes) {
        responseSerializer.acceptableContentTypes = request.responseAcceptableContentTypes;
    } else {
        WXZNetWorkConfig *config = [WXZNetWorkConfig shared];
        if (!config.responseAcceptableContentTypes) {
            responseSerializer.acceptableContentTypes = config.responseAcceptableContentTypes;
        }
    }
    return responseSerializer;;
}

- (NSString *)urlForRequest:(WXZRequest *)request {
    NSString *path = request.path;
    if ([path hasPrefix:@"http"]) {
        return path;
    }
    WXZNetWorkConfig *config = [WXZNetWorkConfig shared];
    NSString *host;
    if (request.useCDN) {
        if (request.cdnHost.length > 0) {
            host = request.cdnHost;
        } else {
            host = config.cdnHost;
        }
    } else {
        if (request.host.length > 0) {
            host = request.host;
        } else {
            host = config.host;
        }
    }
    return [NSString stringWithFormat:@"%@%@", host, path];
}

- (NSDictionary *)paramsForRequest:(WXZRequest *)request {
    WXZNetWorkConfig *config = [WXZNetWorkConfig shared];
    NSDictionary *params = request.params;
    NSDictionary *globalParams;
    if (config.globalParamsBlock) {
        globalParams = config.globalParamsBlock();
    }
    if (!params) {
        return globalParams;
    }
    if (!globalParams) {
        return params;
    }
    NSMutableDictionary *tempParams = params.mutableCopy;
    [tempParams setDictionary:globalParams];
    return tempParams.copy;
}

- (NSDictionary *)headerForRequest:(WXZRequest *)request {
    WXZNetWorkConfig *config = [WXZNetWorkConfig shared];
    NSDictionary *header = request.requestHeaderFieldValueDictionary;
    NSDictionary *globalHeader;
    if (config.globalRequestHeaderBlock) {
        globalHeader = config.globalRequestHeaderBlock();
    }
    NSMutableDictionary *tempHeader = @{}.mutableCopy;
    if (header != nil) {
        [tempHeader setDictionary:header];
    }
    if (globalHeader != nil) {
        [tempHeader setDictionary:globalHeader];
    }
    return tempHeader.copy;
}

#pragma mark - 处理请求结果

- (void)dealRequest:(WXZRequest *)request resopnseObject:(id _Nullable)responseObject error:(NSError * _Nullable)error {
    if (error) {
        if ([request.delegate respondsToSelector:@selector(request:failed:)]) {
            [request.delegate request:request failed:error];
        }
    } else {
        if ([request.delegate respondsToSelector:@selector(request:successWithResponse:)]) {
            [request.delegate request:request successWithResponse:responseObject];
        }
    }
    [self clearRequest:request];
}

@end
