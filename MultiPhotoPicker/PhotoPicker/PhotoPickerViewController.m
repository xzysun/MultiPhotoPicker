//
//  PhotoPickerViewController.m
//  MultiPhotoPicker
//
//  Created by xzysun on 15/7/29.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import "PhotoPickerViewController.h"
#import "PickerItem.h"
#import "PhotoItemCell.h"
#import "PhotoPickerPreviewViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "GVSConstans.h"

@interface PhotoPickerViewController () <UICollectionViewDataSource, UICollectionViewDelegate, PhotoPickerPreviewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *toolView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (nonatomic, strong) NSMutableArray *selectedIndexList;
@end

@implementation PhotoPickerViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"选择照片";
    self.selectedIndexList = [NSMutableArray array];
    self.themeColor = [UIColor colorWithRed:61.0/255.0 green:124.0/255.0 blue:153.0/255.5 alpha:1.0];
    //CollectionView配置
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotoItemCell" bundle:nil] forCellWithReuseIdentifier:PHOTO_ITEM_CELL_REUSE_IDENTIFIER];
    [self configCollectionLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
//    //返回按钮
//    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    backButton.frame = CGRectMake(0, 0, 33, 33);
//    [backButton setTitle:@"" forState:UIControlStateNormal];
//    [backButton setImage:[UIImage imageNamed:@"btn_arrowleft"] forState:UIControlStateNormal];
//    [backButton setImage:[UIImage imageNamed:@"btn_arrowleft_pressed"] forState:UIControlStateHighlighted];
//    backButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
//    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
//    self.navigationController.interactivePopGestureRecognizer.delegate = (id <UIGestureRecognizerDelegate>)self;
    //取消按钮
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 40, 30);
    [rightButton setTitle:@"取消" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    rightButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    [rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    //toolview配置
    self.toolView.backgroundColor = [UIColor whiteColor];
    self.toolView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.toolView.layer.shadowOffset = CGSizeMake(0, -0.5);
    self.toolView.layer.shadowRadius = 0.0;
    self.toolView.layer.shadowOpacity = 1.0;
    self.numberLabel.backgroundColor = self.themeColor;
    self.numberLabel.textColor = [UIColor whiteColor];
    self.numberLabel.layer.cornerRadius = CGRectGetHeight(self.numberLabel.frame)/2.0;
    self.numberLabel.font = [UIFont systemFontOfSize:16.0];
    self.numberLabel.clipsToBounds = YES;
    [self.sendButton setTitleColor:self.themeColor forState:UIControlStateNormal];
    [self.sendButton setTitleColor:self.highlightedThemeColor forState:UIControlStateHighlighted];
    self.scrollView.showsHorizontalScrollIndicator = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setItemList:(NSArray *)itemList
{
    _itemList = itemList;
    [self.collectionView reloadData];
    [self updateToolView];
}

#pragma mark - Button Actions
-(void)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightButtonAction:(id)sender
{
    if (self.navigationController.presentingViewController) {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
            //
        }];
    }
}

- (IBAction)sendButtonAction:(id)sender
{
    if (self.selectedIndexList.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"没有选择任何图片" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [self rightButtonAction:nil];
    //准备数据
    __weak typeof(self) weakSelf = self;
    dispatch_group_t loadImageGroup = dispatch_group_create();
    NSMutableArray *list = [NSMutableArray array];
    for (NSIndexPath *indexPath in self.selectedIndexList) {
        PhotoPickerItem *item = [self.itemList objectAtIndex:indexPath.item];
        dispatch_group_enter(loadImageGroup);
        [self loadImageFromAssetLibraryForURL:item.photoURL WithComplement:^(UIImage *image) {
            if (image) {
                [list addObject:image];
            }
            dispatch_group_leave(loadImageGroup);
        }];
    }
    dispatch_group_notify(loadImageGroup, dispatch_get_main_queue(), ^{
        DDLogDebug(@"获取到图片的数量为:%ld", (unsigned long)list.count);
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(photoPickerDidChooseImage:)]) {
            [weakSelf.delegate photoPickerDidChooseImage:list];
        }
    });
}

-(void)selectionButtonAction:(UIButton *)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
    if ([self.selectedIndexList containsObject:indexPath]) {
        [self.selectedIndexList removeObject:indexPath];
    } else {
        if (self.selectedIndexList.count >= self.maxImageCount) {
            //已选择的数量到大最大值
            NSString *msg = [NSString stringWithFormat:@"最多只能选择%ld张图片", (long)self.maxImageCount];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        [self.selectedIndexList addObject:indexPath];
    }
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    [self updateToolView];
}

