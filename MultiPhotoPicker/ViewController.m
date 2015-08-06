//
//  ViewController.m
//  MultiPhotoPicker
//
//  Created by xzysun on 15/7/29.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import "ViewController.h"
#import "PhotoAlbumListViewController.h"

@interface ViewController () <PhotoPickerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushPickerButtonAction:(id)sender
{
    PhotoAlbumListViewController *pickerVC = [PhotoAlbumListViewController picker];
    pickerVC.delegate = self;
//    pickerVC.themeColor = [UIColor colorWithRed:61.0/255.0 green:124.0/255.0 blue:153.0/255.5 alpha:1.0];
//    pickerVC.maxImageCount = 15;
    [pickerVC showFromViewController:self];
    
//    NSIndexPath *index1 = [NSIndexPath indexPathForItem:0 inSection:0];
//    NSIndexPath *index2 = [NSIndexPath indexPathForItem:0 inSection:0];
//    if ([index1 isEqual:index2]) {
//        NSLog(@"equal!");
//    }
}

-(void)photoPickerDidChooseImage:(NSArray *)images
{
    NSLog(@"pick %ld images", images.count);
}
@end
