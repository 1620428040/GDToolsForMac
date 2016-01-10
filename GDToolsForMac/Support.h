//
//  Support.h
//  GDToolsForMac
//
//  Created by 国栋 on 16/1/7.
//  Copyright (c) 2016年 GD. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GDWindowController : NSWindowController

@end



@interface Support : NSObject

@property (readonly)NSString *programPath;
@property (readonly)NSString *modelPath;
@property (readonly)NSString *savePath;
@property (readonly)NSString *resourcesPath;

+(Support*)share;

@end


