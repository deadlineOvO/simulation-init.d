#!/system/bin/sh



###########################################
#模拟 init.d 脚本
#没有版本
#开坑日期大概是2017-07-**
#可能这是一个世界上最慢，功能最多并且最废，辣鸡的模拟 init.d 启动脚本，更重要的是它是专门为360frop4写的？？？
#制作 by funnypro
#感谢以下人员指导与技术援助（排序不分先后）
# @manhong2112 & @zt515 & @rote66（所有User_id 均取自 Github）
#项目地址：https://github.com/funnypro/simulation-init.d
#
#手动分割
#
#本脚本主要用于 360f4（360-1501_M02或者是360-1501_A02）上，虽然说理论上可以在其他设备用，如果出现问题可以向我反馈
#本脚本默认依靠硬链接 debuggerd64 来工作，按照惯例比依靠 install-recovery.sh 执行优先级高一点
#如果要替换其他类似东西的话，记得重命名为 <原文件名>_original.bak
#不过你也可以软链接一个 install-recovery-2.sh （必须是使用 SuperSU 为 root 授权时）让本脚本工作
#不过这个判定我懒得写，很有可能会属于有生之年系列
#不想写的主要原因是SuperSU自带su.d
#其次是如果有什么东西使用了的话判定可能会麻烦不少
#
#注意事项：
#如果你的设备支持 Magisk 的话，你应该不需要这个脚本，也不要使用这个脚本
#如果希望本脚本正常工作的话务必安装 busybox ，否则我也不知道会发生什么
###########################################





#使用的储存目录？
block="/storage/sdcard0"

#脚本使用到的目录
Ic="${block}/simulation-init.d"

#配置文件
cfd="${Ic}/Settings.ini"

#这个变量最好别动了……
logdir="${Ic}/log"






msrw(){
    mount -o remount,rw /system
    toolbox mount -o remount,rw /system
    if [[ $(busybox --list | grep "mount") == "mount" ]]; then
        busybox mount -o remount,rw /system
    fi
}



