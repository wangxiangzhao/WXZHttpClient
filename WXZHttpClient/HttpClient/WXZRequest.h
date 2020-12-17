//
//  WXZRequest.h
//  WXZHttpClient
//
//  Created by wangxiangzhao on 2020/12/17.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@class WXZRequest;

typedef NS_ENUM(NSUInteger, WXZRequestSerializerType) {
    WXZRequestSerializerTypeHttp,
    WXZRequestSerializerTypeJson,
};

typedef NS_ENUM(NSInteger , WXZResponseSerializerType) {
    WXZResponseSerializerTypeHTTP,
    WXZResponseSerializerTypeJSON,
};

NS_ASSUME_NONNULL_BEGIN

@protocol WXZResponseDelegate <NSObject>

@optional

//上传数据for request
- (nullable void (^)(id<AFMultipartFormData> _Nonnull))formDataForRequest:(WXZRequest *)request;
//数据传输中
- (void)request:(WXZRequest *)request inProgress:(NSProgress *)progress;
//请求失败
- (void)request:(WXZRequest *)request failed:(NSError *)failed;
//请求成功
- (void)request:(WXZRequest *)request successWithResponse:(id)response;

@end

@interface WXZRequest : NSObject

- (instancetype)initWithPath:(NSString *)path method:(NSString *)method params:(NSDictionary * _Nullable)params;

@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *cdnHost;
@property (nonatomic, assign) BOOL useCDN;
@property (nonatomic, copy) NSString *path;

@property (nonatomic, copy) NSString *method;

@property (nonatomic, strong, nullable) NSDictionary *params;
//忽略全局参数, 默认不开启
@property (nonatomic, assign) BOOL ignoreGlobalParameter;

@property (nonatomic, assign) WXZRequestSerializerType requestSerializerType;
@property (nonatomic, assign) WXZResponseSerializerType responseSerializerType;

@property (nonatomic, assign) NSTimeInterval timeOutInterval;
//自定义响应可处理的ContentType
@property (nonatomic, strong) NSSet<NSString *> *responseAcceptableContentTypes;
//自定义header传参
@property (nonatomic, strong) NSDictionary *requestHeaderFieldValueDictionary;

@property (nonatomic, strong) NSURLSessionTask *sessionTask;
@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, weak) id<WXZResponseDelegate> delegate;

@property (nonatomic, strong, readonly) NSDictionary *responseHeaders;
@property (nonatomic, assign, readonly) NSInteger statusCode;
@property (nonatomic, strong, readonly) NSHTTPURLResponse *response;

//开始
- (void)start;
//停止
- (void)stop;
//暂停
- (void)pause;
//重新开始
- (void)restart;

//清除回调
- (void)cleared;

@end

NS_ASSUME_NONNULL_END
