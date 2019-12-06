//
//  ViewController.m
//  HAMLogOutputWindowDemo
//
//  Created by DaiYue’s Macbook on 16/11/9.
//  Copyright © 2016年 Find the Lamp Studio. All rights reserved.
//

#import "ViewController1.h"
#import "HAMStatisticsManager.h"
#import "SYLogManager/SYLogFile.h"

@interface ViewController1 ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger timeNumber;

@end

@implementation ViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.height, self.navigationController.navigationBar.frame.size.height)];
    [button setTitle:@"显示" forState:UIControlStateNormal];
    [button setTitle:@"隐藏" forState:UIControlStateSelected];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *showItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithTitle:@"next" style:UIBarButtonItemStyleDone target:self action:@selector(nextClick)];
    UIBarButtonItem *autoItem = [[UIBarButtonItem alloc] initWithTitle:@"auto" style:UIBarButtonItemStyleDone target:self action:@selector(autoClick)];
    self.navigationItem.rightBarButtonItems = @[nextItem, showItem, autoItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [HAMStatisticsManager event:@"leftViewController_visited"];
    
    NSInteger count = self.navigationController.viewControllers.count;
    if (count == 10) {
        NSLog(@"%s-%d", __func__, self.navigationController.viewControllers[1000]);
    }
}

 - (void)loadView
{
    [super loadView];
    self.view.backgroundColor = UIColor.whiteColor;
}

#pragma mark - Actions

- (IBAction)buttonTapedAction:(UIButton*)sender {
    [HAMStatisticsManager event:@"button_tapped" label:sender.currentTitle];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HAMStatisticsManager event:@"延迟加载"];
    });
    
    NSLog(@"tag = %d", sender.tag);

}

- (void)showClick:(UIButton *)button
{
    button.selected = !button.selected;
    SYLogManager.shareLog.show = button.selected;
}
- (NSArray *)arraylogs
{
    return @[@"昨天，参加商业活动的任达华，被突然闯上台的男子刺伤，瞬间成为爆炸新闻。",@"最近有消息称，苹果或将于明年推出配有屏下指纹的新iPhone手机，这也就代表着没有刘海的全面屏iPhone要来了，但是面部识别也同样保留。",@"从iPhone X开始，苹果就用刷脸取代了指纹识别。随着三星、华为等非苹指标厂都已导入屏下指纹辨识，实现了所谓的“全面屏手机”，成为一大卖点，现在苹果开始思索将屏下指纹识别也正式加入iPhone手机中。",@"今年共享单车市场推出了共享电动助力车，对于一些路途“步行太远，坐车太近”的上班族来说，一辆助力电动车既能解决上班高峰的拥堵问题，又不需要耗费太多体力，十分方便。不过前不久因为市政交通政策限制，各个品牌的电动助力车都被禁止在市区骑行。对于很多年轻人来说，又要面对挤爆公交地铁，开车堵到迟到的痛苦日子。这个时候，小米发布了一款新的出行产品：骑记电动助力自行车。",@"昨天，参加商业活动的任达华，被突然闯上台的男子刺伤，瞬间成为爆炸新闻。"];
}

- (void)nextClick
{
    [SYLogManager.shareLog logText:self.arraylogs[arc4random() % self.arraylogs.count]];
    
    ViewController1 *nextVC = [ViewController1 new];
    nextVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nextVC animated:YES];
}


- (void)autoClick
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(showLog) userInfo:nil repeats:YES];
}
- (void)showLog
{
    self.timeNumber++;
    for (NSInteger index = 0; index < arc4random() % 10 + 1; index++) {
        NSString *string = [NSString stringWithFormat:@"%ld--%ld--%@", (long)self.timeNumber, (long)index, self.arraylogs[arc4random() % self.arraylogs.count]];
        [SYLogManager.shareLog logText:string];
    }
    if (self.timeNumber >= 100) {
        self.timeNumber = 0;
        [self.timer invalidate];
        self.timer = nil;
        [SYLogManager.shareLog logText:@"停止记时"];
    }
}


@end
