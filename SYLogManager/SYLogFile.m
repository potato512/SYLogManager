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
#import <pthread/pthread.h>

/// 最多N条记录
static NSInteger const logMaxCount = 1000;

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
        self.logKey = ([key isKindOfClass:NSString.class] && (key.length > 0)) ? key : @"";
        //
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        NSString *time = [formatter stringFromDate:NSDate.date];
        self.logTime = time;
        //
        CGFloat height = [self heightWithText:text];
        self.height = height;
        //
        NSAttributedString *attribute = [self attributeStringWithTime:self.logTime text:self.logText key:self.logKey];
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
    if ([key isEqualToString:@"crash闪退奔溃"]) {
        [logString addAttribute:NSForegroundColorAttributeName value:UIColor.redColor range:NSMakeRange(0, string.length)];
    } else {
        [logString addAttribute:NSForegroundColorAttributeName value:([key isEqualToString:@"打开应用"] ? UIColor.greenColor : UIColor.yellowColor) range:NSMakeRange(0, (rang.location + rang.length))];
    }
    
    return logString;
}

@end

#pragma mark - 文件管理

@interface SYLogFile ()
{
    pthread_mutex_t mutexLock;
}

@property (nonatomic, strong) SYLogSQLite *sqlite;
/// 默认保存N条记录，超过则自动删除
@property (nonatomic, strong) NSMutableArray *logArray;

@end

@implementation SYLogFile

- (instancetype)init
{
    self = [super init];
    if (self) {
        pthread_mutex_init(&mutexLock, NULL);
        
        [self initializeSQLiteTable];
    }
    return self;
}

- (void)dealloc
{
    pthread_mutex_destroy(&mutexLock);
}

- (SYLogModel *)logWith:(NSString *)text key:(NSString *)key
{
    pthread_mutex_lock(&mutexLock);
    if (self.logArray.count >= (logMaxCount - 1)) {
        [self.logArray removeObjectAtIndex:0];
    }
    SYLogModel *model = [[SYLogModel alloc] initWithlog:text key:key];
    [self.logArray addObject:model];
    [self saveLog:model];
    pthread_mutex_unlock(&mutexLock);
    
    return self.logArray.lastObject;
}

- (void)clear
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        pthread_mutex_lock(&self->mutexLock);
        if (self.logArray.count > 0) {
            [self.logArray removeAllObjects];
            [self deleteLog];
        }
        pthread_mutex_unlock(&self->mutexLock);
    });
}

#pragma mark - setter/getter

- (NSMutableArray *)logArray
{
    if (_logArray == nil) {
        _logArray = [[NSMutableArray alloc] init];
    }
    return _logArray;
}

- (NSArray *)logs
{
    pthread_mutex_lock(&mutexLock);
    NSArray *arrayTmp = [NSArray arrayWithArray:self.logArray];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (SYLogModel *model in arrayTmp) {
        [array insertObject:model atIndex:0];
    }
    pthread_mutex_unlock(&mutexLock);
    return array;
}

#pragma mark - 存储

- (SYLogSQLite *)sqlite
{
    if (_sqlite == nil) {
        _sqlite = [[SYLogSQLite alloc] init];
    }
    return _sqlite;
}

- (void)initializeSQLiteTable
{
    // // ID, LogTime, LogKey, LogText
    NSString *sql = @"CREATE TABLE IF NOT EXISTS SYLogRecord(ID INT TEXTPRIMARY KEY, LogTime TEXT, LogKey TEXT, LogText TEXT NO NULL)";
    [self.sqlite executeSQLite:sql];
}

- (void)saveLog:(SYLogModel *)model
{
    if (model == nil) {
        NSLog(@"没有数据");
        return;
    }
    
    // ID, LogTime, LogKey, LogText
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO SYLogRecord (ID, LogTime, LogKey, LogText) VALUES (NULL, '%@', '%@', '%@')", model.logTime, model.logKey, model.logText];
    [self.sqlite executeSQLite:sql];
}

- (void)deleteLog
{
    NSString *sql = @"DELETE FROM SYLogRecord";
    [self.sqlite executeSQLite:sql];
}

- (void)read
{
    pthread_mutex_lock(&mutexLock);
    NSString *sql = @"SELECT * FROM SYLogRecord";
    NSArray *array = [self.sqlite selectSQLite:sql];
    [self.logArray removeAllObjects];
    NSMutableArray *logTmp = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in array) {
        NSString *logTime = dict[@"logTime"];
        NSString *logKey = dict[@"logKey"];
        NSString *logText = dict[@"logText"];
        SYLogModel *model = [[SYLogModel alloc] initWithTime:logTime log:logText key:logKey];
        [logTmp addObject:model];
    }
    //
    NSInteger number = logTmp.count;
    // 超过N条时删除
    if (number >= logMaxCount) {
        NSInteger numberDel = (number - logMaxCount - 1);
        for (NSInteger index = 0; index < numberDel; index++) {
            // 超过N条时，删除数据库记录
            SYLogModel *model = logTmp.firstObject;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *sql = [NSString stringWithFormat:@"DELETE FROM SYLogRecord WHERE logText = '%@'", model.logText];
                [self.sqlite executeSQLite:sql];
            });
            
            [logTmp removeObjectAtIndex:0];
        }
    }
    [self.logArray addObjectsFromArray:logTmp];
    pthread_mutex_unlock(&mutexLock);
}

@end
