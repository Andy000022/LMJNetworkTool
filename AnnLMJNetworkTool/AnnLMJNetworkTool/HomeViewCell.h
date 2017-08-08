//
//  HomeViewCell.h
//  PackageNetWork
//
//  Created by iSolar on 2017/8/7.
//  Copyright © 2017年 iSolar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProjectModle;
@interface HomeViewCell : UITableViewCell

- (void)setModel:(ProjectModle *)model;

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *acreageL;
@property (weak, nonatomic) IBOutlet UILabel *addrL;

@property (weak, nonatomic) IBOutlet UIImageView *rightArrow;

@end
