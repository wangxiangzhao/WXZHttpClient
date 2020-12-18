//
//  WXZBatchRequest.h
//  WXZHttpClient
//
//  Created by wangxiangzhao on 2020/12/18.
//并行队列请求

#import <Foundation/Foundation.h>
#import "WXZNetWork.h"

@class WXZRequest, WXZResponse;

NS_ASSUME_NONNULL_BEGIN

typedef void(^BatchCompletedBlock)(NSArray<WXZResponse *> *responses);

@interface WXZBatchRequest : NSObject

+ (void)batchRequestWithRequests:(NSArray<WXZRequest *> *)requests appendDataForm:(AppendFormDataBlock _Nullable)appendDataForm completed:(BatchCompletedBlock)completed;

@end


NS_ASSUME_NONNULL_END
