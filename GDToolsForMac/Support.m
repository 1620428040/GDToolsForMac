//
//  Support.m
//  GDToolsForMac
//
//  Created by 国栋 on 16/1/7.
//  Copyright (c) 2016年 GD. All rights reserved.
//

#import "Support.h"
#import "CreateModel.h"

@interface Support()

@property NSFileManager *fileManager;

@end

@implementation Support
@synthesize fileManager;

+(Support*)share
{
    static Support *shareSupport=nil;
    if (shareSupport==nil) {
        shareSupport=[[Support alloc]init];
    }
    return shareSupport;
}

-(NSString *)modelPath
{
    return [[NSBundle mainBundle]pathForResource:@"Model" ofType:nil];
}
-(NSString *)savePath
{
    return [NSString stringWithFormat:@"%@/Desktop/AutoCode",NSHomeDirectory()];
}

@end
