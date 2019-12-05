//
//  SYLogFile.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/4/15.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYLogFile : NSObject

/// 是否允许联调或模拟器模式（默认NO不允许）
@property (nonatomic, assign) BOOL isEnable;

/// log存储文件（默认caches缓存目录）
@property (nonatomic, strong) NSString *filePath;


/// 保存
- (void)saveLogMessage;
/// 删除
- (void)deleteLogMessage;
/// 读取
- (void)readLogMessage:(void (^)(NSString *message))complete;


/// 默认黄色
@property (nonatomic, strong) UIColor *colorTime;



- (void)save:(NSString *)text;
- (void)save:(NSString *)text key:(NSString *)key;
- (void)read:(void (^)(NSAttributedString *text))complete;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
