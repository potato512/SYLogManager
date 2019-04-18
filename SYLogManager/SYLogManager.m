//
//  SYLogManager.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2018/10/12.
//  Copyright © 2018年 zhangshaoyu. All rights reserved.
//

#import "SYLogManager.h"
#import "SYLogFile.h"
#import "SYLogView.h"

@interface SYLogManager ()

@property (nonatomic, strong) SYLogFile *logFile;
@property (nonatomic, strong) SYLogView *logView;
@property (nonatomic, strong) NSString *message;

@end

@implementation SYLogManager

#pragma mark - 实例化

+ (instancetype)shareLog
{
    static SYLogManager *logManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logManager = [[self alloc] init];
    });
    return logManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"\n---------log日志管理 %@------------", NSDate.date);
    }
    return self;
}

#pragma mark - 方法

- (void)initializeLog
{
    [self.logFile saveLogMessage];
}

- (void)clearLog
{
    [self.logFile deleteLogMessage];
}

- (void)uploadLogWithUrl:(NSString *)url parameter:(NSDictionary *)dict complete:(void (^)(BOOL, NSString * _Nonnull))complete
{
    BOOL result = NO;
    NSString *str = nil;
    
    if (result) {
        [self clearLog];
    }
    if (complete) {
        complete(result, str);
    }
}

#pragma mark - 读写操作日志

#pragma mark - getter

- (SYLogFile *)logFile
{
    if (_logFile == nil) {
        _logFile = [[SYLogFile alloc] init];
    }
    return _logFile;
}

- (SYLogView *)logView
{
    if (_logView == nil) {
        _logView = [[SYLogView alloc] init];
        //
        SYLogManager __weak *weakLog = self;
        _logView.showClick = ^ {
            [weakLog.logView.activityView startAnimating];
            [weakLog.logFile readLogMessage:^(NSString * _Nonnull message) {
                [weakLog.logView.activityView stopAnimating];
                weakLog.message = message;
                [weakLog.logView showMessage:message];
            }];
            weakLog.logView.clearClick = ^{
                [weakLog.logFile deleteLogMessage];
                [weakLog.logFile saveLogMessage];
            };
        };
    }
    return _logView;
}

- (NSString *)filePath
{
    return self.logFile.filePath;
}

#pragma mark - setter

- (void)setShow:(BOOL)show
{
    self.logView.baseView = self.showView;
    _show = show;
    if (_show) {
        self.logView.showlogView = YES;
    } else {
        self.logView.showlogView = NO;
    }
}

@end
