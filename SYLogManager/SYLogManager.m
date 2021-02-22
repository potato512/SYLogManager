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

//
// 设备信息
#define kLogDeviceModel [NSString stringWithFormat:@"设备类型：%@", UIDevice.currentDevice.model]
#define kLogDeviceSystem [NSString stringWithFormat:@"设备系统：%@", UIDevice.currentDevice.systemName]
#define kLogDeviceVersion [NSString stringWithFormat:@"设备系统版本：%@", UIDevice.currentDevice.systemVersion]
#define kLogDeviceName [NSString stringWithFormat:@"设备名称：%@", UIDevice.currentDevice.name]
#define kLogDeviceBatteryState [NSString stringWithFormat:@"设备电池：%@", batteryState]
#define kLogDeviceBattery [NSString stringWithFormat:@"设备量：%f", UIDevice.currentDevice.batteryLevel]
// 应用信息
#define kLogAppName [NSString stringWithFormat:@"应用名称：%@", [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleDisplayName"]]
#define kLogAppVersion [NSString stringWithFormat:@"应用版本：%@", [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"]]

//
static CGFloat const originButton = 20.0;
static CGFloat const sizeButton = 60.0;
#define widthButtonView (self.logButton.frame.size.height * 3 + originButton)

@implementation SYLogConfig

@end


@interface SYLogManager () <MFMailComposeViewControllerDelegate>


/// 视图控制器用于弹窗及发邮件（在设置根视图控制器之后）
@property (nonatomic, strong) UIViewController *logController;
/// 邮件接收地址（选填，填写后须设置属性 controller）
@property (nonatomic, strong) NSString *logEmail;
/// 时间颜色（默认红色）
@property (nonatomic, strong) UIColor *logColor;
/// 显示父视图
@property (nonatomic, strong) UIView *logShowView;
/// 显示或隐藏（warning:初始化后最后设置）
@property (nonatomic, assign) BOOL logShow;


@property (nonatomic, strong) SYLogFile *logFile;
@property (nonatomic, strong) SYLogView *logView;
//
@property (nonatomic, strong) UIView *baseView;
//
@property (nonatomic, strong) UIButton *logButton;
@property (nonatomic, strong) NSArray *logActions;
//
@property (nonatomic, assign) BOOL validLog;
@property (nonatomic, assign) SYLogViewShowType showType;
//
@property (nonatomic, strong) SYLogServe *logServe;

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
        [self logInitialize];
    }
    return self;
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
        SYLogPopoverAction *showAction = [SYLogPopoverAction actionWithTitle:@"显示log(非实时)" selectTitle:@"隐藏log(非实时)" handler:^(SYLogPopoverAction * _Nonnull action) {
            if (self.validLog) {
                if (self.showType == SYLogViewShowTypeImmediately) {
                    return ;
                }
                action.selecte = !action.isSelecte;
                self.showType = (action.isSelecte ? SYLogViewShowTypeDefault : 0);
                [self logViewShow:action.isSelecte];
            } else {
                NSLog(@"'- (void)logConfig:(BOOL)enable' 初始化配置为NO，无法显示");
            }
        }];
        [array addObject:showAction];
        SYLogPopoverAction *showiImmediatelyAction = [SYLogPopoverAction actionWithTitle:@"显示log(实时)" selectTitle:@"隐藏log(实时)" handler:^(SYLogPopoverAction * _Nonnull action) {
            if (self.validLog) {
                if (self.showType == SYLogViewShowTypeDefault) {
                    return ;
                }
                action.selecte = !action.isSelecte;
                self.showType = (action.isSelecte ? SYLogViewShowTypeImmediately : 0);
                [self logViewShow:action.isSelecte];
            } else {
                NSLog(@"'- (void)logConfig:(BOOL)enable' 初始化配置为NO，无法显示");
            }
        }];
        [array addObject:showiImmediatelyAction];
        SYLogPopoverAction *scrollAction = [SYLogPopoverAction actionWithTitle:@"开启滚动" selectTitle:@"关闭滚动" handler:^(SYLogPopoverAction * _Nonnull action) {
            action.selecte = !action.isSelecte;
            [self logScroll:action.isSelecte];
        }];
        [array addObject:scrollAction];
        SYLogPopoverAction *searchAction = [SYLogPopoverAction actionWithTitle:@"开启控制" selectTitle:@"关闭控制" handler:^(SYLogPopoverAction * _Nonnull action) {
            action.selecte = !action.isSelecte;
            [self logControl:action.isSelecte];
        }];
        [array addObject:searchAction];
        SYLogPopoverAction *clearAction = [SYLogPopoverAction actionWithTitle:@"删除log" selectTitle:@"" handler:^(SYLogPopoverAction * _Nonnull action) {
            [self logViewShow:NO];
            showAction.selecte = NO;
            showiImmediatelyAction.selecte = NO;
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
        NSLog(@"'- (void)logConfig:(BOOL)enable' 初始化配置为NO，无法记录");
        return;
    }
    if (!self.logShow) {
        NSLog(@"'logShow = NO' 不显示，不处理");
        return;
    }
    if (self.baseView == nil) {
        NSLog(@"'baseView' 不能为nil");
        return;
    }
    
    SYLogModel *model = [self.logFile logWith:text key:key];
    //
    self.logView.showType = self.showType;
    if (self.showType == SYLogViewShowTypeDefault) {
        
    } else if (self.showType == SYLogViewShowTypeImmediately) {
        [self.logView addModel:model];
    }
}

