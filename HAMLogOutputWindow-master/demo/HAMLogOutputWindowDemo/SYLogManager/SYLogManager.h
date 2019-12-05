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

NS_ASSUME_NONNULL_BEGIN

@interface SYLogManager : UIWindow

+ (instancetype)shareLog;

/// 时间颜色（默认红色）
@property (nonatomic, strong) UIColor *colorLog;

+ (void)show;
+ (void)hide;
//
+ (void)logText:(NSString *)text;
+ (void)logText:(NSString *)text key:(NSString *)key;
+ (void)logClear;

@end

NS_ASSUME_NONNULL_END

/*
 记录，查看的信息包括：NSLog打印的信息、闪退信息。
 
 使用说明
 1、需要记录的信息通过NSlog打印，则会自动缓存
 2、继承NSObject的对象需要打印时，通过属性objectDescription，如：
 NSObject *object = [NSObject new]; NSLog("object = %@", object.objectDescription);
 3、SYLogManagerSingle.show = YES;属性的设置在[self.window makeKeyAndVisible];方法之后
 
 注意：截图是保存到相册，因此需要设置相册隐私权限。
 
 使用示例
 1 引入头文件 #import "SYLogManager.h"
 2 初始化 [SYLogManagerSingle initializeLog];
 3 属性设置
 SYLogManagerSingle.showView = self.window;
 SYLogManagerSingle.target = self.window.rootViewController;
 SYLogManagerSingle.email = @"151311301@qq.com";
 SYLogManagerSingle.isEnable = YES;
 4 显示 SYLogManagerSingle.show = YES;
 
 */
