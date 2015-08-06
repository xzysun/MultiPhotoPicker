//
//  PhotoAlbumListViewController.m
//  MultiPhotoPicker
//
//  Created by xzysun on 15/7/29.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import "PhotoAlbumListViewController.h"
#import "PickerItem.h"
#import "PhotoAlbumCell.h"
#import "PhotoPickerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "GVSNavigationController.h"
#import "GVSConstans.h"

@interface PhotoAlbumListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *albumList;
@end

typedef void(^PhotoPickerListBlock)(NSArray *list, NSError *error);

@implementation PhotoAlbumListViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _maxImageCount = 6;
        _themeColor = [UIColor colorWithRed:61.0/255.0 green:124.0/255.0 blue:153.0/255.5 alpha:1.0];
        _highlightedThemeColor = [UIColor colorWithRed:61.0/255.0 green:124.0/255.0 blue:153.0/255.5 alpha:1.0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"相册";
    [self.tableView registerNib:[UINib nibWithNibName:@"PhotoAlbumCell" bundle:nil] forCellReuseIdentifier:PHOTO_ALBUM_CELL_REUSE_IDENTIFIER];
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    //取消按钮
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 40, 30);
    [rightButton setTitle:@"取消" forState:UIControlStateNormal];
    rightButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    [rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

+(instancetype)picker
{
    PhotoAlbumListViewController *albumListVC = [[PhotoAlbumListViewController alloc] initWithNibName:@"PhotoAlbumListViewController" bundle:nil];
    return albumListVC;
}


-(void)showFromViewController:(UIViewController *)viewController
{
    //初始化一个NavigationController
    GVSNavigationController *nav = [[GVSNavigationController alloc] initWithRootViewController:self];
    nav.navigationBar.barTintColor = self.themeColor;
    nav.navigationBar.tintColor = [UIColor whiteColor];
    nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [viewController presentViewController:nav animated:YES completion:^{
        //
    }];
    //默认进入第一个相册
    PhotoPickerViewController *pickerVC = [[PhotoPickerViewController alloc] initWithNibName:@"PhotoPickerViewController" bundle:nil];
    pickerVC.themeColor = self.themeColor;
    pickerVC.highlightedThemeColor = self.highlightedThemeColor;
    pickerVC.maxImageCount = self.maxImageCount;
    pickerVC.delegate = self.delegate;
    [nav pushViewController:pickerVC animated:NO];
    //加载数据
    WeakSelf
    [self getPhotoListWithComplement:^(NSArray *list, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"读取相册失败" message:error.localizedFailureReason delegate:nil cancelButtonTitle:@"" otherButtonTitles:nil, nil];
            [alert show];
        }
        weakSelf.albumList = list;
        [weakSelf.tableView reloadData];
        pickerVC.itemList = [((PhotoAlbum *)[list firstObject]) photos];
    }];
}

-(void)rightButtonAction:(id)sender
{
    if (self.navigationController.presentingViewController) {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
            //
        }];
    }
}

#pragma mark - Talbe View
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.albumList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return PHOTO_ALBUM_CELL_HEIGHT;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:PHOTO_ALBUM_CELL_REUSE_IDENTIFIER];
    PhotoAlbum *album = [self.albumList objectAtIndex:indexPath.row];
    cell.thumbnailImageView.image = album.albumImage;
    cell.nameLabel.text = album.albumName;
    cell.infoLabel.text = [NSString stringWithFormat:@"%ld照片", (unsigned long)album.photos.count];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PhotoAlbum *album = [self.albumList objectAtIndex:indexPath.row];
    PhotoPickerViewController *pickerVC = [[PhotoPickerViewController alloc] initWithNibName:@"PhotoPickerViewController" bundle:nil];
    pickerVC.themeColor = self.themeColor;
    pickerVC.highlightedThemeColor = self.highlightedThemeColor;
    pickerVC.maxImageCount = self.maxImageCount;
    pickerVC.itemList = album.photos;
    pickerVC.delegate = self.delegate;
    [self.navigationController pushViewController:pickerVC animated:YES];
}

#pragma mark - Load Photo
-(void)getPhotoListWithComplement:(PhotoPickerListBlock)complement
{
    NSMutableArray *list = [NSMutableArray array];
    ALAssetsLibrary *library = [ALAssetsLibrary new];
    //    __block NSError *err = nil;
    [library enumerateGroupsWithTypes:ALAssetsGroupLibrary|ALAssetsGroupAlbum|ALAssetsGroupEvent|ALAssetsGroupFaces|ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group == nil) {
            //枚举结束
            complement(list, nil);
            return;
        }
        PhotoAlbum *album = [PhotoAlbum new];
        album.albumName = [group valueForProperty:ALAssetsGroupPropertyName];
        DDLogDebug(@"准备扫描相册:%@", album.albumName);
        NSMutableArray *tmpList = [NSMutableArray array];
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (![[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                //不是图片
                return;
            }
            PhotoPickerItem *item = [PhotoPickerItem new];
            item.thumbnailImage = [UIImage imageWithCGImage:result.thumbnail];
            item.photoDate = [result valueForProperty:ALAssetPropertyDate];
            item.photoURL = [result valueForProperty:ALAssetPropertyAssetURL];
            [tmpList addObject:item];
        }];
        album.photos = [NSArray arrayWithArray:tmpList];
        
        NSComparator photoCmptr = ^(PhotoPickerItem *item1, PhotoPickerItem *item2){
            return [item1.photoDate compare:item2.photoDate];
        };
        album.photos = [album.photos sortedArrayUsingComparator:photoCmptr];
        album.albumImage = ((PhotoPickerItem *)[album.photos lastObject]).thumbnailImage;
        
        if (album.photos.count>0) {
            if ([album.albumName isEqualToString:@"相机胶卷"]||[album.albumName isEqualToString:@"Camera Roll"]) {//相机胶卷插入第一个
                [list insertObject:album atIndex:0];
            } else {
                [list addObject:album];
            }
        }
    } failureBlock:^(NSError *error) {
        DDLogDebug(@"扫描用户相册异常:%@", error);
        complement(nil, error);
    }];
}
@end
