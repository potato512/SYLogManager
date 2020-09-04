//
//  SYLogView.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/4/15.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import "SYLogView.h"
#import <pthread/pthread.h>

#pragma mark - 列表单元格

@interface SYLogCell : UITableViewCell

@property (nonatomic, strong) SYLogModel *model;
@property (nonatomic, strong) UILabel *label;

@end

@implementation SYLogCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(originXY, originXY / 2, widthText, heightText)];
        [self.contentView addSubview:self.label];
        self.label.textColor = UIColor.redColor;
        self.label.font = [UIFont systemFontOfSize:15];
        self.label.numberOfLines = 0;
    }
    return self;
}

- (void)setModel:(SYLogModel *)model
{
    _model = model;
    self.label.attributedText = _model.attributeString;
    CGRect rectLabel = self.label.frame;
    rectLabel.size.height = _model.height;
    self.label.frame = rectLabel;
}

@end

#pragma mark - 列表视图

static NSInteger const kTagButton = 1000;

@interface SYLogView () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    pthread_mutex_t mutexLock;
}

@property (nonatomic, strong) UIView *buttonView;

@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, assign) BOOL isSearch;
@property (nonatomic, assign) BOOL isSelected;
//
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UIButton *crashButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIButton *cpyAllButton;
@property (nonatomic, strong) UIButton *emailAllButton;
@property (nonatomic, strong) UIButton *seleButton;
@property (nonatomic, strong) UIButton *cpySelButton;
@property (nonatomic, strong) UIButton *emailSelButton;

@end

@implementation SYLogView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        //
        if (@available(iOS 11.0, *)){
            [self setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        } else {
            if (@available(iOS 13.0, *)) {
                self.automaticallyAdjustsScrollIndicatorInsets = NO;
            } else {
                // Fallback on earlier versions
            }
        }
        
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.scrollEnabled = YES;
        [self registerClass:SYLogCell.class forCellReuseIdentifier:NSStringFromClass(SYLogCell.class)];
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (void)dealloc
{
    pthread_mutex_destroy(&mutexLock);
}

- (void)reloadLogView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
        [self setContentOffset:CGPointZero];
    });
}

