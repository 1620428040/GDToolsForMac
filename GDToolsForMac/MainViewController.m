//
//  MainViewController.m
//  GDToolsForMac
//
//  Created by 国栋 on 16/1/7.
//  Copyright (c) 2016年 GD. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property NSView *mainView;

@end

@implementation MainViewController
@synthesize mainView;

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(IBAction)readme:(id)sender
{
    [[NSWorkspace sharedWorkspace]openFile:[[NSBundle mainBundle]pathForResource:@"使用说明" ofType:@""]];
}
@end
