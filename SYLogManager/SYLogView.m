//
//  SYLogView.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/4/15.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import "SYLogView.h"

static CGFloat const originXY = 5.0;
static CGFloat const heightClose = 50.0;
static NSInteger const tagSendEmail = 0;
static NSInteger const tagClearLog = 1;
#define sizeHide (self.baseView.frame.size.width / 2 * 1.5)

#define safeTop (self.hasSafeArea ? 44.0 : 20.0)

@interface SYLogView ()

@property (nonatomic, strong) UIButton *logButton;

@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UIView *buttonView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) UIView *hideView;

@property (nonatomic, assign) BOOL hasSafeArea;

@end

@implementation SYLogView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.showlogView = NO;
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNotificationShow) name:NotificationShowLogView object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNotificationHide) name:NotificationHideLogView object:nil];
        [self receiveNotificationHidePanView];
    }
    return self;
}

- (void)showView
{
    // 父视图
    if (self.baseView == nil) {
        self.baseView = UIApplication.sharedApplication.delegate.window;
    }
    if (self.logButton.superview == nil) {
        [self.baseView addSubview:self.logButton];
    }
    if (self.view.superview == nil) {
        [self.baseView addSubview:self.view];
        [self.view addSubview:self.buttonView];
        [self.buttonView addSubview:self.closeButton];
        [self.buttonView addSubview:self.segmentControl];
    }
    if (self.view.superview == nil) {
        [self.baseView addSubview:self.view];
    }
    CGRect rectlog = self.logButton.frame;
    rectlog.origin = CGPointMake(20.0, 20.0);
    self.logButton.frame = rectlog;
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
        _logButton.layer.borderColor = UIColor.redColor.CGColor;
        _logButton.layer.borderWidth = 3.0;
        _logButton.backgroundColor = [UIColor.redColor colorWithAlphaComponent:0.3];
        [_logButton setTitle:@"log日志" forState:UIControlStateNormal];
        [_logButton setTitleColor:UIColor.yellowColor forState:UIControlStateNormal];
        [_logButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
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
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self postNotificationHidePanView];
        
        // 停止拖动时隐藏
        [self showHideView:NO];
    } else {
        // 拖动时显示
        [self showHideView:YES];
        
        // 拖动视图
        UIView *view = (UIView *)recognizer.view;
        [self.baseView bringSubviewToFront:view];
        
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
        
        if (CGRectContainsRect(self.hideView.frame, view.frame)) {
            self.hideView.backgroundColor = UIColor.yellowColor;
            self.hideView.layer.borderColor = UIColor.redColor.CGColor;
            self.hideView.layer.borderWidth = 3.0;
        } else {
            self.hideView.backgroundColor = [UIColor.yellowColor colorWithAlphaComponent:0.6];
            self.hideView.layer.borderColor = UIColor.clearColor.CGColor;
        }
    }
    
    NSLog(@"pan state = %ld", recognizer.state);
}

#pragma mark - getter

- (UIView *)view
{
    if (_view == nil) {
        _view = [[UIView alloc] initWithFrame:self.baseView.bounds];
        _view.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.8];
        //
        _view.userInteractionEnabled = YES;
        //
        _view.hidden = YES;
    }
    return _view;
}

- (UITextView *)textView
{
    if (_textView == nil) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, (safeTop + heightClose), self.view.frame.size.width, (self.view.frame.size.height - safeTop - heightClose))];
        _textView.textColor = UIColor.blackColor;
        _textView.editable = NO;
        _textView.backgroundColor = [UIColor.redColor colorWithAlphaComponent:0.2];
        [self.view addSubview:_textView];
    }
    return _textView;
}

- (UIActivityIndicatorView *)activityView
{
    if (_activityView == nil) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityView.color = UIColor.redColor;
        _activityView.hidesWhenStopped = YES;
        //
        [self.view addSubview:_activityView];
        _activityView.center = self.view.center;
        [_activityView stopAnimating];
    }
    return _activityView;
}

- (UIView *)buttonView
{
    if (_buttonView == nil) {
        _buttonView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, (safeTop + heightClose))];
        _buttonView.backgroundColor = [UIColor yellowColor];
    }
    return _buttonView;
}