- (void)logClear
{
    if (!self.validLog) {
        NSLog(@"'- (void)logConfig:(BOOL)enable' 初始化配置为NO，无记录");
        return;
    }
    
    if (self.logController && [self.logController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"确认删除log？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.logFile clear];
            self.logView.array = [NSMutableArray new];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:deleteAction];
        [self.logController presentViewController:alertController animated:YES completion:NULL];
    }
}

- (void)logControlWithType:(SYLogViewControlType)type array:(NSArray *)array
{
    if (!self.validLog) {
        NSLog(@"'- (void)logConfig:(BOOL)enable' 初始化配置为NO，无记录");
        return;
    }
    
    if (self.logController && [self.logController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        NSMutableString *text = [[NSMutableString alloc] init];
        for (SYLogModel *model in array) {
            if (type == SYLogViewControlTypeEmail || type == SYLogViewControlTypeCopy) {
                NSString *string = model.attributeString.string;
                [text appendFormat:@"%@\n\n", string];
            } else if (type == SYLogViewControlTypeCopySelected || type == SYLogViewControlTypeEmailSelected) {
                if (model.selected) {
                    NSString *string = model.attributeString.string;
                    [text appendFormat:@"%@\n\n", string];
                }
            }
        }
        //
        if (text.length <= 0) {
            NSString *message = @"还没有log日志记录信息~";
            if (type == SYLogViewControlTypeCopySelected || type == SYLogViewControlTypeEmailSelected) {
                message = @"还没有【选择】log日志记录信息~";
            }
            ShowMessage(@"温馨提示", message, @"知道了");
            return;
        }
        if (type == SYLogViewControlTypeCopy || type == SYLogViewControlTypeCopySelected) {
            [self logCopy:text];
        } else if (type == SYLogViewControlTypeEmail || type == SYLogViewControlTypeEmailSelected) {
           [self sentEmail:text];
        }
    }
}

- (void)logViewShow:(BOOL)show
{
    if (show) {
        self.logView.hidden = NO;
        [self.baseView bringSubviewToFront:self.logView];
        [self.baseView bringSubviewToFront:self.logButton];
        
        if (self.showType == SYLogViewShowTypeDefault) {
            self.logView.array = [NSMutableArray arrayWithArray:self.logFile.logs];
        } else if (self.showType == SYLogViewShowTypeImmediately) {
            self.logView.array = [NSMutableArray arrayWithArray:self.logFile.logs];
            [self.logView addNotificationAddModel];
        }
    } else {
        self.logView.hidden = YES;
        [self.baseView sendSubviewToBack:self.logView];
        
        if (self.showType == SYLogViewShowTypeDefault) {
            
        } else if (self.showType == SYLogViewShowTypeImmediately) {
            [self.logView removeNotificationAddModel];
        }
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

- (void)logControl:(BOOL)search
{
    self.logView.showControl = search;
    self.logView.userInteractionEnabled = search;
}

#pragma mark - 复制

- (void)logCopy:(NSString *)text
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = text;
    //
    if (self.logController && [self.logController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"已复制到系统粘贴板" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:cancelAction];
        [self.logController presentViewController:alertController animated:YES completion:NULL];
    }
}

#pragma mark - 邮件

- (BOOL)validEmail:(NSString *)email
{
    return (email && [email isKindOfClass:NSString.class] && email.length > 0);
}

- (void)sentEmail:(NSString *)text
{
    if (![self validEmail:self.logEmail]) {
        ShowMessage(@"温馨提示", @"请设置【logEmail】属性，以便发送邮件", @"知道了");
        return;
    }
    
    if (self.logController == nil || ![self.logController isKindOfClass:UIViewController.class]) {
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
        [emailVC setToRecipients:@[self.logEmail]];
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
        [self.logController presentViewController:emailVC animated:YES completion:nil];
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
            ShowMessage(nil, @"用户取消编辑", @"知道了");
        } break;
        case MFMailComposeResultSaved: {
            NSLog(@"Mail saved: 邮件保存成功");
            ShowMessage(nil, @"邮件保存成功", @"知道了");
        } break;
        case MFMailComposeResultSent: {
            NSLog(@"Mail sent: 邮件发送成功");
            ShowMessage(nil, @"邮件发送成功", @"知道了");
        } break;
        case MFMailComposeResultFailed: {
            NSLog(@"Mail send errored: %@ : 用户尝试保存或发送邮件失败", [error localizedDescription]);
            ShowMessage(nil, [NSString stringWithFormat:@"用户尝试保存或发送邮件失败: %@", [error localizedDescription]], @"知道了");
        } break;
    }
    // 关闭邮件发送视图
    [self.logController dismissViewControllerAnimated:YES completion:nil];
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
    NSString *deviceModel = kLogDeviceModel;
    NSString *deviceSystem = kLogDeviceSystem;
    NSString *deviceVersion = kLogDeviceVersion;
    NSString *deviceName = kLogDeviceName;
    NSString *batteryState = @"UIDeviceBatteryStateUnknown";
    switch (UIDevice.currentDevice.batteryState) {
        case UIDeviceBatteryStateUnknown: batteryState = @"UIDeviceBatteryStateUnknown"; break;
        case UIDeviceBatteryStateUnplugged: batteryState = @"UIDeviceBatteryStateUnplugged"; break;
        case UIDeviceBatteryStateCharging: batteryState = @"UIDeviceBatteryStateCharging"; break;
        case UIDeviceBatteryStateFull: batteryState = @"UIDeviceBatteryStateFull"; break;
        default: break;
    }
    NSString *deviceBatteryState = kLogDeviceBatteryState;
    NSString *deviceBattery = kLogDeviceBattery;
    // 应用信息
    NSString *appName = kLogAppName;
    NSString *appVersion = kLogAppVersion;
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
        _logView.userInteractionEnabled = NO;
        _logView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        _logView.hidden = YES;
        // 搜索记录复制
        __weak SYLogManager *weakSelf = self;
        _logView.buttonClick = ^(SYLogViewControlType type, NSArray * _Nonnull array) {
            [weakSelf logControlWithType:type array:array];
        };
        [self.baseView addSubview:_logView];
    }
    return _logView;
}

