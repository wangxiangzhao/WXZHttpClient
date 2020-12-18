//
//  WXZBatchRequest.m
//  WXZHttpClient
//
//  Created by wangxiangzhao on 2020/12/18.
//

#import "WXZBatchRequest.h"
#import "WXZResponse.h"
#import "WXZRequest.h"

@interface WXZBatchRequest () <WXZResponseDelegate>

@property (nonatomic, strong, nullable) NSArray *requests;
@property (nonatomic, strong) NSMutableDictionary *responseDict;
@property (nonatomic) dispatch_group_t group;

@property (nonatomic, copy, nullable) AppendFormDataBlock formDataBlock;

//防止提前释放
@property (nonatomic, strong, nullable) WXZBatchRequest *request;

@end

@implementation WXZBatchRequest

- (void)dealloc
{
    
}

+ (void)batchRequestWithRequests:(NSArray<WXZRequest *> *)requests appendDataForm:(AppendFormDataBlock _Nullable)appendDataForm completed:(BatchCompletedBlock)completed {
    WXZBatchRequest *batchRequest = [[WXZBatchRequest alloc] init];
    batchRequest.formDataBlock = appendDataForm;
    batchRequest.request = batchRequest;
    [batchRequest startWithRequests:requests completed:completed];
}

#pragma mark - WXZResponseDelegate

//上传数据for request
- (nullable void (^)(id<AFMultipartFormData> _Nonnull))formDataForRequest:(WXZRequest *)request {
    if (!self.formDataBlock) {
        return nil;
    }
    return self.formDataBlock(request);
}

//请求失败
- (void)request:(WXZRequest *)request failed:(NSError *)failed {
    [self dealRequest:request responseObject:nil error:failed];
}

//请求成功
- (void)request:(WXZRequest *)request successWithResponse:(id)response {
    [self dealRequest:request responseObject:response error:nil];
}

#pragma mark - privates

- (void)startWithRequests:(NSArray *)requests completed:(BatchCompletedBlock)completed {
    self.requests = requests;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _group = dispatch_group_create();
    for (WXZRequest *request in requests) {
        dispatch_group_enter(_group);
        request.delegate = self;
        [request start];
    }
    __weak typeof(self) weakself = self;
    dispatch_group_notify(_group, queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) self = weakself;
            self.requests = nil;
            if (completed) {
                NSArray *keys = self.responseDict.allKeys;
                keys = [keys sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString *  _Nonnull obj2) {
                    return obj1.integerValue > obj2.integerValue;
                }];
                NSMutableArray *values = @[].mutableCopy;
                for (NSString *key in keys) {
                    [values addObject:self.responseDict[key]];
                }
                completed(values);
            }
            self.request = nil;
        });
    });
}

- (void)dealRequest:(WXZRequest *)request responseObject:(id _Nullable)responseObject error:(NSError * _Nullable)error {
    NSInteger index = [self.requests indexOfObject:request];
    WXZResponse *response = [[WXZResponse alloc] init];
    response.header = request.responseHeaders;
    response.statusCode = request.statusCode;
    response.error = error;
    response.responseObject = responseObject;
    [self.responseDict setObject:response forKey:[NSString stringWithFormat:@"%ld", index]];
    if (_group) {
        dispatch_group_leave(_group);
    }
}

#pragma mark - setter / getter

- (NSMutableDictionary *)responseDict {
    if (!_responseDict) {
        _responseDict = @{}.mutableCopy;
    }
    return _responseDict;
}

@end

