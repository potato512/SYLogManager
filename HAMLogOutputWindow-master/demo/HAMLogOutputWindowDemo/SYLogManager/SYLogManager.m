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

static CGFloat const originButton = 20.0;
static CGFloat const sizeButton = 60.0;
#define widthButton (self.logButton.frame.size.height * 3 + originButton)

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
    //
    [self logText:[NSString stringWithFormat:@"打开使用[%@--V %@]", [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleDisplayName"], [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"]] key:@"打开应用"];
}

#pragma mark - 菜单视图

- (UIButton *)logButton
{
    if (_logButton == nil) {
        _logButton = [[UIButton alloc] initWithFrame:CGRectMake(originButton, originButton, sizeButton, sizeButton)];
        _logButton.layer.cornerRadius = _logButton.frame.size.width / 2;
        _logButton.layer.masksToBounds = YES;
        _logButton.layer.borderColor = UIColor.redColor.CGColor;
        _logButton.layer.borderWidth = 3.0;
        _logButton.backgroundColor = [UIColor.redColor colorWithAlphaComponent:0.3];
        [_logButton setTitle:@"查看\n日志" forState:UIControlStateNormal];
        _logButton.titleLabel.numberOfLines = 2;
        _logButton.titleLabel.font = [UIFont systemFontOfSize:15];
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
        [self showLogButtonView];
    } else {
        [self hideLogButtonView];
    }
}

- (void)showLogButtonView
{
    CGFloat originX = (self.logButton.frame.origin.x + self.logButton.frame.size.width);
    __block CGRect rect = self.logButtonView.frame;
    rect.origin.x = originX;
    if ((originX + widthButton) > self.baseView.frame.size.width) {
        rect.origin.x = (self.logButton.frame.origin.x - widthButton);
    }
    rect.origin.y = self.logButton.frame.origin.y;
    self.logButtonView.frame = rect;
    //
    self.logButtonView.hidden = NO;
    [self.baseView bringSubviewToFront:self.logButtonView];
    // 动画
    self.logButtonView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.logButtonView.alpha = 1;
    }];
}
- (void)hideLogButtonView
{
    if (self.logButtonView.hidden) {
        return;
    }
    // 动画
    [UIView animateWithDuration:0.3 animations:^{
        self.logButtonView.alpha = 0;
    } completion:^(BOOL finished) {
        self.logButtonView.hidden = YES;
        [self.baseView sendSubviewToBack:self.logButtonView];
    }];
}


- (UIView *)logButtonView
{
    if (_logButtonView == nil) {
        _logButtonView = [[UIView alloc] initWithFrame:CGRectMake(originButton, originButton, widthButton, sizeButton)];
        _logButtonView.layer.cornerRadius = _logButton.frame.size.width / 2;
        _logButtonView.layer.masksToBounds = YES;
        _logButtonView.layer.borderColor = UIColor.yellowColor.CGColor;
        _logButtonView.layer.borderWidth = 3.0;
        _logButtonView.backgroundColor = [UIColor.redColor colorWithAlphaComponent:0.3];
        [self.baseView addSubview:_logButtonView];
        _logButtonView.hidden = YES;
        //
        UIButton *hideButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, sizeButton, sizeButton)];
        [_logButtonView addSubview:hideButton];
        hideButton.layer.cornerRadius = hideButton.frame.size.width / 2;
        hideButton.layer.masksToBounds = YES;
        hideButton.backgroundColor = [UIColor.yellowColor colorWithAlphaComponent:0.4];
        hideButton.titleLabel.numberOfLines = 2;
        hideButton.titleLabel.font = [UIFont systemFontOfSize:13];
        hideButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [hideButton setTitle:@"显示\nlog" forState:UIControlStateNormal];
        [hideButton setTitle:@"隐藏\nlog" forState:UIControlStateSelected];
        [hideButton setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        [hideButton setTitleColor:UIColor.darkGrayColor forState:UIControlStateSelected];
        [hideButton addTarget:self action:@selector(hideButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *enableButton = [[UIButton alloc] initWithFrame:CGRectMake((hideButton.frame.origin.x + hideButton.frame.size.width + originButton / 2), 0, sizeButton, sizeButton)];
        [_logButtonView addSubview:enableButton];
        enableButton.layer.cornerRadius = hideButton.frame.size.width / 2;
        enableButton.layer.masksToBounds = YES;
        enableButton.backgroundColor = [UIColor.yellowColor colorWithAlphaComponent:0.4];
        enableButton.titleLabel.numberOfLines = 2;
        enableButton.titleLabel.font = [UIFont systemFontOfSize:13];
        enableButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [enableButton setTitle:@"开启\n滚动" forState:UIControlStateNormal];
        [enableButton setTitle:@"关闭\n滚动" forState:UIControlStateSelected];
        [enableButton setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        [enableButton setTitleColor:UIColor.darkGrayColor forState:UIControlStateSelected];
        [enableButton addTarget:self action:@selector(enableButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake((enableButton.frame.origin.x + enableButton.frame.size.width + originButton / 2), 0, sizeButton, sizeButton)];
        [_logButtonView addSubview:clearButton];
        clearButton.layer.cornerRadius = clearButton.frame.size.width / 2;
        clearButton.layer.masksToBounds = YES;
        clearButton.backgroundColor = [UIColor.yellowColor colorWithAlphaComponent:0.4];
        clearButton.titleLabel.numberOfLines = 2;
        clearButton.titleLabel.font = [UIFont systemFontOfSize:13];
        clearButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [clearButton setTitle:@"清除\nlog" forState:UIControlStateNormal];
        [clearButton setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        [clearButton setTitleColor:UIColor.darkGrayColor forState:UIControlStateHighlighted];
        [clearButton addTarget:self action:@selector(clearButtonClick:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)clearButtonClick:(UIButton *)button
{
    [self logClear];
}

// 拖动手势方法
- (void)panRecognizerAction:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self hideLogButtonView];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
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
    [self.logFile logWith:text key:key];
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
    [SYLogManager.shareLog logText:crashString key:@"crash闪退"];
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
    //
    self.logButton.hidden = !_show;
    if (self.logButton.hidden) {
        [self.baseView sendSubviewToBack:self.logButton];
        [self hideLogButtonView];
    } else {
        [self.baseView bringSubviewToFront:self.logButton];
    }
}

@end
