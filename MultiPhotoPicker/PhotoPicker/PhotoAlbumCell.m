//
//  PhotoAlbumCell.m
//  MultiPhotoPicker
//
//  Created by xzysun on 15/7/29.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import "PhotoAlbumCell.h"

@implementation PhotoAlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.thumbnailImageView.layer.cornerRadius = 3.0;
    self.thumbnailImageView.clipsToBounds = YES;
    self.nameLabel.textColor = [UIColor darkGrayColor];
    self.nameLabel.font = [UIFont systemFontOfSize:16.0];
    self.infoLabel.textColor = [UIColor lightGrayColor];
    self.infoLabel.font = [UIFont systemFontOfSize:12.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
