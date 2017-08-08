//
//  AnnLiuNetworking.m
//  PackageNetWork
//
//  Created by iSolar on 2017/8/7.
//  Copyright © 2017年 iSolar. All rights reserved.
//

#import "AnnLiuNetworking.h"
#import <AFNetworkActivityIndicatorManager.h>
#import "AnnLSVPHUD.h"
#import "AnnLiuCachesHelper.h"
#import "AnnLIuAPIClient.h"
#import "AnnLiuNetConfig.h"

/**
 *  基础URL
 */
static NSString *Ann_privateNetworkBaseUrl = nil;
/**
 *  是否开启接口打印信息
 */
static BOOL Ann_isEnableInterfaceDebug = YES;
/**
 *  是否开启自动转换URL里的中文
 */
static BOOL Ann_shouldAutoEncode = NO;
/**
 *  设置请求头，默认为空
 */
static NSDictionary *Ann_httpHeaders = nil;
/**
 *  设置的返回数据类型
 */
static AnnResponseType Ann_responseType = kAnnResponseTypeData;
/**
 *  设置的请求数据类型
 */
static AnnRequestType  Ann_requestType  = kAnnRequestTypePlainText;
/**
 *  监测网络状态
 */
static AnnNetworkStatus Ann_networkStatus = kAnnNetWorkStatusUnknown;
/**
 *  保存所有网络请求的task
 */
static NSMutableArray *Ann_requestTasks;
/**
 *  是否开启取消请求
 */
static BOOL Ann_shouldCallbackOnCancelRequest = YES;
/**
 *  请求的超时时间
 */
static NSTimeInterval Ann_timeout = 25.0f;
/**
 *  是否从从本地提取数据
 */
static BOOL Ann_shoulObtainLocalWhenUnconnected = YES;
/**
 *  基础url是否更改，默认为yes
 */
static BOOL Ann_isBaseURLChanged = YES;
/**
 *  请求管理者
 */
static AnnLIuAPIClient *Ann_sharedManager = nil;

@implementation AnnLiuNetworking

//更新基础url
+(void)updateBaseUrl:(NSString *)baseUrl
{
    if ([baseUrl isEqualToString:Ann_privateNetworkBaseUrl] && baseUrl && baseUrl.length) {
        Ann_isBaseURLChanged = YES;
    }else
    {
        Ann_isBaseURLChanged = NO;
    }
    Ann_privateNetworkBaseUrl = baseUrl;
}

//url
+(NSString *)baseUrl
{
    return Ann_privateNetworkBaseUrl;
}

//设置超时时间
+(void)setTimeout:(NSTimeInterval)timeout
{
    Ann_timeout = timeout;
}

//网络异常时,是否从缓存取出
+(void)obtainDataFromLocalWhenNetworkUnconnected:(BOOL)shouldObtain
{
    Ann_shoulObtainLocalWhenUnconnected = shouldObtain;
}

//是否打印信息
+(void)enableInterfaceDebug:(BOOL)isDebug
{
    Ann_isEnableInterfaceDebug = isDebug;
}

+ (BOOL)isDebug {
    return Ann_isEnableInterfaceDebug;
}

+ (NSMutableArray *)allTasks {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (Ann_requestTasks == nil) {
            Ann_requestTasks = @[].mutableCopy;
        }
    });
    
    return Ann_requestTasks;
}

+ (void)cancelAllRequest {
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(AnnURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[AnnURLSessionTask class]]) {
                [task cancel];
            }
        }];
        
        [[self allTasks] removeAllObjects];
    };
}

+ (void)cancelRequestWithURL:(NSString *)url {
    if (url == nil) {
        return;
    }
    
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(AnnURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[AnnURLSessionTask class]]
                && [task.currentRequest.URL.absoluteString hasSuffix:url]) {
                [task cancel];
                [[self allTasks] removeObject:task];
                return;
            }
        }];
    };
}

