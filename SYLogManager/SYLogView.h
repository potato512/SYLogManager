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

@interface SYLogView : UITableView

@property (nonatomic, strong) NSMutableArray *array;
/// 时间颜色（默认深灰色）
@property (nonatomic, strong) UIColor *colorLog;
@property (nonatomic, assign) SYLogViewShowType showType;
@property (nonatomic, assign) BOOL showSearch;

- (void)addModel:(SYLogModel *)model;
//
- (void)postNotificationAddModel;
- (void)addNotificationAddModel;
- (void)removeNotificationAddModel;

@end

NS_ASSUME_NONNULL_END
