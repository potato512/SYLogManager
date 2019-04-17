//
//  NSObject+SYLogCategory.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/4/17.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import "NSObject+SYLogCategory.h"
#import <objc/runtime.h>

@implementation NSObject (SYLogCategory)

- (NSString *)description
{
    NSString *desc = @"\n{";
    //
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (int i = 0; i < outCount; i ++) {
        objc_property_t property = properties[i];
        //获取property的C字符串
        const char * propName = property_getName(property);
        if (propName) {
            //获取NSString类型的property名字
            NSString *prop = [NSString stringWithCString:propName encoding:[NSString defaultCStringEncoding]];
            //获取property对应的值
            id obj = prop;
            if ([self respondsToSelector:@selector(valueForKey:)]) {
                obj = [self valueForKey:prop];
            }
            //将属性名和属性值拼接起来
            desc = [desc stringByAppendingFormat:@"%@: %@,\n",prop,obj];
        }
    }
    desc = [desc stringByAppendingFormat:@"}\n"];
    free(properties);
    
    return desc;
}

@end
