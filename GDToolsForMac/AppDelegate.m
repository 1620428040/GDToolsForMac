//
//  AppDelegate.m
//  GDToolsForMac
//
//  Created by 国栋 on 16/1/7.
//  Copyright (c) 2016年 GD. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@interface AppDelegate ()

@property NSTextField *tip;

@end

@implementation AppDelegate
@synthesize tip;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(windowDidChangeScreenNotification:) name:NSWindowDidChangeScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(windowDidBecomeKeyNotification:) name:NSWindowDidBecomeKeyNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(windowDidResignKeyNotification:) name:NSWindowDidResignKeyNotification object:nil];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


//调整窗口大小
-(void)windowDidChangeScreenNotification:(NSNotification*)noti
{
    NSWindow *window=noti.object;
    [window setLevel:10];
    [window setTitle:@"GDTools工具集"];
    window.alphaValue=0.95;
    [self windowDidBecomeKeyNotification:noti];
}
-(void)windowDidBecomeKeyNotification:(NSNotification*)noti
{
    CGRect screen=[NSScreen mainScreen].frame;
    NSWindow *window=noti.object;
    if (tip!=nil) {
        [tip removeFromSuperview];
        tip=nil;
    }
    [window setFrame:CGRectMake(screen.size.width-300, screen.size.height-524, 300, 524) display:YES animate:YES];
}
-(void)windowDidResignKeyNotification:(NSNotification*)noti
{
    CGRect screen=[NSScreen mainScreen].frame;
    NSWindow *window=noti.object;
    NSView *contentView=window.contentView;
    [window setFrame:CGRectMake(screen.size.width-300, screen.size.height-30, 300, 50) display:YES animate:YES];
    if (tip==nil) {
        tip=[[NSTextField alloc]initWithFrame:CGRectMake(0, 0, 300, 25)];
        [tip.cell setTitle:@"程序待命中，点击窗口开始工作..."];
        [tip.cell setTextColor:[NSColor redColor]];
        tip.editable=NO;
        tip.backgroundColor=[NSColor lightGrayColor];
        [contentView addSubview:tip];
    }
}
@end
