//
//  WXZSerialRequest.h
//  WXZHttpClient
//
//  Created by wangxiangzhao on 2020/12/18.
//串行队列请求

#import <Foundation/Foundation.h>
#import "WXZNetWork.h"

@class WXZRequest, WXZResponse;

NS_ASSUME_NONNULL_BEGIN

//stop可控制是否继续执行下去
typedef void(^SerialNextBlock)(NSInteger idx, WXZResponse *response, BOOL *stop);

@interface WXZSerialRequest : NSObject

+ (void)serialRequestWithRequests:(NSArray<WXZRequest *> *)requests appendDataForm:(AppendFormDataBlock _Nullable)appendDataForm next:(SerialNextBlock _Nullable)nextBlock completed:(dispatch_block_t _Nullable)completed;

@end

NS_ASSUME_NONNULL_END
