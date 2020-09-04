# SYLogManager
log日志查看工具。

### 特点：
* log日志实时显示
* log日志显示时，可设置界面交互，或禁止界面交互
* log日志缓存在本地
* log日志可复制，并粘贴到其他应用，如微信，QQ 等
* log日志可发送邮件
* log日志可清空
* log日志除自定义信息外，还定制实现了 crash 信息，并显示相关的设备等信息
* 通过关键词，搜索过滤需要查看的 log日志

> `查看日志`按钮可拖动的任意位置；'release' 模式下，不记录 log 日志；

# 使用介绍
* 自动导入：使用命令`pod 'SYLogManager'`导入到项目中
* 手动导入：或下载源码后，将源码添加到项目中


# 代码示例
~~~ javascript
// 导入头文件
#import "SYLogManager.h"
~~~

~~~ javascript
// 显示等设置
SYLogConfig *config = [SYLogConfig new];
config.logEmail = @"151311301@qq.com";
config.logColor = UIColor.greenColor;
config.logController = self.window.rootViewController;
config.logShowView = self.window;
config.logShow = YES;
config.logEnable = YES;

// 配置
SYLogManager.shareLog.config = config;
 
// 显示，或隐藏
SYLogManager.shareLog.show = YES;
SYLogManager.shareLog.show = NO;

// 使用
[SYLogManager.shareLog logText:@"hello world~"];
[SYLogManager.shareLog logText:@"hello world~" key:@"001")];
SYLogSave(YES, @"网络", @"正在进行网络请求");
// 或
SYLog(YES, @"人物", @"%@", @"小明");
SYLog(YES, @"花草", @"%@", @"牡丹蝴蝶");
~~~ 

效果图

![SYLogManager.gif](./SYLogManager.gif) 

# 待修改-收集
* 20200902
  * crash搜索默认选中
  * 修改方法名：SYLogPopoverView-DegreesToRadians，改成SYLogDegreesToRadians

# 修改完善
* 20200902
  * 版本号：1.5.0
  * 修改优化
    * 菜单栏简化：显示、滚动、控制、删除
    * 交互优化：
      * 新增crash搜索
      * 控制（搜索、复制全部、发邮件全部、编辑、复制所选、发邮件所选）

* 20200901
  * 版本号：1.4.0
  * 修改优化
    * 中控台信息打印不全
    * 搜索
      * 开启时可交互
      * 关闭时禁止交互
      * 筛选复制
      * 筛选发邮件

* 20200822
  * 版本号：1.3.2
  * 修改优化
    * 搜索优化（时间、内容、分类）
    
* 20200821
  * 版本号：1.3.1
  * 修改优化
    * 搜索控制显示，或隐藏
    * 自定义父视图（解决黑屏bug）

* 20191231
  * 版本号：1.2.9 1.3.0
  * 修改优化
    * 实时快速显示时，闪退修复
    * 新增非实时显示
    * 修改实时刷新策略
    * 实时显示时，界面显示异常修改

* 20191227
  * 版本号：1.2.8
  * 修改优化
    * 初始化NO时，也不显示
    * bug修复
    
* 20191226
  * 版本号：1.2.7
  * 修改优化
    * 闪退高亮红色显示
    * 搜索显示时，闪退修复
    * 去掉属性`logEnable`
    * 修改初始化方法为`- (void)config:(BOOL)enable;`
    * 新增宏定义（即可中控打印显示，又log日志记录）`SYLog(logEnable, logKey, format, ...)`

* 20191225
  * 版本号：1.2.5 1.2.6
  * 修改优化
    * 添加属性`logEnable`

* 20191212
  * 版本号：1.2.2 1.2.3 1.2.4
  * 修改优化
    * 异常修改
    
* 20191208
  * 版本号：1.2.1
  * 修改优化
    * 缓存文件名格式为：应用包名_logFile.db
    * 条件过滤
    * 自动区分 deg 和 release 模式

* 20191207
  * 版本号：1.2.0
  * 修改优化
    * 修改缓存处理（sqlite）
    * 优化交互界面
      * 操作菜单自适应：显示/隐藏、滚动响应、删除、复制、发邮件
      * 实时显示
      * 显示过程中可操作，或禁止操作

* 20191126
  * 版本号：1.1.3
  * 修改完善
    * 新增联调/模拟器模式开关
    * 修改log缓存默认目录
    * 打开时显示滚动后的位置

* 20190916
  * 版本号：1.1.2
  * 修改完善
  
* 20190901
  * 版本号：1.1.1
  * 修改优化
    * 初始化log接收邮件地址

* 20190725
  * 版本号：1.1.0
  * 功能完善
    * 新增拖动时关闭悬浮窗口
    
* 20190521
  * 版本号：1.0.7 1.0.8 1.0.9
  * 功能完善
    * 发送邮件
    
* 20190425
  * 版本号：1.0.6
  * 功能完善
  
* 20190417
  * 版本号：1.0.2 1.0.3 1.0.4 1.0.5
  * 功能完善
    * 显示对象信息
    
* 20190416
  * 版本号：1.0.0 1.0.1
  * 添加源码