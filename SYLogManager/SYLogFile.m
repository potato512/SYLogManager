//
//  SYLogFile.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/4/15.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import "SYLogFile.h"
#import <UIKit/UIKit.h>

static NSString *const logFile = @"SYLog.txt";

#pragma mark - 数据格式

@interface SYLogText : NSObject

@property (nonatomic, assign) NSString *logTime;
@property (nonatomic, strong) NSString *logText;
@property (nonatomic, strong) NSString *logKey;

@end

@implementation SYLogText

+ (instancetype)logText:(NSString *)text key:(NSString *)key
{
    SYLogText *log = [SYLogText new];
    log.logText = text;
    log.logKey = (key.length > 0 ? key : @"未设置");
    //
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    NSString *time = [formatter stringFromDate:NSDate.date];
    log.logTime = time;
    //
    return log;
}

// 属性编码 向coder中写入数据
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.logTime forKey:@"logTime"];
    [aCoder encodeObject:self.logText forKey:@"logText"];
    [aCoder encodeObject:self.logKey forKey:@"logKey"];
}

// 属性解码 读取coder中的数据
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.logTime = [aDecoder decodeObjectForKey:@"logTime"];
        self.logText = [aDecoder decodeObjectForKey:@"logText"];
        self.logKey = [aDecoder decodeObjectForKey:@"logKey"];
    }
    return self;
}

@end

#pragma mark - 文件管理

@interface SYLogFile ()

@property (nonatomic, strong) NSMutableArray *logArray;

@end

@implementation SYLogFile

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - 日志操作

- (void)saveLogMessage
{
    if (self.isEnable) {
        
    } else {
        // 联调调试不保存
        if (isatty(STDOUT_FILENO)) {
            return;
        }
        // 模拟器不保存
        if ([UIDevice.currentDevice.model hasPrefix:@"Simulator"]) {
            return;
        }
    }
    
    NSLog(@"\n---------log日志管理 %@------------", NSDate.date);
    // 输入到文件
    // log信息
    freopen([self.filePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    // 错误信息
    freopen([self.filePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr); 
}

- (void)readLogMessage:(void (^)(NSString *message))complete
{
    // 读取的内容
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *string = [[NSString alloc] initWithContentsOfFile:self.filePath encoding:NSUTF8StringEncoding error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete(string);
                }
            });
        });
    } else {
        if (complete) {
            complete(nil);
        }
    }
    
}

- (void)deleteLogMessage
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
    }
}

#pragma mark - getter

- (NSString *)filePath
{
    if (_filePath == nil) {
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *string = array.firstObject;
        string = [string stringByAppendingPathComponent:logFile];
        _filePath = [NSString stringWithString:string];
    }
    return _filePath;
}




- (void)save:(NSString *)text
{
    [self save:text key:@""];
}

- (void)save:(NSString *)text key:(NSString *)key
{
    @synchronized (self) {
        SYLogText *model = [SYLogText logText:text key:key];
        [self.logArray addObject:model];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL result = [self.logArray writeToFile:self.filePath atomically:NO];
            NSLog(@"log日志保存：%@", (result ? @"成功" : @"失败"));
        });
    };
}

- (void)read:(void (^)(NSAttributedString *text))complete
{
    @synchronized (self) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableAttributedString *attributedText = [NSMutableAttributedString new];
            for (SYLogText *model in self.logArray) {
                NSString *string = [NSString stringWithFormat:@"%@ -- %@\n%@", model.logTime, model.logKey, model.logText];
                NSMutableAttributedString *logString = [[NSMutableAttributedString alloc] initWithString:string];
                NSRange rang = [string rangeOfString:model.logKey];
                [logString addAttribute:NSForegroundColorAttributeName value:(self.colorTime ? : UIColor.yellowColor) range:NSMakeRange(0, (rang.location + rang.length))];
                [attributedText appendAttributedString:logString];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete(attributedText);
                }
            });
        });
    };
}

- (void)clear
{
    @synchronized (self) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.logArray removeAllObjects];
            if ([NSFileManager.defaultManager isExecutableFileAtPath:self.filePath]) {
                BOOL result = [NSFileManager.defaultManager removeItemAtPath:self.filePath error:nil];
                NSLog(@"log日志删除：%@", (result ? @"成功" : @"失败"));
            }
        });
    };
}

- (NSMutableArray *)logArray
{
    if (_logArray == nil) {
        _logArray = [[NSMutableArray alloc] init];
        // 默认加载本地
        if ([NSFileManager.defaultManager isExecutableFileAtPath:self.filePath]) {
            NSArray *array = [NSArray arrayWithContentsOfFile:self.filePath];
            [_logArray addObjectsFromArray:array];
        }
    }
    return _logArray;
}

@end
