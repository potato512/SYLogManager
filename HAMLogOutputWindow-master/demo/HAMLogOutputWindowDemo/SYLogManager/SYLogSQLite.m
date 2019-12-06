//
//  SYLogSQLite.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/12/6.
//  Copyright © 2019 Find the Lamp Studio. All rights reserved.
//

#import "SYLogSQLite.h"
#import <sqlite3.h>

static NSString *const logFile = @"SYLogFile.db";

@interface SYLogSQLite ()
{
    // 数据库
    sqlite3 *dataBase;
    BOOL isOpenDataBase;
}

@property (nonatomic, strong) NSString *filePath;

@end

@implementation SYLogSQLite

- (instancetype)init
{
    self = [super init];
    if (self) {
        
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
        // doucment
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
//        NSString *filePath = [paths objectAtIndex:0];
        // 缓存
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _filePath = [paths objectAtIndex:0];
        _filePath = [_filePath stringByAppendingPathComponent:logFile];
    }
    return _filePath;
}

- (BOOL)openSQLite
{
    const char *fileName = self.filePath.UTF8String;
    int execStatus = sqlite3_open(fileName, &dataBase);
    if (execStatus == SQLITE_OK) {
        NSLog(@"数据库打开成功 >>>");
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
            NSLog(@"<<< 数据库关闭成功");
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
                    NSLog(@"[%@]执行失败：%s", sqlString, errorMsg);
                }
                [self closeSQLite];
            }
        }
    }
    return result;
}

- (void)createSQLiteTable:(NSString *)sqlString
{
    if ([self executeSQLite:sqlString]) {
        NSLog(@"数据库创建表成功");
    } else {
        NSLog(@"数据库创建表失败：%s", sqlite3_errmsg(dataBase));
    }
}

- (void)dropSQLiteTable:(NSString *)sqlString
{
    if ([self executeSQLite:sqlString]) {
        NSLog(@"数据库删除表成功");
    } else {
        NSLog(@"数据库删除表失败：%s", sqlite3_errmsg(dataBase));
    }
}

- (void)insertSQLite:(NSString *)sqlString
{
    if ([self executeSQLite:sqlString]) {
        NSLog(@"数据库插入成功");
    } else {
        NSLog(@"数据库插入数据失败：%s", sqlite3_errmsg(dataBase));
    }
}

- (void)updateSQLite:(NSString *)sqlString
{
    if ([self executeSQLite:sqlString]) {
        NSLog(@"数据库更新数据成功");
    } else {
        NSLog(@"数据库更新数据失败：%s", sqlite3_errmsg(dataBase));
    }
}

- (void)deleteSQLite:(NSString *)sqlString
{
    if ([self executeSQLite:sqlString]) {
        NSLog(@"数据库删除数据成功");
    } else {
        NSLog(@"数据库删除数据失败：%s", sqlite3_errmsg(dataBase));
    }
}

- (void)selectSQLite:(NSString *)sqlString
{
    if ([self executeSQLite:sqlString]) {
        NSLog(@"数据库查找数据成功");
    } else {
        NSLog(@"数据库查找数据失败：%s", sqlite3_errmsg(dataBase));
    }
}

