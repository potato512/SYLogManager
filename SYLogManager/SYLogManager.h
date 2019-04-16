//
//  SYLogManager.h
//  SYLogManager
//
//  Created by zhangshaoyu on 2018/10/12.
//  Copyright © 2018年 zhangshaoyu. All rights reserved.
//  日志管理器

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSArray+SYLogCategory.h"
#import "NSDictionary+SYLogCategory.h"

#define SYLogManagerSingle ([SYLogManager shareLog])

NS_ASSUME_NONNULL_BEGIN

@interface SYLogManager : NSObject

+ (instancetype)shareLog;

/// 日志记录路径
@property (nonatomic, strong, readonly) NSString *filePath;
/// 是否自动清除日志（默认不清除）
@property (nonatomic, assign) BOOL autoClear;
/// 显示日志信息（默认不显示）
@property (nonatomic, assign) BOOL show;
@property (nonatomic, strong) UIView *showView;

// 初始化
- (void)initializeLog;
// 清除
- (void)clearLog;
// 上传（待开发）
- (void)uploadLogWithUrl:(NSString *)url parameter:(NSDictionary *)dict complete:(void (^)(BOOL success, NSString *message))complete;

@end

NS_ASSUME_NONNULL_END
