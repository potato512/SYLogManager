//
//  SYLogSQLite.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/12/6.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import "SYLogSQLite.h"
#import <sqlite3.h>

@interface SYLogSQLite ()
{
    // 数据库
    sqlite3 *dataBase;
    BOOL isOpenDataBase;
}

/// 缓存路径
@property (nonatomic, strong) NSString *filePath;

@end

@implementation SYLogSQLite

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *fileName = [NSString stringWithFormat:@"LogFile_%@.db", [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleIdentifier"]];
        // doucment
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
//        NSString *filePath = [paths objectAtIndex:0];
        // 缓存
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        self.filePath = [paths objectAtIndex:0];
        self.filePath = [self.filePath stringByAppendingPathComponent:fileName];
        NSLog(@"sqlite path: %@", self.filePath);
    }
    return self;
}

- (BOOL)isValidSQL:(NSString *)sql
{
    return (sql && [sql isKindOfClass:NSString.class] && sql.length > 0);
}

- (NSString *)filePath
{
    if (_filePath == nil) {
        NSString *fileName = [NSString stringWithFormat:@"LogFile_%@.db", [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleIdentifier"]];
        // doucment
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
//        NSString *filePath = [paths objectAtIndex:0];
        // 缓存
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _filePath = [paths objectAtIndex:0];
        _filePath = [_filePath stringByAppendingPathComponent:fileName];
        NSLog(@"sqlite path: %@", _filePath);
    }
    return _filePath;
}

- (BOOL)openSQLite
{
    const char *fileName = self.filePath.UTF8String;
    int execStatus = sqlite3_open(fileName, &dataBase);
    if (execStatus == SQLITE_OK) {
        isOpenDataBase = YES;
        return YES;
    } else {
        NSLog(@"数据库打开失败：%s", sqlite3_errmsg(dataBase));
        isOpenDataBase = NO;
        return NO;
    }
}

- (void)closeSQLite
{
    if (isOpenDataBase) {
        // 关闭数据库
        isOpenDataBase = NO;
        int execStatus = sqlite3_close(dataBase);
        if (execStatus == SQLITE_OK) {
        } else {
            NSLog(@"数据库关闭失败：%s", sqlite3_errmsg(dataBase));
        }
    }
}

int callback(void *param, int f_num, char **f_value, char **f_name)
{
    printf("%s:这是回调函数!\n", __FUNCTION__);
    return 0;
}

- (BOOL)executeSQLite:(NSString *)sqlString
{
    BOOL result = NO;
    @synchronized (self) {
        if ([self isValidSQL:sqlString]) {
            if (self.openSQLite) {
                char *errorMsg;
                int execStatus = sqlite3_exec(dataBase, sqlString.UTF8String, callback, NULL, &errorMsg);
                if (execStatus == SQLITE_OK) {
                    result = YES;
                } else {
                    NSLog(@"[%@]执行失败：%s", [sqlString substringToIndex:20], errorMsg);
                }
                [self closeSQLite];
            }
        }
    }
    return result;
}

- (NSArray *)selectSQLite:(NSString *)sqlString
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if ([self isValidSQL:sqlString]) {
        if (self.openSQLite) {
            sqlite3_stmt *statement;
            int execStatus = sqlite3_prepare_v2(dataBase, sqlString.UTF8String, -1, &statement, NULL);
            if (execStatus == SQLITE_OK) {
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    // ID, LogTime, LogKey, LogText
                    char *time = (char *)sqlite3_column_text(statement, 1);
                    char *key = (char *)sqlite3_column_text(statement, 2);
                    char *text = (char *)sqlite3_column_text(statement, 3);
                    //
                    NSString *logTime = [[NSString alloc] initWithUTF8String:time];
                    NSString *logKey = [[NSString alloc] initWithUTF8String:key];
                    NSString *logText = [[NSString alloc] initWithUTF8String:text];
                    //
                    NSDictionary *dict = @{@"logTime":logTime, @"logKey":logKey, @"logText":logText};
                    [array addObject:dict];
                }
            }
            // 释放sqlite3_stmt对象资源
            sqlite3_finalize(statement);
            [self closeSQLite];
        }
    }
    return array;
}

@end
