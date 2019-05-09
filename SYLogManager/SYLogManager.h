//
//  SYLogManager.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2018/10/12.
//  Copyright © 2018年 zhangshaoyu. All rights reserved.
//  日志管理器 https://github.com/potato512/SYLogManager

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSArray+SYLogCategory.h"
#import "NSDictionary+SYLogCategory.h"
#import "NSObject+SYLogCategory.h"

#define SYLogManagerSingle ([SYLogManager shareLog])

NS_ASSUME_NONNULL_BEGIN

@interface SYLogManager : NSObject

+ (instancetype)shareLog;

/// 日志记录路径
@property (nonatomic, strong, readonly) NSString *filePath;
/// 显示日志信息（默认不显示）
@property (nonatomic, assign) BOOL show;
/// 父视图
@property (nonatomic, strong) UIView *showView;
/// 控制器
@property (nonatomic, strong) UIViewController *target;

/// 初始化
- (void)initializeLog;
/// 清除
- (void)clearLog;
/// 上传（待开发）
- (void)uploadLogWithUrl:(NSString *)url parameter:(NSDictionary *)dict complete:(void (^)(BOOL success, NSString *message))complete;

@end

NS_ASSUME_NONNULL_END

/*
 记录，查看的信息包括：NSLog打印的信息、闪退信息。
 
 使用说明
 1、需要记录的信息通过NSlog打印，则会自动缓存
 2、继承NSObject的对象需要打印时，通过属性objectDescription，如：
 NSObject *object = [NSObject new]; NSLog("object = %@", object.objectDescription);
 3、SYLogManagerSingle.show = YES;属性的设置在[self.window makeKeyAndVisible];方法之后
 
 */
