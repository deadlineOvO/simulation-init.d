#!/system/bin/sh



###########################################
#模拟init.d脚本
#没有版本
#开坑日期大概是2017-07-**
#（这是一个世界上最慢，功能最多并且最废，辣鸡的模拟 init.d 启动脚本，更重要的是它是专门为360frop4写的？？？）
#制作 by funnypro
#感谢以下人员指导与技术援助（排序不分先后）
# @manhong2112 & @zt515 & @rote66（所有User_id 均取自 Github）
#项目地址：https://github.com/funnypro/simulation-init.d
#
#手动分割
#
#本脚本主要用于 360f4（360-1501_M02或者是360-1501_A02）上，如果出现意外可以向我反馈
#本脚本默认依靠硬链接 debuggerd64 来工作，按照惯例比依靠 install-recovery.sh 执行优先级高一点
#如果要替换其他类似东西的话，记得重命名为 <原文件名>_original.bak
#不过你也可以软链接一个 install-recovery2.sh （必须是使用 SuperSU 为 root 授权时）让本脚本工作
#不过这个判定我懒得写，很有可能会属于有生之年系列
#
#注意：
#如果你的设备支持 Magisk 的话，你应该不需要这个脚本，也不要使用这个脚本
#如果希望本脚本正常工作的话最好安装 busybox ，否则我也不知道会怎样
###########################################




#使用的储存目录？
block="/storage/sdcard0"

#脚本使用到的目录
Ic="${block}/simulation-init.d"

#配置文件
cfd="${Ic}/Settings.ini"

#这个变量最好别动了……
logdir="${Ic}/log"




if [[ "${0}" == "*/install-simulation-init.d" ]]; then

    
    help(){
        echo "使用方法：[第一参数] [第二参数] [第三参数]"
        echo "第一参数："
        echo "    -i, --install         安装这个脚本"
        echo "    -h, --help            你当前看到的东西"
        echo "没有第一参数会模拟init.d行为"
        echo "第二参数："
        echo "    -h                    使用硬链接来链接脚本和依靠源"
        echo "    -s                    使用软链接来链接脚本和依靠源"
        echo "    -n                    直接把脚本移动到依靠源的位置"
        echo "第三参数："
        echo "    -c                    设置 chattr 保护权限，不填写则为不设置"
        echo "注意："
        echo "如果第二参数和第三参数都不填写，那么它们的默认值分别为 -h 和 -c"
        echo "理论上 -c 可以放在第二参数，不过按照标准它应该在第三参数，并且当第二参数为 -c 时，默认使用 -h 参数"
    }

    First_one(){
        First_argument="install"
    }

    case "${1}" in
    "-h")
        help
    ;;
    "-i")
        First_one
    ;;
    "--help")
        help
    ;;
    "--install")
        First_one
    ;;
    *)
        help
        exit 1
    ;;
    esac
fi



