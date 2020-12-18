//
//  WXZSerialRequest.m
//  WXZHttpClient
//
//  Created by wangxiangzhao on 2020/12/18.
//

#import "WXZSerialRequest.h"
#import "WXZResponse.h"
#import "WXZRequest.h"

@interface WXZSerialRequest () <WXZResponseDelegate>

@property (nonatomic, strong, nullable) NSArray *requests;
@property (nonatomic) dispatch_semaphore_t semaphore;

@property (nonatomic, copy, nullable) AppendFormDataBlock formDataBlock;
@property (nonatomic, copy, nullable) SerialNextBlock nextBlock;

//防止提前释放
@property (nonatomic, strong, nullable) WXZSerialRequest *request;
@property (nonatomic, assign) BOOL stop;

@end

@implementation WXZSerialRequest

- (void)dealloc
{
    
}

+ (void)serialRequestWithRequests:(NSArray<WXZRequest *> *)requests appendDataForm:(AppendFormDataBlock _Nullable)appendDataForm next:(SerialNextBlock _Nullable)nextBlock completed:(dispatch_block_t _Nullable)completed{
    WXZSerialRequest *serialRequest = [[WXZSerialRequest alloc] init];
    serialRequest.formDataBlock = appendDataForm;
    serialRequest.nextBlock = nextBlock;
    serialRequest.request = serialRequest;
    [serialRequest startWithRequests:requests completed:completed];
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

- (void)startWithRequests:(NSArray *)requests completed:(dispatch_block_t)completed {
    self.requests = requests;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _semaphore = dispatch_semaphore_create(0);
    __weak typeof(self) weakself = self;
    dispatch_async(queue, ^{
        __strong typeof(self) self = weakself;
        for (WXZRequest *request in requests) {
            if (self.stop) {
                self.requests = nil;
                self.request = nil;
                return;
            }
            request.delegate = self;
            [request start];
            dispatch_semaphore_wait(self.semaphore, dispatch_walltime(NULL, 20 * NSEC_PER_SEC));
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                completed();
            }
        });
        self.requests = nil;
        self.request = nil;
    });
}

- (void)dealRequest:(WXZRequest *)request responseObject:(id _Nullable)responseObject error:(NSError * _Nullable)error {
    NSInteger index = [self.requests indexOfObject:request];
    WXZResponse *response = [[WXZResponse alloc] init];
    response.header = request.responseHeaders;
    response.statusCode = request.statusCode;
    response.error = error;
    response.responseObject = responseObject;
    BOOL stop = NO;
    if (self.nextBlock) {
        self.nextBlock(index, response, &stop);
    }
    self.stop = stop;
    if (_semaphore) {
        dispatch_semaphore_signal(_semaphore);
    }
}

@end