#pragma mark - setter

- (void)setLogShow:(BOOL)logShow
{
    _logShow = logShow;
    //
    if (self.logShowView) {
        if (self.baseView == nil) {
            self.baseView = self.logShowView;
        }
        if (self.logColor) {
            self.logView.colorLog = self.logColor;
        }
    }

    self.show = _logShow;
}

- (void)setShow:(BOOL)show
{
    _show = show;
    //
    if (self.config == nil) {
        NSLog(@"config = nil, 必须先配置config");
        return;
    }
    
    self.logButton.hidden = !_show;
    if (self.logButton.hidden) {
        [self.baseView sendSubviewToBack:self.logButton];
    } else {
        [self.baseView bringSubviewToFront:self.logButton];
    }
}

- (void)setConfig:(SYLogConfig *)config
{
    _config = config;
    //
    if (_config == nil) {
        return;
    }
    
    BOOL logEnable = _config.logEnable;
    BOOL logSend = _config.isSendEnable;
    self.validLog = (logEnable || logSend);
    if (!self.validLog) {
        return;
    }
    
    self.logEmail = _config.logEmail;
    self.logColor = _config.logColor;
    self.logController = _config.logController;
    self.logShowView = _config.logShowView;
    self.logShow = _config.logShow;

    NSSetUncaughtExceptionHandler(&readException);
    //
    [self.logFile read];
    //
    [self logText:[NSString stringWithFormat:@"打开使用[%@--V %@]", [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleDisplayName"], [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"]] key:@"打开应用"];
}

