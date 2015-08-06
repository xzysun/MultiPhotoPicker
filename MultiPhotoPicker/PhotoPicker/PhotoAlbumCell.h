//
//  PhotoAlbumCell.h
//  MultiPhotoPicker
//
//  Created by xzysun on 15/7/29.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PHOTO_ALBUM_CELL_REUSE_IDENTIFIER @"PhotoAlbumCellReuseIdentifier"
#define PHOTO_ALBUM_CELL_HEIGHT 100.0

@interface PhotoAlbumCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@end