- (UIButton *)closeButton
{
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.backgroundColor = UIColor.yellowColor;
        [_closeButton setTitle:@"关闭" forState:UIControlStateNormal];
        [_closeButton setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        [_closeButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
        [_closeButton addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
        //
        _closeButton.frame = CGRectMake(0.0, safeTop, (self.buttonView.frame.size.width - originXY * 2 - 120.0), heightClose);
    }
    return _closeButton;
}

- (void)closeClick
{
    self.logButton.hidden = NO;
    self.view.hidden = YES;
}

- (UISegmentedControl *)segmentControl
{
    if (_segmentControl == nil) {
        _segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"发送", @"清空"]];
        _segmentControl.frame = CGRectMake((self.buttonView.frame.size.width - originXY * 2 - 120.0), (safeTop + originXY), 120.0, (heightClose - originXY * 2));
        _segmentControl.momentary = YES;
        [_segmentControl addTarget:self action:@selector(segmentControlClick:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentControl;
}

- (void)segmentControlClick:(UISegmentedControl *)control
{
    NSInteger tag = control.selectedSegmentIndex;
    if (tag == tagSendEmail) {
        // 截图
        if (self.sendEmailClick) {
            self.sendEmailClick();
        }
    } else if (tag == tagClearLog) {
        // 清空
        [self showMessage:@""];
        [self closeClick];
        if (self.clearClick) {
            self.clearClick();
        }
    }
}

- (BOOL)hasSafeArea
{
    if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        if (window.safeAreaInsets.bottom > 0.0) {
            // 是机型iPhoneX/iPhoneXR/iPhoneXS/iPhoneXSMax
            return YES;
        }
    }
    return NO;
}

- (UIView *)hideView
{
    if (_hideView == nil) {
        _hideView = [[UIView alloc] initWithFrame:CGRectMake((self.baseView.frame.size.width + sizeHide), (self.baseView.frame.size.height + sizeHide), sizeHide, sizeHide)];
        _hideView.backgroundColor = [UIColor.yellowColor colorWithAlphaComponent:0.6];
        _hideView.layer.cornerRadius = sizeHide / 2;
        _hideView.layer.masksToBounds = YES;
        _hideView.layer.borderColor = UIColor.clearColor.CGColor;
        _hideView.layer.borderWidth = 3.0;
        
        [self.baseView addSubview:_hideView];
        //
        CGFloat sizelabel = _hideView.frame.size.width / 2;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, sizelabel, sizelabel)];
        label.backgroundColor = UIColor.clearColor;
        label.textColor = UIColor.blackColor;
        label.text = @"取消悬浮";
        label.textAlignment = NSTextAlignmentCenter;
        [_hideView addSubview:label];
    }
    return _hideView;
}

- (void)showHideView:(BOOL)show
{
    if (show) {
        if (CGRectEqualToRect(self.hideView.frame, CGRectMake((self.baseView.frame.size.width - sizeHide / 2), (self.baseView.frame.size.height - sizeHide / 2), sizeHide, sizeHide))) {
            return;
        }
        [UIView animateWithDuration:0.3 animations:^{
            self.hideView.frame = CGRectMake((self.baseView.frame.size.width - sizeHide / 2), (self.baseView.frame.size.height - sizeHide / 2), sizeHide, sizeHide);
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.hideView.frame = CGRectMake((self.baseView.frame.size.width + sizeHide), (self.baseView.frame.size.height + sizeHide), sizeHide, sizeHide);
        } completion:^(BOOL finished) {
            
        }];
    }
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
    self.textView.text = message;
}

#pragma mark - 通知

- (void)addNotificationShow
{
    self.logButton.hidden = NO;
    self.view.hidden = YES;
}

- (void)addNotificationHide
{
    self.logButton.hidden = YES;
    self.view.hidden = YES;
}

- (void)postNotificationHidePanView
{
    [NSNotificationCenter.defaultCenter postNotificationName:@"hidePanView" object:nil];
}

- (void)receiveNotificationHidePanView
{
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(hidePanView) name:@"hidePanView" object:nil];
}

- (void)hidePanView
{
    if (CGRectContainsRect(self.hideView.frame, self.logButton.frame)) {
        [self addNotificationHide];
    }
}

@end
