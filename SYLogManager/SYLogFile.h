//
//  SYLogFile.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/4/15.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const keyCrash = @"crash闪退奔溃";

static CGFloat const originXY = 10;
static CGFloat const heightText = (25 + 25);
#define widthText (UIScreen.mainScreen.bounds.size.width - originXY * 2)

@interface SYLogModel : NSObject

@property (nonatomic, assign) NSString *logTime;
@property (nonatomic, strong) NSString *logText;
@property (nonatomic, strong) NSString *logKey;
//
@property (nonatomic, strong) NSAttributedString *attributeString;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) BOOL selected;

- (instancetype)initWithlog:(NSString *)text key:(NSString *)key;

@end

@interface SYLogFile : NSObject

/// 记录（最多500条，倒序）
@property (nonatomic, strong, readonly) NSArray *logs;
/// crash记录
@property (nonatomic, strong, readonly) NSArray *logsCrash;

- (SYLogModel *)logWith:(NSString *)text key:(NSString *)key;
- (void)read;
- (void)clear;
/// 条件删除（key = model.logText）
- (void)clearWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
