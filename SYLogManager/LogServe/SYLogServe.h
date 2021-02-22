//
//  SYLogServe.h
//  DemoLog
//
//  Created by zhangshaoyu on 2021/2/20.
//  Copyright © 2021 zhangshaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 数据model

@interface SYLogCrashModel : NSObject

/// 应用名称
@property (nonatomic, strong) NSString *logAppName;
/// 应用版本
@property (nonatomic, strong) NSString *logAppVersion;
/// 应用设备类型（1 iPhone，2 Android）
@property (nonatomic, strong) NSNumber *logDeviceType;
/// 应用设备系统（iOS，Android）
@property (nonatomic, strong) NSString *logDeviceSystem;
/// 应用设备系统版本，iOS14
@property (nonatomic, strong) NSString *logDeviceSystemV;
/// 应用设备名称
@property (nonatomic, strong) NSString *logDeviceName;

/// 上传时间
@property (nonatomic, strong) NSString *logUploadTime;
/// 上传内容
@property (nonatomic, strong) NSString *logMessage;
/// 备注
@property (nonatomic, strong) NSString *logMark;

/// 用户名
@property (nonatomic, strong) NSString *logUserName;
/// 用户设备ID，如车架号
@property (nonatomic, strong) NSString *logUserVin;

/// 自定义 应用设备类型（1 iPhone，2 Android）
@property (nonatomic, strong, readonly) NSString *logDeviceTypeName;
/// 自定义 系统id
@property (nonatomic, strong) NSString *logID;


@end

#pragma mark - 数据服务

@interface SYLogServe : NSObject

- (instancetype)init;

/// 初始化
- (void)logCarashInitialize;

/// 保存数据
- (void)logCrashSaveWithModel:(SYLogCrashModel *)model complete:(void (^)(BOOL isSuccessful, NSError *error))complete;
/// 修改数据（更新备注）
- (void)logCrashUpdateWithModel:(SYLogCrashModel *)model complete:(void (^)(BOOL isSuccessful, NSError *error))complete;

/// 获取数据
- (void)logCrashReadWithPage:(NSInteger)page size:(NSInteger)size complete:(void (^)(NSArray <SYLogCrashModel *>*array, NSError *error))complete;

@end

/*
 1)将BmobSDK引入项目:

 在你的XCode项目工程中，添加BmobSDK.framework

 2)添加使用的系统framework:

 在你的XCode工程中Project ->TARGETS -> Build Phases->Link Binary With Libraries引入
 2.1)CoreLocation.framework
 2.2)Security.framework
 2.3)CoreGraphics.framework
 2.4)MobileCoreServices.framework
 2.5)CFNetwork.framework
 2.6)CoreTelephony.framework
 2.7)SystemConfiguration.framework
 2.8)libz.1.2.5.tbd
 2.9)libicucore.tbd
 2.10)libsqlite3.tbd
 2.11)libc++.tbd
 2.12)photos.framework
 
 */
NS_ASSUME_NONNULL_END
