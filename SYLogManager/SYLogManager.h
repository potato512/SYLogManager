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

/// 中控打印及log记录
#define SYLog(logEnable, logKey, format, ...) {SYLogSave(logEnable, logKey, [NSString stringWithFormat:(format), ##__VA_ARGS__]);}

NS_ASSUME_NONNULL_BEGIN

@interface SYLogConfig : NSObject

/// 视图控制器用于弹窗及发邮件
@property (nonatomic, strong) UIViewController *logController;
/// 邮件接收地址（选填，填写后须设置属性 controller）
@property (nonatomic, strong) NSString *logEmail;
/// 时间颜色（默认红色）
@property (nonatomic, strong) UIColor *logColor;
/// 显示父视图
@property (nonatomic, strong) UIView *logShowView;
/// 显示或隐藏
@property (nonatomic, assign) BOOL logShow;
/// 开关log日志
@property (nonatomic, assign) BOOL logEnable;

@end

@interface SYLogManager : NSObject

+ (instancetype)shareLog;

/// 配置
@property (nonatomic, strong) SYLogConfig *config;
/// 显示或隐藏（warning:config初始化后设置才有效）
@property (nonatomic, assign) BOOL show;

/**
 *  记录log日志
 *  text:log日志信息
 */
- (void)logText:(NSString *)text;
/**
 *  记录log日志
 *  text:log日志信息
 *  key:类型，用于搜索和区分区分log日志
 */
- (void)logText:(NSString *)text key:(NSString *)key;

/// 打印及记录
void SYLogSave(BOOL logEnable, NSString *key, NSString *text);

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
 2 属性设置
 SYLogConfig *config = [SYLogConfig new];
 config.logEmail = @"151311301@qq.com";
 config.logColor = UIColor.greenColor;
 config.logController = self.window.rootViewController;
 config.logShowView = self.window;
 config.logShow = YES;
 config.logEnable = YES;
 3 配置
 SYLogManager.shareLog.config = config;
 // 或
 SYLogManager.shareLog.show = YES;
 // 或
 SYLogManager.shareLog.show = NO;
 4 自定义日志信息
 [SYLogManager.shareLog logText:@"正在进行网络请求"];
 [SYLogManager.shareLog logText:@"正在进行网络请求" key:@"网络"];
 SYLogSave(YES, @"网络", @"正在进行网络请求");
 或
 SYLog(YES, @"网络", @"%@", @"正在进行网络请求");
 
 */
