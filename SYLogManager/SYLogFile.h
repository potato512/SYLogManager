//
//  SYLogFile.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/4/15.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@end

NS_ASSUME_NONNULL_END
