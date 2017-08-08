//
//  AnnLSVPHUD.m
//  PackageNetWork
//
//  Created by iSolar on 2017/8/7.
//  Copyright © 2017年 iSolar. All rights reserved.
//

#import "AnnLSVPHUD.h"

typedef enum {
    HUDTypeSuccess,
    HUDTypeError,
    HUDTypeLoding,
    HUDTypeInfo,
    HUDTypeProgress
} HUDType;

@implementation AnnLSVPHUD

+ (void)initialize {
    [super initialize];
    
    [SVProgressHUD setFont:[UIFont systemFontOfSize:14.0]];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setMinimumDismissTimeInterval:1.5];
}

+ (void)showSuccessWithStatus:(NSString *)status {
    [self LMJShowWithType:HUDTypeSuccess Status:status Image:nil Progress:NSNotFound];
}

+ (void)showErrorWithStatus:(NSString *)status {
    [self LMJShowWithType:HUDTypeError Status:status Image:nil Progress:NSNotFound];
}

+ (void)showLodingWithStatus:(NSString *)status {
    [self LMJShowWithType:HUDTypeLoding Status:status Image:nil Progress:NSNotFound];
}

+ (void)showInfoWithStatus:(NSString *)status {
    [self LMJShowWithType:HUDTypeInfo Status:status Image:nil Progress:NSNotFound];
}

+ (void)showProgress:(CGFloat)progress Status:(NSString *)status {
    [self LMJShowWithType:HUDTypeProgress Status:status Image:nil Progress:progress];
}

+ (void)dismissHUD {
    [SVProgressHUD dismiss];
}

// 私有方法
+ (void)LMJShowWithType:(HUDType)type Status:(NSString *)status Image:(UIImage *)img Progress:(CGFloat)progress {
    
    switch (type) {
            
        case HUDTypeSuccess:
            [SVProgressHUD showSuccessWithStatus:status];
            break;
        case HUDTypeError:
            [SVProgressHUD showErrorWithStatus:status];
            break;
        case HUDTypeLoding:
            [SVProgressHUD showWithStatus:status];
            break;
        case HUDTypeInfo:
            [SVProgressHUD showInfoWithStatus:status];
            break;
        case HUDTypeProgress:
            [SVProgressHUD showProgress:progress status:status];
            break;
            
        default:
            break;
    }

}

@end
