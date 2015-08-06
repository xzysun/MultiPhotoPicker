//
//  PhotoPickerViewController.h
//  MultiPhotoPicker
//
//  Created by xzysun on 15/7/29.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoPickerDelegate.h"

@interface PhotoPickerViewController : UIViewController

@property (nonatomic, strong) UIColor *themeColor;
@property (nonatomic, strong) UIColor *highlightedThemeColor;
@property (nonatomic, assign) NSInteger maxImageCount;
@property (nonatomic, strong) NSArray *itemList;
@property (nonatomic, weak) id<PhotoPickerDelegate> delegate;
@end
