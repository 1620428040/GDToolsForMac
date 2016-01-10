//
//  CreateModelData.h
//  GDToolsForMac
//
//  Created by 国栋 on 16/1/7.
//  Copyright (c) 2016年 GD. All rights reserved.
//

#import <Foundation/Foundation.h>

//支持的数据类型
@interface DataType : NSObject

@property NSString *signName;
@property NSString *nameForObjectC;
@property NSString *nameForCoreData;

@property NSString *trans;//非对象的数据要转化成的 对象类型
@property NSString *hold;//占位符
@property NSString *tran1;//转化类型用的代码，前一部分
@property NSString *tran2;//后一部分
@property NSString *reve1;//反转化
@property NSString *reve2;

@end

//要创建的文件中的属性
@interface Property : NSObject

@property NSString *name;
@property DataType *dataType;

@end

//记录数据，管理支持的数据类型的类
@interface CreateModelData : NSObject

@property NSString *name;
@property BOOL useCoreData;
@property NSInteger number;
@property NSMutableArray *propertyList;
@property NSMutableArray *dataTypeList;

+(CreateModelData*)share;//获取单例对象
-(void)updataPropertyNameToList:(NSString*)theName index:(NSInteger)index;//修改／添加一个属性的名称
-(void)updataPropertyTypeToList:(NSString*)theSignName index:(NSInteger)index;//修改／添加一个属性的类型
-(BOOL)checkModelData;//检查并处理创建文件用的数据
-(NSString *)description;//以介绍的形式输出内容

@end



