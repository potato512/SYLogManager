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

@interface SYLogFile ()

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
    // 联调调试不保存
    if (isatty(STDOUT_FILENO)) {
        return;
    }
    // 模拟器不保存
    if ([UIDevice.currentDevice.model hasPrefix:@"Simulator"]) {
        return;
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
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *string = array.firstObject;
        string = [string stringByAppendingPathComponent:logFile];
        _filePath = [NSString stringWithString:string];
    }
    return _filePath;
}

@end
