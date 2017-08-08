//
//  AnnLSVPHUD.h
//  PackageNetWork
//
//  Created by iSolar on 2017/8/7.
//  Copyright © 2017年 iSolar. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>

@interface AnnLSVPHUD : SVProgressHUD

+ (void)showSuccessWithStatus:(NSString *)status;
+ (void)showErrorWithStatus:(NSString *)status;
+ (void)showLodingWithStatus:(NSString *)status;
+ (void)showInfoWithStatus:(NSString *)status;
+ (void)showProgress:(CGFloat)progress Status:(NSString *)status;

+ (void)dismissHUD;

@end
