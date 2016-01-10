//
//  CreateModel.h
//  GDToolsForMac
//
//  Created by 国栋 on 16/1/7.
//  Copyright (c) 2016年 GD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CreateModelData.h"
#import "FileCreate.h"

@interface CreateModel : NSView<NSTableViewDataSource,NSTableViewDelegate>
{
    NSInteger num;
}

@property IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *nameInput;
@property (weak) IBOutlet NSButton *useCoreData;
@property (weak) IBOutlet NSTextField *number;

@property CreateModelData *createModelData;
@property NSString *stringOfNumber;

@end

@interface PromptController : NSObject

@property (weak) IBOutlet NSTextField *promptView;
+(void)postPrompt:(NSString*)prompt type:(int)typenum;

@end