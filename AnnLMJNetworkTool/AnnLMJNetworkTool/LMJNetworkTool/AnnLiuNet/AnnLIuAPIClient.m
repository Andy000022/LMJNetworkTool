//
//  AnnLIuAPIClient.m
//  PackageNetWork
//
//  Created by iSolar on 2017/8/7.
//  Copyright © 2017年 iSolar. All rights reserved.
//

#import "AnnLIuAPIClient.h"

@implementation AnnLIuAPIClient

+ (instancetype)shareClient {

    static AnnLIuAPIClient *_shareClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _shareClient = [[AnnLIuAPIClient alloc] init];
        _shareClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
    });

    return _shareClient;
}

@end