+ (void)configRequestType:(AnnRequestType)requestType
             responseType:(AnnResponseType)responseType
      shouldAutoEncodeUrl:(BOOL)shouldAutoEncode
  callbackOnCancelRequest:(BOOL)shouldCallbackOnCancelRequest {
    Ann_requestType = requestType;
    Ann_responseType = responseType;
    Ann_shouldAutoEncode = shouldAutoEncode;
    Ann_shouldCallbackOnCancelRequest = shouldCallbackOnCancelRequest;
}
//是否将url中文转化
+ (BOOL)shouldEncode {
    return Ann_shouldAutoEncode;
}
//设置请求头
+ (void)configCommonHttpHeaders:(NSDictionary *)httpHeaders {
    Ann_httpHeaders = httpHeaders;
}
//get请求不带提示
+(AnnURLSessionTask *)getWithUrl:(NSString *)url params:(NSDictionary *)params Cache:(BOOL)cache refreshCache:(BOOL)refreshCache success:(AnnResponseSuccess)success fail:(AnnResponseFail)fail
{
    return [self requestWithUrl:url Cache:cache refreshCache:refreshCache isShowHUD:NO showHUD:nil httpMethod:1 params:params progress:nil success:success fail:fail];
}
//get请求带提示
+(AnnURLSessionTask *)getWithUrl:(NSString *)url params:(NSDictionary *)params Cache:(BOOL)cache refreshCache:(BOOL)refreshCache showHUD:(NSString *)statusText success:(AnnResponseSuccess)success fail:(AnnResponseFail)fail
{
    return [self requestWithUrl:url Cache:cache refreshCache:refreshCache isShowHUD:YES showHUD:statusText httpMethod:1 params:params progress:nil success:success fail:fail];
}
//post请求不带提示
+(AnnURLSessionTask *)postWithUrl:(NSString *)url params:(NSDictionary *)params Cache:(BOOL)cache refreshCache:(BOOL)refreshCache success:(AnnResponseSuccess)success fail:(AnnResponseFail)fail
{
    return [self requestWithUrl:url Cache:cache refreshCache:refreshCache isShowHUD:NO showHUD:nil httpMethod:2 params:params progress:nil success:success fail:fail];
}
//post请求带提示
+(AnnURLSessionTask *)postWithUrl:(NSString *)url params:(NSDictionary *)params Cache:(BOOL)cache refreshCache:(BOOL)refreshCache showHUD:(NSString *)statusText success:(AnnResponseSuccess)success fail:(AnnResponseFail)fail
{
    return [self requestWithUrl:url Cache:cache refreshCache:refreshCache isShowHUD:YES showHUD:statusText httpMethod:1 params:params progress:nil success:success fail:fail];
}

+(AnnURLSessionTask *)uploadWithImage:(UIImage *)image url:(NSString *)url filename:(NSString *)filename name:(NSString *)name mimeType:(NSString *)mimeType parameters:(NSDictionary *)parameters progress:(AnnUploadProgress)progress success:(AnnResponseSuccess)success fail:(AnnResponseFail)fail
{
    if ([self baseUrl] == nil) {
        if ([NSURL URLWithString:url] == nil) {
            
            return nil;
        }
    } else {
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]] == nil) {
            
            return nil;
        }
    }
    
    if ([self shouldEncode]) {
        url = [self encodeUrl:url];
    }
    
    NSString *absolute = [self absoluteUrlWithPath:url];
    
    AnnLIuAPIClient *manager = [self manager];
    AnnURLSessionTask *session = [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        NSLog(@"%@",imageData);
        NSString *imageFileName = filename;
        if (filename == nil || ![filename isKindOfClass:[NSString class]] || filename.length == 0) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            imageFileName = [NSString stringWithFormat:@"%@.jpg", str];
        }
        
        // 上传图片，以文件流的格式
        [formData appendPartWithFileData:imageData name:name fileName:imageFileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[self allTasks] removeObject:task];
        [self successResponse:responseObject callback:success];
        
        if ([self isDebug]) {
            [self logWithSuccessResponse:responseObject
                                     url:absolute
                                  params:parameters];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[self allTasks] removeObject:task];
        
        [self handleCallbackWithError:error fail:fail];
        
        if ([self isDebug]) {
            [self logWithFailError:error url:absolute params:nil];
        }
    }];
    
    
    if (session) {
        [[self allTasks] addObject:session];
    }
    
    return session;
    
}

