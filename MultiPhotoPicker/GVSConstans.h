//
//  GVSConstans.h
//  MultiPhotoPicker
//
//  Created by xzysun on 15/8/6.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#ifndef MultiPhotoPicker_GVSConstans_h
#define MultiPhotoPicker_GVSConstans_h

#ifdef DEBUG
#define DDLogDebug(...) NSLog(__VA_ARGS__)
#else
#define DDLogDebug(...)
#endif


#define DDLogError(...) NSLog(__VA_ARGS__)
#define WeakSelf    __weak typeof(self) weakSelf = self;
#define SCREEN_WIDTH    ([[UIScreen mainScreen] bounds].size.width)

#endif
