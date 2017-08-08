# LMJNetworkTool
二次封装AFNetworking和SVProgressHUD

#AnnLSVPHUD使用

        #import "AnnLSVPHUD.h"
        
        [AnnLSVPHUD showSuccessWithStatus:@"加载成功"];
        [AnnLSVPHUD showLodingWithStatus:@""];
        [AnnLSVPHUD showInfoWithStatus:@""];
        [AnnLSVPHUD showErrorWithStatus:@""];
        [AnnLSVPHUD showProgress:0.5 Status:@""];
#AnnLiuNet使用

        #import "AnnLSVPHUD.h"
        #import "AnnLiuNetworking.h"
        
        [AnnLiuNetworking getWithUrl:@"" params:nil Cache:NO refreshCache:YES success:^(id responseObj) {

              [AnnLSVPHUD showSuccessWithStatus:@"加载成功"];
              [AnnLSVPHUD showLodingWithStatus:@""];
              [AnnLSVPHUD showInfoWithStatus:@""];
              [AnnLSVPHUD showErrorWithStatus:@""];
              [AnnLSVPHUD showProgress:0.5 Status:@""];

        } fail:^(NSError *error) {

        }];

