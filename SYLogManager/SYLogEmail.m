//
//  SYLogEmail.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/4/17.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import "SYLogEmail.h"
#import <MessageUI/MessageUI.h>

@interface SYLogEmail () <MFMailComposeViewControllerDelegate>

@property (nonatomic, copy) void (^completeBlock)(NSInteger state);

@end

@implementation SYLogEmail

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)sendEmailWithTarget:(id)target complete:(void (^)(NSInteger state))complete
{
    if ([MFMailComposeViewController canSendMail]) {
        if (target && [target isKindOfClass:UIViewController.class]) {
            self.completeBlock = [complete copy];
            
            UIViewController *controller = (UIViewController *)target;
            //
            MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
            mailVC.mailComposeDelegate = self;
            [mailVC setToRecipients:@[self.emailReceive]];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSString *dateStr = [formatter stringFromDate:NSDate.date];
            NSString *title = [NSString stringWithFormat:@"%@ log日志", dateStr];
            [mailVC setSubject:title];
            [mailVC setMessageBody:self.emailMessage isHTML:NO];
            //
            [controller presentViewController:mailVC animated:YES completion:NULL];
        }
    } else {
        if (complete) {
            complete(EamilStatePermission);
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
            case MFMailComposeResultCancelled: {
                // 取消
                if (self.completeBlock) {
                    self.completeBlock(EamilStateCancel);
                }
            } break;
            case MFMailComposeResultSaved: {
                // 保存
                if (self.completeBlock) {
                    self.completeBlock(EamilStateCache);
                }
            } break;
            case MFMailComposeResultSent: {
                // 发送
                if (self.completeBlock) {
                    self.completeBlock(EamilStateSuccess);
                }
            } break;
            case MFMailComposeResultFailed: {
                // 失败
                if (self.completeBlock) {
                    self.completeBlock(EamilStateFailed);
                }
            } break;
        default: break;
    }
}

@end
