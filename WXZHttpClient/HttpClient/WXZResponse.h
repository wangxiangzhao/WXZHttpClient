//
//  WXZResponse.h
//  WXZHttpClient
//
//  Created by wangxiangzhao on 2020/12/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXZResponse : NSObject

@property (nonatomic, strong) NSDictionary *header;
@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) NSInteger statusCode;

@end

NS_ASSUME_NONNULL_END
