//
//  PhotoPickerDelegate.h
//  MultiPhotoPicker
//
//  Created by xzysun on 15/7/29.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoPickerDelegate <NSObject>

-(void)photoPickerDidChooseImage:(NSArray *)images;

@end
