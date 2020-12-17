//
//  WXZNetWorkConfig.m
//  WXZHttpClient
//
//  Created by wangxiangzhao on 2020/12/17.
//

#import "WXZNetWorkConfig.h"

@implementation WXZNetWorkConfig

static WXZNetWorkConfig *shared = nil;

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[WXZNetWorkConfig alloc] init];
    });
    return shared;
}

+ (instancetype)configWithHost:(NSString *)host cdn:(NSString * _Nullable)cdn params:(NetConfigGlobalParamsBlock _Nullable)params header:(NetConfigGlobalRequestHeaderBlock _Nullable)header {
    WXZNetWorkConfig *config = [WXZNetWorkConfig shared];
    config.host = host;
    config.cdnHost = cdn;
    config.globalParamsBlock = params;
    config.globalRequestHeaderBlock = header;
    return config;
}

@end
