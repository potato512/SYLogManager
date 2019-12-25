//
//  SYLogView.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/4/15.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import "SYLogView.h"

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

@interface SYLogView () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, assign) BOOL isSearch;
//
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation SYLogView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.tableFooterView = [UIView new];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.scrollEnabled = YES;
        [self registerClass:SYLogCell.class forCellReuseIdentifier:NSStringFromClass(SYLogCell.class)];
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

#pragma mark - 交互

- (void)scrollToBottom
{
    NSInteger count = self.array.count;
    if (count > 1) {
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

#pragma mark - delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.searchView.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.searchView;
}

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
        return cell;
    }
    
    SYLogCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(SYLogCell.class)];
    cell.label.textColor = (self.colorLog ? self.colorLog : UIColor.darkGrayColor);
    SYLogModel *model = self.array[indexPath.row];
    cell.model = model;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - getter

- (UIView *)searchView
{
    if (_searchView == nil) {
        CGFloat top = 20;
        if (@available(iOS 11.0, *)) {
            UIWindow *window = [UIApplication sharedApplication].delegate.window;
            if (window.safeAreaInsets.bottom > 0.0) {
                // 是机型iPhoneX/iPhoneXR/iPhoneXS/iPhoneXSMax
                top = 44;
            }
        }
        _searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, (top + 48))];
        _searchView.backgroundColor = UIColor.clearColor;
        //
        self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, (top + 5), (_searchView.frame.size.width - 40), (_searchView.frame.size.height - top - 10))];
        [_searchView addSubview:self.searchTextField];
        self.searchTextField.layer.cornerRadius = self.searchTextField.frame.size.height / 2;
        self.searchTextField.layer.masksToBounds = YES;
        self.searchTextField.backgroundColor = UIColor.whiteColor;
        self.searchTextField.placeholder = @"请输入过滤词";
        self.searchTextField.textColor = UIColor.blackColor;
        self.searchTextField.font = [UIFont systemFontOfSize:15];
        self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.searchTextField.frame.size.height)];
        leftView.backgroundColor = UIColor.clearColor;
        self.searchTextField.leftView = leftView;
        self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
        self.searchTextField.returnKeyType = UIReturnKeySearch;
        self.searchTextField.delegate = self;
        //
        self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake((_searchView.frame.size.width - 20 - 60), (top + 5), 60, (_searchView.frame.size.height - top - 10))];
        [_searchView addSubview:self.cancelButton];
        self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:UIColor.redColor forState:UIControlStateHighlighted];
        self.cancelButton.layer.cornerRadius = self.cancelButton.frame.size.height / 2;
        self.cancelButton.layer.masksToBounds = YES;
        self.cancelButton.backgroundColor = UIColor.whiteColor;
        [self.cancelButton addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
        self.cancelButton.alpha = 0.0;
    }
    return _searchView;
}

- (void)cancelClick:(UIButton *)button
{
    [UIApplication.sharedApplication.delegate.window endEditing:YES];
    //
    self.searchTextField.text = @"";
    //
    self.isSearch = NO;
    [self.searchArray removeAllObjects];
    [self reloadData];
    
    __block CGRect rect = self.searchTextField.frame;
    [UIView animateWithDuration:0.3 animations:^{
        rect.size.width = (self.searchView.frame.size.width - 40);
        self.searchTextField.frame = rect;
        button.alpha = 0;
    }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.isSearch = YES;
    [self reloadData];
    //
    __block CGRect rect = self.searchTextField.frame;
    [UIView animateWithDuration:0.3 animations:^{
        rect.size.width = (self.searchView.frame.size.width - 40 - 60 - 20);
        self.searchTextField.frame = rect;
        self.cancelButton.alpha = 1;
    }];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIApplication.sharedApplication.delegate.window endEditing:YES];
    [self.searchArray removeAllObjects];
    //
    NSString *text = textField.text;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"logText CONTAINS %@", text];
    NSArray *array = [self.array filteredArrayUsingPredicate:predicate];
    [self.searchArray addObjectsFromArray:array];
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

#pragma mark - setter

- (void)setArray:(NSMutableArray *)array
{
    _array = array;
    [self reloadData];
    [self scrollToBottom];
}

@end


