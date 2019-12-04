//
//  SYLogView.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/4/15.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const NotificationShowLogView = @"NotificationShowLogView";
static NSString *const NotificationHideLogView = @"NotificationHideLogView";

@interface SYLogView : UIView

/// 父视图
@property (nonatomic, strong) UIView *baseView;
/// 是否显示
@property (nonatomic, assign) BOOL showlogView;
/// 显示回调
@property (nonatomic, copy) void (^showClick)(void);
/// 清除回调
@property (nonatomic, copy) void (^clearClick)(void);
/// 邮件发送回调
@property (nonatomic, copy) void (^sendEmailClick)(void);
/// 状态
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
/// 显示
- (void)showMessage:(NSString *)message;



- (void)showLog:(NSAttributedString *)message;

@end

NS_ASSUME_NONNULL_END