+(AnnURLSessionTask *)uploadFileWithUrl:(NSString *)url uploadingFile:(NSString *)uploadingFile progress:(AnnUploadProgress)progress success:(AnnResponseSuccess)success fail:(AnnResponseFail)fail
{
    if ([NSURL URLWithString:uploadingFile] == nil) {
        
        return nil;
    }
    
    NSURL *uploadURL = nil;
    if ([self baseUrl] == nil) {
        uploadURL = [NSURL URLWithString:url];
    } else {
        uploadURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]];
    }
    
    if (uploadURL == nil) {
        
        return nil;
    }
    
    AnnLIuAPIClient *manager = [self manager];
    NSURLRequest *request = [NSURLRequest requestWithURL:uploadURL];
    AnnURLSessionTask *session = nil;
    
    [manager uploadTaskWithRequest:request fromFile:[NSURL URLWithString:uploadingFile] progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [[self allTasks] removeObject:session];
        
        [self successResponse:responseObject callback:success];
        
        if (error) {
            [self handleCallbackWithError:error fail:fail];
            
            if ([self isDebug]) {
                [self logWithFailError:error url:response.URL.absoluteString params:nil];
            }
        } else {
            if ([self isDebug]) {
                [self logWithSuccessResponse:responseObject
                                         url:response.URL.absoluteString
                                      params:nil];
            }
        }
    }];
    
    if (session) {
        [[self allTasks] addObject:session];
    }
    
    return session;
    
}
+(AnnURLSessionTask *)uploadFileWithUrl:(NSString *)url uploadBody:(NSData *)body progress:(AnnUploadProgress)progress success:(AnnResponseSuccess)success fail:(AnnResponseFail)fail
{
    if ([self baseUrl] == nil) {
        if ([NSURL URLWithString:url] == nil) {
            
            return nil;
        }
    } else {
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]] == nil) {
            
            return nil;
        }
    }
    
    if ([self shouldEncode]) {
        url = [self encodeUrl:url];
    }
    
    
    NSString *absolute = [self absoluteUrlWithPath:url];
    
    AnnLIuAPIClient *manager = [self manager];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"PUT" URLString:absolute parameters:nil error:nil];
    request.timeoutInterval = 20;
    
    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    // 设置body
    [request setHTTPBody:body];
    
    AnnURLSessionTask *session = nil;
    
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        [[self allTasks] removeObject:session];
        
        [self successResponse:responseObject callback:success];
        
        if (error) {
            [self handleCallbackWithError:error fail:fail];
            
            if ([self isDebug]) {
                [self logWithFailError:error url:response.URL.absoluteString params:nil];
            }
        } else {
            if ([self isDebug]) {
                [self logWithSuccessResponse:responseObject
                                         url:response.URL.absoluteString
                                      params:nil];
            }
        }
    }] resume];
    
    if (session) {
        [[self allTasks] addObject:session];
    }
    
    return session;
    
}
+(AnnURLSessionTask *)downloadWithUrl:(NSString *)url saveToPath:(NSString *)saveToPath progress:(AnnUploadProgress)progressBlock success:(AnnResponseSuccess)success failure:(AnnResponseFail)failure
{
    if ([self baseUrl] == nil) {
        if ([NSURL URLWithString:url] == nil) {
            
            return nil;
        }
    } else {
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]] == nil) {
            
            return nil;
        }
    }
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AnnLIuAPIClient *manager = [self manager];
    
    AnnURLSessionTask *session = nil;
    
    session = [manager downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:saveToPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [[self allTasks] removeObject:session];
        
        if (error == nil) {
            if (success) {
                success(filePath.absoluteString);
            }
            
            if ([self isDebug]) {
                NSLog(@"Download success for url %@",
                      [self absoluteUrlWithPath:url]);
            }
        } else {
            [self handleCallbackWithError:error fail:failure];
            
            if ([self isDebug]) {
                NSLog(@"Download fail for url %@, reason : %@",
                      [self absoluteUrlWithPath:url],
                      [error description]);
            }
        }
    }];
    
    if (session) {
        [[self allTasks] addObject:session];
    }
    
    return session;
}

