//
//  SYLogEmail.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/4/17.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EamilState) {
    EamilStatePermission = 0,
    EamilStateSuccess = 1,
    EamilStateFailed = 2,
    EamilStateCancel = 3,
    EamilStateCache = 4
};

@interface SYLogEmail : NSObject

// 邮箱-接收
@property (nonatomic, strong) NSString *emailReceive;
// 邮箱-发送
@property (nonatomic, strong) NSString *emailSend;
@property (nonatomic, strong) NSString *emailMessage;

- (void)sendEmailWithTarget:(id)target complete:(void (^)(NSInteger state))complete;

@end

NS_ASSUME_NONNULL_END
