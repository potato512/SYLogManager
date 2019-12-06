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

@interface SYLogView () <UITableViewDelegate, UITableViewDataSource>

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYLogModel *model = self.array[indexPath.row];
    CGFloat height = (originXY + model.height);
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

#pragma mark - setter

- (void)setArray:(NSMutableArray *)array
{
    _array = array;
    [self reloadData];
    [self scrollToBottom];
}

@end


