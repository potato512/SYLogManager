//
//  SYLogPopoverView.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/12/7.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 事件

@interface SYLogPopoverAction : NSObject

@property (nonatomic, strong) NSString *titleNormal;
@property (nonatomic, strong) NSString *titleSelect;
@property (nonatomic, assign, getter=isSelecte) BOOL selecte;
@property (nonatomic, copy) void(^handler)(SYLogPopoverAction *action);
//
+ (instancetype)actionWithTitle:(NSString *)titleNormal selectTitle:(NSString *)titleSelect handler:(void (^)(SYLogPopoverAction *action))handler;

@end

#pragma mark - 弹出窗

@interface SYLogPopoverView : UIView

@property (nonatomic, assign) BOOL hideAfterTouchOutside;
@property (nonatomic, assign) BOOL showShade;

+ (instancetype)popoverView;

/*! @brief 指向指定的View来显示弹窗
 *  @param pointView 箭头指向的View
 *  @param actions   动作对象集合<SYLogPopoverAction>
 */
- (void)showToView:(UIView *)pointView actions:(NSArray<SYLogPopoverAction *> *)actions;

/*! @brief 指向指定的点来显示弹窗
 *  @param toPoint 箭头指向的点(这个点的坐标需按照keyWindow的坐标为参照)
 *  @param actions 动作对象集合<SYLogPopoverAction>
 */
- (void)showToPoint:(CGPoint)toPoint actions:(NSArray<SYLogPopoverAction *> *)actions;

@end

NS_ASSUME_NONNULL_END