+ (AnnURLSessionTask *)requestWithUrl:(NSString *)url
                                  Cache:(BOOL)cache
                           refreshCache:(BOOL)refreshCache
                              isShowHUD:(BOOL)isShowHUD
                                showHUD:(NSString *)statusText
                             httpMethod:(NSUInteger)httpMethod
                                 params:(NSDictionary *)params
                               progress:(AnnDownloadProgress)progress
                                success:(AnnResponseSuccess)success
                                   fail:(AnnResponseFail)fail {
    
    //如果填写了url,判断url是否
    if (url) {
        if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
            
        }else{
            
            NSString *serverAddress = [AnnLiuNetConfig getAnnServerAddr];
            url = [serverAddress stringByAppendingString:url];
        }
        
    }else{
        return nil;
    }
    //是否转化url中的中文
    if ([self shouldEncode]) {
        url = [self encodeUrl:url];
    }
    //创建manager
    AnnLIuAPIClient *manager = [self manager];
    //对网址进行处理
    NSString *absolute = [self absoluteUrlWithPath:url];
    //拼接网址和参数,用于测试接口,以及作为存储的key
    NSString *keyUrl = [self urlDictToStringWithUrlStr:absolute Parameters:params];
    
    AnnURLSessionTask *session = nil;
    //是否显示提示框
    if (isShowHUD) {
        [AnnLSVPHUD showLodingWithStatus:statusText];
    }
    //httpMethod == 1 ,get请求,2 post请求
    if (httpMethod == 1){
        //判断是否开启缓存
        if (cache){
            //是否开启了本地缓存
            if (Ann_shoulObtainLocalWhenUnconnected){
                //判断网络状况,如果网络出现问题,直接获取本地数据
                if (Ann_networkStatus == kAnnNetWorkStatusNotReachable ||  Ann_networkStatus == kAnnNetWorkStatusUnknown ){
                    
                    if (isShowHUD) {
                        [AnnLSVPHUD dismissHUD];
                    }
                    
                    //从本地获取数据
                    id response = [AnnLiuCachesHelper getResponseCacheForKey:keyUrl];
                    if (response) {
                        if (success) {
                            //数据回调
                            [self successResponse:response callback:success];
                            //如果是测试环境,输出信息
                            if ([self isDebug]) {
                                [self logWithSuccessResponse:response url:keyUrl params:params];
                            }
                            
                        }
                        
                        return nil;
                    }
                }
            }
        }
        //如果不刷新缓存
        if (!refreshCache) {
            id response = [AnnLiuCachesHelper getResponseCacheForKey:keyUrl];
            if (response) {
                if (success) {
                    //数据回调
                    [self successResponse:response callback:success];
                    //如果是测试环境,输出信息
                    if ([self isDebug]) {
                        [self logWithSuccessResponse:response url:keyUrl params:params];
                    }
                }
                return nil;
            }
        }
        //利用AF请求数据
        session = [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //如果添加了提示,在这里移除
            if (isShowHUD) {
                [AnnLSVPHUD dismissHUD];
            }
            //移除task
            [[self allTasks] removeObject:task];
            //返回数据
            [self successResponse:responseObject callback:success];
            //对数据进行缓存
            if (cache) {
                [AnnLiuCachesHelper saveResponseCache:responseObject forKey:keyUrl];
            }
            //如果是测试环境,输出信息
            if ([self isDebug]) {
                [self logWithSuccessResponse:responseObject url:keyUrl params:params];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (isShowHUD) {
                [AnnLSVPHUD dismissHUD];
            }
            [[self allTasks] removeObject:task];
            
            if ([error code] < 0 && cache) {
                id response = [AnnLiuCachesHelper getResponseCacheForKey:keyUrl];
                if (response) {
                    if (success) {
                        [self successResponse:response callback:success];
                    }
                    //如果是测试环境,输出信息
                    if ([self isDebug]) {
                        [self logWithSuccessResponse:response url:keyUrl params:params];
                    }
                }else
                {
                    [self handleCallbackWithError:error fail:fail];
                    
                    if ([self isDebug]) {
                        [self logWithFailError:error url:keyUrl params:params];
                    }
                }
            }else
            {
                [self handleCallbackWithError:error fail:fail];
                
                if ([self isDebug]) {
                    [self logWithFailError:error url:keyUrl params:params];
                }
            }
            
        }];
        
    }else if(httpMethod == 2)
    {
        //判断是否开启缓存
        if (cache){
            //是否开启了本地缓存
            if (Ann_shoulObtainLocalWhenUnconnected){
                //判断网络状况,如果网络出现问题,直接获取本地数据
                if (Ann_networkStatus == kAnnNetWorkStatusNotReachable ||  Ann_networkStatus == kAnnNetWorkStatusUnknown ){
                    //从本地获取数据
                    id response = [AnnLiuCachesHelper getResponseCacheForKey:keyUrl];
                    if (response) {
                        if (success) {
                            //数据回调
                            [self successResponse:response callback:success];
                            //如果是测试环境,输出信息
                            if ([self isDebug]) {
                                [self logWithSuccessResponse:response url:keyUrl params:params];
                            }
                            
                        }
                        
                        return nil;
                    }
                }
            }
        }
        //如果不刷新缓存
        if (!refreshCache) {
            id response = [AnnLiuCachesHelper getResponseCacheForKey:keyUrl];
            if (response) {
                if (success) {
                    //数据回调
                    [self successResponse:response callback:success];
                    //如果是测试环境,输出信息
                    if ([self isDebug]) {
                        [self logWithSuccessResponse:response url:keyUrl params:params];
                    }
                }
                return nil;
            }
        }
        //利用AF请求数据
        session = [manager POST:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //如果添加了提示,在这里移除
            if (isShowHUD) {
                [AnnLSVPHUD dismissHUD];
            }
            //移除task
            [[self allTasks] removeObject:task];
            //返回数据
            [self successResponse:responseObject callback:success];
            //对数据进行缓存
            if (cache) {
                [AnnLiuCachesHelper saveResponseCache:responseObject forKey:keyUrl];
            }
            //如果是测试环境,输出信息
            if ([self isDebug]) {
                [self logWithSuccessResponse:responseObject url:keyUrl params:params];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (isShowHUD) {
                [AnnLSVPHUD dismissHUD];
            }
            [[self allTasks] removeObject:task];
            
            if ([error code] < 0 && cache) {
                id response = [AnnLiuCachesHelper getResponseCacheForKey:keyUrl];
                if (response) {
                    if (success) {
                        [self successResponse:response callback:success];
                    }
                    //如果是测试环境,输出信息
                    if ([self isDebug]) {
                        [self logWithSuccessResponse:response url:keyUrl params:params];
                    }
                }else
                {
                    [self handleCallbackWithError:error fail:fail];
                    
                    if ([self isDebug]) {
                        [self logWithFailError:error url:keyUrl params:params];
                    }
                }
            }else
            {
                [self handleCallbackWithError:error fail:fail];
                
                if ([self isDebug]) {
                    [self logWithFailError:error url:keyUrl params:params];
                }
            }
            
        }];
    }
    
    if (session) {
        [[self allTasks] addObject:session];
    }
    
    return session;
}