#pragma mark - 打印及记录

void SYLogSave(BOOL logEnable, NSString *key, NSString *text)
{
    if (logEnable) {
        [SYLogManager.shareLog logText:text key:key];
    }
    
#ifdef DEBUG
    printf("\n< %s:(第 %d 行) > \n%s", [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [text UTF8String]);
#endif
}

#pragma mark - 日志服务

- (SYLogServe *)logServe
{
    if (_logServe == nil) {
        _logServe = [[SYLogServe alloc] init];
    }
    return _logServe;
}

/// 初始化
- (void)logInitialize
{
    [self.logServe logCarashInitialize];
}

/// 上传log日志
- (void)logSend:(void (^)(BOOL success))handle
{
    if (!self.config.logSendEnable) {
        return;
    }
    
    // 上传 应用名称
    NSString *logAppName = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleDisplayName"];
    // 上传 应用版本
    NSString *logAppVersion = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // 上传 日志时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy年MM月dd日 HH:mm";
    NSString *logTime = [formatter stringFromDate:NSDate.date];
    // 上传 设备类型（1 iPhone，2 Android）
    NSNumber *logDeviceType = @1;
    // 上传 设备系统（iOS，Android）
    NSString *logDeviceSystem = UIDevice.currentDevice.systemName;
    // 上传 设备系统版本，如：iOS14
    NSString *logDeviceSystemV = UIDevice.currentDevice.systemVersion;
    // 上传 设备名称
    NSString *logDeviceName = UIDevice.currentDevice.name;
    // 上传 日志信息
    NSArray *array = self.logFile.logsCrash;
    NSLog(@"日志上传：%@", array.count <= 0 ? @"没有记录" : [NSString stringWithFormat:@"有 %ld 条记录", array.count]);
    for (SYLogModel *modelCrash in array) {
        NSString *string = modelCrash.logText;
        //
        SYLogCrashModel *model = [[SYLogCrashModel alloc] init];
        model.logAppName = logAppName;
        model.logAppVersion = logAppVersion;
        model.logUploadTime = logTime;
        model.logDeviceType = logDeviceType;
        model.logDeviceSystem = logDeviceSystem;
        model.logDeviceSystemV = logDeviceSystemV;
        model.logDeviceName = logDeviceName;
        model.logMessage = string;
        model.logUserName = self.logUser;
        model.logUserVin = self.logVin;
        //
        __weak SYLogManager *weak = self;
        [self.logServe logCrashSaveWithModel:model complete:^(BOOL isSuccessful, NSError * _Nonnull error) {
            if (isSuccessful) {
                [weak.logFile clearWithKey:string];
            } 
            NSLog(@"crash日志上传：%@", (isSuccessful ? @"成功" : @"失败"));
        }];
    }
}

/// 获取上传log日志
- (void)logReadWithPage:(NSInteger)page size:(NSInteger)size complete:(void (^)(NSArray <SYLogCrashModel *>*array, NSError *error))complete
{
    [self.logServe logCrashReadWithPage:page size:size complete:^(NSArray<SYLogCrashModel *> * _Nonnull array, NSError * _Nonnull error) {
        NSLog(@"日志记录：%@", array.count <= 0 ? @"没有记录" : [NSString stringWithFormat:@"有 %ld 条记录", array.count]);
        if (complete) {
            complete(array, error);
        }
    }];
}

@end
