//
//  PhotoItemCell.h
//  MultiPhotoPicker
//
//  Created by xzysun on 15/7/29.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PHOTO_ITEM_CELL_REUSE_IDENTIFIER @"PhotoItemCellReuseIdentifier"

@interface PhotoItemCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *selectionButton;
@end
