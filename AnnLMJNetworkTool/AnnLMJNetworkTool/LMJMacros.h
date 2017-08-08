//
//  LMJMacros.h
//  PackageNetWork
//
//  Created by iSolar on 2017/8/7.
//  Copyright © 2017年 iSolar. All rights reserved.
//

#ifndef LMJMacros_h
#define LMJMacros_h

#ifdef DEBUG
#   define DLog(fmt, ...) {NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
#   define ELog(err) {if(err) DLog(@"%@", err)}
#else
#   define DLog(...)
#   define ELog(err)
#endif


//#define docDataInfoPath [docPath stringByAppendingPathComponent:@"Data/info"]
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kApplicationFrameHeight [UIScreen mainScreen].applicationFrame.size.height

#define     TLURL(urlString)    [NSURL URLWithString:urlString]
#define W(obj)   (!obj?0:(obj).frame.size.width)
#define H(obj)   (!obj?0:(obj).frame.size.height)
#define X(obj)   (!obj?0:(obj).frame.origin.x)
#define Y(obj)   (!obj?0:(obj).frame.origin.y)
#define XW(obj) (X(obj)+W(obj))
#define YH(obj) (Y(obj)+H(obj))
#define BoldFont(x) [UIFont boldSystemFontOfSize:x]
#define Font(x) [UIFont systemFontOfSize:x]

#define baseurl @"https://news-at.zhihu.com/api/"

#endif /* LMJMacros_h */
