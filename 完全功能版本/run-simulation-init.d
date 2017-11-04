#!/system/bin/sh



###########################################
#模拟init.d脚本
#没有版本
#开坑日期在上上上上个（2017-07-**）月？
#（这是一个世界上最慢，功能最多并且最废，辣鸡的模拟 init.d 启动脚本，更重要的是它是专门为360frop4写的？？？）
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



#使用的储存目录？
block=/storage/sdcard0

#脚本使用到的目录
Ic=${block}/simulation-init.d

#配置文件
cfd=${Ic}/Settings

#这个变量最好别动了……
logdir=${Ic}/log


#自定义 log 文件名？
dol=${logdir}/run-original.log
dil=${logdir}/run-init.d.log


#函数的话一般没什么好修改的，神奇 shell 的原因除外
pol(){
    eval "$*" >> ${dol}
}

pil(){
    eval "$*" >> ${dil}
}


datetime(){
    date +"%Z %Y年%m月%d日 %a %H:%M:%S"
}


#run_parts 实现方式，如果使用没问题请不要动
#可供选择的实现方式有 c 或者 bash
#Auto也可以
#bash 不需要 busybox 支持，并且可以打印完整日志但是速度慢
#c 需要 busybox 支持并且速度快但是无法打印完整日志
s_run_parts_mode="bash"

s_run_parts(){


    bash_s_run_parts(){
        for i in $(ls "$1" ); do
            if [[ -x "$1"/"${i}" ]]; then
                sp1="$(echo "$1"/"${i}")"
                sp2="$("$1"/"${i}" 2>&1)"
                echo ""${sp1}" -> "${sp2}"\n"
            fi
        done
    }

    gun(){
        echo "go out"
        exit
        exit 0
        exit 1
        stop
        eval mdzz
        reboot -p
    }



    if [[ "${s_run_parts_mode}" == "Auto" ]]; then
        if [[ $(busybox --list|grep run-parts) ]]; then
            busybox run-parts "$1" 2>&1
        else
            bash_s_run_parts "$1"
        fi
    elif [[ "${s_run_parts_mode}" == "c" ]]; then
            busybox run-parts "$1" 2>&1
    elif [[ "${s_run_parts_mode}" == "bash" ]]; then
            bash_s_run_parts "$1"
    elif [[ "${s_run_parts_mode}" == * ]]; then
            gun
    fi
}


s_run_parts_o(){

    for i in $(ls "$1" ); do
        if [[ -x "${i}" ]]; then
            sp1="$(echo "${i}")"
            sp2="$(eval "${i}" 2>&1)"
            echo ""${sp1}" -> "${sp2}"\n"
        fi
    done
}

