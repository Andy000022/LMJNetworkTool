//
//  AnnLiuNetworking.h
//  PackageNetWork
//
//  Created by iSolar on 2017/8/7.
//  Copyright © 2017年 iSolar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 下载进度
 
 @param bytesRead      已下载的大小
 @param totalBytesRead 文件总大小
 */
typedef void (^AnnDownloadProgress)(int64_t bytesRead,int64_t totalBytesRead);
typedef AnnDownloadProgress AnnGetProgress;
typedef AnnDownloadProgress AnnPostProgress;

/**
 上传进度
 
 @param bytesWritten      已上传的问题
 @param totalBytesWritten 总文件的大小
 */
typedef void (^AnnUploadProgress)(int64_t bytesWritten, int64_t totalBytesWritten);
//设置Responsetype
typedef NS_ENUM(NSInteger, AnnResponseType)
{
    kAnnResponseTypeJSON = 1, //默认
    kAnnResponseTypeXML = 2,  //XML
    kAnnResponseTypeData = 3  //
};
//设置Requesttype
typedef NS_ENUM(NSUInteger, AnnRequestType)
{
    kAnnRequestTypeJSON = 1,   //默认
    kAnnRequestTypePlainText = 2 //普通text/html
};
typedef NS_ENUM (NSInteger, AnnNetworkStatus)
{
    kAnnNetWorkStatusUnknown = -1, //未知网络
    kAnnNetWorkStatusNotReachable = 0,//网络无连接
    kAnnNetWorkStatusReachableViaWWAN = 1,//2,3,4g
    kAnnNetWorkStatusReachableViaWifi = 2, //wifi网络
};
//所有的接口都返回NSURLSessionTask
typedef NSURLSessionTask AnnURLSessionTask;

/**
 请求成功的回调
 
 @param responseObj 服务端返回的数据类型
 */
typedef void(^AnnResponseSuccess)(id responseObj);

/**
 网络响应失败的回调
 
 @param error 错误信息
 */
typedef void(^AnnResponseFail) (NSError *error);

@interface AnnLiuNetworking : NSObject

/**
 用于指定网络请求接口的基础url
 
 @param baseUrl 基础url
 */
+(void)updateBaseUrl:(NSString *)baseUrl;
+(NSString *)baseUrl;

/**
 设置请求超时时间,默认30秒
 
 @param timeout 超时时间
 */
+(void)setTimeout:(NSTimeInterval)timeout;
/**
 *	当检查到网络异常时，是否从从本地提取数据。默认为NO。一旦设置为YES,当设置刷新缓存时，
 *  若网络异常也会从缓存中读取数据。同样，如果设置超时不回调，同样也会在网络异常时回调，除非
 *  本地没有数据！
 *
 *	@param shouldObtain	YES/NO
 */
+ (void)obtainDataFromLocalWhenNetworkUnconnected:(BOOL)shouldObtain;

/*!
 *
 *
 *  开启或关闭接口打印信息
 *
 *  @param isDebug 开发期，最好打开，默认是NO
 */
+ (void)enableInterfaceDebug:(BOOL)isDebug;

/*!
 *
 *  配置请求格式，默认为JSON。
 *
 *  @param requestType                      请求格式，默认为JSON
 *  @param responseType                     响应格式，默认为JSO，
 *  @param shouldAutoEncode                 YES or NO,默认为NO，是否自动encode url
 *  @param shouldCallbackOnCancelRequest    当取消请求时，是否要回调，默认为YES
 */
+ (void)configRequestType:(AnnRequestType)requestType
             responseType:(AnnResponseType)responseType
      shouldAutoEncodeUrl:(BOOL)shouldAutoEncode
  callbackOnCancelRequest:(BOOL)shouldCallbackOnCancelRequest;
/*!
 *
 *  配置公共的请求头，只调用一次即可
 *
 *  @param httpHeaders 只需要将与服务器商定的固定参数设置即可
 */
+ (void)configCommonHttpHeaders:(NSDictionary *)httpHeaders;

/**
 get请求
 
 @param url          接口路径
 @param params       参数
 @param cache        是否缓存
 @param refreshCache 是否刷新缓存
 @param success      成功后的回调
 @param fail         失败后的回调
 
 @return 返回的对象中有可取消请求的API
 */
+(AnnURLSessionTask *)getWithUrl:(NSString *)url params:(NSDictionary *)params Cache:(BOOL)cache refreshCache:(BOOL)refreshCache success:(AnnResponseSuccess)success fail:(AnnResponseFail)fail;

