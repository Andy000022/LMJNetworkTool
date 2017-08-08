//
//  HomeViewCell.m
//  PackageNetWork
//
//  Created by iSolar on 2017/8/7.
//  Copyright © 2017年 iSolar. All rights reserved.
//

#import "HomeViewCell.h"
#import "ProjectModle.h"

@implementation HomeViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(ProjectModle *)model {
    
    
    _acreageL.text = model.title;

    [_icon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",model.images[0]]] placeholderImage:[UIImage imageNamed:@"dd_album"]];
    
}

@end
