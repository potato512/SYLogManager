//
//  NSArray+SYLogCategory.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/4/15.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import "NSArray+SYLogCategory.h"

@implementation NSArray (SYLogCategory)

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSMutableString *str = [NSMutableString stringWithString:@"(\n"];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [str appendFormat:@"\t%@,\n", obj];
    }];
    [str appendString:@")"];
    return str;
}

@end
