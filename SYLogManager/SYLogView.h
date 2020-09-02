//
//  SYLogView.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/4/15.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYLogFile.h"

NS_ASSUME_NONNULL_BEGIN

/// 显示类型，非实时，或实时
typedef NS_ENUM(NSInteger, SYLogViewShowType) {
    /// 显示类型，非实时
    SYLogViewShowTypeDefault = 1,
    /// 显示类型，实时
    SYLogViewShowTypeImmediately = 2
};
/// 交互类型，复制all、发邮件all、复制选择、发邮件选择
typedef NS_ENUM(NSInteger, SYLogViewControlType) {
    /// 交互类型，复制all
    SYLogViewControlTypeCopy = 1,
    /// 交互类型，发邮件all
    SYLogViewControlTypeEmail = 2,
    /// 交互类型，复制选择
    SYLogViewControlTypeCopySelected = 3,
    /// 交互类型，发邮件选择
    SYLogViewControlTypeEmailSelected = 4
};

@interface SYLogView : UITableView

@property (nonatomic, strong) NSMutableArray *array;
/// 时间颜色（默认深灰色）
@property (nonatomic, strong) UIColor *colorLog;
@property (nonatomic, assign) SYLogViewShowType showType;
@property (nonatomic, assign) BOOL showControl;
@property (nonatomic, copy) void (^buttonClick)(SYLogViewControlType type, NSArray *array);

- (void)addModel:(SYLogModel *)model;
//
- (void)postNotificationAddModel;
- (void)addNotificationAddModel;
- (void)removeNotificationAddModel;

@end

NS_ASSUME_NONNULL_END
