//
//  SYLogServe.m
//  DemoLog
//
//  Created by zhangshaoyu on 2021/2/20.
//  Copyright © 2021 zhangshaoyu. All rights reserved.
//

#import "SYLogServe.h"
#import "BmobSDK.framework/Headers/Bmob.h"

static NSString *const kAppKey = @"e9d47506a346a6f118c0d38346d7498b";
static NSString *const kCacheTable = @"AppCrashTable";

#pragma mark - 数据model

@implementation SYLogCrashModel

- (NSString *)logDeviceTypeName
{
    NSString *text = @"未定义";
    switch (self.logDeviceType.integerValue) {
        case 1: text = @"iPhone"; break;
        case 2: text = @"Android"; break;
        default:
            break;
    }
    return text;
}

@end

#pragma mark - 数据服务

@implementation SYLogServe

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

NSString *logValidText(NSString *text)
{
    if ([text isKindOfClass:NSString.class] && text.length > 0) {
        return text;
    }
    return @"未定义";
}

/// 初始化
- (void)logCarashInitialize
{
    [Bmob registerWithAppKey:kAppKey];
}

/// 保存数据
- (void)logCrashSaveWithModel:(SYLogCrashModel *)model complete:(void (^)(BOOL isSuccessful, NSError *error))complete
{
    if (model == nil) {
        if (complete) {
            complete(NO, nil);
        }
        return;
    }
    
    // 在 AppCrashTable 创建一条数据，如果当前没 AppCrashTable 表，则会创建 AppCrashTable 表
    BmobObject *crashObject = [BmobObject objectWithClassName:kCacheTable];
    // 保存信息
    NSString *logAppName = model.logAppName;
    NSString *logAppVersion = model.logAppVersion;
    NSString *logDeviceName = model.logDeviceName;
    NSNumber *logDeviceType = model.logDeviceType;
    NSString *logDeviceSystem = model.logDeviceSystem;
    NSString *logDeviceSystemV = model.logDeviceSystemV;
    NSString *logUploadTime = model.logUploadTime;
    NSString *logMessage = model.logMessage;
    NSString *logUserName = model.logUserName;
    NSString *logUserVin = model.logUserVin;
    //
    [crashObject setObject:logValidText(logAppName) forKey:@"logAppName"];
    [crashObject setObject:logValidText(logAppVersion) forKey:@"logAppVersion"];
    [crashObject setObject:logDeviceType forKey:@"logDeviceType"];
    [crashObject setObject:logValidText(logDeviceSystem) forKey:@"logDeviceSystem"];
    [crashObject setObject:logValidText(logDeviceSystemV) forKey:@"logDeviceSystemV"];
    [crashObject setObject:logValidText(logUploadTime) forKey:@"logUploadTime"];
    [crashObject setObject:logValidText(logMessage) forKey:@"logMessage"];
    [crashObject setObject:logValidText(logDeviceName) forKey:@"logDeviceName"];
    [crashObject setObject:logValidText(logUserName) forKey:@"logUserName"];
    [crashObject setObject:logValidText(logUserVin) forKey:@"logUserVin"];
    
    // 异步保存到服务器
    [crashObject saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (complete) {
            complete(isSuccessful, error);
        }
    }];
}

/// 修改数据（更新备注）
- (void)logCrashUpdateWithModel:(SYLogCrashModel *)model complete:(void (^)(BOOL isSuccessful, NSError *error))complete
{
    if (model == nil) {
        if (complete) {
            complete(NO, nil);
        }
        return;
    }
   
    // 查找 AppCrashTable 表
    BmobQuery *bquery = [BmobQuery queryWithClassName:kCacheTable];
    // 查找 AppCrashTable 表里面id为 model.logID 的数据
    [bquery getObjectInBackgroundWithId:model.logID block:^(BmobObject *object, NSError *error){
      // 没有返回错误
      if (!error) {
          // 对象存在
          if (object) {
              BmobObject *result = [BmobObject objectWithoutDataWithClassName:object.className objectId:object.objectId];
              // 设置备注
              NSString *mark = model.logMark;
              [result setObject:mark forKey:@"logMark"];
              // 异步更新数据
              [result updateInBackgroundWithResultBlock:complete];
          }
      } else {
          // 进行错误处理
          if (complete) {
              complete(NO, error);
          }
      }
    }];
}

/// 获取数据
- (void)logCrashReadWithPage:(NSInteger)page size:(NSInteger)size complete:(void (^)(NSArray <SYLogCrashModel *>*array, NSError *error))complete
{
    // 查找 AppCrashTable 表的数据
    BmobQuery *cacheBquery = [BmobQuery queryWithClassName:kCacheTable];
    // 分页查询
    cacheBquery.limit = size;
    cacheBquery.skip = ((page - 1) * size);
    // 异步查找
    [cacheBquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (complete) {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            for (BmobObject *object in array) {
                NSString *logAppName = [object objectForKey:@"logAppName"];
                NSString *logAppVersion = [object objectForKey:@"logAppVersion"];
                NSString *logDeviceName = [object objectForKey:@"logDeviceName"];
                NSNumber *logDeviceType = [object objectForKey:@"logDeviceType"];
                NSString *logDeviceSystem = [object objectForKey:@"logDeviceSystem"];
                NSString *logDeviceSystemV = [object objectForKey:@"logDeviceSystemV"];
                NSString *logUploadTime = [object objectForKey:@"logUploadTime"];
                NSString *logMessage = [object objectForKey:@"logMessage"];
                NSString *logUserName = [object objectForKey:@"logUserName"];
                NSString *logUserVin = [object objectForKey:@"logUserVin"];
                NSString *logID = [object objectForKey:@"objectId"];
                NSString *logMark = [object objectForKey:@"logMark"];
                //
                SYLogCrashModel *model = [[SYLogCrashModel alloc] init];
                model.logAppName = logAppName;
                model.logAppVersion = logAppVersion;
                model.logDeviceName = logDeviceName;
                model.logDeviceType = logDeviceType;
                model.logDeviceSystem = logDeviceSystem;
                model.logDeviceSystemV = logDeviceSystemV;
                model.logUploadTime = logUploadTime;
                model.logMessage = logMessage;
                model.logUserName = logUserName;
                model.logUserVin = logUserVin;
                model.logID = logID;
                //
                [list addObject:model];
            }
            complete(list, error);
        }
    }];
}

@end
