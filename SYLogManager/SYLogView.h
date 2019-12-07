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

@interface SYLogView : UITableView

@property (nonatomic, strong) NSMutableArray *array;
/// 时间颜色（默认深灰色）
@property (nonatomic, strong) UIColor *colorLog;

@end

NS_ASSUME_NONNULL_END