/**
 get请求,添加请求提示
 
 @param url          接口路径
 @param params       参数
 @param cache        是否缓存
 @param refreshCache 是否刷新缓存
 @param statusText   提示语
 @param success      成功后的回调
 @param fail         失败后的回调
 
 @return 返回的对象中有可取消请求的API
 */
+(AnnURLSessionTask *)getWithUrl:(NSString *)url params:(NSDictionary *)params Cache:(BOOL)cache refreshCache:(BOOL)refreshCache showHUD:(NSString *)statusText success:(AnnResponseSuccess)success fail:(AnnResponseFail)fail;


/**
 post请求
 
 @param url          接口路径
 @param params       参数
 @param cache        是否缓存
 @param refreshCache 是否刷新缓存
 @param success      成功的回调
 @param fail         失败后的回调
 
 @return 返回的对象中有可取消请求的API
 */
+(AnnURLSessionTask *)postWithUrl:(NSString *)url params:(NSDictionary *)params Cache:(BOOL)cache refreshCache:(BOOL)refreshCache success:(AnnResponseSuccess)success fail:(AnnResponseFail)fail;


/**
 post请求,添加请求提示
 
 @param url          接口路径
 @param params       参数
 @param cache        是否缓存
 @param refreshCache 是否刷新缓存
 @param statusText   请求提示
 @param success      成功后的回调
 @param fail         失败后的回调
 
 @return 返回的对象中有可取消请求的API
 */
+(AnnURLSessionTask *)postWithUrl:(NSString *)url params:(NSDictionary *)params Cache:(BOOL)cache refreshCache:(BOOL)refreshCache showHUD:(NSString *)statusText success:(AnnResponseSuccess)success fail:(AnnResponseFail)fail;



/**
 *
 *	图片上传接口，若不指定baseurl，可传完整的url
 *
 *	@param image		图片对象
 *	@param url			上传图片的接口路径，如/path/images/
 *	@param filename		给图片起一个名字，默认为当前日期时间,格式为"yyyyMMddHHmmss"，后缀为`jpg`
 *	@param name			与指定的图片相关联的名称，这是由后端写接口的人指定的，如imagefiles
 *	@param mimeType		默认为image/jpeg
 *	@param parameters	参数
 *	@param progress		上传进度
 *	@param success		上传成功回调
 *	@param fail			上传失败回调
 *
 *	@return 返回的对象中有可取消请求的API
 */
+ (AnnURLSessionTask *)uploadWithImage:(UIImage *)image
                                  url:(NSString *)url
                             filename:(NSString *)filename
                                 name:(NSString *)name
                             mimeType:(NSString *)mimeType
                           parameters:(NSDictionary *)parameters
                             progress:(AnnUploadProgress)progress
                              success:(AnnResponseSuccess)success
                                 fail:(AnnResponseFail)fail;

/**
 *
 *	上传文件操作
 *
 *	@param url				上传路径
 *	@param uploadingFile	待上传文件的路径
 *	@param progress			上传进度
 *	@param success			上传成功回调
 *	@param fail				上传失败回调
 *
 *	@return 返回的对象中有可取消请求的API
 */
+ (AnnURLSessionTask *)uploadFileWithUrl:(NSString *)url
                          uploadingFile:(NSString *)uploadingFile
                               progress:(AnnUploadProgress)progress
                                success:(AnnResponseSuccess)success
                                   fail:(AnnResponseFail)fail;


/**
 用body方式上传文件,主要用于向阿里云oss上传图片
 
 @param url      上传路径
 @param body     上传的文件
 @param progress 上传进度
 @param success  上传成功的回调
 @param fail     上传失败的回调
 
 @return 返回的对象中有可取消请求的API
 */
+(AnnURLSessionTask *)uploadFileWithUrl:(NSString *)url uploadBody:(NSData *)body progress:(AnnUploadProgress)progress success:(AnnResponseSuccess)success fail:(AnnResponseFail)fail;


/*!
 *
 *  下载文件
 *
 *  @param url           下载URL
 *  @param saveToPath    下载到哪个路径下
 *  @param progressBlock 下载进度
 *  @param success       下载成功后的回调
 *  @param failure       下载失败后的回调
 */
+ (AnnURLSessionTask *)downloadWithUrl:(NSString *)url
                           saveToPath:(NSString *)saveToPath
                             progress:(AnnUploadProgress)progressBlock
                              success:(AnnResponseSuccess)success
                              failure:(AnnResponseFail)failure;

@end
