//
//  ViewController.m
//  DemoLog
//
//  Created by zhangshaoyu on 2018/10/12.
//  Copyright © 2018年 zhangshaoyu. All rights reserved.
//

#import "ViewController.h"
#import "SYLogManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self showInfo];
    
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithTitle:@"next" style:UIBarButtonItemStyleDone target:self action:@selector(nextClick)];
    UIBarButtonItem *showItem = [[UIBarButtonItem alloc] initWithTitle:@"show" style:UIBarButtonItemStyleDone target:self action:@selector(showClick)];
    UIBarButtonItem *clearItem = [[UIBarButtonItem alloc] initWithTitle:@"clear" style:UIBarButtonItemStyleDone target:self action:@selector(clearClick)];
    self.navigationItem.rightBarButtonItems = @[nextItem, clearItem, showItem];
}

- (void)dealloc
{
    NSLog(@"%@ 被释放了~", self.class);
}

- (void)showInfo
{
    NSArray *array = @[@"张三", @"李四", @"wangWu", @"小明"];
    NSLog(@"array: %@", array);
    
    NSDictionary *dict = @{@"姓名":@"张三丰", @"职业":@"研发工程师", @"年龄":@(35), @"company":@"BYD Auto"};
    NSLog(@"dict: %@", dict);
    
    if (self.navigationController.viewControllers.count > 5) {
        NSLog(@"text: %@", [array objectAtIndex:20]);
    }
    
    NSLog(@"123");
}

- (void)nextClick
{
    ViewController *next = [[ViewController alloc] init];
    [self.navigationController pushViewController:next animated:YES];
}

- (void)showClick
{
    SYLogManagerSingle.show = YES;
}

- (void)clearClick
{
    [SYLogManagerSingle clearLog];
}

@end