#pragma mark - delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isSearch) {
        return self.searchArray.count;
    }
    return self.array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearch) {
        SYLogModel *model = self.searchArray[indexPath.row];
        CGFloat height = (originXY + model.height);
        return height;
    }
    SYLogModel *model = self.array[indexPath.row];
    CGFloat height = (originXY + model.height);
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearch) {
        SYLogCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(SYLogCell.class)];
        cell.label.textColor = (self.colorLog ? self.colorLog : UIColor.darkGrayColor);
        SYLogModel *model = self.searchArray[indexPath.row];
        cell.model = model;
        //
        cell.backgroundColor = UIColor.clearColor;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (model.selected) {
            cell.backgroundColor = [UIColor.blueColor colorWithAlphaComponent:0.1];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        return cell;
    }
    
    SYLogCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(SYLogCell.class)];
    cell.label.textColor = (self.colorLog ? self.colorLog : UIColor.darkGrayColor);
    SYLogModel *model = self.array[indexPath.row];
    cell.model = model;
    //
    cell.backgroundColor = UIColor.clearColor;
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (model.selected) {
        cell.backgroundColor = [UIColor.blueColor colorWithAlphaComponent:0.1];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSelected) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //
    if (self.isSelected) {
        if (self.isSearch) {
            SYLogModel *model = self.searchArray[indexPath.row];
            model.selected = !model.selected;
        } else {
            SYLogModel *model = self.array[indexPath.row];
            model.selected = !model.selected;
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - 搜索

- (UIView *)buttonView
{
    if (_buttonView == nil) {
        CGFloat origin = 10;
        CGFloat widthButton = (self.frame.size.width - origin * 6) / 5;
        CGFloat heightText = 36;
        //
        CGFloat top = 20;
        if (@available(iOS 11.0, *)) {
            UIWindow *window = [UIApplication sharedApplication].delegate.window;
            if (window.safeAreaInsets.bottom > 0.0) {
                // 是机型iPhoneX/iPhoneXR/iPhoneXS/iPhoneXSMax
                top = 44;
            }
        }
        CGFloat height = (top + origin + heightText + origin + heightText + origin);
        //
        _buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, top, self.frame.size.width, height)];
        _buttonView.backgroundColor = UIColor.whiteColor;
        _buttonView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.superview addSubview:_buttonView];
        // 搜索
        self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(origin, (top + origin), (_buttonView.frame.size.width - origin * 2), heightText)];
        [_buttonView addSubview:self.searchTextField];
        self.searchTextField.layer.cornerRadius = self.searchTextField.frame.size.height / 2;
        self.searchTextField.layer.borderColor = UIColor.lightGrayColor.CGColor;
        self.searchTextField.layer.borderWidth = 0.5;
        self.searchTextField.layer.masksToBounds = YES;
        self.searchTextField.backgroundColor = UIColor.whiteColor;
        self.searchTextField.placeholder = @"请输入搜索词";
        self.searchTextField.textColor = UIColor.blackColor;
        self.searchTextField.font = [UIFont systemFontOfSize:15];
        self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.searchTextField.frame.size.height)];
        leftView.backgroundColor = UIColor.clearColor;
        self.searchTextField.leftView = leftView;
        self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
        self.searchTextField.returnKeyType = UIReturnKeySearch;
        self.searchTextField.delegate = self;
        // 搜索闪退
        self.crashButton = [[UIButton alloc] initWithFrame:CGRectMake((_buttonView.frame.size.width - origin - widthButton - origin - widthButton), (top + origin), widthButton, heightText)];
        [_buttonView addSubview:self.crashButton];
        self.crashButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [self.crashButton setTitle:@"crash" forState:UIControlStateNormal];
        [self.crashButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [self.crashButton setTitleColor:UIColor.redColor forState:UIControlStateHighlighted];
        self.crashButton.layer.cornerRadius = self.crashButton.frame.size.height / 2;
        self.crashButton.layer.borderColor = UIColor.lightGrayColor.CGColor;
        self.crashButton.layer.borderWidth = 0.5;
        self.crashButton.layer.masksToBounds = YES;
        self.crashButton.backgroundColor = UIColor.whiteColor;
        [self.crashButton addTarget:self action:@selector(crashClick:) forControlEvents:UIControlEventTouchUpInside];
        self.crashButton.alpha = 0.0;
        // 取消
        self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake((_buttonView.frame.size.width - origin - widthButton), (top + origin), widthButton, heightText)];
        [_buttonView addSubview:self.cancelButton];
        self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:UIColor.redColor forState:UIControlStateHighlighted];
        self.cancelButton.layer.cornerRadius = self.cancelButton.frame.size.height / 2;
        self.cancelButton.layer.borderColor = UIColor.lightGrayColor.CGColor;
        self.cancelButton.layer.borderWidth = 0.5;
        self.cancelButton.layer.masksToBounds = YES;
        self.cancelButton.backgroundColor = UIColor.whiteColor;
        [self.cancelButton addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
        self.cancelButton.alpha = 0.0;
        
        UIView *currentView = self.cancelButton;
        // 复制
        self.cpyAllButton = [[UIButton alloc] initWithFrame:CGRectMake(origin, (currentView.frame.origin.y + currentView.frame.size.height + origin), widthButton, heightText)];
        [_buttonView addSubview:self.cpyAllButton];
        self.cpyAllButton.titleLabel.font = [UIFont systemFontOfSize:10];
        self.cpyAllButton.titleLabel.numberOfLines = 2;
        [self.cpyAllButton setTitle:@"复制\n全部" forState:UIControlStateNormal];
        [self.cpyAllButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [self.cpyAllButton setTitleColor:UIColor.redColor forState:UIControlStateHighlighted];
        self.cpyAllButton.layer.cornerRadius = self.cpyAllButton.frame.size.height / 2;
        self.cpyAllButton.layer.borderColor = UIColor.lightGrayColor.CGColor;
        self.cpyAllButton.layer.borderWidth = 0.5;
        self.cpyAllButton.layer.masksToBounds = YES;
        self.cpyAllButton.backgroundColor = UIColor.whiteColor;
        self.cpyAllButton.tag = kTagButton + SYLogViewControlTypeCopy;
        [self.cpyAllButton addTarget:self action:@selector(buttonTapClick:) forControlEvents:UIControlEventTouchUpInside];
        currentView = self.cpyAllButton;
        // 发邮件
        self.emailAllButton = [[UIButton alloc] initWithFrame:CGRectMake((currentView.frame.origin.x + currentView.frame.size.width + origin), currentView.frame.origin.y, widthButton, heightText)];
        [_buttonView addSubview:self.emailAllButton];
        self.emailAllButton.titleLabel.font = [UIFont systemFontOfSize:10];
        self.emailAllButton.titleLabel.numberOfLines = 2;
        [self.emailAllButton setTitle:@"发邮件\n全部" forState:UIControlStateNormal];
        [self.emailAllButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [self.emailAllButton setTitleColor:UIColor.redColor forState:UIControlStateHighlighted];
        self.emailAllButton.layer.cornerRadius = self.emailAllButton.frame.size.height / 2;
        self.emailAllButton.layer.borderColor = UIColor.lightGrayColor.CGColor;
        self.emailAllButton.layer.borderWidth = 0.5;
        self.emailAllButton.layer.masksToBounds = YES;
        self.emailAllButton.backgroundColor = UIColor.whiteColor;
        self.emailAllButton.tag = kTagButton + SYLogViewControlTypeEmail;
        [self.emailAllButton addTarget:self action:@selector(buttonTapClick:) forControlEvents:UIControlEventTouchUpInside];
        currentView = self.emailAllButton;
        // 选择
        self.seleButton = [[UIButton alloc] initWithFrame:CGRectMake((currentView.frame.origin.x + currentView.frame.size.width + origin), currentView.frame.origin.y, widthButton, heightText)];
        [_buttonView addSubview:self.seleButton];
        self.seleButton.titleLabel.font = [UIFont systemFontOfSize:10];
        self.seleButton.titleLabel.numberOfLines = 2;
        [self.seleButton setTitle:@"编辑\n多选" forState:UIControlStateNormal];
        [self.seleButton setTitle:@"取消\n多选" forState:UIControlStateSelected];
        [self.seleButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [self.seleButton setTitleColor:UIColor.redColor forState:UIControlStateHighlighted];
        [self.seleButton setTitleColor:UIColor.redColor forState:UIControlStateSelected];
        self.seleButton.layer.cornerRadius = self.seleButton.frame.size.height / 2;
        self.seleButton.layer.borderColor = UIColor.lightGrayColor.CGColor;
        self.seleButton.layer.borderWidth = 0.5;
        self.seleButton.layer.masksToBounds = YES;
        self.seleButton.backgroundColor = UIColor.whiteColor;
        [self.seleButton addTarget:self action:@selector(selClick:) forControlEvents:UIControlEventTouchUpInside];
        currentView = self.seleButton;
        // 复制选择
        self.cpySelButton = [[UIButton alloc] initWithFrame:CGRectMake((currentView.frame.origin.x + currentView.frame.size.width + origin), currentView.frame.origin.y, widthButton, heightText)];
        [_buttonView addSubview:self.cpySelButton];
        self.cpySelButton.titleLabel.font = [UIFont systemFontOfSize:10];
        self.cpySelButton.titleLabel.numberOfLines = 2;
        [self.cpySelButton setTitle:@"复制\n仅选择" forState:UIControlStateNormal];
        [self.cpySelButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [self.cpySelButton setTitleColor:UIColor.redColor forState:UIControlStateHighlighted];
        self.cpySelButton.layer.cornerRadius = self.cpySelButton.frame.size.height / 2;
        self.cpySelButton.layer.borderColor = UIColor.lightGrayColor.CGColor;
        self.cpySelButton.layer.borderWidth = 0.5;
        self.cpySelButton.layer.masksToBounds = YES;
        self.cpySelButton.backgroundColor = UIColor.whiteColor;
        self.cpySelButton.tag = kTagButton + SYLogViewControlTypeCopySelected;
        [self.cpySelButton addTarget:self action:@selector(buttonTapClick:) forControlEvents:UIControlEventTouchUpInside];
        self.cpySelButton.enabled = NO;
        currentView = self.cpySelButton;
        // 发邮件选择
        self.emailSelButton = [[UIButton alloc] initWithFrame:CGRectMake((currentView.frame.origin.x + currentView.frame.size.width + origin), currentView.frame.origin.y, widthButton, heightText)];
        [_buttonView addSubview:self.emailSelButton];
        self.emailSelButton.titleLabel.font = [UIFont systemFontOfSize:10];
        self.emailSelButton.titleLabel.numberOfLines = 2;
        [self.emailSelButton setTitle:@"发邮件\n仅选择" forState:UIControlStateNormal];
        [self.emailSelButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [self.emailSelButton setTitleColor:UIColor.redColor forState:UIControlStateHighlighted];
        self.emailSelButton.layer.cornerRadius = self.emailSelButton.frame.size.height / 2;
        self.emailSelButton.layer.borderColor = UIColor.lightGrayColor.CGColor;
        self.emailSelButton.layer.borderWidth = 0.5;
        self.emailSelButton.layer.masksToBounds = YES;
        self.emailSelButton.backgroundColor = UIColor.whiteColor;
        self.emailSelButton.tag = kTagButton + SYLogViewControlTypeEmailSelected;
        [self.emailSelButton addTarget:self action:@selector(buttonTapClick:) forControlEvents:UIControlEventTouchUpInside];
        self.emailSelButton.enabled = NO;
    }
    return _buttonView;
}

- (void)crashClick:(UIButton *)button
{
    self.searchTextField.text = @"crash";
    [UIApplication.sharedApplication.delegate.window endEditing:YES];
    [self searchWithText:self.searchTextField.text];
    [self reloadData];
}
- (void)cancelClick:(UIButton *)button
{
    if (self.showType == SYLogViewShowTypeImmediately) {
        [self addNotificationAddModel];
    }
    
    [UIApplication.sharedApplication.delegate.window endEditing:YES];
    //
    self.searchTextField.text = @"";
    //
    self.isSearch = NO;
    [self.searchArray removeAllObjects];
    [self reloadData];
    
    __block CGRect rect = self.searchTextField.frame;
    [UIView animateWithDuration:0.3 animations:^{
        rect.size.width = (self.buttonView.frame.size.width - rect.origin.x * 2);
        self.searchTextField.frame = rect;
        button.alpha = 0;
        self.crashButton.alpha = 0;
    }];
}

- (void)selClick:(UIButton *)button
{
    button.selected = !button.selected;
    self.isSelected = button.selected;
    if (button.selected) {
        self.cpySelButton.enabled = YES;
        self.emailSelButton.enabled = YES;
    } else {
        self.cpySelButton.enabled = NO;
        self.emailSelButton.enabled = NO;
        for (SYLogModel *model in self.array) {
            model.selected = NO;
        }
        [self reloadData];
    }
}

- (void)buttonTapClick:(UIButton *)button
{
    if (self.buttonClick) {
        SYLogViewControlType type = button.tag - kTagButton;
        self.buttonClick(type, self.array);
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.showType == SYLogViewShowTypeImmediately) {
        // 避免搜索时还在刷新界面，导致无法进行编辑
        [self removeNotificationAddModel];
    }
    
    self.isSearch = YES;
    [self reloadData];
    //
    __block CGRect rect = self.searchTextField.frame;
    [UIView animateWithDuration:0.3 animations:^{
        rect.size.width = (self.buttonView.frame.size.width - self.searchTextField.frame.origin.x * 4 - self.cancelButton.frame.size.width * 2);
        self.searchTextField.frame = rect;
        self.cancelButton.alpha = 1;
        self.crashButton.alpha = 1;
    }];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIApplication.sharedApplication.delegate.window endEditing:YES];
    [self searchWithText:textField.text];
    [self reloadData];
    
    return YES;
}

- (NSMutableArray *)searchArray
{
    if (_searchArray == nil) {
        _searchArray = [[NSMutableArray alloc] init];
    }
    return _searchArray;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [UIApplication.sharedApplication.delegate.window endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.showType == SYLogViewShowTypeImmediately) {
        [self removeNotificationAddModel];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.showType == SYLogViewShowTypeImmediately) {
        [self addNotificationAddModel];
    }
}

- (void)searchWithText:(NSString *)text
{
    [self.searchArray removeAllObjects];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"attributeString.string CONTAINS %@", text];
    NSArray *array = [self.array filteredArrayUsingPredicate:predicate];
    // 默认选中crash
    for (SYLogModel *model in array) {
        NSString *text = model.attributeString.string;
        NSRange range = [text rangeOfString:keyCrash];
        if (range.location != NSNotFound) {
            model.selected = YES;
        }
    }
    [self.searchArray addObjectsFromArray:array];
}

#pragma mark - setter

- (void)setArray:(NSMutableArray *)array
{
    pthread_mutex_lock(&mutexLock);
    _array = array;
    pthread_mutex_unlock(&mutexLock);
    if (self.isSearch) {
        return;
    }
    //
    [self reloadLogView];
}

- (void)setShowControl:(BOOL)showControl
{
    _showControl = showControl;
    if (_showControl) {
        self.tableHeaderView = self.buttonView;
    } else {
        self.tableHeaderView = nil;
    }
    self.contentOffset = CGPointZero;
}

#pragma mark - 方法通知

- (void)addModel:(SYLogModel *)model
{
    if (model) {
        pthread_mutex_lock(&mutexLock);
        [self.array insertObject:model atIndex:0];
        pthread_mutex_unlock(&mutexLock);
        if (self.isSearch) {
            return;
        }
        
        [self postNotificationAddModel];
    }
}

static NSString *const kNotificationName = @"reloadTableWhileAddModel";
- (void)postNotificationAddModel
{
    [NSNotificationCenter.defaultCenter postNotificationName:kNotificationName object:nil];
}

- (void)addNotificationAddModel
{
    [self removeNotificationAddModel];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(reloadLogView) name:kNotificationName object:nil];
}

- (void)removeNotificationAddModel
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:kNotificationName object:nil];
}

@end


