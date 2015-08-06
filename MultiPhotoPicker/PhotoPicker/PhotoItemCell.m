//
//  PhotoItemCell.m
//  MultiPhotoPicker
//
//  Created by xzysun on 15/7/29.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import "PhotoItemCell.h"

@implementation PhotoItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

@end
