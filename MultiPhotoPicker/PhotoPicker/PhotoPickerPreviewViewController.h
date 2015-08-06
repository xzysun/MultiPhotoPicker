//
//  PhotoPickerPreviewViewController.h
//  MultiPhotoPicker
//
//  Created by xzysun on 15/7/29.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoPickerPreviewDelegate <NSObject>

-(NSInteger)numberOfSelectedItems;
-(BOOL)isItemSelectedAtIndex:(NSInteger)index;
-(void)changeSelectedStateAtIndex:(NSInteger)index;
-(void)previewViewTapSendButon;

@end

@interface PhotoPickerPreviewViewController : UIViewController

@property (nonatomic, strong) UIColor *themeColor;
@property (nonatomic, strong) UIColor *highlightedThemeColor;
@property (nonatomic, assign) NSInteger maxImageCount;

@property (nonatomic, copy) NSArray *itemList;

@property (nonatomic, assign) NSInteger beginIndex;
@property (nonatomic, weak) id<PhotoPickerPreviewDelegate> delegate;
@end
