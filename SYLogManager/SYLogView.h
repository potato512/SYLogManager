//
//  SYLogView.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/4/15.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYLogView : UIView

/// u父视图
@property (nonatomic, strong) UIView *baseView;
/// 是否显示
@property (nonatomic, assign) BOOL showlogView;
/// 显示回调
@property (nonatomic, copy) void (^showClick)(void);
/// 清除回调
@property (nonatomic, copy) void (^clearClick)(void);
/// 状态
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
/// 显示
- (void)showMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
