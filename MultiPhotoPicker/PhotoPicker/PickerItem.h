//
//  PickerItem.h
//  MultiPhotoPicker
//
//  Created by xzysun on 15/7/29.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoAlbum : NSObject

@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, strong) UIImage *albumImage;
@property (nonatomic, strong) NSArray *photos;
@end


@interface PhotoPickerItem : NSObject

@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) NSDate *photoDate;
@property (nonatomic, strong) NSURL *photoURL;
@end
