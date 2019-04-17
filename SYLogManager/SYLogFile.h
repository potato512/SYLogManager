//
//  SYLogFile.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/4/15.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYLogFile : NSObject

@property (nonatomic, strong) NSString *filePath;

- (void)saveLogMessage;
- (void)deleteLogMessage;
//
- (void)readLogMessage:(void (^)(NSString *message))complete;

@end

NS_ASSUME_NONNULL_END
