//
//  AnnLiuNetConfig.h
//  PackageNetWork
//
//  Created by iSolar on 2017/8/7.
//  Copyright © 2017年 iSolar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnnLiuNetConfig : NSObject

// env: 环境参数 00: 测试环境 01: 生产环境
+ (void)setZYConfigEnv:(NSString *)value;

// 返回环境参数 00: 测试环境 01: 生产环境
+ (NSString *)AnnConfigEnv;

// 获取服务器地址
+ (NSString *)getAnnServerAddr;

@end
