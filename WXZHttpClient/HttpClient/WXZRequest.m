//
//  WXZRequest.m
//  WXZHttpClient
//
//  Created by wangxiangzhao on 2020/12/17.
//

#import "WXZRequest.h"
#import "WXZRequestManager.h"

static NSTimeInterval const kDefaultTimeOut = 15;

@implementation WXZRequest

- (instancetype)initWithPath:(NSString *)path method:(NSString *)method params:(NSDictionary * _Nullable)params {
    self = [self init];
    if (self) {
        _path = path;
        _method = method;
        _params = params;
    }
    return self;
}

- (void)start {
    [[WXZRequestManager shared] addRequest:self];
}

- (void)stop {
    [[WXZRequestManager shared] cancelRequest:self];
}

- (void)pause {
    [[WXZRequestManager shared] pauseRequest:self];
}

- (void)restart {
    [[WXZRequestManager shared] restartRequest:self];
}

- (void)cleared {
    self.delegate = nil;
}

#pragma mark - setter / getter

- (NSDictionary *)responseHeaders {
    return self.response.allHeaderFields;
}

- (NSInteger)statusCode {
    return self.response.statusCode;
}

- (NSHTTPURLResponse *)response {
    return (NSHTTPURLResponse *)self.sessionTask.response;
}

- (NSTimeInterval)timeOutInterval {
    return _timeOutInterval == 0 ? kDefaultTimeOut : _timeOutInterval;
}


@end
