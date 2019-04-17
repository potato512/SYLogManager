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

@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, assign) BOOL showlogView;
@property (nonatomic, copy) void (^showClick)(void);
@property (nonatomic, copy) void (^sendClick)(void);
@property (nonatomic, assign) BOOL showSendEmail;

- (void)showMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
