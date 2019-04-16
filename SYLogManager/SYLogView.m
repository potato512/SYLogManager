//
//  SYLogView.m
//  DemoLog
//
//  Created by zhangshaoyu on 2019/4/15.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import "SYLogView.h"

static CGFloat const heightClose = 40.0;

@interface SYLogView ()

@property (nonatomic, strong) UIButton *logButton;

@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *label;

@end

@implementation SYLogView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.showlogView = NO;
    }
    return self;
}

- (void)showView
{
    // 父视图
    if (self.baseView == nil) {
        self.baseView = UIApplication.sharedApplication.delegate.window;
    }
    [self.baseView addSubview:self.logButton];
    [self.baseView addSubview:self.view];
    [self.baseView bringSubviewToFront:self.logButton];
}

#pragma mark - 按钮

- (UIButton *)logButton
{
    if (_logButton == nil) {
        CGFloat size = 80.0;
        _logButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 20.0, size, size)];
        _logButton.layer.cornerRadius = _logButton.frame.size.width / 2;
        _logButton.layer.masksToBounds = YES;
        _logButton.layer.borderColor = UIColor.brownColor.CGColor;
        _logButton.layer.borderWidth = 3.0;
        _logButton.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
        [_logButton setTitle:@"log日志" forState:UIControlStateNormal];
        [_logButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_logButton setTitleColor:UIColor.redColor forState:UIControlStateHighlighted];
        [_logButton addTarget:self action:@selector(showMessage) forControlEvents:UIControlEventTouchUpInside];
        // 添加拖动手势
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognizerAction:)];
        _logButton.userInteractionEnabled = YES;
        [_logButton addGestureRecognizer:panRecognizer];
        [self.baseView bringSubviewToFront:_logButton];
    }
    return _logButton;
}

- (void)showMessage
{
    if (self.view.hidden) {
        self.logButton.hidden = YES;
        self.view.hidden = NO;
        if (self.showClick) {
            self.showClick();
        }
    }
}

// 拖动手势方法
- (void)panRecognizerAction:(UIPanGestureRecognizer *)recognizer
{
    // 拖动视图
    UIView *view = (UIView *)recognizer.view;
    
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

#pragma mark - 显示

- (UIView *)view
{
    if (_view == nil) {
        _view = [[UIView alloc] initWithFrame:CGRectZero];
        _view.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
        _view.frame = self.baseView.bounds;
        //
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0, (_view.frame.size.height - heightClose), _view.frame.size.width, heightClose)];
        [_view addSubview:button];
        _view.userInteractionEnabled = YES;
        button.backgroundColor = UIColor.yellowColor;
        [button setTitle:@"关闭" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        [button setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
        //
        _view.hidden = YES;
    }
    return _view;
}

- (UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        // 父视图
        [self.view addSubview:_scrollView];
        _scrollView.frame = CGRectMake(0.0, 34.0, self.view.frame.size.width, (self.view.frame.size.height - 34.0 - heightClose));
    }
    return _scrollView;
}

- (void)closeClick
{
    self.logButton.hidden = NO;
    self.view.hidden = YES;
}

- (UILabel *)label
{
    if (_label == nil) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0.0, (self.scrollView.frame.size.width - 40.0), self.scrollView.frame.size.height)];
        [self.scrollView addSubview:_label];
        _label.textColor = UIColor.blackColor;
        _label.numberOfLines = 0;
    }
    return _label;
}

#pragma mark - setter

- (void)setShowlogView:(BOOL)showlogView
{
    _showlogView = showlogView;
    self.logButton.hidden = !_showlogView;
    [self showView];
}

- (void)showMessage:(NSString *)message
{
    self.label.text = message;
    CGSize size = self.label.frame.size;
    if (7.0 <= [UIDevice currentDevice].systemVersion.floatValue)
    {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *dict = @{NSFontAttributeName:self.label.font, NSParagraphStyleAttributeName:paragraphStyle.copy};
        size = [self.label.text boundingRectWithSize:CGSizeMake(self.label.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    }
    CGRect rect = self.label.frame;
    rect.size.height = size.height;
    self.label.frame = rect;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, (rect.size.height + rect.origin.y));
    // 显示最新信息
    if (self.scrollView.contentSize.height > self.scrollView.frame.size.height) {
        [self.scrollView setContentOffset:CGPointMake(0.0, self.scrollView.contentSize.height - self.scrollView.frame.size.height)];
    }
}

@end