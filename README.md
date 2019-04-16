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
SYLogManagerSingle.autoClear = YES;
[SYLogManagerSingle initializeLog];
SYLogManagerSingle.showView = self.window;
SYLogManagerSingle.show = YES;
~~~ 

# 修改完善
* 20190416
  * 版本号：1.0.0
  * 添加源码