//
//  SYLogFile.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/4/15.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import "SYLogFile.h"
#import <UIKit/UIKit.h>
#import "SYLogSQLite.h"

//static NSString *const logFile = @"SYLogFile.db";

@interface SYLogModel ()

@property (nonatomic, assign) NSString *logTime;
@property (nonatomic, strong) NSString *logText;
@property (nonatomic, strong) NSString *logKey;

@end

@implementation SYLogModel

- (instancetype)initWithlog:(NSString *)text key:(NSString *)key
{
    self = [super init];
    if (self) {
        self.logText = text;
        self.logKey = (key.length > 0 ? key : @"");
        //
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        NSString *time = [formatter stringFromDate:NSDate.date];
        self.logTime = time;
        //
        CGFloat height = [self heightWithText:text];
        self.height = height;
        //
        NSAttributedString *attribute = [self attributeStringWithTime:time text:text key:key];
        self.attributeString = attribute;
    }
    return self;
}

/// 内部使用
- (instancetype)initWithTime:(NSString *)time log:(NSString *)text key:(NSString *)key
{
    self = [super init];
    if (self) {
        self.logText = text;
        self.logKey = (key.length > 0 ? key : @"");
        self.logTime = time;
        //
        CGFloat height = [self heightWithText:text];
        self.height = height;
        //
        NSAttributedString *attribute = [self attributeStringWithTime:time text:text key:key];
        self.attributeString = attribute;
    }
    return self;
}

- (CGFloat)heightWithText:(NSString *)text
{
    CGFloat heigt = heightText;
    if (text && [text isKindOfClass:NSString.class] && text.length > 0) {
        if (7.0 <= [UIDevice currentDevice].systemVersion.floatValue) {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:15], NSParagraphStyleAttributeName:paragraphStyle.copy};
            
            CGSize size = [text boundingRectWithSize:CGSizeMake(widthText, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
            CGFloat heightTmp = size.height;
            heightTmp += 25;
            if (heightTmp < heightText) {
                heightTmp = heightText;
            }
            heigt = heightTmp;
        }
    }
    return heigt;
}

static NSString *const keyStyle = @"--";
- (NSAttributedString *)attributeStringWithTime:(NSString *)time text:(NSString *)text key:(NSString *)key
{
    NSString *string = [NSString stringWithFormat:@"%@ %@ %@\n%@", time, keyStyle, key, text];
    NSMutableAttributedString *logString = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange rang = [string rangeOfString:key];
    if (rang.location == NSNotFound) {
        rang = [string rangeOfString:keyStyle];
    }
    [logString addAttribute:NSForegroundColorAttributeName value:([key isEqualToString:keyCrash] ? UIColor.redColor : UIColor.yellowColor) range:NSMakeRange(0, (rang.location + rang.length))];
    return logString;
}


@end

#pragma mark - 文件管理

@interface SYLogFile ()

//@property (nonatomic, strong) NSString *logPath;
@property (nonatomic, strong) SYLogSQLite *sqlite;

@end

@implementation SYLogFile

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initializeSQLiteTable];
    }
    return self;
}

- (SYLogModel *)logWith:(NSString *)text key:(NSString *)key
{
    @synchronized (self) {
        SYLogModel *model = [[SYLogModel alloc] initWithlog:text key:key];
        [self.logArray addObject:model];
        [self saveLog:model];
        return model;
    };
}

- (void)clear
{
    @synchronized (self) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.logArray removeAllObjects];
            [self deleteLog];
        });
    };
}

- (NSMutableArray *)logArray
{
    if (_logArray == nil) {
        _logArray = [[NSMutableArray alloc] init];
    }
    return _logArray;
}

#pragma mark - 存储

//- (NSString *)logPath
//{
//    if (_logPath == nil) {
//        // doucment
////        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
////        NSString *filePath = [paths objectAtIndex:0];
//        // 缓存
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//        NSString *filePath = [paths objectAtIndex:0];
//
//        _logPath = [filePath stringByAppendingPathComponent:logFile];
//    }
//    return _logPath;
//}

- (SYLogSQLite *)sqlite
{
    if (_sqlite == nil) {
        _sqlite = [[SYLogSQLite alloc] init];
    }
    return _sqlite;
}

