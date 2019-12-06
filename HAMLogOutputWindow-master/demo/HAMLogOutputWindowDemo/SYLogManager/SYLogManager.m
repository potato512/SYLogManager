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
//
@property (nonatomic, strong) UIView *baseView;
//
@property (nonatomic, strong) UIButton *logButton;
@property (nonatomic, strong) UIView *logButtonView;

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
        self.baseView = UIApplication.sharedApplication.delegate.window;
    }
    return self;
}

- (void)configLog
{
    NSSetUncaughtExceptionHandler(&readException);
    [self.logFile read];
    self.logView.array = self.logFile.logArray;
}

#pragma mark - 菜单视图

- (UIButton *)logButton
{
    if (_logButton == nil) {
        CGFloat size = 60.0;
        _logButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 20.0, size, size)];
        _logButton.layer.cornerRadius = _logButton.frame.size.width / 2;
        _logButton.layer.masksToBounds = YES;
        _logButton.layer.borderColor = UIColor.redColor.CGColor;
        _logButton.layer.borderWidth = 3.0;
        _logButton.backgroundColor = [UIColor.redColor colorWithAlphaComponent:0.3];
        [_logButton setTitle:@"log日志" forState:UIControlStateNormal];
        _logButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_logButton setTitleColor:UIColor.yellowColor forState:UIControlStateNormal];
        [_logButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
        [_logButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
        // 添加拖动手势
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognizerAction:)];
        _logButton.userInteractionEnabled = YES;
        [_logButton addGestureRecognizer:panRecognizer];
        //
        [self.baseView addSubview:_logButton];
        [self.baseView bringSubviewToFront:_logButton];
    }
    return _logButton;
}

- (void)showMenu:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        self.logButtonView.hidden = NO;
        [self.baseView bringSubviewToFront:self.logButtonView];
    } else {
        self.logButtonView.hidden = YES;
        [self.baseView sendSubviewToBack:self.logButtonView];
    }
}

- (UIView *)logButtonView
{
    if (_logButtonView == nil) {
        _logButtonView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, (self.logButton.frame.size.height * 2 + 20 * 2), self.logButton.frame.size.height)];
        _logButtonView.layer.cornerRadius = _logButton.frame.size.width / 2;
        _logButtonView.layer.masksToBounds = YES;
        _logButtonView.layer.borderColor = UIColor.redColor.CGColor;
        _logButtonView.layer.borderWidth = 3.0;
        _logButtonView.backgroundColor = [UIColor.redColor colorWithAlphaComponent:0.3];
        [self.baseView addSubview:_logButtonView];
        _logButtonView.hidden = YES;
        //
        UIButton *hideButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, _logButtonView.frame.size.height, _logButtonView.frame.size.height)];
        [_logButtonView addSubview:hideButton];
        hideButton.layer.cornerRadius = hideButton.frame.size.width / 2;
        hideButton.layer.masksToBounds = YES;
        [hideButton setTitle:@"显示" forState:UIControlStateNormal];
        [hideButton setTitle:@"隐藏" forState:UIControlStateSelected];
        [hideButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [hideButton addTarget:self action:@selector(hideButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *enableButton = [[UIButton alloc] initWithFrame:CGRectMake((hideButton.frame.origin.x + hideButton.frame.size.width + 20), 0, _logButtonView.frame.size.height, _logButtonView.frame.size.height)];
        [_logButtonView addSubview:enableButton];
        enableButton.layer.cornerRadius = hideButton.frame.size.width / 2;
        enableButton.layer.masksToBounds = YES;
        [enableButton setTitle:@"允许" forState:UIControlStateNormal];
        [enableButton setTitle:@"禁止" forState:UIControlStateSelected];
        [enableButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [enableButton addTarget:self action:@selector(enableButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _logButtonView;
}

- (void)hideButtonClick:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        self.logView.hidden = NO;
        [self.baseView bringSubviewToFront:self.logView];
        [self.baseView bringSubviewToFront:self.logButton];
        [self.baseView bringSubviewToFront:self.logButtonView];
    } else {
        self.logView.hidden = YES;
        [self.baseView sendSubviewToBack:self.logView];
    }
}

- (void)enableButtonClick:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        self.logView.userInteractionEnabled = YES;
    } else {
        self.logView.userInteractionEnabled = NO;
    }
}

// 拖动手势方法
- (void)panRecognizerAction:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {

    } else {
        // 拖动视图
        UIView *view = (UIView *)recognizer.view;
        [self.baseView bringSubviewToFront:view];
        
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

#pragma mark - log处理

- (void)logText:(NSString *)text
{
    [self logText:text key:@""];
}

- (void)logText:(NSString *)text key:(NSString *)key
{
    SYLogModel *model = [self.logFile logWith:text key:key];
//    [self.logView logModel:model];
    self.logView.array = self.logFile.logArray;
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
        [errorSymbol appendString:@"\n"];
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
    [SYLogManager.shareLog logText:crashString key:keyCrash];
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
        _logView = [[SYLogView alloc] initWithFrame:self.baseView.bounds style:UITableViewStylePlain];
        [self.baseView addSubview:_logView];
        _logView.userInteractionEnabled = NO;
        _logView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        _logView.hidden = YES;

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
//    self.buttonView.hidden = !_show;
//    if (self.buttonView.hidden) {
//        [self.baseView sendSubviewToBack:self.buttonView];
//    } else {
//        [self.baseView bringSubviewToFront:self.buttonView];
//    }
    
    self.logButton.hidden = !_show;
    if (self.logButton.hidden) {
        [self.baseView sendSubviewToBack:self.logButton];
    } else {
        [self.baseView bringSubviewToFront:self.logButton];
    }
}

@end
