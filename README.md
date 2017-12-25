# simulation-init.d



简介：  
从某些方面讲，这个项目可能算是 [360f4复活大法][funnypro/3mptros] 的附属项目

这个项目提供的脚本可能是一个世界上兼容性最差，速度最慢的模拟 init.d 行为的脚本  
甚至要让脚本正常工作的话好像还要安装 [busybox][meefik/busybox]

___

制做相关：  
作者 by @funnypro  
感谢以下人员指导与技术援助（排序不分先后）  
@manhong2112 & @zt515 & @rote66（所有User_id 均取自 Github）  

___

说明：   
本脚本默认依靠硬链接 debuggerd64 来工作，按照惯例比依靠 install-recovery.sh 执行优先级高一点  
如果要替换其他类似东西的话，记得重命名为 <原文件名>_original.bak  
不过你也可以软链接一个 install-recovery-2.sh （必须是使用 SuperSU 为 root 授权时）让本脚本工作  
不过这个判定我懒得写，很有可能会属于有生之年系列  
不想写的主要原因是SuperSU自带su.d  
其次是如果有什么东西使用了的话判定可能会麻烦不少  

___

使用方法：
  
1. 下载脚本和 [终端][zt515/Ansole] 以及 [busybox][meefik/busybox]
2. 安装 [终端][zt515/Ansole] 和 [busybox][meefik/busybox]
3. 把脚本复制到任意位置并使用任意文件管理器添加可执行权限
4. 复制脚本的路径并粘贴在 [终端][zt515/Ansole] （记得把终端打开）
5. 使用参数 `-h` 执行一次之后你就知道应该怎么做了，也可以直接使用 `-i` 参数完成安装
6. 按照提示检查脚本是否安装成功
7. 成功后就开始享受 init.d 的便利吧，如果出现问题请向我反馈

___

注意事项：  
  
1. 如果你的设备安装了 [Magisk][topjohnwu/Magisk] ，你应该不需要这个脚本，也不要使用这个脚本，因为 [Magisk][topjohnwu/Magisk] 有类似功能  
2. 如果希望脚本正常工作的话最好安装 [busybox][meefik/busybox] ，否则我也不知道会发生什么  
3. 如果一样脚本在 `Android M` 以上正常工作可能必须关闭 `SELinux` 否则可能会导致无法正常开机  
这个问题理论上的解决方案：在 [Re文件管理器][speedsoftware/rootexplorer] 尝试设置依靠源最开始的 `SE上下文` 在脚本和依靠源以尝试规避 `SELinux` 的限制问题导致的无法正常开机问题  
4. 尚不明确

  
  
免责：  
使用本项目提供的脚本前记得备份重要数据，否则后果自负  
使用本项目提供的脚本出现任何意外我都有权不负责的……  
虽然我会尽力帮你解决那些意外  


*******************
[funnypro/3mptros]:https://github.com/funnypro/360f4
[meefik/busybox]:https://github.com/meefik/busybox/releases
[zt515/Ansole]:http://www.coolapk.com/apk/com.romide.terminal
[topjohnwu/Magisk]:https://github.com/topjohnwu/MagiskManager/releases
[bin/mtfileManager]:http://www.coolapk.com/apk/bin.mt.plus
[speedsoftware/rootexplorer]:http://www.coolapk.com/apk/com.speedsoftware.rootexplorer
