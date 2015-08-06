//
//  PhotoPickerPreviewViewController.m
//  MultiPhotoPicker
//
//  Created by xzysun on 15/7/29.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import "PhotoPickerPreviewViewController.h"
#import "PickerItem.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "GVSConstans.h"

@interface PhotoPickerPreviewViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *toolView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, strong) UIImageView *preImageView;
@property (nonatomic, strong) UIImageView *currentImageView;
@property (nonatomic, strong) UIImageView *nextImageView;
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation PhotoPickerPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.delegate = self;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    //取消按钮
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 33, 33);
    rightButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    [rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    self.rightButton = rightButton;
    //toolview配置
    self.toolView.backgroundColor = [UIColor whiteColor];
    self.numberLabel.backgroundColor = self.themeColor;
    self.numberLabel.textColor = [UIColor whiteColor];
    self.numberLabel.layer.cornerRadius = CGRectGetHeight(self.numberLabel.frame)/2.0;
    self.numberLabel.font = [UIFont systemFontOfSize:16.0];
    self.numberLabel.clipsToBounds = YES;
    [self.sendButton setTitleColor:self.themeColor forState:UIControlStateNormal];
    [self.sendButton setTitleColor:self.highlightedThemeColor forState:UIControlStateHighlighted];
    //加载数据
    [self setupImageViews];
    [self updateToolView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self updateImageViewFrame];
}

-(void)updateToolView
{
    NSInteger count = 0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfSelectedItems)]) {
        count = [self.delegate numberOfSelectedItems];
    }
    self.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
    self.title = [NSString stringWithFormat:@"%ld/%ld", (long)count, (long)self.maxImageCount];
    BOOL selectedFlag = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(isItemSelectedAtIndex:)]) {
        selectedFlag = [self.delegate isItemSelectedAtIndex:self.currentIndex];
    }
    if (selectedFlag) {
        [self.rightButton setImage:[UIImage imageNamed:@"btn_selected_top"] forState:UIControlStateNormal];
    } else {
        [self.rightButton setImage:[UIImage imageNamed:@"btn_select_top"] forState:UIControlStateNormal];
    }
}

-(UIImageView *)makeImageView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:imageView];
    return imageView;
}

-(void)setupImageViews
{
    NSInteger count = self.itemList.count;
    if (count == 0) {
        //没有图片
        return;
    }
    //初始化控件
    if (count >= 1) {
        self.currentImageView = [self makeImageView];
    }
    if (count >= 2 && self.beginIndex > 0) {
        self.preImageView = [self makeImageView];
    }
    if (count >= 2 && self.beginIndex < count-1) {
        self.nextImageView = [self makeImageView];
    }
    DDLogDebug(@"初始显示的页面为%ld", (long)self.beginIndex);
    self.currentIndex = self.beginIndex;
    [self updateImageViewFrame];
    //初始化加载图片
    [self loadImageForImageView:self.currentImageView ForIndex:self.beginIndex];
    if (self.beginIndex-1>=0) {
        [self loadImageForImageView:self.preImageView ForIndex:self.beginIndex-1];
    }
    if (self.beginIndex+1<self.itemList.count) {
        [self loadImageForImageView:self.nextImageView ForIndex:self.beginIndex+1];
    }
}

-(void)updateImageViewFrame
{
    //更新ScrollView内部的大小
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    CGFloat pageHeight = CGRectGetHeight(self.scrollView.frame);
    NSInteger count = self.itemList.count;
    CGRect frame = self.scrollView.bounds;
    frame.size.width -= (self.scrollView.contentInset.left+self.scrollView.contentInset.right);
    frame.origin.x = self.scrollView.contentInset.left;
    if (self.preImageView) {
        self.preImageView.frame = frame;
        frame.origin.x += pageWidth;
    }
    if (self.currentImageView) {
        self.currentImageView.frame = frame;
        frame.origin.x += pageWidth;
    }
    if (self.nextImageView) {
        self.nextImageView.frame = frame;
    }
    NSInteger showPageCount = MIN(count, 3);
    if (self.preImageView == nil) {
        showPageCount --;
    }
    if (self.nextImageView == nil) {
        showPageCount --;
    }
    self.scrollView.contentSize = CGSizeMake(pageWidth*showPageCount, pageHeight);
    if (self.preImageView) {
        self.scrollView.contentOffset = CGPointMake(pageWidth, 0);
    } else {
        self.scrollView.contentOffset = CGPointZero;
    }
}

