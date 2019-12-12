//
//  SYLogSQLite.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/12/6.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYLogSQLite : NSObject

/// 建表/删表/插入、更新、删除数据
- (BOOL)executeSQLite:(NSString *)sqlString;
/// 查询
- (NSArray *)selectSQLite:(NSString *)sqlString;

@end

NS_ASSUME_NONNULL_END
