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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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
    
    NSDictionary *dict = @{@"姓名":@"张三", @"职业":@"农二代", @"年龄":@(30), @"company":@"个体"};
    NSLog(@"dict: %@", dict);
    
    NSArray *arrayDict = @[array, dict];
    NSLog(@"arrayDict: %@", arrayDict);
    
    if (self.navigationController.viewControllers.count > 5) {
        NSLog(@"text: %@", [array objectAtIndex:20]);
        [SYLogManager.shareLog logText:[NSString stringWithFormat:@"text: %@", [array objectAtIndex:20]] key:NSStringFromClass(self.class)];
    }
    
    Person *person = [[Person alloc] init];
    person.name = @"小明";
    person.job = @"研发工程师";
    person.age = @"28";
    person.company = @"BYD Auto";
    person.project = @[@"project1", @"王者荣耀", @"跑跑卡丁车", @"逃离神庙", @"吃鸡"];
    person.learn = @{@"开发":@"Objective-C", @"project":@(10), @"team":@[@"张三", @"李四", @"wangWu", @"小明"]};
    NSLog(@"person: %@", person.objectDescription);
    
    [SYLogManager.shareLog logText:person.objectDescription key:NSStringFromClass(self.class)];
    
}

- (void)nextClick
{
    ViewController *next = [[ViewController alloc] init];
    [self.navigationController pushViewController:next animated:YES];
}

- (void)showClick
{
    [self showInfo];
}

- (void)clearClick
{
 
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

@end
