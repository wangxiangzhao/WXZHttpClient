//
//  WXZRequestManager.h
//  WXZHttpClient
//
//  Created by wangxiangzhao on 2020/12/17.
//

#import <Foundation/Foundation.h>

@class WXZRequest;

NS_ASSUME_NONNULL_BEGIN

@interface WXZRequestManager : NSObject

+ (instancetype)shared;

- (void)addRequest:(WXZRequest *)request;
- (void)cancelRequest:(WXZRequest *)request;

- (void)pauseRequest:(WXZRequest *)request;
- (void)restartRequest:(WXZRequest *)request;

- (void)cancelAllRequests;
- (void)pauseAllRequests;
- (void)restartAllRequests;

@end

NS_ASSUME_NONNULL_END
