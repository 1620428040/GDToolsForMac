//
//  CreateModelData.m
//  GDToolsForMac
//
//  Created by 国栋 on 16/1/7.
//  Copyright (c) 2016年 GD. All rights reserved.
//

#import "CreateModelData.h"
#import "Support.h"
#import "CreateModel.h"

@implementation DataType
@synthesize signName,nameForObjectC,nameForCoreData;

@end



@implementation Property
@synthesize name,dataType;

@end



@implementation CreateModelData
@synthesize name,useCoreData,number,propertyList,dataTypeList;

+(CreateModelData *)share
{
    __strong static CreateModelData  *shareCreateModelData=nil;
    if (shareCreateModelData==nil) {
        shareCreateModelData=[[self alloc]init];
    }
    return shareCreateModelData;
}
-(instancetype)init
{
    if (self=[super init]) {
        [self createDataTypeList];//创建支持的数据类型的列表，以后可以用plist的形式加载
        name=@"";
        useCoreData=1;
        number=0;
        propertyList=[NSMutableArray array];
    }
    return self;
}
-(DataType*)findDataTypeBySignName:(NSString*)theSignName
{
    for (DataType *dataType in dataTypeList) {
        if ([dataType.signName isEqualToString:theSignName]) {
            return dataType;
        }
    }
    return nil;
}
-(void)updataPropertyNameToList:(NSString*)theName index:(NSInteger)index
{
    if (theName==nil) {
        return;
    }
    
    while (propertyList.count<=index) {
        Property *property=[[Property alloc]init];
        [propertyList addObject:property];
    }
    
    Property *property=[propertyList objectAtIndex:index];
    property.name=theName;
}
-(void)updataPropertyTypeToList:(NSString*)theSignName index:(NSInteger)index
{
    if (theSignName==nil) {
        return;
    }
    
    DataType *dataType=[self findDataTypeBySignName:theSignName];
    if (dataType==nil) {
        [PromptController postPrompt:@"未记录的数据类型，有可能出错" type:0];
        return;
    }
    
    while (propertyList.count<=index) {
        Property *property=[[Property alloc]init];
        [propertyList addObject:property];
    }
    
    Property *property=[propertyList objectAtIndex:index];
    property.dataType=dataType;
}
-(BOOL)checkModelData
{
    if (name==nil||[name isEqualToString:@""]) {
        [PromptController postPrompt:@"模型的名称不能为空" type:0];
        return NO;
    }
    if (number==0) {
        [PromptController postPrompt:@"没有添加属性" type:0];
        return NO;
    }
    if (propertyList.count<number) {
        [PromptController postPrompt:@"模型的属性数量小于设定值" type:0];
        return NO;
    }
    for (NSInteger i=0;i<propertyList.count;i++) {
        if (i>=number) {
            [propertyList removeObjectAtIndex:i];
        }
        else
        {
            Property *property=[propertyList objectAtIndex:i];
            if (property.name==nil||[property.name isEqualToString:@""]||property.dataType==nil) {
                [PromptController postPrompt:@"属性的名称和数据类型不能为空" type:0];
                return NO;
            }
        }
    }
    return YES;
}
-(NSString *)description
{
    NSString *describe=[NSString stringWithFormat:@"数据模型名称：%@\n使用CoreData=%d\n属性数量＝%ld\n",name,useCoreData,number];
    for (Property *property in propertyList) {
        describe=[NSString stringWithFormat:@"%@\nname=%@   type=%@",describe,property.name,property.dataType.signName];
    }
    return describe;
}

#pragma mark 以下内容是将数据写进dataTypeList用的
-(void)createDataTypeList
{
    dataTypeList=[NSMutableArray array];
    
    [self addWithSignName:@"NSString" objectC:@"NSString*" coreData:@"String"];
    [self addWithSignName:@"NSNumber" objectC:@"NSNumber *" coreData:@"Transformable"];
    [self addWithSignName:@"NSData" objectC:@"NSData *" coreData:@"Binary"];
    [self addWithSignName:@"NSDate" objectC:@"NSDate *" coreData:@"Date"];
    [self addWithSignName:@"NSInteger" objectC:@"NSInteger " coreData:@"Transformable" trans:@"NSNumber *" hold:@"%ld" tran1:@"[NSNumber numberWithInteger:" tran2:@"]" reve1:@"[" reve2:@" integerValue]"];
    [self addWithSignName:@"UIImage" objectC:@"UIImage *" coreData:@"Binary" trans:@"NSData *" hold:@"%@" tran1:@"UIImagePNGRepresentation(" tran2:@")" reve1:@"[UIImage imageWithData:" reve2:@"]"];
    [self addWithSignName:@"BOOL" objectC:@"BOOL " coreData:@"Transformable" trans:@"NSNumber *" hold:@"%d" tran1:@"[NSNumber numberWithBool:" tran2:@"]" reve1:@"[" reve2:@" boolValue]"];
}
-(BOOL)addWithSignName:(NSString *)signName objectC:(NSString *)objectC coreData:(NSString *)coreData
{
    [self addWithSignName:signName objectC:objectC coreData:coreData trans:objectC hold:@"%@" tran1:@"" tran2:@"" reve1:@"" reve2:@""];
    return YES;
}
-(BOOL)addWithSignName:(NSString *)signName objectC:(NSString *)objectC coreData:(NSString *)coreData trans:(NSString *)trans hold:(NSString *)hold tran1:(NSString *)tran1 tran2:(NSString *)tran2 reve1:(NSString *)reve1 reve2:(NSString *)reve2
{
    DataType *new=[[DataType alloc]init];
    new.signName=signName;
    new.nameForObjectC=objectC;
    new.nameForCoreData=coreData;
    new.trans=trans;
    new.hold=hold;
    new.tran1=tran1;
    new.tran2=tran2;
    new.reve1=reve1;
    new.reve2=reve2;
    [dataTypeList addObject:new];
    return YES;
}
@end
