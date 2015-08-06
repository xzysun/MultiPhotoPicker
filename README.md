# MultiPhotoPicker
一个图片多选控件，支持预览

####使用方法，目前支持设置主要颜色和传入照片数量

```Objective-C
    PhotoAlbumListViewController *pickerVC = [PhotoAlbumListViewController picker];
    pickerVC.delegate = self;
//    pickerVC.maxImageCount = 15;
    [pickerVC showFromViewController:self];
```
通过Delegate方法回调
```Objective-C
-(void)photoPickerDidChooseImage:(NSArray *)images
{
    NSLog(@"pick %ld images", images.count);
}
```
