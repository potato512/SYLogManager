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
#import "SYLogPopoverView.h"

static CGFloat const originButton = 20.0;
static CGFloat const sizeButton = 60.0;
#define widthButtonView (self.logButton.frame.size.height * 3 + originButton)

@interface SYLogManager () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) SYLogFile *logFile;
@property (nonatomic, strong) SYLogView *logView;
//
@property (nonatomic, strong) UIView *baseView;
//
@property (nonatomic, strong) UIButton *logButton;
@property (nonatomic, strong) NSArray *logActions;
//
@property (nonatomic, assign) BOOL validLog;

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

- (void)config
{
    self.validLog = YES;
    
#ifdef DEBUG
    if (!self.logEnable) {
        return;
    }
    
    NSSetUncaughtExceptionHandler(&readException);
    //
    [self.logFile read];
    self.logView.array = [NSMutableArray arrayWithArray:self.logFile.logs];
    //
    [self logText:[NSString stringWithFormat:@"打开使用[%@--V %@]", [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleDisplayName"], [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"]] key:@"打开应用"];
#endif
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
    [self logMenu];
}

// 拖动手势方法
- (void)panRecognizerAction:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
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

- (void)logMenu
{
    [SYLogPopoverView.popoverView showToView:self.logButton actions:self.logActions];
}

- (NSArray *)logActions
{
    if (_logActions == nil) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        SYLogPopoverAction *showAction = [SYLogPopoverAction actionWithTitle:@"显示log" selectTitle:@"隐藏log" handler:^(SYLogPopoverAction * _Nonnull action) {
            if (self.validLog) {
                action.selecte = !action.isSelecte;
                [self logShow:action.isSelecte];
            } else {
                if (self.controller && [self.controller respondsToSelector:@selector(presentViewController:animated:completion:)]) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"未进行初始化配置" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    [alertController addAction:cancelAction];
                    [self.controller presentViewController:alertController animated:YES completion:NULL];
                }
            }
        }];
        [array addObject:showAction];
        SYLogPopoverAction *scrollAction = [SYLogPopoverAction actionWithTitle:@"开启滚动" selectTitle:@"关闭滚动" handler:^(SYLogPopoverAction * _Nonnull action) {
            action.selecte = !action.isSelecte;
            [self logScroll:action.isSelecte];
        }];
        [array addObject:scrollAction];
        if ([self validEmail:self.email]) {
            SYLogPopoverAction *sendAction = [SYLogPopoverAction actionWithTitle:@"发送邮件" selectTitle:@"" handler:^(SYLogPopoverAction * _Nonnull action) {
                [self logShow:NO];
                showAction.selecte = NO;
                [self logSend];
            }];
            [array addObject:sendAction];
        }
        SYLogPopoverAction *copyAction = [SYLogPopoverAction actionWithTitle:@"复制" selectTitle:@"" handler:^(SYLogPopoverAction * _Nonnull action) {
            [self logShow:NO];
            showAction.selecte = NO;
            [self logCopy];
        }];
        [array addObject:copyAction];
        SYLogPopoverAction *clearAction = [SYLogPopoverAction actionWithTitle:@"删除log" selectTitle:@"" handler:^(SYLogPopoverAction * _Nonnull action) {
            [self logShow:NO];
            showAction.selecte = NO;
            [self logClear];
        }];
        [array addObject:clearAction];
        //
        _logActions = [NSArray arrayWithArray:array];
    }
    return _logActions;
}

#pragma mark - log处理

- (void)logText:(NSString *)text
{
    [self logText:text key:@""];
}

- (void)logText:(NSString *)text key:(NSString *)key
{
    if (!self.validLog) {
        return;
    }
    
#ifdef DEBUG
    if (!self.logEnable) {
        return;
    }
    
    [self.logFile logWith:text key:key];
    self.logView.array = [NSMutableArray arrayWithArray:self.logFile.logs];
#endif
}

- (void)logClear
{
    if (self.controller && [self.controller respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"确认删除log？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.logFile clear];
            self.logView.array = [NSMutableArray new];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:deleteAction];
        [self.controller presentViewController:alertController animated:YES completion:NULL];
    }
}

- (void)logCopy
{
    NSMutableString *text = [[NSMutableString alloc] init];
    for (SYLogModel *model in self.self.logFile.logs) {
        NSString *string = model.attributeString.string;
        [text appendFormat:@"%@\n\n", string];
    }
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = text;
    //
    if (self.controller && [self.controller respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"已复制到系统粘贴板" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:cancelAction];
        [self.controller presentViewController:alertController animated:YES completion:NULL];
    }
}

