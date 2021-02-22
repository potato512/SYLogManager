//
//  ViewController.m
//  DemoLog
//
//  Created by zhangshaoyu on 2018/10/12.
//  Copyright © 2018年 zhangshaoyu. All rights reserved.
//

#import "ViewController.h"
#import "SYLogManager.h"
#import "Person.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSTimer *timer;
//
@property (nonatomic, strong) NSArray *crashArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [button setTitle:@"显示" forState:UIControlStateNormal];
    [button setTitle:@"隐藏" forState:UIControlStateSelected];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button setTitleColor:UIColor.redColor forState:UIControlStateSelected];
    [button addTarget:self action:@selector(showClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *showItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithTitle:@"next" style:UIBarButtonItemStyleDone target:self action:@selector(nextClick)];
    UIBarButtonItem *logItem = [[UIBarButtonItem alloc] initWithTitle:@"log" style:UIBarButtonItemStyleDone target:self action:@selector(logClick)];
    UIBarButtonItem *clearItem = [[UIBarButtonItem alloc] initWithTitle:@"auto" style:UIBarButtonItemStyleDone target:self action:@selector(autoClick)];
    self.navigationItem.rightBarButtonItems = @[nextItem, clearItem, logItem, showItem];
    //
    [self crashTable];
}

- (void)dealloc
{
    NSLog(@"%@ 被释放了~", self.class);
}

- (void)showClick:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        SYLogManager.shareLog.show = YES;
    } else {
        SYLogManager.shareLog.show = NO;
    }
}

- (void)nextClick
{
    ViewController *nextVC = [ViewController new];
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (NSArray *)array
{
    return @[@"创始人跑路，办公点人去楼空，又一互联网巨头倒下了", @"香港修例风波延宕至今，900余场游行集会活动，不少演变成严重暴力违法行为。繁华街市沦为“战区”，大学校园惨遭“洗礼”，“黑色恐怖”阴霾不散，香港的社会秩序与经济发展已在暴徒投掷的燃烧弹中烟熏火燎、千疮百孔，刺痛着所有珍爱她的心。近六个月了，假“自由”“民主”之名的暴力并没有“给文明以岁月”，却正要把家园故土拉入黑暗沉沦的旋涡，“回头望望，沧海茫茫”，看看如今的东方之珠，还是我们曾经引以为傲的“爱人”吗？", @"技术不是万能药，不要过分依赖", @"40岁失业程序员，面试失败后，当场流泪，太心酸了", @"2015年，深圳全市跨境电商交易额达到333.95亿美元，同比增长95.98%。2016年1月，国务院常务会议决定在深圳等12个城市新设跨境电子商务综合试验区。"];
}

- (void)logClick
{
    NSLog(@"array: %@", self.array);
    
    NSDictionary *dict = @{@"姓名":@"张三", @"职业":@"农二代", @"年龄":@(30), @"company":@"个体"};
    NSLog(@"dict: %@", dict);
    
    NSArray *arrayDict = @[self.array, dict];
    NSLog(@"arrayDict: %@", arrayDict);
    
    if (self.navigationController.viewControllers.count > 5) {
        NSLog(@"text: %@", [self.array objectAtIndex:20]);
        [SYLogManager.shareLog logText:[NSString stringWithFormat:@"text: %@", [self.array objectAtIndex:20]] key:NSStringFromClass(self.class)];
    }
    
    Person *person = [[Person alloc] init];
    person.name = @"小明";
    person.job = @"研发工程师";
    person.age = @"28";
    person.company = @"BYD Auto";
    person.project = @[@"project1", @"王者荣耀", @"跑跑卡丁车", @"逃离神庙", @"吃鸡"];
    person.learn = @{@"开发":@"Objective-C", @"project":@(10), @"team":@[@"张三", @"李四", @"wangWu", @"小明"]};
    NSLog(@"person: %@", person.objectDescription);
    
//    [SYLogManager.shareLog logText:person.objectDescription key:NSStringFromClass(self.class)];
    SYLog(YES, NSStringFromClass(self.class), @"%@", person.objectDescription);
}

- (void)autoClick
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    } else {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(printLog) userInfo:nil repeats:YES];
    }
}
NSInteger count = 0;
- (void)printLog
{
    NSLog(@"timer count = %@", @(count));
    count++;
    NSString *string = self.array[arc4random() % self.array.count];
    SYLog(YES, @"计时保存SYLog", @"%@", string);
    SYLogSave(YES, @"计时保存SYLogSave", string);
    if (count >= 10) {
        count = 0;
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)saveFile
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = pathArray.firstObject;
    filePath = [filePath stringByAppendingPathComponent:@"file.txt"];
    NSLog(@"filePath = %@", filePath);
    
//    NSArray *array = @[@"张三", @"李四", @"wangWu", @"小明"];
    //
    Person *person = [[Person alloc] init];
    person.name = @"小明";
    person.job = @"研发工程师";
    person.age = @"28";
    person.company = @"BYD Auto";
    person.project = @[@"project1", @"王者荣耀", @"跑跑卡丁车", @"逃离神庙", @"吃鸡"];
    person.learn = @{@"开发":@"Objective-C", @"project":@(10), @"team":@[@"张三", @"李四", @"wangWu", @"小明"]};
    NSArray *array = @[person];
    //
    BOOL result = [array writeToFile:filePath atomically:NO];
    NSLog(@"保存情况：%d", result);
    
    NSArray *temps = [NSArray arrayWithContentsOfFile:filePath];
    NSLog(@"%@", temps);
}

#pragma mark - crash

- (void)crashTable
{
    UITableView *table = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:table];
    table.delegate = self;
    table.dataSource = self;
    table.tableFooterView = [UIView new];
}

- (NSArray *)crashArray
{
    return @[@"数组越界", @"数组nil值", @"未定义方法"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.crashArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    NSString *test = self.crashArray[indexPath.row];
    cell.textLabel.text = test;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:{
            [self crashOutofSize];
        } break;
        case 1:{
            [self crashNilValue];
        } break;
        case 2:{
            [self crashSelector];
        } break;
        default:
            break;
    }
}

- (void)crashOutofSize
{
    NSInteger random = arc4random() % 100;
    NSString *text = self.array[100];
}

- (void)crashNilValue
{
    NSString *text = nil;
    NSArray *list = @[@"1",text];
}

- (void)crashSelector
{
    [self performSelector:@selector(pushClick)];
}

@end
