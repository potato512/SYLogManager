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
                weakLog.logMessage = message;
                [weakLog.logView showMessage:message];
            }];
            weakLog.logView.sendEmailClick = ^() {
                [weakLog sentEmail];
            };
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

#pragma mark - 发送邮件

- (void)sentEmail
{
    if (self.target == nil || ![self.target isKindOfClass:UIViewController.class]) {
        ShowMessage(@"温馨提示", @"请设置【target】属性，以便发送邮件", @"知道了");
        return;
    }
    // 判断用户是否已设置邮件账户
    if ([MFMailComposeViewController canSendMail]) {
        [NSNotificationCenter.defaultCenter postNotificationName:NotificationHideLogView object:nil];
        
        // 弹出邮件发送视图
        MFMailComposeViewController *emailVC = [[MFMailComposeViewController alloc] init];
        // 设置邮件代理
        [emailVC setMailComposeDelegate:self];
        // 设置收件人
        [emailVC setToRecipients:@[@"3378459350@qq.com"]];
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
        NSString *emailContent = [NSString stringWithFormat:@"邮件内容: \n%@", self.message];
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
        [self.target presentViewController:emailVC animated:YES completion:nil];
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
//            ShowMessage(nil, @"用户已取消发送并删除草稿", @"知道了");
        } break;
        case MFMailComposeResultSaved: {
            NSLog(@"Mail saved: 用户保存邮件");
//            ShowMessage(nil, @"用户已取消发送并保存邮件", @"知道了");
        } break;
        case MFMailComposeResultSent: {
            NSLog(@"Mail sent: 用户点击发送");
//            ShowMessage(nil, @"发送成功", @"知道了");
        } break;
        case MFMailComposeResultFailed: {
            NSLog(@"Mail send errored: %@ : 用户尝试保存或发送邮件失败", [error localizedDescription]);
//            ShowMessage(nil, @"用户尝试保存或发送邮件失败", @"知道了");
        } break;
    }
    // 关闭邮件发送视图
    [self.target dismissViewControllerAnimated:YES completion:nil];
    [NSNotificationCenter.defaultCenter postNotificationName:NotificationShowLogView object:nil];
}

void ShowMessage(NSString *title, NSString *message, NSString *button)
{
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:button, nil] show];
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