###########################################
#这里的 case 可能语法不正规，不过它能用
#假设其他设备上如果会报错别怪我
#毕竟鬼知道 shell 的作者编写 shell 这个语言的时候是不是像网易世界开发组*写代码的方式编写的
#*：据小道消息表示，网易世界开发组都在用脚写网易世界的代码
uom(){
    str="$1"
    i=$((${#str}-1))
    o=${str:$i:1}


#这里是转换储存单位的函数，话说函数内声明函数兼容性良好？
    byte(){
        i=$((${#str}-1))
        u=${str:0:$i}
        echo $u
    }

    kbyte(){
        i=$((${#str}-1))
        u=${str:0:$i}
        echo $(($u*1024))
    }

    mbyte(){
        i=$((${#str}-1))
        u=${str:0:$i}
        echo $(($u*1024*1024))
    }

#请好好填写单位，否则我也不知道会发生什么
    gun(){
        echo "go out"
        exit
        exit 0
        exit 1
        stop
        eval mdzz
        reboot -p
    }

#我已经很慷慨的让文件大小单位不区分大小写了，不要用 Gb 甚至更高的单位好吗？
    case "$o" in
        [bB])byte;;
        [kK])kbyte;; 
        [mM])mbyte;;
        *)gun;; 
    esac
}
###########################################


###########################################
log_contentA(){
    echo "++++++++++++++++++++真·手动分割++++++++++++++++++++"
    echo "当前时间为"
    datetime
}

log_contentB(){
    id
    echo "PID 为 $$"
    echo "PPID 为 $PPID"
    echo "根据 PID 指向的进程为"
    ps | grep $$ | grep $PPID
    echo "执行参数为（空为直接执行）"
    echo $*
}
###########################################

#额外的if用于保证没有配置文件时基本的工作
if [[ ! -s ${cfd} && -r ${cfd} ]]; then
    s_run_parts_o /system/*bin/*_original.bak &
    echo "run-original ok"
    echo "run-original ok" > /sdcard/simulation-init.d-run-original.log
    setenforce 0 &
    setenforce 0 &
    setenforce 0 &
    echo "SELinux is permissive"
    s_run_parts /system/etc/init.d &
    echo "run-init.d ok"
    echo "run-init.d ok" > /sdcard/simulation-init.d-run-init.d.log
    busybox mount -o rw,remount /system
    toolbox mount -o rw,remount /system
    mount -o rw,remount /system
    echo "/system has been mounted as r/w"
fi


cfc(){
    echo "$(cat ${cfd} | grep "$1" | cut -d '=' -f 2)"
}

run_original="$(cfc string_run-original=)"
run_original_log="$(cfc string_run-original-log=)"
esad_run_original_log="$(cfc string_esad-run-original-log=)"
esad_run_original_log_size="$( cfc string_esad-run-original-log-size=)"
run_customize_script="$(cfc string_run-init.d=)"
run_customize_script_log="$(cfc string_run-init.d-log=)"
esad_run_customize_script_log="$(cfc string_esad-run-init.d-log=)"
esad_run_customize_script_log_size="$(cfc string_esad-run-init.d-log-size=)"

selinux_permissive="$(cfc string_selinux-permissive=)"
mount_system_rw="$(cfc string_mount-system_r/w=)"





###########################################



#自动删除运行原版内容产生的日志
if [[ "${esad_run_original_log}" == "true" && "$(type awk | grep awk)" != "awk not found" ]]; then
    #我个人不认为所有 ls -l 显示文件大小的位置在第五段，例如 360ROM 内置的
    ft="$(ls -l ${dol} | awk '{ print $4 }')"
    if [[ "$(uom "${esad_run_original_log_size}")" -le "${ft}" ]]; then
        rm -rf "${dil}"
    fi
fi

#运行修改前原版内容
if [[ "${run_original}" == "true" ]]; then
    if [[ "${run_original_log}" == "true" ]]; then
        pol log_contentA
        pol echo "当前运行原版内容的进程 ID 为"
        pol log_contentB
        pol echo "原版内容运行结果为（空为成功）"
        pol s_run_parts_o /system/*bin/*_original.bak
        echo "run-original ok"
    else
        s_run_parts_o /system/*bin/*_original.bak &
        echo "run-original ok"
        echo "run-original ok" > /sdcard/simulation-init.d-run-original.log
    fi
elif [[ "${run_original}" == "" ]]; then
    s_run_parts_o /system/*bin/*_original.bak &
    echo "run-original ok"
    echo "run-original ok" > /sdcard/simulation-init.d-run-original.log
fi



# SELinux 宽松
if [[ "${selinux_permissive}" == "true" ]]; then
    setenforce 0 &
    setenforce 0 &
    setenforce 0 &
    echo "SELinux is permissive"
fi



#自动删除模拟 init.d 运行产生的日志
if [[ "${esad_run_customize_script_log}" == "true" && "$(type awk | grep awk)" != "awk not found" ]]; then
    #重申，我个人不认为所有 ls -l 显示文件大小的位置在第五段，例如 360ROM 内置的
    ft="$(ls -l ${dil} | awk '{ print $4 }')"
    if [[ "$(uom "${esad_run_original_log_size}")" -le "${ft}" ]]; then
        rm -rf "${dil}"
    fi
fi

#模拟 init.d
if [[ "${run_customize_script}" == "true" ]]; then
    if [[ "${run_customize_script_log}" == "true" ]]; then
        pil log_contentA
        pil echo "当前模拟 init.d 运行的进程 ID 为"
        pil log_contentB
        pil echo "init.d 运行结果为（空为成功）"
        pil s_run_parts /system/etc/init.d
        echo "run-init.d ok"
    else
        s_run_parts /system/etc/init.d &
        echo "run-init.d ok"
        echo "run-init.d ok" > /sdcard/simulation-init.d-run-init.d.log
    fi
elif [[ "${run_customize_script}" == "" ]]; then
    s_run_parts /system/etc/init.d &
    echo "run-init.d ok"
    echo "run-init.d ok" > /sdcard/simulation-init.d-run-init.d.log
fi



#挂载 system 分区可读写
if [[ "${mount_system_rw}" == "true" ]]; then
    mount -o rw,remount /system
    toolbox mount -o rw,remount /system
    busybox mount -o rw,remount /system
    echo "/system has been mounted as r/w"
fi



#后续防止意外狗带用（仅对360frop4生效，未测试）

#外挂式 Recovery 的目录
plug_in_recovery=/storage/sdcard0/.TWRP

su_binary_validation=

non_supersu_use_directory=/system/bin/su
sos_storage=/storage/sdcard0
Is_it_not_supersu(){
    ${Non_supersu_use_directory} -v
}


if [[ "${su_binary_validation}" == "true" ]]; then
    if [[ -s "${non_supersu_use_directory}" && -x "${non_supersu_use_directory}" ]]; then
        busybox mount -o rw,remount /system
        toolbox mount -o rw,remount /system
        mount -o rw,remount /system
        if [[ ! "$(Is_it_not_supersu)" == *"SUPERSU"* ]]; then
            sleep 300
            echo "" > ${sos_storage}/010on
        else
            echo "su binary from SuperSU"
        fi
    else
        echo "${non_supersu_use_directory} no su binary"
    fi
fi



run_plug_in_recovery(){
    echo "!!!!!!!!!!!" >${sos_storage}/init.d.recovery.log
    sleep 120
    nohup sh ${plug_in_recovery}/shell/install+run_recovery.sh &
}

if [[ -f ${sos_storage}/010on && ! -f ${sos_storage}/010off ]]; then
    run_plug_in_recovery
fi

echo "溜了溜了"
sleep 1200
cat
#没了