#pragma mark - Private
+ (AnnLIuAPIClient *)manager {
    
    @synchronized (self) {
        
        if (Ann_sharedManager == nil || Ann_isBaseURLChanged) {
            // 开启转圈圈
            [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
            
            AnnLIuAPIClient *manager = nil;;
            if ([self baseUrl] != nil) {
                manager = [[AnnLIuAPIClient shareClient] initWithBaseURL:[NSURL URLWithString:[self baseUrl]]];
            } else {
                manager = [AnnLIuAPIClient shareClient];
            }
            
            switch (Ann_requestType) {
                case kAnnRequestTypeJSON: {
                    manager.requestSerializer = [AFJSONRequestSerializer serializer];
                    break;
                }
                case kAnnRequestTypePlainText: {
                    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
                    break;
                }
                default: {
                    break;
                }
            }
            
            switch (Ann_responseType) {
                case kAnnResponseTypeJSON: {
                    manager.responseSerializer = [AFJSONResponseSerializer serializer];
                    break;
                }
                case kAnnResponseTypeXML: {
                    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
                    break;
                }
                case kAnnResponseTypeData: {
                    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                    break;
                }
                default: {
                    break;
                }
            }
            
            manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
            
            
            for (NSString *key in Ann_httpHeaders.allKeys) {
                if (Ann_httpHeaders[key] != nil) {
                    [manager.requestSerializer setValue:Ann_httpHeaders[key] forHTTPHeaderField:key];
                }
            }
            
            // 设置cookie
            //            [self setUpCoookie];
            
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                                      @"text/html",
                                                                                      @"text/json",
                                                                                      @"text/plain",
                                                                                      @"text/javascript",
                                                                                      @"text/xml",
                                                                                      @"image/*"]];
            
            manager.requestSerializer.timeoutInterval = Ann_timeout;
            
            manager.operationQueue.maxConcurrentOperationCount = 3;
            Ann_sharedManager = manager;
        }
    }
    
    return Ann_sharedManager;
}

