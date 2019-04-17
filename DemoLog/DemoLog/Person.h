//
//  Person.h
//  DemoLog
//
//  Created by zhangshaoyu on 2019/4/17.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *age;
@property (nonatomic, strong) NSString *job;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSArray *project;
@property (nonatomic, strong) NSDictionary *learn;

@end

NS_ASSUME_NONNULL_END
