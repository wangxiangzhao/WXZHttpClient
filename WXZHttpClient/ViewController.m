//
//  ViewController.m
//  WXZHttpClient
//
//  Created by wangxiangzhao on 2020/12/17.
//

#import "ViewController.h"
#import "WXZRequestManager.h"
#import "WXZNetWorkConfig.h"
#import "AFNetworking.h"
#import "WXZRequest.h"

#import "WXZBatchRequest.h"
#import "WXZSerialRequest.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //全局配置
    [WXZNetWorkConfig configWithHost:@"https://app.hotnovelapp.com/" cdn:nil params:nil header:^NSDictionary * _Nullable{
        return @{};
    }];
    //单个请求
    UIDevice * currentDevice = [UIDevice currentDevice];
    NSString * deviceId = [[currentDevice identifierForVendor] UUIDString];
    WXZRequest *request = [[WXZRequest alloc] initWithPath:@"user/register/" method:@"POST" params:@{@"deviceId" : deviceId}];
    request.requestSerializerType = WXZRequestSerializerTypeJson;
    request.responseSerializerType = WXZResponseSerializerTypeJSON;
    request.delegate = self;
    [request start];
    
    WXZRequest *request1 = [[WXZRequest alloc] initWithPath:@"user/register/" method:@"POST" params:@{@"deviceId" : deviceId}];
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
    
    NSLog(@"啊哈哈");
}

#pragma mark - WXZResponseDelegate

////请求成功
//- (void)request:(WXZRequest *)request successWithResponse:(id)response {
//
//}

@end
