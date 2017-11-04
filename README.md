# simulation-init.d
===========================
这个项目提供的脚本可能是一个世界上兼容性最差，速度最慢的模拟 init.d 行为的脚本
甚至它要正常工作的话都需要安装 busybox 才能用

****
	
启用完整版脚本方法：
1. 下载完整版脚本和配置文件
2. 准备好 RootExplorer 或者其他可以对 /system 分区挂载读写并进行操作的文件管理器（如果你拥有 RootExplorer 之类的文件管理器无视这步）
3. 把下载好的 run-simulation-init.d 移动到 /system/etc 下
4. 对移动到 /system/etc 下的 run-simulation-init.d 赋予 0755 权限和所有者与群组均为 root 的权限归属设定
5. 把 /system/bin/debuggerd64 加上 _original.bak 的后缀
6. 软链接 /system/etc/run-simulation-init.d 到 /system/bin/debuggerd64
7. 在 /system/etc 下建立一个名为 init.d 的文件夹，并赋予 0755 权限和所有者与群组均为 root 的权限归属设定
8. 把下载好的 Settings 文件放在 /sdcard/simulation-init.d 下即可
<STRIKE>以下有废话倾向</STRIKE>
9. 在 /system/etc/init.d 下放置你想每一次开机都会运行的脚本吧
10. 更改 Settings 文件的键值内容可以设置脚本功能

重启手机试一试，看看 /sdcard/simulation-init.d/log下有没有生成 log 文件？
或者在 /sdcard 下就能找到

如果找到了生成的 log 文件
那么开始享用吧

****
	
你想问基础功能版本的脚本安装方法？
安装脚本正在路上
虽然不知道我会拖到什么时候就是了

