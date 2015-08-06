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
    [pickerVC showFromViewController:self];
}

-(void)photoPickerDidChooseImage:(NSArray *)images
{
    NSLog(@"pick %ld images", images.count);
}
@end
