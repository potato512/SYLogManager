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

static CGFloat const originXY = 10;
static CGFloat const heightText = (25 + 25);
#define widthText (UIScreen.mainScreen.bounds.size.width - originXY * 2)

@interface SYLogModel : NSObject

//
@property (nonatomic, strong) NSAttributedString *attributeString;
@property (nonatomic, assign) CGFloat height;

- (instancetype)initWithlog:(NSString *)text key:(NSString *)key;

@end

@interface SYLogFile : NSObject

/// 记录（最多5000条）
@property (nonatomic, strong, readonly)  NSArray *logs;

- (SYLogModel *)logWith:(NSString *)text key:(NSString *)key;
- (void)read;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
