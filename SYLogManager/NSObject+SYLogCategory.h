//
//  NSObject+SYLogCategory.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/4/17.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SYLogCategory)

/// 对象信息（需要主动调用）
- (NSString *)objectDescription;

@end

NS_ASSUME_NONNULL_END
