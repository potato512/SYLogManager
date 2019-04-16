//
//  NSDictionary+SYLogCategory.m
//  DemoLog
//
//  Created by zhangshaoyu on 2019/4/15.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import "NSDictionary+SYLogCategory.h"

@implementation NSDictionary (SYLogCategory)

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSMutableString *str = [NSMutableString stringWithString:@"(\n"];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [str appendFormat:@"\t%@ = %@;\n", key, obj];
    }];
    [str appendString:@")"];
    return str;
}

@end
