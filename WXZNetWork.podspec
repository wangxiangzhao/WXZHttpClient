#
#  Be sure to run `pod spec lint WXZNetWork.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "WXZNetWork"
  spec.version      = "1.0.1"
  spec.summary      = "AFNetworking的封装"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = <<-DESC
                1、全局配置header和基础参数，host以及cdn等
                2、可以更好的对请求进行管理，暂停请求、重新开始请求等多个操作
                3、支持单个请求，并发多个请求统一处理结果，串行执行多个请求并可以中断执行等

    以下是各个操作的执行例子

    //全局配置
    [WXZNetWorkConfig configWithHost:@"https://app.hotnovelapp.com/" cdn:nil params:nil header:^NSDictionary * _Nullable{
        return @{};
    }];
    //单个请求
    WXZRequest *request = [[WXZRequest alloc] initWithPath:@"user/register/" method:@"POST" params:@{}];
    request.requestSerializerType = WXZRequestSerializerTypeJson;
    request.responseSerializerType = WXZResponseSerializerTypeJSON;
    # request.delegate = self;
    # [request start];
    
    WXZRequest *request1 = [[WXZRequest alloc] initWithPath:@"user/register/" method:@"POST" params:@{}];
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

                   DESC

  spec.homepage     = "https://github.com/wangxiangzhao/WXZHttpClient"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See https://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  spec.license      = "MIT"
  # spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  spec.author             = { "小叨" => "13269532539@163.com" }
  # Or just: spec.author    = "小叨"
  # spec.authors            = { "小叨" => "13269532539@163.com" }
  # spec.social_media_url   = "https://twitter.com/小叨"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # spec.platform     = :ios
  spec.platform     = :ios, "9.0"

  #  When using multiple platforms
  spec.ios.deployment_target = "9.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  spec.source       = { :git => "https://github.com/wangxiangzhao/WXZHttpClient.git", :tag => "#{spec.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  spec.source_files  = "WXZHttpClient", "WXZHttpClient/WXZHttpClient/HttpClient/*.{h,m}"
  spec.exclude_files = "WXZHttpClient/WXZHttpClient/HttpClient/"

  spec.public_header_files = "WXZHttpClient/WXZHttpClient/HttpClient/WXZNetWork.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"

  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # spec.framework  = "SomeFramework"
  spec.frameworks = "Foundation", "UIKit"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  spec.dependency "AFNetworking", "~> 4.0.1"

end
