//
//  FileCreate.m
//  AutoAPP
//
//  Created by 国栋 on 15/11/26.
//  Copyright (c) 2015年 GD. All rights reserved.
//

#import "FileCreate.h"
#import "CreateModelData.h"
#import "Support.h"
#import "CreateModel.h"

@interface FileCreate ()

@property CreateModelData *createModelData;
@property NSFileManager *fileManager;
@property NSString *modelPath;
@property NSString *createdFilePath;
@end

@implementation FileCreate
@synthesize createModelData,fileManager,modelPath,createdFilePath;

-(id)init
{
    if ([super init]!=nil) {
        createModelData=[CreateModelData share];
        fileManager=[NSFileManager defaultManager];
        modelPath=[[Support share]modelPath];
        createdFilePath=[[Support share]savePath];
        
        //[PromptController postPrompt:createdFilePath type:2];
    }
    return self;
}
-(void)createfile
{
    BOOL isDirectory=YES;
    if (![fileManager fileExistsAtPath:modelPath isDirectory:&isDirectory]) {
        [PromptController postPrompt:@"找不到文件" type:0];
        return;
    }
    if (![fileManager fileExistsAtPath:createdFilePath isDirectory:&isDirectory]) {
        [fileManager createDirectoryAtPath:createdFilePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if(createModelData.useCoreData==NO)
    {
        [self create:@"Manager.h" useModelFile:@"UnStoreManager"];
        [self create:@"Manager.m" useModelFile:@"UnStoreManager"];
    }
    else
    {
        [self create:@"Manager.h" useModelFile:@"CoreDataManager"];
        [self create:@"Manager.m" useModelFile:@"CoreDataManager"];
        [self updateModel];
    }
    [PromptController postPrompt:@"文件创建成功" type:1];
    [[NSWorkspace sharedWorkspace]openFile:createdFilePath];
}
-(void)create:(NSString *)filename useModelFile:(NSString *)model
{
    NSString *modelFileName;
    if (createModelData.useCoreData==YES) {
        modelFileName=@"CoreDataManager";
    }
    else
    {
        modelFileName=@"UnStoreManager";
    }
    NSString *content=[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",modelPath,modelFileName] encoding:NSUTF8StringEncoding error:nil];
    
    content=[[content componentsSeparatedByString:[NSString stringWithFormat:@"/*<%@>*/\n",filename]]objectAtIndex:1];//注意，截取模型时，需要截掉开头的换行符，否则coredata会出错
    content=[self translateMark:@"/*/name/*/Mark" by:createModelData.name in:content];//替换模型文件中所有的 数据模型 名称 的标签
    //此处可以添加要替换的其它标签
    
    content=[self copyForList:content model:filename];
    
    [content writeToFile:[NSString stringWithFormat:@"%@/%@%@",createdFilePath,createModelData.name,filename] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
-(NSString*)translateMark:(NSString*)mark by:(NSString*)str in:(NSString*)content
{
    NSArray *array=[content componentsSeparatedByString:mark];
    content=[array firstObject];
    for (int i=1; i<array.count; i++) {
        content=[NSString stringWithFormat:@"%@%@%@",content,str,[array objectAtIndex:i]];
    }
    return content;
}
-(NSString*)copyForList:(NSString*)content model:(NSString*)model
{
    NSArray *array=[content componentsSeparatedByString:@"/*<LIST>*/"];
    content=[array firstObject];
    for (int i=1; i<array.count; i++) {
        NSString *current=[array objectAtIndex:i];
        //NSLog(@"循环检测");
        if ([current containsString:@"/*/ATT"]) {
            //NSLog(@"匹配%d",(int)datagroupmanger.attributeList.count);
            for (int j=0; j<createModelData.propertyList.count; j++) {
                NSString *copy=[current copy];
                Property *property=[createModelData.propertyList objectAtIndex:j];
                copy=[self transAttIn:copy model:model currentAtt:property];
                content=[NSString stringWithFormat:@"%@%@",content,copy];
            }
        }
        else
        {
            content=[NSString stringWithFormat:@"%@%@",content,current];
        }
    }
    return content;
}

//转换每条属性相关的内容
-(NSString*)transAttIn:(NSString*)copy model:(NSString*)model currentAtt:(Property*)currentAtt
{
    //转换"/*/ATTname/*/Mark"标签
    copy=[self translateMark:@"/*/ATTname/*/Mark" by:currentAtt.name in:copy];
    
    //转换"/*/ATTtype/*/NSString *"标签
    NSString *type;//类型（coredata和objectc中的类型相互转换）
    if ([model isEqualToString:@"contents"]) {
        type=currentAtt.dataType.nameForCoreData;
    }
    //else if此处添加对其他类型的模型中的数据类型的转换，如果有的话
    else
    {
        type=currentAtt.dataType.nameForObjectC;
    }
    copy=[self translateMark:@"/*/ATTtype/*/NSString *" by:type in:copy];
    
    //转换"/*/ATTtrans/*/NSString *"标签
    //转换"/*/ATThold/*/%@"标签
    //转换"/*/ATTtran1/*/"标签
    //转换"/*/ATTtran2/*/"标签
    //转换"/*/ATTreve1/*/"标签
    //转换"/*/ATTreve2/*/"标签
    copy=[self translateMark:@"/*/ATTtrans/*/NSString *" by:currentAtt.dataType.trans in:copy];
    copy=[self translateMark:@"/*/ATThold/*/%@" by:currentAtt.dataType.hold in:copy];
    copy=[self translateMark:@"/*/ATTtran1/*/" by:currentAtt.dataType.tran1 in:copy];
    copy=[self translateMark:@"/*/ATTtran2/*/" by:currentAtt.dataType.tran2 in:copy];
    copy=[self translateMark:@"/*/ATTreve1/*/" by:currentAtt.dataType.reve1 in:copy];
    copy=[self translateMark:@"/*/ATTreve2/*/" by:currentAtt.dataType.reve2 in:copy];
    
    //转换"strong"标签
    if ((![currentAtt.dataType.signName isEqualToString:@"NSNumber"])&&[currentAtt.dataType.trans isEqualToString:@"NSNumber *"]) {
        copy=[self translateMark:@"strong" by:@"assign" in:copy];
    }
    //此处可以添加其他需要转化的标签
    return copy;
}
-(void)updateModel
{
    NSString *content=[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/CodeModel",modelPath] encoding:NSUTF8StringEncoding error:nil];
    
    content=[[content componentsSeparatedByString:@"/*<contents>*/\n"]objectAtIndex:1];//注意，截取模型时，需要截掉开头的换行符，否则coredata会出错
    content=[self translateMark:@"/*/name/*/Mark" by:createModelData.name in:content];//替换模型文件中所有的 数据模型 名称 的标签
    //此处可以添加要替换的其它标签
    
    content=[self copyForList:content model:@"contents"];
    if (content==nil) {
        return;
    }
    
    NSString *xcdatamodeldFilePath=[NSString stringWithFormat:@"%@/%@Model.xcdatamodeld",createdFilePath,createModelData.name];
    if ([fileManager fileExistsAtPath:xcdatamodeldFilePath isDirectory:nil]) {
        [[NSFileManager defaultManager]removeItemAtPath:xcdatamodeldFilePath error:nil];
    }
    NSString *path=[NSString stringWithFormat:@"%@/Model.xcdatamodeld",modelPath];
    if (![[NSFileManager defaultManager]fileExistsAtPath:path]) {
        [PromptController postPrompt:@"找不到文件" type:0];
    }
    [[NSFileManager defaultManager]copyItemAtPath:path toPath:xcdatamodeldFilePath error:nil];
    NSString *modelContentsPath=[NSString stringWithFormat:@"%@/Model.xcdatamodel/contents",xcdatamodeldFilePath];
    [content writeToFile:modelContentsPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
@end