-(void)imageButtonAction:(UIButton *)sender
{
    NSIndexPath *indexPath = [self.selectedIndexList objectAtIndex:sender.tag];
    [self showPreviewVCWithIndex:indexPath];
}

#pragma mark - CollectionView
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.itemList.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PHOTO_ITEM_CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
    PhotoPickerItem *item = [self.itemList objectAtIndex:indexPath.item];
    cell.imageView.image = item.thumbnailImage;
    cell.selectionButton.tag = indexPath.item;
    [cell.selectionButton addTarget:self action:@selector(selectionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    if ([self.selectedIndexList containsObject:indexPath]) {
        [cell.selectionButton setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
    } else {
        [cell.selectionButton setImage:[UIImage imageNamed:@"btn_select"] forState:UIControlStateNormal];
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self showPreviewVCWithIndex:indexPath];
}

#pragma mark - Private Method
-(void)configCollectionLayout
{
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    CGFloat space = 2.0;
    CGFloat itemWidth = (SCREEN_WIDTH - space * 2)/3.0;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    flowLayout.minimumInteritemSpacing = space;
    flowLayout.minimumLineSpacing = space;
    flowLayout.sectionInset = UIEdgeInsetsMake(space, 0.0, space, 0.0);
    self.collectionView.collectionViewLayout = flowLayout;
    [self.collectionView reloadData];
}

-(void)updateToolView
{
    for (UIView *subView in self.scrollView.subviews) {
        [subView removeFromSuperview];
    }
    NSInteger count = self.selectedIndexList.count;
    CGFloat height = CGRectGetHeight(self.scrollView.frame);
    CGFloat space = 6.0;
    for (NSInteger i = 0; i < count; i ++) {
        NSIndexPath *indexPath = [self.selectedIndexList objectAtIndex:i];
        PhotoPickerItem *item = [self.itemList objectAtIndex:indexPath.item];
        UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [imageButton setBackgroundImage:item.thumbnailImage forState:UIControlStateNormal];
        imageButton.frame = CGRectMake((height+space)*i, 0, height, height);
        imageButton.tag = i;
        [imageButton addTarget:self action:@selector(imageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:imageButton];
    }
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake((height+space)*self.selectedIndexList.count, 0, height+space, height)];
    infoLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)count, (long)self.maxImageCount];
    infoLabel.textColor = self.themeColor;
    infoLabel.textAlignment = NSTextAlignmentLeft;
    infoLabel.adjustsFontSizeToFitWidth = YES;
    [self.scrollView addSubview:infoLabel];
    self.scrollView.contentSize = CGSizeMake((height+space)*(count + 1), height);
    self.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
}

-(void)showPreviewVCWithIndex:(NSIndexPath *)index
{
    PhotoPickerPreviewViewController *previewVC = [[PhotoPickerPreviewViewController alloc] initWithNibName:@"PhotoPickerPreviewViewController" bundle:nil];
    previewVC.themeColor = self.themeColor;
    previewVC.maxImageCount = self.maxImageCount;
    previewVC.itemList = self.itemList;
    previewVC.beginIndex = index.item;
    previewVC.delegate = self;
    [self.navigationController pushViewController:previewVC animated:YES];
}

-(void)loadImageFromAssetLibraryForURL:(NSURL *)photoURL WithComplement:(void(^)(UIImage *image))complement
{
    ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:photoURL resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
            UIImage *largeImage = [UIImage imageWithCGImage:iref];
            complement(largeImage);
        }
    } failureBlock:^(NSError *error) {
        DDLogError(@"Photo from asset library error: %@",error);
    }];
}

#pragma mark - Picker Preview Delegate
-(NSInteger)numberOfSelectedItems
{
    return self.selectedIndexList.count;
}

-(BOOL)isItemSelectedAtIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    return [self.selectedIndexList containsObject:indexPath];
}

-(void)changeSelectedStateAtIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    if ([self.selectedIndexList containsObject:indexPath]) {
        [self.selectedIndexList removeObject:indexPath];
    } else {
        [self.selectedIndexList addObject:indexPath];
    }
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    [self updateToolView];
}

-(void)previewViewTapSendButon
{
    [self sendButtonAction:nil];
}
@end
