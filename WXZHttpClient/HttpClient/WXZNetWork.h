//
//  WXZNetWork.h
//  WXZHttpClient
//
//  Created by wangxiangzhao on 2020/12/17.
//

#ifndef WXZNetWork_h
#define WXZNetWork_h

#ifdef __OBJC__

#import "WXZRequest.h"
#import "WXZRequestManager.h"
#import "WXZNetWorkConfig.h"
#import "AFNetworking.h"
#import "WXZSerialRequest.h"
#import "WXZSerialRequest.h"

#endif

//主要为了多个请求一起时获得上传文件的formData
typedef void(^FormDataBlock)(id<AFMultipartFormData> _Nonnull);
typedef FormDataBlock _Nullable (^AppendFormDataBlock)(WXZRequest * _Nullable request);

#endif /* WXZNetWork_h */
