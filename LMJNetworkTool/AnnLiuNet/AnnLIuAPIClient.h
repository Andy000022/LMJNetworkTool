//
//  AnnLIuAPIClient.h
//  PackageNetWork
//
//  Created by iSolar on 2017/8/7.
//  Copyright © 2017年 iSolar. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface AnnLIuAPIClient : AFHTTPSessionManager

+ (instancetype)shareClient;

@end
