#!/system/bin/sh -x



###########################################
#模拟init.d脚本简版
#没有版本
#开坑日期在2017-11-04 20:05
#恭喜这个脚本成为了一个仅为模拟 init.d 行为服务的脚本，虽然内置禁用 SELinux
#制作 by funnypro
#感谢以下人员指导与技术援助（排序不分先后）
# @manhong2112 & @zt515 & @rote66（所有User_id 均取自 Github）
#
#手动分割
#
#本脚本主要用于 360f4（360-1501_M02或者是360-1501_A02）上
#本脚本依靠软链接 debuggerd64 来工作，理论上应该比依靠 install-recovery.sh 执行优先级高一点
#如果要替换 debuggerd 或者其他类似东西的话，记得重命名为 <原文件名>*_original.bak
#不过你也可以软链接一个 install-recovery2.sh （使用 SuperSU 为 root 授权时）让本脚本工作
#如果希望本脚本正常工作的话最好安装 busybox ，否则我也不知道会怎样
###########################################



s_run_parts(){

sd="$1"

    for i in $(ls "${sd}" ); do
    [[ -x "${sd}"/"${i}" ]] && "${sd}"/"${i}"
    done
}


selinux_permissive="true"


/system/*bin/*_original.bak &
echo "run-original ok"


# SELinux 宽松
if [[ "${selinux_permissive}" == "true" ]]; then
    setenforce 0 &
    setenforce 0 &
    setenforce 0 &
    echo "SELinux is permissive"
fi

s_run_parts /system/etc/init.d &
echo "run-init.d ok"



echo "溜了溜了"
sleep 1200
cat
#没了