//- (void)saveLog:(SYLogModel *)model
//{
//    if (model == nil) {
//        NSLog(@"没有数据");
//        return;
//    }
//    /*
//     // ?号表示一个未定的值
//     NSString *sql = @"INSERT OR REPLACE INTO SYLogRecord(ID, LogTime, LogKey, LogText) VALUES (NULL, ?, ?, ?)";
//     if (sql && 0 != sql.length) {
//     if ([NSFileManager.defaultManager fileExistsAtPath:self.logPath]) {
//     // 打开数据库
//     sqlite3 *dataBase; // sqlite3
//     const char *fileName = self.logPath.UTF8String;
//     int openStatus = sqlite3_open(fileName, &dataBase);
//     if (openStatus != SQLITE_OK) {
//     // 数据库打开失败，关闭数据库
//     sqlite3_close(dataBase);
//     NSAssert(0, @"打开数据库失败");
//
//     NSLog(@"打开数据库失败");
//     }
//
//     NSLog(@"打开数据库成功");
//
//     const char *execSql = sql.UTF8String;
//     sqlite3_stmt *statment;
//     int execStatus = sqlite3_prepare_v2(dataBase, execSql, -1, &statment, nil); // 接口把一条SQL语句解析到statement结构里去. 使用该接口访问数据库是当前比较好的的一种方法
//     if (execStatus == SQLITE_OK) {
//     NSLog(@"1 插入更新表成功");
//
//     // 绑定参数开始 这里的数字1，2，3代表上面的第几个问号，这里将三个值绑定到三个绑定变量
//     sqlite3_bind_text(statment, 1, model.logTime.UTF8String, -1, NULL);
//     sqlite3_bind_text(statment, 2, model.logKey.UTF8String, -1, NULL);
//     sqlite3_bind_text(statment, 3, model.logText.UTF8String, -1, NULL);
//
//     // 执行SQL语句 执行插入
//     if (sqlite3_step(statment) != SQLITE_DONE) {
//     [self logWith:[NSString stringWithUTF8String:sqlite3_errmsg(dataBase)] key:@"插入数据"];
//     NSAssert(NO, @"2 插入更新表失败。");
//     } else {
//     NSLog(@"3 插入更新表成功");
//     }
//     } else {
//     NSLog(@"4 插入更新表失败");
//     [self logWith:[NSString stringWithUTF8String:sqlite3_errmsg(dataBase)] key:@"插入数据"];
//     }
//
//     // 释放sqlite3_stmt对象资源
//     sqlite3_finalize(statment);
//
//     // 关闭数据库
//     sqlite3_close(dataBase);
//     }
//     }
//     */
//
//    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO SYLogRecord(ID, LogTime, LogKey, LogText) VALUES (NULL, %@, %@, %@)", model.logTime, model.logKey, model.logText];
//    if (sql && 0 != sql.length) {
//        if ([NSFileManager.defaultManager fileExistsAtPath:self.logPath]) {
//            // 打开数据库
//            sqlite3 *dataBase; // sqlite3
//            const char *fileName = self.logPath.UTF8String;
//            int openStatus = sqlite3_open(fileName, &dataBase);
//            if (openStatus != SQLITE_OK) {
//                // 数据库打开失败，关闭数据库
//                sqlite3_close(dataBase);
//                NSAssert(0, @"打开数据库失败");
//
//                NSLog(@"打开数据库失败");
//            }
//
//            const char *execSql = sql.UTF8String;
//            int execStatus = sqlite3_exec(dataBase, execSql, callback, 0, &zErrMsg);
//            if( rc != SQLITE_OK ){
//                fprintf(stderr, "SQL error: %s\n", zErrMsg);
//                sqlite3_free(zErrMsg);
//            }else{
//                fprintf(stdout, "Records created successfully\n");
//            }
//            sqlite3_close(dataBase);
//        }
//    }
//
//    sqlite3 *db;
//    char *zErrMsg = 0;
//    int rc;
//    char *sql;
//
//    /* Open database */
//    rc = sqlite3_open("test.db", &db);
//    rc = sqlite3_exec(db, sql, callback, 0, &zErrMsg);
//    if( rc != SQLITE_OK ){
//        fprintf(stderr, "SQL error: %s\n", zErrMsg);
//        sqlite3_free(zErrMsg);
//    }else{
//        fprintf(stdout, "Records created successfully\n");
//    }
//    sqlite3_close(db);
//}
//
//- (void)deleteLog
//{
//    NSString *sql = @"DROP TABLE SYLogRecord";
//    if (sql && 0 != sql.length) {
//        if ([NSFileManager.defaultManager fileExistsAtPath:self.logPath]) {
//            // 打开数据库
//            sqlite3 *dataBase; // sqlite3
//            const char *fileName = self.logPath.UTF8String;
//            int openStatus = sqlite3_open(fileName, &dataBase);
//            if (openStatus != SQLITE_OK) {
//                // 数据库打开失败，关闭数据库
//                sqlite3_close(dataBase);
//                NSAssert(0, @"打开数据库失败");
//
//                NSLog(@"打开数据库失败");
//            }
//
//            NSLog(@"打开数据库成功");
//
//            const char *execSql = sql.UTF8String;
//            sqlite3_stmt *statment;
//            int execStatus = sqlite3_prepare_v2(dataBase, execSql, -1, &statment, nil);
//            if (execStatus == SQLITE_OK) {
//                // 执行删除
//                if (sqlite3_step(statment) != SQLITE_DONE) {
//                    [self logWith:[NSString stringWithUTF8String:sqlite3_errmsg(dataBase)] key:@"删除表"];
//                    NSAssert(NO, @"删除表失败。");
//                    NSLog(@"删除表失败");
//                } else {
//                    NSLog(@"删除表成功");
//                }
//            } else {
//                [self logWith:[NSString stringWithUTF8String:sqlite3_errmsg(dataBase)] key:@"删除表"];
//                NSLog(@"删除表失败");
//            }
//
//            // 释放sqlite3_stmt对象资源
//            sqlite3_finalize(statment);
//
//            // 关闭数据库
//            sqlite3_close(dataBase);
//        }
//    }
//}
//
//- (void)read
//{
//    [self.logArray removeAllObjects];
//    //
//    NSString *sql = @"SELECT * FROM SYLogRecord";
//    if (sql && 0 != sql.length) {
//        if ([NSFileManager.defaultManager fileExistsAtPath:self.logPath]) {
//            // 打开数据库
//            sqlite3 *dataBase; // sqlite3
//            const char *fileName = self.logPath.UTF8String;
//            int openStatus = sqlite3_open(fileName, &dataBase);
//            if (openStatus != SQLITE_OK) {
//                // 数据库打开失败，关闭数据库
//                sqlite3_close(dataBase);
//                NSAssert(0, @"打开数据库失败");
//
//                NSLog(@"打开数据库失败");
//            }
//
//            NSLog(@"打开数据库成功");
//
//            const char *execSql = sql.UTF8String;
//            sqlite3_stmt *statment;
//            int execStatus = sqlite3_prepare_v2(dataBase, execSql, -1, &statment, nil);
//            if (execStatus == SQLITE_OK) {
//                NSLog(@"查询成功");
//
//                // 查询成功，执行遍历操作
//                // 查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值，跟上面sqlite3_bind_text绑定的列值不一样！一定要分开，不然会crash，只有这一处的列号不同，注意！
//                while (sqlite3_step(statment) == SQLITE_ROW) {
//                    NSString *logTime;
//                    NSString *logKey;
//                    NSString *logText;
//                    const char *time = (char *)sqlite3_column_text(statment, 1);
//                    if (time != NULL) {
//                        logTime = [[NSString alloc] initWithUTF8String:time];
//                    }
//
//                    char *key = (char *)sqlite3_column_text(statment, 2);
//                    if (key != NULL) {
//                        logKey = [[NSString alloc] initWithUTF8String:key];
//                    }
//
//                    char *text = (char *)sqlite3_column_text(statment, 3);
//                    if (text != NULL) {
//                        logText = [[NSString alloc] initWithUTF8String:text];
//                    }
//                    SYLogModel *model = [[SYLogModel alloc] initWithTime:logTime log:logText key:logKey];
//                    [self.logArray addObject:model];
//                }
//            } else {
//                [self logWith:[NSString stringWithUTF8String:sqlite3_errmsg(dataBase)] key:@"查数据"];
//                NSLog(@"查询失败");
//            }
//
//            // 释放sqlite3_stmt对象资源
//            sqlite3_finalize(statment);
//
//            // 关闭数据库
//            sqlite3_close(dataBase);
//        }
//    }
//}

@end
