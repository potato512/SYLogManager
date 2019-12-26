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

#ifdef DEBUG
/// 中控打印及log记录
#define SYLog(logEnable, logKey, format, ...) {NSLog( @"< %@:(第 %d 行) > %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(format), ##__VA_ARGS__]);if (logEnable) {[SYLogManager.shareLog logText:[NSString stringWithFormat:(format), ##__VA_ARGS__] key:logKey];}}
#else
/// 中控打印及log记录
#define SYLog(logEnable, logKey, format, ...)
#endif

NS_ASSUME_NONNULL_BEGIN

@interface SYLogManager : NSObject

+ (instancetype)shareLog;

/// 视图控制器用于弹窗及发邮件（在设置根视图控制器之后）
@property (nonatomic, strong) UIViewController *controller;
/// 邮件接收地址（选填，填写后须设置属性 controller）
@property (nonatomic, strong) NSString *email;
/// 时间颜色（默认红色）
@property (nonatomic, strong) UIColor *colorLog;
/// 显示或隐藏（在设置根视图控制器之后）
@property (nonatomic, assign) BOOL show;

/// 初始化配置，默认缓存地址（在设置根视图控制器之前）
- (void)config:(BOOL)enable;
/// log
- (void)logText:(NSString *)text;
- (void)logText:(NSString *)text key:(NSString *)key;

@end

NS_ASSUME_NONNULL_END

/*
 记录，查看的信息包括：自定义信息、闪退信息（初始化配置时默认添加）。
 
 使用说明
 1、继承NSObject的对象需要打印时，通过属性objectDescription，如：
 NSObject *object = [NSObject new]; NSLog("object = %@", object.objectDescription);
 2、属性（controller，show）的设置在[self.window makeKeyAndVisible];方法之后
 
 注意：日志记录是通过sqlite进行保存，故项目中需要添加库：libsqlite3.tbd
 
 使用示例
 1 引入头文件 #import "SYLogManager.h"
 2 初始化 [SYLogManager.shareLog config:YES];
 3 属性设置
 SYLogManager.shareLog.target = self.window.rootViewController;
 SYLogManager.shareLog.email = @"151311301@qq.com";
 SYLogManager.shareLog.colorLog = UIColor.greenColor;
 SYLogManager.shareLog.show = YES;
 4 自定义日志信息
 [SYLogManager.shareLog logText:@"正在进行网络请求"];
 [SYLogManager.shareLog logText:@"正在进行网络请求" key:@"网络"];
 或
 SYLog(YES, @"网络", @"%@", @"正在进行网络请求");
 
 */
