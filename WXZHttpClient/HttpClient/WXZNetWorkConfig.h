//
//  WXZNetWorkConfig.h
//  WXZHttpClient
//
//  Created by wangxiangzhao on 2020/12/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSDictionary * _Nullable (^NetConfigGlobalParamsBlock)(void);
typedef NSDictionary *_Nullable(^NetConfigGlobalRequestHeaderBlock)(void);

@interface WXZNetWorkConfig : NSObject

+ (instancetype)shared;

+ (instancetype)configWithHost:(NSString *)host cdn:(NSString * _Nullable)cdn params:(NetConfigGlobalParamsBlock _Nullable)params header:(NetConfigGlobalRequestHeaderBlock _Nullable)header;

@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *cdnHost;

@property (nonatomic, strong) NSSet<NSString *> *responseAcceptableContentTypes;
@property (nonatomic, copy) NetConfigGlobalParamsBlock globalParamsBlock;
@property (nonatomic, copy) NetConfigGlobalRequestHeaderBlock globalRequestHeaderBlock;

@end

NS_ASSUME_NONNULL_END
