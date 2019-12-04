//
//  ViewController.m
//  HAMLogOutputWindowDemo
//
//  Created by DaiYue’s Macbook on 16/11/9.
//  Copyright © 2016年 Find the Lamp Studio. All rights reserved.
//

#import "ViewController1.h"
#import "HAMStatisticsManager.h"

@interface ViewController1 ()

@end

@implementation ViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [HAMStatisticsManager event:@"leftViewController_visited"];
}

#pragma mark - Actions

- (IBAction)buttonTapedAction:(UIButton*)sender {
    [HAMStatisticsManager event:@"button_tapped" label:sender.currentTitle];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HAMStatisticsManager event:@"延迟加载"];
    });
}

@end