-(void)loadImageForImageView:(UIImageView *)imageView ForIndex:(NSInteger)index
{
    imageView.image = nil;
    PhotoPickerItem *item = [self.itemList objectAtIndex:index];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(CGRectGetWidth(imageView.frame)/2.0, CGRectGetHeight(imageView.frame)/2.0);
    [imageView addSubview:indicator];
    [indicator startAnimating];
    ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:item.photoURL resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
            UIImage *largeImage = [UIImage imageWithCGImage:iref];
            imageView.image = largeImage;
        }
        [indicator stopAnimating];
        [indicator removeFromSuperview];
    } failureBlock:^(NSError *error) {
        DDLogError(@"Photo from asset library error: %@",error);
        [indicator stopAnimating];
        [indicator removeFromSuperview];
    }];
}

#pragma mark - Button Actions
-(void)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightButtonAction:(id)sender
{
    BOOL selectedFlag = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(isItemSelectedAtIndex:)]) {
        selectedFlag = [self.delegate isItemSelectedAtIndex:self.currentIndex];
    }
    NSInteger count = 0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfSelectedItems)]) {
        count = [self.delegate numberOfSelectedItems];
    }
    if (!selectedFlag && count+1>self.maxImageCount) {
        NSString *msg = [NSString stringWithFormat:@"最多只能选择%ld张图片", (long)self.maxImageCount];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeSelectedStateAtIndex:)]) {
        [self.delegate changeSelectedStateAtIndex:self.currentIndex];
    }
    [self updateToolView];
}

- (IBAction)sendButtonAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfSelectedItems)]) {
        NSInteger count = [self.delegate numberOfSelectedItems];
        if (count == 0) {
            //当前没有选择图片但是用户点击了发送，则直接帮助用户选择目前正在展示的图片并进行发送
            [self rightButtonAction:nil];
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(previewViewTapSendButon)]) {
        [self.delegate previewViewTapSendButon];
    }
}

#pragma mark - Scroll View Delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSInteger pageIndex = self.scrollView.contentOffset.x / pageWidth;
    NSInteger count = self.itemList.count;
    if (pageIndex == 0 && self.preImageView) {
        //向前翻了一页
        self.currentIndex --;
        [self.nextImageView removeFromSuperview];
        self.nextImageView = self.currentImageView;
        self.currentImageView = self.preImageView;
        if (count > 2 && self.currentIndex-1>=0) {
            self.preImageView = [self makeImageView];
            [self loadImageForImageView:self.preImageView ForIndex:self.currentIndex-1];
        } else {
            self.preImageView = nil;
            [self.preImageView removeFromSuperview];
        }
    } else if ((pageIndex == 2||(pageIndex==1&&self.preImageView==nil)) && self.nextImageView) {
        //向后翻了一页
        self.currentIndex ++;
        [self.preImageView removeFromSuperview];
        self.preImageView = self.currentImageView;
        self.currentImageView = self.nextImageView;
        if (count > 2 && self.currentIndex+1<count) {
            self.nextImageView = [self makeImageView];
            [self loadImageForImageView:self.nextImageView ForIndex:self.currentIndex+1];
        } else {
            self.nextImageView = nil;
            [self.nextImageView removeFromSuperview];
        }
    }
    DDLogDebug(@"准备显示页面%ld", (long)self.currentIndex);
    [self updateImageViewFrame];
    [self updateToolView];
}
@end
