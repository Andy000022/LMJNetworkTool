//
//  AnnLiuNetConfig.m
//  PackageNetWork
//
//  Created by iSolar on 2017/8/7.
//  Copyright © 2017年 iSolar. All rights reserved.
//

#import "AnnLiuNetConfig.h"

static NSString *AnnConfigEnv;  //环境参数 00: 测试环境,01: 生产环境
#pragma  服务地址
NSString *const  AnnURL = @"https://news-at.zhihu.com/api/";
NSString *const  AnnURL_Test = @"https://news-at.zhihu.com/api/";

@implementation AnnLiuNetConfig

+(void)setZYConfigEnv:(NSString *)value
{
    AnnConfigEnv = value;
}

+(NSString *)AnnConfigEnv
{
    return AnnConfigEnv;
}
//获取服务器地址
+ (NSString *)getAnnServerAddr{
    if ([AnnConfigEnv isEqualToString:@"00"]) {
        return AnnURL_Test;
    }else{
        return AnnURL;
    }
}

@end