if [[ $(ls "${0}" | grep '/install-simulation-init.d.sh') == "${0}" ]]; then




    help(){
        echo "使用方法：[第一参数] [第二参数] [第三参数]"
        echo "第一参数："
        echo "    -i, --install         安装这个脚本"
        echo "    -h, --help            你当前看到的东西"
        echo "没有第一参数会模拟 init.d 行为"
        echo "第二参数："
        echo "    -h                    使用硬链接来链接脚本和依靠源"
        echo "    -s                    使用软链接来链接脚本和依靠源"
        echo "    -n                    直接把脚本移动到依靠源的位置"
        echo "第三参数："
        echo "    -c                    设置 chattr 特殊权限，不填写则为不设置"
        echo "注意："
        echo "如果第二参数和第三参数都不填写，那么它们的默认值分别为 -h 和 -c"
        echo "理论上 -c 可以放在第二参数，不过按照标准它应该在第三参数\n并且当第二参数为 -c 时，默认使用 -h 作为真正的第二参数。"
        echo "如果以 install-recovery.sh 作为依靠源的话，第二参数将会作废。不过 -c 作为第二参数时例外。"
    }









    install(){



        #判断是否以 root 进程执行
        if [[ "${USER_ID}" == "" ]]; then
            if [[ "${USER}" == "root" ]]; then
                USER_ID="0"
            elif [[ $(type cut) != *"not found"* ]]; then
                USER_ID=$(id | cut  -b 5)
            elif [[ $(busybox --list | grep cut) == "cut" ]]; then
                USER_ID=$(id | busybox cut -b 5)
            fi
        fi
        if [[ "${USER_ID}" == "0" ]]; then 
            if [[ $(su -v) == *"360"* ]]; then
                echo "小心点，360root 很有可能占用了 debuggerd 导致脚本可能会出现优先级低或者没有被启动以及更多意外\n"
            elif [[ $(su -v) == *"king"* ]]; then
                echo "按照惯例，本脚本在 Kingroot 为 su 提供方时很有可能会不可用\n"
            elif [[ $(su -v) == *"SUPERSU"* ]]; then
                echo "有很大几率能成功的样子，不过 install-recovery-2.sh 的判定没做就是了\n主要是因为懒以及可能容易出现意外的各种问题\n"
            elif [[ $(su -v) == *"MAGISKSU"* ]]; then
                echo "你是闲得慌吗？\nMagisk 本就有类似功能，不需要这个！"
                exit 1
            else
                echo "我有些不清楚你的 su 提供方是谁，不过注意点总是对的\n"
            fi
        else
            echo "本脚本需要 root 权限才可以使用！ \n请输入 'su' 以获取 root 权限"
            exit 1
        fi



        echoAccess(){

            lsEcho=$(ls -l "${1}")


            access="${lsEcho:1:9}"
        
            #owner="${access:0:3}"
            #usergroup="${owner:3:3}"
            #others="${usergroup:6:6}"
            echo "${access}"
        }



        choon(){
            chmod 6755 "${1}"
            chown 0:2000 "${1}"
        }
    
    
    
        check(){
            if [[ -f "${1}" && -s "${1}" && -x "${1}" ]]; then
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
        sinitdsh="${etc}/run-simulation-init.d"

        irss=$(cat /*.* | grep "flash_recovery" | grep "install-recovery.sh")
        irsf="${irss:23:31}"
        sinite='if [[ $(cat "/system/etc/run-simulation-init.d" | grep -E  "^#依靠 debuggerd(64)? 启动$") == *"debuggerd"* ]];then /system/etc/run-simulation-init.d;fi'
    
        if [[ $(cat "${irsf}" | grep -F "${sinite}")  == "${sinite}" && -x "${irsf}" && -w "${irsf}" ]]; then
            h_file="install-recovery.sh-y"
        else
            check "${irsf}"
        fi



        exec_chattr(){
            if [[ $(type "chattr") != *"not found"* ]]; then
                chattr "${@}"
            elif [[ $(busybox --list | grep "chattr") == "chattr" ]]; then
                busybox chattr "${@}"
            else
                echo "chattr 不存在" 1>&2
            fi
        }


        restore(){
            _original="${1}_original.bak"
            if [[ -f "${_original}" && -s "${_original}" && -x "${_original}" ]]; then
                exec_chattr "-i" "-a" "-A" "${1}"
                rm -rf "${1}" $?
                mv "${_original}" "${1}"
            fi
        }






        bin="/system/bin"


        dg="${bin}/debuggerd"
        restore "${dg}"
        check "${dg}"


        dg64="${bin}/debuggerd64"
        restore "${dg64}"
        check "${dg64}"






        sinitdsho="${0}"


        link_mode="${2}"
        chattr_mode="${3}"
        link_file(){
            if [[ "${link_mode}" == "-h" ]]; then
                if [[ "${h_file}" == *"install-recovery.sh"* ]]; then
                    echo "这尼玛令我有些尴尬\n因为不使用 debuggerd 作为依靠的话……\n请问 -h 参数有啥用啊？"
                else
                    ln "${1}" "${2}"
                fi
            elif [[ "${link_mode}" == "-s" ]]; then
                if [[ "${h_file}" == *"install-recovery.sh"* ]]; then
                    echo "这尼玛令我有些尴尬\n因为不使用 debuggerd 作为依靠的话……\n请问 -s 参数有啥用啊？"
                else
                    ln -s "${1}" "${2}"
                fi
            elif [[ "${link_mode}" == "-n" ]]; then
                if [[ "${h_file}" == *"install-recovery.sh"* ]]; then
                    echo "这尼玛令我有些尴尬\n因为不使用 debuggerd 作为依靠的话……\n请问 -n 参数有啥用啊？"
                else
                    cp "${1}" "${2}"
                    sinitdsh="${2}"
                fi
            elif [[ "${link_mode}" == "-c" && "${chattr_mode}" == "" ]]; then
                if [[ "${h_file}" == *"install-recovery.sh"* ]]; then
                    echo "emmm"
                else
                    ln "${1}" "${2}"
                fi
            elif [[ "${link_mode}" == "" && "${chattr_mode}" == "" ]]; then
                if [[ "${h_file}" == *"install-recovery.sh"* ]]; then
                    echo "emmm"
                else
                    ln "${1}" "${2}"
                fi
            else
                if [[ "${h_file}" == *"install-recovery.sh"* ]]; then
                    echo "emmm"
                else
                    ln "${1}" "${2}"
                    echo "可能是因为你输入了错误的参数，所以自动给你选择硬链接"
                fi
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
                echo "看起来你不想进行设置 chattr 特殊权限"
            fi
        }




        install_initd(){
            msrw
            echo "#依靠 ${1} 启动" >> "${sinitdsh}"
            choon "${sinitdsh}"
            chattr_file "${sinitdsh}"


            initdir="${etc}/init.d"
            if [[ -f "${initdir}" ]]; then
                mv "${initdir}" "${initdir}_original.bak"
                echo "我不清楚这是怎么回事，不过还是建立了原 ${initdir} 的备份"
                mkdir "${initdir}"
                choon "${initdir}"
            elif [[ ! -e "${initdir}" ]]; then
                mkdir "${initdir}"
                choon "${initdir}"
            else
                choon "${initdir}"
            fi

            if [[ -f "${lc}" ]]; then
                mv "${lc}" "${lc}_original.bak"
                mkdir "${lc}"
            elif [[ ! -e "${lc}" ]]; then
                mkdir "${lc}"
            fi

            if [[ -f "${logdir}" ]]; then
                mv "${logdir}" "${logdir}_original.bak"
                mkdir "${logdir}"
            elif [[ ! -e "${logdir}" ]]; then
                mkdir "${logdir}"
            fi

            cfdString(){
                echo "#SELinux是否为许可模式"
                echo "string_selinux-permissive=false"
                echo "\n"
                echo "#是否模拟 init.d 工作"
                echo "string_run-init.d=true"
                echo "\n"
                echo "#是否记录 init.d 工作时产生的所有日志"
                echo "string_run-init.d-log=true"
                echo "\n"
                echo "#是否在 init.d 工作时产生的日志超过一定大小时删除它"
                echo "string_esad-run-init.d-log=true"
                echo "\n"
                echo "#自动删除 init.d 工作日志的大小（可用单位：b;k;m）（不区分大小写）"
                echo "string_esad-run-init.d-log-size=64k"
                echo "\n"
                echo "#是否开机自动让system挂载为可读写"
                echo "string_mount-system_r/w=false"
                echo "\r"
            }

            if [[ -d "${cfd}" ]]; then
                mv "${cfd}" "{$cfd}_original.bak"
                cfdString >"${cfd}"
            elif [[ -f  "${cfd}" && ! -s "${cfd}" ]]; then
                cfdString >"${cfd}"
            elif [[ ! -e  "${cfd}" ]]; then
                cfdString >"${cfd}"
            fi


            echo "安装完成"
            echo "请重启手机\n重启手机后到 ${logdir} 目录下查看是否生成 run-original.log 文件\n生成代表成功，没有代表失败。\n成功后可以从配置文件文件关闭 log 生成"
            exit 0
        }



        rmsinitdsh(){
            if [[ -e "${sinitdsh}" ]]; then
                exec_chattr "-i" "-a" "-A" "${sinitdsh}"
                rm -rf "${sinitdsh}"
            fi
        }

        debuggerd_install(){
            _original="${1}_original.bak"
            msrw
            mv "${1}" "${_original}"
            choon "${_original}"
            rmsinitdsh
            cp -rf "${sinitdsho}" "${sinitdsh}"
            link_file "${sinitdsh}" "${1}"
            install_initd "${2}"
        }



        if [[ "${h_file}" == "${dg64}" ]]; then
            echo "依靠源为 debuggerd64\n"
            debuggerd_install "${dg64}" "debuggerd64"
        elif [[ "${h_file}" == "${dg}" ]]; then
            echo "依靠源为 debuggerd\n"
            debuggerd_install "${dg}" "debuggerd"
        elif [[ "${h_file}" == "${irsf}" ]]; then
            msrw
            rmsinitdsh
            choon "${irsf}"
            cp "${sinitdsho}" "${sinitdsh}"
            choon "${sinitdfile}"
            echo "${sinite}" >>"${irsf}"
            echo "依靠源为 install-recovery.sh\n"
            install_initd "install-recovery.sh"
        elif [[ "${h_file}" == "install-recovery.sh-y" ]]; then
            msrw
            rmsinitdsh
            cp "${sinitdsho}" "${sinitdsh}"
            choon "${sinitdsh}"
            echo "依靠源为 install-recovery.sh\n"
            install_initd "install-recovery.sh"
        else
            echo "我觉得你可能需要一部 MI6 或者是 =6T 用于搭配 Magisk"
            echo "问我为啥？"
            echo "这个脚本好像不能在你的设备上正常工作"
            echo "因为你使用了 export 干扰了这个脚本的正常工作的环境=)"
            sleep 0.7
            echo "开个玩笑"
            echo "因为没有可用的东西可以作为脚本启动的依靠"
            echo "不能怪我对吧_(:з」∠)_"
            echo "虽然说有可能是写这个脚本的制杖落了什么东西导致的"
            exit 1
        fi
    
    }




    case "${1}" in
    "-h")
        help
        exit 0
    ;;
    "-i")
        install
    ;;
    "--help")
        help
        exit 0
    ;;
    "--install")
        install
    ;;
    *)
        help
        exit 1
    ;;
    esac
    


fi



###########################################





#自定义 log 文件名？
dil="${logdir}/run-init.d.log"


#函数的话一般没什么好修改的，神奇 shell 的原因除外

pil(){
    eval "${@}" >> ${dil}
}





#run_parts 实现方式，如果使用没问题请不要动
#可供选择的实现方式有 c 或者 bash
#Auto也可以
#bash 不需要 busybox 支持，并且可以打印完整日志但是速度慢
#c 需要 busybox 支持并且速度快但是无法打印完整日志
s_run_parts_mode="sh"


#请好好填写标准值，否则我也不知道会发生什么
gun(){
    echo "go out"
    exit 1
    stop
    eval mdzz
    reboot -p
}

s_run_parts(){


    sh_s_run_parts(){
        for i in $(ls "$1"); do
            if [[ -x "$1"/"${i}" ]]; then
                sp1="$(echo "$1"/"${i}")"
                sp2="$("$1"/"${i}" 2>&1)"
                echo ""${sp1}" => "${sp2}"\n"
            fi
        done
    }



    if [[ "${s_run_parts_mode}" == "Auto" ]]; then
        if [[ $(type "run-parts") != "run-parts not found" ]]; then
            run-parts "$1" 2>&1
        elif [[ $(busybox --list|grep run-parts) == "run-parts" ]]; then
            busybox run-parts "$1" 2>&1
        else
            sh_s_run_parts "$1"
        fi
    elif [[ "${s_run_parts_mode}" == "c" ]]; then
            busybox run-parts "$1" 2>&1
    elif [[ "${s_run_parts_mode}" == "sh" ]]; then
            sh_s_run_parts "$1"
    elif [[ "${s_run_parts_mode}" == * ]]; then
            gun
    fi
}

s_run_parts_o(){

    for i in $(ls ${1}); do
        [[ -x "${i}" ]] && "${i}"
    done
}

###########################################
#额外的if用于保证没有配置文件时基本的工作
if [[ ! -s ${cfd} && ! -r ${cfd} ]]; then
    setenforce 0 &
    setenforce 0 &
    setenforce 0 &
    echo "SELinux is permissive"
    s_run_parts /system/etc/init.d &
    echo "run-init.d ok"
    
    echo "溜了溜了"
    s_run_parts_o '/system/*/*_original.bak'
    echo "run-original ok"
fi
###########################################


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
    b(){
        i=$(("${#str}"-1))
        u=${str:0:"${i}"}
        echo "${u}"
    }

    kb(){
        i=$(("${#str}"-1))
        u=${str:0:"${i}"}
        echo $(("${u}"*1024))
    }

    mb(){
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
    "${3}" "${4}"
}



# SELinux 宽松
selinux_permissive="$(cfc string_selinux-permissive=)"
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



#模拟 init.d
run_customize_script="$(cfc string_run-init.d=)"
if [[ "${run_customize_script}" == "true" ]]; then
    run_customize_script_log="$(cfc string_run-init.d-log=)"
    if [[ "${run_customize_script_log}" == "true" ]]; then
        pil log_content "当前模拟 init.d 运行的进程 ID 为" "init.d 运行结果为（空为成功）" s_run_parts '/system/etc/init.d'
        echo "run-init.d ok"
    else
        s_run_parts /system/etc/init.d &
        echo "run-init.d ok"
    fi
elif [[ "${run_customize_script}" == "" ]]; then
    s_run_parts /system/etc/init.d &
    echo "run-init.d ok"
fi



#挂载 system 分区可读写
mount_system_rw="$(cfc string_mount-system_r/w=)"
if [[ "${mount_system_rw}" == "true" ]]; then
    msrw
    echo "/system has been mounted as r/w"
fi



#后续防止意外狗带用（仅对360frop4生效，未测试）

#外挂式 Recovery 的目录
plug_in_recovery="/system/res/plug_TWRP"

su_binary_validation=

non_supersu_use_directory="/system/bin/su"
sos_storage="/data/media/0"
Is_it_not_supersu(){
    ${Non_supersu_use_directory} -v
}


if [[ "${su_binary_validation}" == "true" ]]; then
    if [[ -s "${non_supersu_use_directory}" && -x "${non_supersu_use_directory}" ]]; then
        msrw
        if [[ "$(Is_it_not_supersu)" == *"SUPERSU"* ]]; then
            echo "su binary from SuperSU"
        else
            touch ${sos_storage}/010on
        fi
    else
        echo "${non_supersu_use_directory} no su binary"
    fi
fi



run_plug_in_recovery(){
    echo "!!!!!!!!!!!" >${sos_storage}/init.d.recovery.log
    ${plug_in_recovery}/shell/install+run_recovery.sh &
}

if [[ -f ${sos_storage}/010on && ! -f ${sos_storage}/010off ]]; then
    run_plug_in_recovery
fi


echo "溜了溜了"

s_run_parts_o '/system/*/*_original.bak'
echo "run-original ok"
#没了
