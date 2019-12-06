//
//  SYLogSQLite.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/12/6.
//  Copyright © 2019 Find the Lamp Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYLogSQLite : NSObject

- (BOOL)executeSQLite:(NSString *)sqlString;
- (NSArray *)selectSQLite:(NSString *)sqlString;

@end

NS_ASSUME_NONNULL_END