- (void)logSend
{
    if (self.controller && [self.controller respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        NSMutableString *text = [[NSMutableString alloc] init];
        for (SYLogModel *model in self.self.logFile.logs) {
            NSString *string = model.attributeString.string;
            [text appendFormat:@"%@\n\n", string];
        }
        //
        [self sentEmail:text];
    }
}

- (void)logShow:(BOOL)show
{
    if (show) {
        self.logView.hidden = NO;
        [self.baseView bringSubviewToFront:self.logView];
        [self.baseView bringSubviewToFront:self.logButton];
    } else {
        self.logView.hidden = YES;
        [self.baseView sendSubviewToBack:self.logView];
    }
}

- (void)logScroll:(BOOL)scroll
{
    if (scroll) {
        self.logView.userInteractionEnabled = YES;
    } else {
        self.logView.userInteractionEnabled = NO;
    }
}

#pragma mark - 邮件

- (BOOL)validEmail:(NSString *)email
{
    return (email && [email isKindOfClass:NSString.class] && email.length > 0);
}

- (void)sentEmail:(NSString *)text
{
    if (self.controller == nil || ![self.controller isKindOfClass:UIViewController.class]) {
        ShowMessage(@"温馨提示", @"请设置【target】属性，以便发送邮件", @"知道了");
        return;
    }
    
    // 判断用户是否已设置邮件账户
    if ([MFMailComposeViewController canSendMail]) {
        // 弹出邮件发送视图
        MFMailComposeViewController *emailVC = [[MFMailComposeViewController alloc] init];
        // 设置邮件代理
        [emailVC setMailComposeDelegate:self];
        // 设置收件人
        [emailVC setToRecipients:@[self.email]];
        // 设置抄送人
        // [emailVC setCcRecipients:@[@"1622849369@qq.com"]];
        // 设置密送人
        // [emailVC setBccRecipients:@[@"15690725786@163.com"]];
        // 设置邮件主题
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        NSString *date = [dateFormatter stringFromDate:NSDate.date];
        NSString *title = [NSString stringWithFormat:@"log日志【%@】%@", [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"], date];
        [emailVC setSubject:title];
        //设置邮件的正文内容
        NSString *emailContent = [NSString stringWithFormat:@"邮件内容: \n%@", text];
        // 是否为HTML格式
        [emailVC setMessageBody:emailContent isHTML:NO];
        // 如使用HTML格式，则为以下代码
        // [mailCompose setMessageBody:@"<html><body><p>Hello</p><p>World！</p></body></html>" isHTML:YES];
        // 添加附件
        // UIImage *image = [UIImage imageNamed:@"qq"];
        // NSData *imageData = UIImagePNGRepresentation(image);
        // [mailCompose addAttachmentData:imageData mimeType:@"" fileName:@"qq.png"];
        // NSString *file = [[NSBundle mainBundle] pathForResource:@"EmptyPDF" ofType:@"pdf"];
        // NSData *pdf = [NSData dataWithContentsOfFile:file];
        // [mailCompose addAttachmentData:pdf mimeType:@"" fileName:@"EmptyPDF.pdf"];
        [self.controller presentViewController:emailVC animated:YES completion:nil];
    } else {
        // 给出提示,设备未开启邮件服务
        ShowMessage(@"没有邮件帐户", @"请添加邮件帐户（添加方法：设置->邮件、通讯录、日历->添加帐户->其他->添加邮件帐户）", @"知道了");
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled: {
            NSLog(@"Mail send canceled: 用户取消编辑");
            ShowMessage(nil, @"Mail send canceled: 用户取消编辑", @"知道了");
        } break;
        case MFMailComposeResultSaved: {
            NSLog(@"Mail saved: 邮件保存成功");
            ShowMessage(nil, @"Mail saved: 邮件保存成功", @"知道了");
        } break;
        case MFMailComposeResultSent: {
            NSLog(@"Mail sent: 邮件发送成功");
            ShowMessage(nil, @"Mail sent: 邮件发送成功", @"知道了");
        } break;
        case MFMailComposeResultFailed: {
            NSLog(@"Mail send errored: %@ : 用户尝试保存或发送邮件失败", [error localizedDescription]);
            ShowMessage(nil, [NSString stringWithFormat:@"Mail send errored: %@ : 用户尝试保存或发送邮件失败", [error localizedDescription]], @"知道了");
        } break;
    }
    // 关闭邮件发送视图
    [self.controller dismissViewControllerAnimated:YES completion:nil];
}

void ShowMessage(NSString *title, NSString *message, NSString *button)
{
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:button, nil] show];
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
    } else {
        [self.baseView bringSubviewToFront:self.logButton];
    }
}

@end
