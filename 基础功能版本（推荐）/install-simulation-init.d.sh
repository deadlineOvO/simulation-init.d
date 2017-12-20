#!/system/bin/sh



###########################################
#模拟init.d脚本简版
#没有版本
#开坑日期在2017-11-04 20:05
#恭喜这个脚本成为了一个模拟 init.d 行为服务的脚本，虽然内置安装和禁用 SELinux 
#制作 by funnypro
#感谢以下人员指导与技术援助（排序不分先后）
# @manhong2112 & @zt515 & @rote66（所有User_id 均取自 Github）
#项目地址：https://github.com/funnypro/simulation-init.d
#
#手动分割
#
#本脚本理论上所有设备都可以用，如果出现意外可以向我反馈
#本脚本默认依靠硬链接 debuggerd64 来工作，按照惯例比依靠 install-recovery.sh 执行优先级高一点
#如果要替换其他类似东西的话，记得重命名为 <原文件名>_original.bak
#不过你也可以软链接一个 install-recovery-2.sh （必须是使用 SuperSU 为 root 授权时）让本脚本工作
#不过这个判定我懒得写，很有可能会属于有生之年系列
#不想写的主要原因是SuperSU自带su.d
#其次是如果有什么东西使用了的话判定可能会麻烦不少
#
#注意：
#如果你的设备支持 Magisk 的话，你应该不需要这个脚本，也不要使用这个脚本
#如果希望本脚本正常工作的话务必安装 busybox ，否则我也不知道会发生什么
###########################################



if [[ $(ls "${0}" | grep '/install-simulation-init.d.sh') != "${0}" ]]; then
    
    s_run_parts(){
        for i in $(ls ${1}); do
            [[ -x "${i}" ]] && "${i}"
        done
    }



    #禁用 SELinux
    selinux_permissive="false"
    if [[ "${selinux_permissive}" == "true" ]]; then
        setenforce 0
        setenforce 0
        setenforce 0
        echo "SELinux is permissive"
    fi



    s_run_parts '/system/etc/init.d/*'
    echo "run-init.d ok"



    echo "溜了溜了"

    s_run_parts '/system/*/*_original.bak'
    echo "run-original ok"
    

###########################################
else

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
        echo "理论上 -c 可以放在第二参数，不过按照标准它应该在第三参数\n并且当第二参数为 -c 时，默认使用 -h 作为第二参数"
    }


    install(){


        msrw(){
            mount -o remount,rw /system
            toolbox mount -o remount,rw /system
            if [[ $(busybox --list | grep "mount") == "mount" ]]; then
                busybox mount -o remount,rw /system
            fi
        }



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
        sinitsh="${etc}/run-simulation-init.d"

        irss=$(cat /*.* | grep "flash_recovery" | grep "install-recovery.sh")
        irsf="${irss:23:31}"
        sinite='if [[ $(cat "/system/etc/run-simulation-init.d" | grep -E  "^#依靠 debuggerd(64)? 启动$") == "#依靠 *" ]];then /system/etc/run-simulation-init.d;fi'
    
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
            echo "#依靠 ${1} 启动" >> "${sinitsh}"
            choon "${sinitsh}"
            chattr_file "${sinitsh}"


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


            echo "安装完成"
            echo "#!/system/bin/sh\ntouch /sdcard/init.d-run.log\n"> /system/etc/init.d/log
            choon /system/etc/init.d/log
            echo "请重启手机\n重启手机后到 /sdcard 目录下查看是否生成 init.d-run.log 文件\n生成代表成功，没有代表失败。\n成功后请删除 /system/etc/init.d/log 文件"
            exit 0
        }



        rmsinitsh(){
            if [[ -e "${sinitsh}" ]]; then
                exec_chattr "-i" "-a" "-A" "${sinitsh}"
                rm -rf "${sinitsh}"
            fi
        }

        debuggerd_install(){
            _original="${1}_original.bak"
            msrw
            mv "${1}" "${_original}"
            choon "${_original}"
            rmsinitsh
            cp -rf "${sinitsho}" "${sinitsh}"
            link_file "${sinitsh}" "${1}"
            install_initd "${2}"
        }



        if [[ "${h_file}" == "${dg64}" ]]; then
            debuggerd_install "${dg64}" "debuggerd64"
        elif [[ "${h_file}" == "${dg}" ]]; then
            debuggerd_install "${dg}" "debuggerd"
        elif [[ "${h_file}" == "${irsf}" ]]; then
            msrw
            choon "${irsf}"
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
            echo "你好像使用了 export 干扰了这个脚本的正常工作的环境=)"
            sleep 0.7
            echo "开个玩笑"
            echo "因为没有什么可以作为脚本启动的依靠"
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

#没了
