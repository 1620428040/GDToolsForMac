//
//  CreateModel.m
//  GDToolsForMac
//
//  Created by 国栋 on 16/1/7.
//  Copyright (c) 2016年 GD. All rights reserved.
//

#import "CreateModel.h"

#pragma mark CellView
@interface GDTableCellView : NSTableCellView<NSTextFieldDelegate>
@property NSTextField *nameInput;
@property NSComboBox *selecter;
@property NSString *column;
@property NSInteger index;

-(GDTableCellView*)initWithFrame:(NSRect)frameRect column:(NSString*)column index:(NSInteger)index;

@end

@implementation GDTableCellView
@synthesize nameInput,selecter;

-(GDTableCellView *)initWithFrame:(NSRect)frameRect column:(NSString*)column index:(NSInteger)index
{
    self.column=column;
    self.index=index;
    
    //创建新的NSTableCellView
    if (self=[super initWithFrame:frameRect]) {
        if ([column isEqualToString:@"AutomaticTableColumnIdentifier.0"]) {
            nameInput=[[NSTextField alloc]initWithFrame:frameRect];
            nameInput.autoresizingMask=2;
            nameInput.delegate=self;
            nameInput.placeholderString=@"输入属性的名称，比如:name";
            [self addSubview:nameInput];
        }
        if ([column isEqualToString:@"AutomaticTableColumnIdentifier.1"]) {
            selecter=[[NSComboBox alloc]initWithFrame:frameRect];
            NSArray *dataTypeList=[CreateModelData share].dataTypeList;
            for (DataType *dataType in dataTypeList) {
                [selecter addItemWithObjectValue:dataType.signName];
            }
            
            [self addSubview:selecter];
        }
    }
    return self;
}

-(void)postData//接到消息后，将自身的报存的数据发送到CreateModelData中
{
    if ([self.column isEqualToString:@"AutomaticTableColumnIdentifier.0"]) {
        [[CreateModelData share]updataPropertyNameToList:[self.nameInput.cell title] index:self.index];
    }
    if ([self.column isEqualToString:@"AutomaticTableColumnIdentifier.1"]) {
        [[CreateModelData share]updataPropertyTypeToList:[self.selecter.cell title] index:self.index];
    }
}
- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
    //NSLog(@"textShouldBeginEditing");
    
    return YES;
}
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    //NSLog(@"textShouldEndEditing");
    [self postData];
    
    return YES;
}
@end




@implementation CreateModel
@synthesize createModelData;

-(instancetype)init
{
    if (self=[super init]) {
        createModelData=[CreateModelData share];
    }
    return self;
}

-(IBAction)changeNumber:(NSTextField*)sender
{
    num=[[sender.cell title]integerValue];
    createModelData.number=num;
    [self.tableView reloadData];
}
-(IBAction)clear:(id)sender
{
    createModelData.name=@"";
    createModelData.number=0;
    createModelData.useCoreData=1;
    createModelData.propertyList=[NSMutableArray array];
    [self.nameInput.cell setTitle:@""];
    [self.number.cell setTitle:@"0"];
    [self.useCoreData setState:1];
    [self.tableView reloadData];
}
-(IBAction)create:(NSButton*)sender
{
    createModelData.name=[self.nameInput.cell title];
    createModelData.number=[[self.number.cell title]integerValue];
    createModelData.useCoreData=[self.useCoreData state];
    
    for (NSInteger i=0; i<num; i++) {
        [[self.tableView viewAtColumn:0 row:i makeIfNecessary:NO]postData];
        [[self.tableView viewAtColumn:1 row:i makeIfNecessary:NO]postData];
    }
    
    if ([createModelData checkModelData]) {
        //[PromptController postPrompt:@"操作成功" type:1];
        
        //开始创建文件
        [[[FileCreate alloc]init]createfile];
    }
    else
    {
        NSLog(@"失败");
    }
}

#pragma mark 表视图（属性列表）
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return createModelData.number;
}
-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 30;
}
-(BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return YES;
}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    GDTableCellView *cell=[tableView makeViewWithIdentifier:@"reuseCellView" owner:self];//不知道为啥，获取不了ID对应的对象
    if (cell==nil) {
        CGRect cellRect=CGRectMake(0, 0, tableColumn.width, 30);
        cell=[[GDTableCellView alloc]initWithFrame:cellRect column:tableColumn.identifier index:row];
    }
    //赋值
    if (row<createModelData.propertyList.count) {
        Property *property=[createModelData.propertyList objectAtIndex:row];
        if ([tableColumn.identifier isEqualToString:@"AutomaticTableColumnIdentifier.0"]) {
            if (property.name!=nil) {
                [cell.nameInput.cell setTitle:property.name];
            }
        }
        if ([tableColumn.identifier isEqualToString:@"AutomaticTableColumnIdentifier.1"]) {
            if (property.dataType.signName!=nil) {
                [cell.nameInput.cell setTitle:property.dataType.signName];
            }
        }
    }
    return cell;
}
-(NSString*)stringOfNumber
{
    return [NSString stringWithFormat:@"%ld",createModelData.number];
}
-(void)setStringOfNumber:(NSString*)stringOfNumber
{
    if (stringOfNumber==nil) {
        createModelData.number=0;
    }
    else
    {
        createModelData.number=[stringOfNumber integerValue];
    }
}
@end



PromptController *sharePromptController;
@implementation PromptController
-(instancetype)init
{
    if (self=[super init]) {
        sharePromptController=self;
    }
    return self;
}

+(void)postPrompt:(NSString *)prompt type:(int)typenum
{
    //延迟后续的提示，以使之前的不被覆盖
    static NSDate *lastTime=nil;
    if (lastTime==nil) {
        lastTime=[NSDate date];
    }
    else if ([lastTime timeIntervalSinceNow]>-0.3) {
        NSLog(@"%f",[lastTime timeIntervalSinceNow]);
        return;
    }
    else lastTime=[NSDate date];
    
    switch (typenum) {
        case 0:
            [sharePromptController.promptView.cell setTextColor:[NSColor redColor]];//警告信息
            break;
        case 1:
            [sharePromptController.promptView.cell setTextColor:[NSColor greenColor]];//成功提示
            break;
        default:
            [sharePromptController.promptView.cell setTextColor:[NSColor yellowColor]];//默认颜色
            break;
    }
    [sharePromptController.promptView.cell setTitle:prompt];
}

@end