- (void)initializeSQLiteTable
{
    NSString *sql = @"CREATE TABLE IF NOT EXISTS SYLogRecord(ID INT TEXTPRIMARY KEY, LogTime TEXT, LogKey TEXT, LogText TEXT NO NULL)";
    [self.sqlite createSQLiteTable:sql];
    
//    // ID, LogTime, LogKey, LogText
//    NSString *sql = @"CREATE TABLE IF NOT EXISTS SYLogRecord(ID INT TEXTPRIMARY KEY, LogTime TEXT, LogKey TEXT, LogText TEXT NO NULL)";
//    if (sql && 0 != sql.length) {
//        if (![NSFileManager.defaultManager fileExistsAtPath:self.logPath]) {
//            // 打开数据库
//            sqlite3 *dataBase; // sqlite3
//            const char *fileName = self.logPath.UTF8String; // [xxx UTF8String]是将NSString转换为C字符串，因为SQLite3是采用可移植的C(而不是            Objective-C)编写的，它不知道什么是NSString.
//            int openStatus = sqlite3_open(fileName, &dataBase);
//            if (openStatus != SQLITE_OK) {
//                // 数据库打开失败，关闭数据库
//                sqlite3_close(dataBase);
//                NSAssert(0, @"打开数据库失败");
//            }
//
//            NSLog(@"打开数据库成功");
//
//            // 创建表
//            char *errorMsg;
//            const char *execSql = sql.UTF8String;
//            int execStatus = sqlite3_exec(dataBase, execSql, NULL, NULL, &errorMsg);
//            if (execStatus != SQLITE_OK) {
//                // 创建表失败，关闭数据库
//                sqlite3_close(dataBase);
//                NSAssert1(0, @"创建表失败：%s", errorMsg);
//                [self logWith:[NSString stringWithUTF8String:sqlite3_errmsg(dataBase)] key:@"创建表"];
//            }
//            NSLog(@"创建表成功");
//        }
//    }
}

- (void)saveLog:(SYLogModel *)model
{
    if (model == nil) {
        NSLog(@"没有数据");
        return;
    }
    
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO SYLogRecord(ID, LogTime, LogKey, LogText) VALUES (NULL, %@, %@, %@)", model.logTime, model.logKey, model.logText];
    [self.sqlite insertSQLite:sql];
    
    /*
    // ?号表示一个未定的值
    NSString *sql = @"INSERT OR REPLACE INTO SYLogRecord(ID, LogTime, LogKey, LogText) VALUES (NULL, ?, ?, ?)";
    if (sql && 0 != sql.length) {
        if ([NSFileManager.defaultManager fileExistsAtPath:self.logPath]) {
            // 打开数据库
            sqlite3 *dataBase; // sqlite3
            const char *fileName = self.logPath.UTF8String;
            int openStatus = sqlite3_open(fileName, &dataBase);
            if (openStatus != SQLITE_OK) {
                // 数据库打开失败，关闭数据库
                sqlite3_close(dataBase);
                NSAssert(0, @"打开数据库失败");
                
                NSLog(@"打开数据库失败");
            }
            
            NSLog(@"打开数据库成功");
            
            const char *execSql = sql.UTF8String;
            sqlite3_stmt *statment;
            int execStatus = sqlite3_prepare_v2(dataBase, execSql, -1, &statment, nil); // 接口把一条SQL语句解析到statement结构里去. 使用该接口访问数据库是当前比较好的的一种方法
            if (execStatus == SQLITE_OK) {
                NSLog(@"1 插入更新表成功");
                
                // 绑定参数开始 这里的数字1，2，3代表上面的第几个问号，这里将三个值绑定到三个绑定变量
                sqlite3_bind_text(statment, 1, model.logTime.UTF8String, -1, NULL);
                sqlite3_bind_text(statment, 2, model.logKey.UTF8String, -1, NULL);
                sqlite3_bind_text(statment, 3, model.logText.UTF8String, -1, NULL);
                
                // 执行SQL语句 执行插入
                if (sqlite3_step(statment) != SQLITE_DONE) {
                    [self logWith:[NSString stringWithUTF8String:sqlite3_errmsg(dataBase)] key:@"插入数据"];
                    NSAssert(NO, @"2 插入更新表失败。");
                } else {
                    NSLog(@"3 插入更新表成功");
                }
            } else {
                NSLog(@"4 插入更新表失败");
                [self logWith:[NSString stringWithUTF8String:sqlite3_errmsg(dataBase)] key:@"插入数据"];
            }
            
            // 释放sqlite3_stmt对象资源
            sqlite3_finalize(statment);
            
            // 关闭数据库
            sqlite3_close(dataBase);
        }
    }
    */
    
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
}

- (void)deleteLog
{
    NSString *sql = @"DROP TABLE SYLogRecord";
    [self.sqlite dropSQLiteTable:sql];
    
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
}

- (void)read
{
    NSString *sql = @"SELECT * FROM SYLogRecord";
    [self.sqlite selectSQLite:sql];
    
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
}

@end
