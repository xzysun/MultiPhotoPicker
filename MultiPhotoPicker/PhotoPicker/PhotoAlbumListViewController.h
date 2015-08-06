//
//  PhotoAlbumListViewController.h
//  MultiPhotoPicker
//
//  Created by xzysun on 15/7/29.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoPickerDelegate.h"

@interface PhotoAlbumListViewController : UIViewController

@property (nonatomic, strong) UIColor *themeColor;
@property (nonatomic, strong) UIColor *highlightedThemeColor;
@property (nonatomic, assign) NSInteger maxImageCount;
@property (nonatomic, weak) id<PhotoPickerDelegate> delegate;
+(instancetype)picker;

-(void)showFromViewController:(UIViewController *)viewController;
@end