+ (NSString *)encodeUrl:(NSString *)url {
    return [self urlEncode:url];
}

+ (NSString *)urlEncode:(NSString *)url {
    if ([url respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        
        static NSString * const kAFCharacterHTeneralDelimitersToEncode = @":#[]@";
        static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
        
        NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [allowedCharacterSet removeCharactersInString:[kAFCharacterHTeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
        static NSUInteger const batchSize = 50;
        
        NSUInteger index = 0;
        NSMutableString *escaped = @"".mutableCopy;
        
        while (index < url.length) {
            NSUInteger length = MIN(url.length - index, batchSize);
            NSRange range = NSMakeRange(index, length);
            range = [url rangeOfComposedCharacterSequencesForRange:range];
            NSString *substring = [url substringWithRange:range];
            NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
            [escaped appendString:encoded];
            
            index += range.length;
        }
        return escaped;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *encoded = (__bridge_transfer NSString *)
        CFURLCreateStringByAddingPercentEscapes(
                                                kCFAllocatorDefault,
                                                (__bridge CFStringRef)url,
                                                NULL,
                                                CFSTR("!#$&'()*+,/:;=?@[]"),
                                                cfEncoding);
        return encoded;
#pragma clang diagnostic pop
    }
}

//对网址进行处理
+ (NSString *)absoluteUrlWithPath:(NSString *)path {
    //如果path为空,返回@""
    if (path == nil || path.length == 0) {
        return @"";
    }
    //如果基础网址没进行设置,也就是path 就是请求路劲
    if ([self baseUrl] == nil || [[self baseUrl] length] == 0) {
        return path;
    }
    
    NSString *absoluteUrl = path;
    //对网址进行判断,判断是否是完整网址
    if (![path hasPrefix:@"http://"] && ![path hasPrefix:@"https://"]) {
        //判断基础网址结尾是否包含该/,如果包含,对path进行判断,如果也包含/,删除
        if ([[self baseUrl] hasSuffix:@"/"]) {
            if ([path hasPrefix:@"/"]) {
                NSMutableString * mutablePath = [NSMutableString stringWithString:path];
                [mutablePath deleteCharactersInRange:NSMakeRange(0, 1)];
                absoluteUrl = [NSString stringWithFormat:@"%@%@",
                               [self baseUrl], mutablePath];
            }else {
                absoluteUrl = [NSString stringWithFormat:@"%@%@",[self baseUrl], path];
            }
        }else {
            if ([path hasPrefix:@"/"]) {
                absoluteUrl = [NSString stringWithFormat:@"%@%@",[self baseUrl], path];
            }else {
                absoluteUrl = [NSString stringWithFormat:@"%@/%@",
                               [self baseUrl], path];
            }
        }
    }
    
    
    return absoluteUrl;
}
//对网址和参数进行拼接,方便展示带有参数的网址,用于测试或者浏览器直接打开
+(NSString *)urlDictToStringWithUrlStr:(NSString *)urlStr Parameters:(NSDictionary *)parameters
{
    if (!parameters) {
        return urlStr;
    }
    
    
    NSMutableArray *parts = [NSMutableArray array];
    //便利参数,将key和value 进行拼接
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        //接收key
        NSString *finalKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        //接收值
        NSString *finalValue = [obj stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        
        NSString *part =[NSString stringWithFormat:@"%@=%@",finalKey,finalValue];
        
        [parts addObject:part];
        
    }];
    
    NSString *queryString = [parts componentsJoinedByString:@"&"];
    
    queryString = queryString ? [NSString stringWithFormat:@"?%@",queryString] : @"";
    
    NSString *pathStr = [NSString stringWithFormat:@"%@%@",urlStr,queryString];
    
    return pathStr;
    
}
//成功后的回调
+ (void)successResponse:(id)responseData callback:(AnnResponseSuccess)success {
    if (success) {
        success([self tryToParseData:responseData]);
    }
}
// 解析json数据
+ (id)tryToParseData:(id)json {
    if (!json || json == (id)kCFNull) return nil;
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return dic;
}

+ (void)logWithSuccessResponse:(id)response url:(NSString *)url params:(NSDictionary *)params {
    NSLog(@"\n");
    NSLog(@"\nRequest success, URL: %@\n params:%@\n response:%@\n\n",
          url,
          params,
          [self tryToParseData:response]);
}

+ (void)logWithFailError:(NSError *)error url:(NSString *)url params:(id)params {
    NSString *format = @" params: ";
    if (params == nil || ![params isKindOfClass:[NSDictionary class]]) {
        format = @"";
        params = @"";
    }
    
    NSLog(@"\n");
    if ([error code] == NSURLErrorCancelled) {
        NSLog(@"\nRequest was canceled mannully, URL: %@ %@%@\n\n",
              url,
              format,
              params);
    } else {
        NSLog(@"\nRequest error, URL: %@ %@%@\n errorInfos:%@\n\n",
              url,
              format,
              params,
              [error localizedDescription]);
    }
}
+ (void)handleCallbackWithError:(NSError *)error fail:(AnnResponseFail)fail {
    if ([error code] == NSURLErrorCancelled) {
        if (Ann_shouldCallbackOnCancelRequest) {
            if (fail) {
                fail(error);
            }
        }
    } else {
        if (fail) {
            fail(error);
        }
    }
}

#pragma mark  - Cookie
// 获取并保存cookie
+ (void)getAndSaveCookie:(NSURLSessionDataTask *)task andUrl:(NSString *)url
{
    //获取cookie
    NSDictionary *headers = [(NSHTTPURLResponse *)task.response allHeaderFields];
    
    NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:headers forURL:[NSURL URLWithString:url]];
    
    if (cookies && cookies.count != 0) {
        
        NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
        //存储归档后的cookie
        [[NSUserDefaults standardUserDefaults] setObject:cookiesData forKey:@"UserCookie"];
        
    }
    
    
}


// 删除cookie
+ (void)deleteCookieWithLoginOut
{
    NSData *cookiesData = [NSData data];
    
    [[NSUserDefaults standardUserDefaults] setObject:cookiesData forKey:@"UserCookie"];
    // [CommonUtils saveValueInUD:cookiesData forKey:@"UserCookie"];
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    
    //删除cookie
    for (NSHTTPCookie *tempCookie in cookies) {
        [cookieStorage deleteCookie:tempCookie];
    }
    
}
// 重新设置cookie
+ (void)setUpCoookie
{
    
    //取出保存的cookie
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //对取出的cookie进行反归档处理
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:@"UserCookie"]];
    
    if (cookies && cookies.count != 0) {
        
        //设置cookie
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (id cookie in cookies) {
            [cookieStorage setCookie:(NSHTTPCookie *)cookie];
        }
    }else{
        
    }
    
}

@end