if [[ "${First_argument}" == "install" ]]; then
    
    
    
    msrw(){
      mount -o remount,rw /system
      toolbox mount -o remount,rw /system
      if [[ $(busybox --list | grep "mount") == "mount" ]]; then
          busybox mount -o remount,rw /system
      fi
    }
    
    
    choon(){
        chmod 7755 "${1}"
        chmod 7755 "${1}"
        chown 0:2000 "${1}"
    }
    
    
    echoAccess(){
    
        lsEcho=$(ls -l "${1}")
        
        
        access="${lsEcho:1:9}"
        echo "${access}"
        
        #owner="${access:0:3}"
        #usergroup="${owner:3:3}"
        #others="${usergroup:6:6}"
    }
    
    
        
    check(){
        if [[ -f "${1}" && -s "${1}" ]]; then
            chmod 0444 "${1}"
            sleep 0.2
            if [[ $(echoAccess "${1}") == "r--r--r--" ]]; then
                h_file="${1}"
                choon "${1}"
            else
                echo "${1} 被占用"
            fi
        else
            echo "${1} 不可用"
        fi
    }
    
    
    
    
    msrw
    
    etc="/system/etc"
    sinitsh="${etc}/run-simulation-init.d"
    
    irss=$(cat /*.* | grep "flash_recovery" | grep "install-recovery.sh")
    irsf="${irss:23:31}"
    sinite='if [[ $(cat "/system/etc/run-simulation-init.d" | grep -E  "^#依靠 debuggerd(64)? 启动$") == "#依靠 debuggerd*" ]];then /system/etc/run-simulation-init.d;fi'
    
    if [[ $(cat "${irsf}" | grep -F "${sinite}")  == "${sinite}" && -x "${irsf}" && -w "${irsf}" ]]; then
        h_file="install-recovery.sh-y"
    else
        check "${irsf}"
    fi
    
    
    
    exec_chattr(){
        if [[ $(type "chattr") != "chattr not found" ]]; then
            chattr "${@}"
        elif [[ $(busybox --list | grep "chattr") == "chattr" ]]; then
            busybox chattr "${@}"
        else
            echo "chattr 不存在" 1>&2
        fi
    }
    
    restore(){
        if [[ -f "${1}" && -s "${1}" && -x "${1}" ]]; then
            exec_chattr "-i" "-a" "-A" "${2}"
            rm -rf "${2}" $?
            mv "${1}" "${2}"
        fi
    }
    
    
    
    
    
    
    bin="/system/bin"
    
    
    dg="${bin}/debuggerd"
    dgo="${dg}_original.bak"
    restore "${dgo}" "${dg}"
    check "${dg}"
    
    
    dg64="${bin}/debuggerd64"
    dg64o="${dg64}_original.bak"
    restore "${dg64o}" "${dg64}"
    check "${dg64}"
    
    
    
    
    
    
    rmsinitsh(){
        if [[ -e "${sinitsh}" ]]; then
            exec_chattr "-i" "-a" "-A" "${sinitsh}"
            rm -rf "${sinitsh}"
        fi
    }
    
    
    
    sinitsho="${0}"
    
    
    link_mode="${2}"
    chattr_mode="${3}"
    link_file(){
        if [[ "${link_mode}" == "-h" ]]; then
            ln "${1}" "${2}"
        elif [[ "${link_mode}" == "-s" ]]; then
            ln -s "${1}" "${2}"
        elif [[ "${link_mode}" == "-n" ]]; then
            cp -rf "${1}" "${2}"
            sinitsh="${2}"
        elif [[ "${link_mode}" == "-c" && "${chattr_mode}" == "" ]]; then
            ln "${1}" "${2}"
        elif [[ "${link_mode}" == "" && "${chattr_mode}" == "" ]]; then
            ln "${1}" "${2}"
        else
            ln "${1}" "${2}"
            echo "可能是因为你输入了错误的参数，所以自动给你选择硬链接"
        fi
    }
    
    chattr_file(){
        if [[ "${chattr_mode}" == "-c" ]]; then
            exec_chattr "+i" "+a" "+A" "${1}"
        elif [[ "${chattr_mode}" == "" && "${link_mode}" == "-c" ]]; then
            exec_chattr "+i" "+a" "+A" "${1}"
        elif [[ "${chattr_mode}" == "" && "${link_mode}" == "" ]]; then
            exec_chattr "+i" "+a" "+A" "${1}"
        else
            echo "看起来你不想进行设置 chattr 权限"
        fi
    }
    
    install_initd(){
        msrw
        choon "${sinitsh}"
        echo "#依靠 ${1} 启动" >> "${sinitsh}"
        chattr_file "${sinitsh}"
        
        
        
        initdir="${etc}/init.d"
        if [[ -d "${initdir}" ]]; then
            choon "${initdir}"
        elif [[ -f "${initdir}" ]]; then
            mv "${initdir}" "${initdir}_original.bak"
            echo "我不清楚这是怎么回事，不过还是建立了原 ${initdir} 的备份"
            mkdir "${initdir}"
            choon "${initdir}"
        else
            mkdir "${initdir}"
            choon "${initdir}"
        fi
        
        
        if [[ -d "${lc}" ]]; then
            bingin="0"
        elif [[ -f "${lc}" ]]; then
            mv "${lc}" "${lc}_original.bak"
            mkdir "${lc}"
        else
            mkdir "${lc}"
        fi
        
        
        if [[ -d "${logdir}" ]]; then
            bingin="1"
        elif [[ -f "${logdir}" ]]; then
            mv "${logdir}" "${logdir}_original.bak"
            mkdir "${logdir}"
        else
            mkdir "${logdir}"
        fi
        
        cfdString(){
             echo "#SELinux是否为许可模式"
             echo "string_selinux-permissive=true"
             echo "\n"
             echo "#是否执行原版内容"
             echo "string_run-original=true"
             echo "\n"
             echo "#是否模拟 init.d 工作"
             echo "string_run-init.d=true"
             echo "\n"
             echo "#是否记录执行原版内容产生的所有日志"
             echo "string_run-original-log=true"
             echo "\n"
             echo "#是否记录 init.d 工作时产生的所有日志"
             echo "string_run-init.d-log=true"
             echo "\n"
             echo "#是否在执行原版内容日志超过一定大小时自动删除它"
             echo "string_esad-run-original-log=true"
             echo "\n"
             echo "#是否在 init.d 工作时产生的日志超过一定大小时删除它"
             echo "string_esad-run-init.d-log=true"
             echo "\n"
             echo "#自动删除原版内容产生日志的大小（可用单位：b;k;m）（不区分大小写）"
             echo "string_esad-run-original-log-size=64k"
             echo "\n"
             echo "#自动删除 init.d 工作日志的大小（可用单位：b;k;m）（不区分大小写）"
             echo "string_esad-run-init.d-log-size=64k"
             echo "\n"
             echo "#是否开机自动让system挂载为可读写"
             echo "string_mount-system_r/w=true"
             echo "\r"
        }
        if [[ -f  "${cfd}" && -s "${cfd}" ]]; then
            bingin="2"
        elif [[ -d "${cfd}" ]]; then
            mv "${cfd}" "{$cfd}_original.bak"
            cfdString >"${cfd}"
        else
            cfdString >"${cfd}"
        fi
        
        
        echo "请重启手机\n重启手机后到 ${logdir} 目录下查看是否生成 run-original.log 文件\n生成代表成功，没有代表失败。\n成功后可以从配置文件文件关闭 log 生成"
        exit 0
    }
    
    
    
    
    debuggerd_install(){
        msrw
        mv "${1}" "${2}"
        choon "${2}"
        rmsinitsh
        cp -rf "${sinitsho}" "${sinitsh}"
        link_file "${sinitsh}" "${1}"
        install_initd "${3}"
    }
    
    
    
    if [[ "${h_file}" == "${dg64}" ]]; then
        debuggerd_install "${dg64}" "${dg64o}" "debuggerd64"
        
    elif [[ "${h_file}" == "${dg}" ]]; then
        debuggerd_install "${dg}" "${dgo}" "debuggerd"
        
    elif [[ "${h_file}" == "${irsf}" ]]; then
        msrw
        chmod 7755 "${irsf}"
        rmsinitsh
        echo "${sinite}" >>"${irsf}"
        install_initd "install-recovery.sh"
        
    elif [[ "${h_file}" == "install-recovery.sh-y" ]]; then
        msrw
        rmsinitsh
        install_initd "install-recovery.sh"
        
    else
        echo "我觉得你可能需要一部 MI6 或者是 =6T 用于搭配 Magisk"
        echo "问我为啥？"
        echo "这个脚本好像不能在你的设备上起作用"
        echo "也有可能是这个制杖落了什么东西导致的"
        exit 1
    fi
    
fi






#自定义 log 文件名？
dol="${logdir}/run-original.log"
dil="${logdir}/run-init.d.log"


#函数的话一般没什么好修改的，神奇 shell 的原因除外
pol(){
    eval "$*" >> ${dol}
}

pil(){
    eval "$*" >> ${dil}
}





###########################################

#额外的if用于保证没有配置文件时基本的工作
if [[ ! -s ${cfd} && -r ${cfd} ]]; then
    s_run_parts_o /system/*bin/*_original.bak
    echo "run-original ok"
    setenforce 0 &
    setenforce 0 &
    setenforce 0 &
    echo "SELinux is permissive"
    s_run_parts /system/etc/init.d
    echo "run-init.d ok"
    busybox mount -o rw,remount /system
    toolbox mount -o rw,remount /system
    mount -o rw,remount /system
    echo "/system has been mounted as r/w"
    
    echo "溜了溜了"
    sleep 1200
    cat
    #没了
fi


cfc(){
    echo "$(cat ${cfd} | grep "$1" | cut -d '=' -f 2)"
}



###########################################




#这里的 case 可能语法不正规，不过它能用
#假设其他设备上如果会报错别怪我
#毕竟鬼知道 shell 的作者编写 shell 这个语言的时候是不是像网易世界开发组*写代码的方式编写的
#*：据小道消息表示，网易世界开发组都在用脚写网易世界的代码
uom(){
    str="${1}"
    i=$(("${#str}"-1))
    o=${str:"${i}":1}


#这里是转换储存单位的函数，话说函数内声明函数兼容性良好？
    byte(){
        i=$(("${#str}"-1))
        u=${str:0:"${i}"}
        echo "${u}"
    }

    kbyte(){
        i=$(("${#str}"-1))
        u="${str:0:${i}}"
        echo $(("${u}"*1024))
    }

    mbyte(){
        i=$(("${#str}"-1))
        u=${str:0:"${i}"}
        echo $(("${u}"*1024*1024))
    }


#我已经很慷慨的让文件大小单位不区分大小写了，不要用 Gb 甚至更高的单位好吗？
    case "$o" in
        [bB])
            byte
        ;;
        [kK])
            kbyte
        ;;
        [mM])
            mbyte
        ;;
        *)
            gun
        ;; 
    esac
}

#自动删除运行原版内容产生的日志
esad_run_original_log="$(cfc string_esad-run-original-log=)"
if [[ "${esad_run_original_log}" == "true" && "$(type awk | grep awk)" != "awk not found" ]]; then
    #我个人不认为所有 ls -l 显示文件大小的位置在第五段，例如 360ROM 内置的
    ft="$(ls -l ${dol} | awk { print $4 })"
    esad_run_original_log_size="$( cfc string_esad-run-original-log-size=)"
    if [[ "$(uom ${esad_run_original_log_size})" -le "${ft}" ]]; then
        rm -rf "${dil}"
    fi
fi



timedate(){
    date +"%Z %Y年%m月%d日 %a %H:%M:%S"
}

log_content(){
    echo "++++++++++++++++++++真·手动分割++++++++++++++++++++"
    echo "当前时间为"
    timedate
    echo "${1}"
    id
    echo "PID 为 $$"
    echo "PPID 为 $PPID"
    echo "根据 PID 指向的进程为"
    ps | grep $$ | grep $PPID
    echo "执行参数为（空为直接执行）"
    echo $*
    echo "${2}"
    eval "${3}"
}

s_run_parts_o(){

    for i in $(ls "$1" ); do
        if [[ -x "${i}" ]]; then
            sp1="$(echo ${i})"
            sp2="$(${i} 2>&1)"
            echo "${sp1} => ${sp2}\n"
        fi
    done
}

#运行修改前原版内容
run_original="$(cfc string_run-original=)"
if [[ "${run_original}" == "true" ]]; then
    run_original_log="$(cfc string_run-original-log=)"
    if [[ "${run_original_log}" == "true" ]]; then
        pol log_content "当前运行原版内容的进程 ID 为" "原版内容运行结果为（空为成功）" s_run_parts_o /system/*bin/*_original.bak
        echo "run-original ok"
    else
        s_run_parts_o /system/*bin/*_original.bak
        echo "run-original ok"
    fi
elif [[ "${run_original}" == "" ]]; then
    s_run_parts_o /system/*bin/*_original.bak
    echo "run-original ok"
fi



# SELinux 宽松
mount_system_rw="$(cfc string_mount-system_r/w=)"
if [[ "${selinux_permissive}" == "true" ]]; then
    setenforce 0
    setenforce 0
    setenforce 0
    echo "SELinux is permissive"
fi



#自动删除模拟 init.d 运行产生的日志
esad_run_customize_script_log="$(cfc string_esad-run-init.d-log=)"
if [[ "${esad_run_customize_script_log}" == "true" && "$(type awk | grep awk)" != "awk not found" ]]; then
    #重申，我个人不认为所有 ls -l 显示文件大小的位置在第五段，例如 360ROM 内置的
    ft="$(ls -l ${dil} | awk { print $4 })"
    esad_run_customize_script_log_size="$(cfc string_esad-run-init.d-log-size=)"
    if [[ "$(uom ${esad_run_original_log_size})" -le "${ft}" ]]; then
        rm -rf "${dil}"
    fi
fi


#run_parts 实现方式，如果使用没问题请不要动
#可供选择的实现方式有 c 或者 bash
#Auto也可以
#bash 不需要 busybox 支持，并且可以打印完整日志但是速度慢
#c 需要 busybox 支持并且速度快但是无法打印完整日志
s_run_parts_mode="bash"


#请好好填写标准值，否则我也不知道会发生什么
gun(){
    echo "go out"
    exit 1
    stop
    eval mdzz
    reboot -p
}

s_run_parts(){


    bash_s_run_parts(){
        for i in $(ls "$1" ); do
            if [[ -x "$1"/"${i}" ]]; then
                sp1="$(echo "$1"/"${i}")"
                sp2="$("$1"/"${i}" 2>&1)"
                echo ""${sp1}" => "${sp2}"\n"
            fi
        done
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

#模拟 init.d
run_customize_script="$(cfc string_run-init.d=)"
if [[ "${run_customize_script}" == "true" ]]; then
    run_customize_script_log="$(cfc string_run-init.d-log=)"
    if [[ "${run_customize_script_log}" == "true" ]]; then
        pil log_content "当前模拟 init.d 运行的进程 ID 为" "init.d 运行结果为（空为成功）" s_run_parts /system/etc/init.d
        echo "run-init.d ok"
    else
        s_run_parts /system/etc/init.d
        echo "run-init.d ok"
    fi
elif [[ "${run_customize_script}" == "" ]]; then
    s_run_parts /system/etc/init.d
    echo "run-init.d ok"
fi



#挂载 system 分区可读写
selinux_permissive="$(cfc string_selinux-permissive=)"
if [[ "${mount_system_rw}" == "true" ]]; then
    mount -o rw,remount /system
    toolbox mount -o rw,remount /system
    busybox mount -o rw,remount /system
    echo "/system has been mounted as r/w"
fi



#后续防止意外狗带用（仅对360frop4生效，未测试）

#外挂式 Recovery 的目录
plug_in_recovery="/system/res/TWRP"

su_binary_validation=

non_supersu_use_directory="/system/bin/su"
sos_storage="/storage/sdcard0"
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
    sh ${plug_in_recovery}/shell/install+run_recovery.sh &
}

if [[ -f ${sos_storage}/010on && ! -f ${sos_storage}/010off ]]; then
    run_plug_in_recovery
fi

echo "溜了溜了"
sleep 1200
cat
#没了
