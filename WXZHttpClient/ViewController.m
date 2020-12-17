//
//  ViewController.m
//  WXZHttpClient
//
//  Created by wangxiangzhao on 2020/12/17.
//

#import "ViewController.h"
#import "WXZNetWork.h"

@interface ViewController () <WXZResponseDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [WXZNetWorkConfig configWithHost:@"https://app.hotnovelapp.com/" cdn:nil params:nil header:^NSDictionary * _Nullable{
        return @{};
    }];
    UIDevice * currentDevice = [UIDevice currentDevice];
    NSString * deviceId = [[currentDevice identifierForVendor] UUIDString];
    WXZRequest *request = [[WXZRequest alloc] initWithPath:@"user/register/" method:@"POST" params:@{@"deviceId" : deviceId}];
    request.requestSerializerType = WXZRequestSerializerTypeJson;
    request.responseSerializerType = WXZResponseSerializerTypeJSON;
    request.delegate = self;
    [request start];
}

#pragma mark - WXZResponseDelegate

//请求成功
- (void)request:(WXZRequest *)request successWithResponse:(id)response {
    
}

@end
