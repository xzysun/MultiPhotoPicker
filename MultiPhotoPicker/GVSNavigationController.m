//
//  GVSNavigationController.m
//  MultiPhotoPicker
//
//  Created by xzysun on 15/8/6.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import "GVSNavigationController.h"

@interface GVSNavigationController ()

@end

@implementation GVSNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [self.visibleViewController supportedInterfaceOrientations];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.visibleViewController preferredStatusBarStyle];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
