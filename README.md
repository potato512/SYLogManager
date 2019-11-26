# SYLogManager
log日志查看。


# 使用介绍
* 自动导入：使用命令`pod 'SYLogManager'`导入到项目中
* 手动导入：或下载源码后，将源码添加到项目中


# 代码示例
~~~ javascript
#import "SYLogManager.h"
~~~

~~~ javascript
[SYLogManagerSingle initializeLog];
SYLogManagerSingle.showView = self.window;
SYLogManagerSingle.target = self.window.rootViewController;
SYLogManagerSingle.email = @"151311301@qq.com";
SYLogManagerSingle.show = YES;
~~~ 

$ 待开发功能
* 上传指定服务器
* 发送指定邮箱
* 显示对象信息

# 修改完善
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