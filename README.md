1、全局配置header和基础参数，host以及cdn等
2、可以更好的对请求进行管理，暂停请求、重新开始请求等多个操作
3、支持单个请求，并发多个请求统一处理结果，串行执行多个请求并可以中断执行等

    以下是各个操作的执行例子

    //全局配置
    [WXZNetWorkConfig configWithHost:@"https://app.hotnovelapp.com/" cdn:nil params:nil header:^NSDictionary * _Nullable{
        return @{};
    }];
    //单个请求
    WXZRequest *request = [[WXZRequest alloc] initWithPath:@"user/register/" method:@"POST" params:@{}];
    request.requestSerializerType = WXZRequestSerializerTypeJson;
    request.responseSerializerType = WXZResponseSerializerTypeJSON;
    # request.delegate = self;
    # [request start];
    
    WXZRequest *request1 = [[WXZRequest alloc] initWithPath:@"user/register/" method:@"POST" params:@{}];
    request.requestSerializerType = WXZRequestSerializerTypeJson;
    request.responseSerializerType = WXZResponseSerializerTypeJSON;
    
    //并行请求
    [WXZBatchRequest batchRequestWithRequests:@[request, request1] appendDataForm:^FormDataBlock _Nullable(WXZRequest * _Nonnull request) {
        return nil;
    } completed:^(NSArray<WXZResponse *> * _Nonnull responses) {

    }];
    
    //串行请求
    [WXZSerialRequest serialRequestWithRequests:@[request, request1] appendDataForm:nil next:^(NSInteger idx, WXZResponse * _Nonnull response, BOOL * _Nonnull stop) {
        *stop = YES;
    } completed:^{
        
    }];
