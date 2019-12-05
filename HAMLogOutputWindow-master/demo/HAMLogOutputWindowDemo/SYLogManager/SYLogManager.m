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
#import <MessageUI/MessageUI.h>

@interface SYLogManager () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) SYLogFile *logFile;
@property (nonatomic, strong) SYLogView *logView;

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
    self = [super initWithFrame:UIScreen.mainScreen.bounds];
    if (self) {
        self.rootViewController = [UIViewController new]; // suppress warning
        self.windowLevel = UIWindowLevelAlert;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        self.userInteractionEnabled = NO;
        //
        [self addSubview:self.logView];
    }
    return self;
}

- (void)logWithText:(NSString *)text
{
    [self logWithText:text key:@""];
}

- (void)logWithText:(NSString *)text key:(NSString *)key
{
    [self.logFile printLog:text key:key];
    self.logView.array = self.logFile.logArray;
}

- (void)logWhileClear
{
    [self.logFile clear];
    self.logView.array = self.logFile.logArray;
}

#pragma mark - log处理

+ (void)logText:(NSString *)text
{
    [SYLogManager logText:text key:@""];
}

+ (void)logText:(NSString *)text key:(NSString *)key
{
    [SYLogManager.shareLog logWithText:text key:key];
}

+ (void)logClear
{
    [SYLogManager.shareLog logWhileClear];
}

+ (void)show
{
    SYLogManager.shareLog.hidden = NO;
}

+ (void)hide
{
    SYLogManager.shareLog.hidden = YES;
}

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
        _logView = [[SYLogView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _logView.backgroundColor = [UIColor clearColor];
    }
    return _logView;
}

#pragma mark - setter

- (void)setColorLog:(UIColor *)colorLog
{
    _colorLog = colorLog;
    self.logView.colorLog = _colorLog;
}

@end
