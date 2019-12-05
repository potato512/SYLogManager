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

@property (nonatomic, strong) UIView *buttonView;

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
        UIView *view = UIApplication.sharedApplication.delegate.window;
        self.frame = view.bounds;
        [view addSubview:self];
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        self.userInteractionEnabled = NO;
        //
        [self addSubview:self.logView];
        //
        [view addSubview:self.buttonView];
        
        self.hidden = YES;
        self.buttonView.hidden = YES;
    }
    return self;
}


- (UIView *)buttonView
{
    if (_buttonView == nil) {
        _buttonView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 210, 50)];
        _buttonView.backgroundColor = UIColor.yellowColor;
        UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"可点", @"不可", @"隐藏", @"显示", @"清除"]];
        segment.frame = _buttonView.bounds;
        segment.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [_buttonView addSubview:segment];
        [segment addTarget:self action:@selector(segmentClick:) forControlEvents:UIControlEventValueChanged];
        // 添加拖动手势
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognizerAction:)];
        [_buttonView addGestureRecognizer:panRecognizer];
    }
    return _buttonView;
}

- (void)segmentClick:(UISegmentedControl *)segment
{
    NSInteger index = segment.selectedSegmentIndex;
    if (index == 0) {
        self.userInteractionEnabled = NO;
    } else if (index == 1) {
        self.userInteractionEnabled = YES;
    } else if (index == 2) {
        self.hidden = YES;
        [self.superview sendSubviewToBack:self];
    } else if (index == 3) {
        self.hidden = NO;
        [self.superview bringSubviewToFront:self];
        [self.superview bringSubviewToFront:self.buttonView];
    } else if (index == 4) {
        [self logClear];
    }
}

// 拖动手势方法
- (void)panRecognizerAction:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {

    } else {
        // 拖动视图
        UIView *view = (UIView *)recognizer.view;
        [self.superview bringSubviewToFront:view];
        
        CGPoint translation = [recognizer translationInView:view.superview];
        CGFloat centerX = view.center.x + translation.x;
        if (centerX < view.frame.size.width / 2) {
            centerX = view.frame.size.width / 2;
        } else if (centerX > view.superview.frame.size.width - view.frame.size.width / 2) {
            centerX = view.superview.frame.size.width - view.frame.size.width / 2;
        }
        CGFloat centerY = view.center.y + translation.y;
        if (centerY < (view.frame.size.height / 2)) {
            centerY = (view.frame.size.height / 2);
        } else if (centerY > view.superview.frame.size.height - view.frame.size.height / 2) {
            centerY = view.superview.frame.size.height - view.frame.size.height / 2;
        }
        view.center = CGPointMake(centerX, centerY);
        [recognizer setTranslation:CGPointZero inView:view];
    }
}




- (void)configLog
{
    NSSetUncaughtExceptionHandler(&readException);
    [self.logFile read];
    self.logView.array = self.logFile.logArray;
}

#pragma mark - log处理

- (void)logText:(NSString *)text
{
    [self logText:text key:@""];
}

- (void)logText:(NSString *)text key:(NSString *)key
{
    SYLogModel *model = [self.logFile logWith:text key:key];
    [self.logView logModel:model];
}

- (void)logClear
{
    [self.logFile clear];
    self.logView.array = self.logFile.logArray;
}

#pragma mark - 异常

// 获得异常的C函数
void readException(NSException *exception)
{
    // 设备信息
    NSString *deviceModel = [NSString stringWithFormat:@"设备类型：%@", UIDevice.currentDevice.model];
    NSString *deviceSystem = [NSString stringWithFormat:@"设备系统：%@", UIDevice.currentDevice.systemName];
    NSString *deviceVersion = [NSString stringWithFormat:@"设备系统版本：%@", UIDevice.currentDevice.systemVersion];
    NSString *deviceName = [NSString stringWithFormat:@"设备名称：%@", UIDevice.currentDevice.name];
    NSString *batteryState = @"UIDeviceBatteryStateUnknown";
    switch (UIDevice.currentDevice.batteryState) {
        case UIDeviceBatteryStateUnknown: batteryState = @"UIDeviceBatteryStateUnknown"; break;
        case UIDeviceBatteryStateUnplugged: batteryState = @"UIDeviceBatteryStateUnplugged"; break;
        case UIDeviceBatteryStateCharging: batteryState = @"UIDeviceBatteryStateCharging"; break;
        case UIDeviceBatteryStateFull: batteryState = @"UIDeviceBatteryStateFull"; break;
        default: break;
    }
    NSString *deviceBatteryState = [NSString stringWithFormat:@"设备电池：%@", batteryState];
    NSString *deviceBattery = [NSString stringWithFormat:@"设备量：%f", UIDevice.currentDevice.batteryLevel];
    // 应用信息
    NSString *appName = [NSString stringWithFormat:@"应用名称：%@", [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleDisplayName"]];
    NSString *appVersion = [NSString stringWithFormat:@"应用版本：%@", [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    // 异常信息
    NSString *errorName = [NSString stringWithFormat:@"异常名称：%@", exception.name];
    NSString *errorReason = [NSString stringWithFormat:@"异常原因：%@",exception.reason];
    NSString *errorUser = [NSString stringWithFormat:@"用户信息：%@",exception.userInfo];
    NSString *errorAddress = [NSString stringWithFormat:@"栈内存地址：%@",exception.callStackReturnAddresses];
    NSArray *symbols = exception.callStackSymbols;
    NSMutableString *errorSymbol = [[NSMutableString alloc] initWithString:@"异常描述："];
    for (NSString *item in symbols) {
        [errorSymbol appendString:@"\r\n"];
        [errorSymbol appendString:item];
    }
    [errorSymbol appendString:@"\n"];
    //
    NSArray *array = @[deviceModel, deviceSystem, deviceVersion, deviceName, deviceBatteryState, deviceBattery, appName, appVersion, errorName, errorReason, errorUser, errorAddress, errorSymbol];
    NSMutableString *crashString = [[NSMutableString alloc] init];
    for (NSString *string in array) {
        [crashString appendString:string];
        [crashString appendString:@"\n"];
    }
    NSLog(@"%@", crashString);
    [SYLogManager.shareLog logText:crashString key:@"闪退"];
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

- (void)setShow:(BOOL)show
{
    _show = show;
    self.buttonView.hidden = !_show;
    if (self.buttonView.hidden) {
        [self.superview sendSubviewToBack:self.buttonView];
    } else {
        [self.superview bringSubviewToFront:self.buttonView];
    }
}

@end
