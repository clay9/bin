#!/bin/bash
# wcq 2022/11/30

### mac && linux环境一键配置

### 说明
# 1. bash环境初始化, 详见.bash_profile
#    1) bash基础环境
#    2) git自动补全
#    3) .emacs.d的连接
# 2. ssh私钥
# 3. 修改bin.git的remote为git地址
# 4. 配置git config -- global


bin_dir=~/my/bin
step=1

#******************** os-type ********************
os_type="ubuntu"
fun_get_os_type(){
    st=`uname -a`
    mac="Darwin"
    ubuntu="ubuntu"

    if [[ $st =~ $mac ]];then
       os_type="mac" #
    elif [[ $st =~ $ubuntu ]];then
	 os_type="ubuntu"
    else
	os_type="unknow"
    fi
}
fun_get_os_type

#******************** file-mode ******************
fun_ln_id_rsa_github(){
    ## 如果有多个 提示个错误信息 退出
    nums=`find ~/my -name "id_rsa_github" -type f | wc -l`
    if [ $nums -gt 1 ]; then
       tput setaf 1
       printf 'step%2s. %-25s fail. find %s id_rsa_github in ~/my\n' $((step++)) "ln-id-rsa-github" $nums
       tput sgr0
       exit
    fi

    cd ~/my/bin/ssh
    ln -fs `find ~/my -name "id_rsa_github" -type f` id_rsa_github
    tput setaf 3
    printf 'step%2s. %-25s success\n' $((step++)) "ln-id-rsa-github"
    tput sgr0
}
fun_set_file_mode(){
    fun_ln_id_rsa_github

    cd ~
    # 启动ssh-agent && ssh-add公钥 都应该放到.bashrc中处理(bash_profile)
    # 因为ssh-agent 是与bash挂钩的, ssh-agent bash只是在新的bash中开启了ssh-agent, 但是在old bash中并没有作用
    # 我们需要的是获取bash的时候 自动开启ssh-agent && ssh-add, 在退出bash的时候自动关闭ssh-agent
    # 因此只能放到.bashrc中处理
    chmod 600 ~/my/bin/ssh/id_rsa_github

    # for-mac
    if [ $os_type = "mac" ];then
       chmod 777 ~/my/bin/mac/mac_startup.sh
       chmod 777 ~/my/bin/mac/user_startup.sh

       chmod 644 ~/my/bin/mac/mac_startup.plist
       chmod 644 ~/my/bin/mac/user_startup.plist
    fi

    tput setaf 3
    printf 'step%2s. %-25s success\n' $((step++)) "set-file-mode"
    tput sgr0
}

#********************  bash  *********************
fun_init_bash(){
    cd ~
    # emacs
    if [ -h .emacs.d ]; then
	:
    else
	if [ -d .emacs.d ]; then
	    mv .emacs.d .emacs.d.bk
	fi
	# 部分linux下 不识别-fsh 中的 -h
	# -h的意义是重新连接TARGET的对应文件(不管之前是否存在)
	ln -fs my/emacs.d .emacs.d
    fi

    # bash
    if [ $os_type = "mac" ]; then
	fun_init_bash_for_mac
    elif [ $os_type = "ubuntu" ];then
	 fun_init_bash_for_ubuntu
    else
	: #如果unknow, do noting
    fi
}

fun_init_bash_for_mac(){
    cd ~
    # bash env
    if [ -f .bash_profile ]; then
	mv .bash_profile .bash_profile_back
    fi
    cp ~/my/bin/bash/bash_profile_mac  .bash_profile

    # bash env for zsh
    rc=".zshrc"
    if [ -f $rc ]; then
	ret=`cat $rc |grep -w wcq`
	if [[ $ret != "" ]]; then
	    tput setaf 2
	    printf 'step%2s. %-25s already have\n' $((step++)) "/bin/bash"
	    tput sgr0
	else
	    echo -e "\n# added by wcq"  >> $rc
	    echo ". ~/my/bin/bash/bash_profile_mac"    >> $rc

	    ## set zsh theme
	    sed -i "" "/^ZSH_THEME/c\\"$'\n'"ZSH_THEME=\"apple\"" $rc

	    tput setaf 3
	    printf 'step%2s. %-25s init success\n' $((step++)) "/bin/bash"
	    tput sgr0
	fi
    fi

    # github private key
    mkdir -p .ssh
    if [ -h .ssh/id_rsa ]; then
	:
    else
	if [ -f .ssh/id_rsa ]; then
	    mv .ssh/id_rsa .ssh/id_rsa_backup
	fi
	ln -fs ~/my/bin/ssh/id_rsa_github .ssh/id_rsa
    fi

    # launchd
    if [ -f /Library/LaunchDaemons/mac_startup.plist ]; then
	tput setaf 2
	printf 'step%2s. %-25s already have\n' $((step++)) "launchd mac_startup"
	tput sgr0
    else
	sudo cp ~/my/bin/mac/mac_startup.plist   /Library/LaunchDaemons/
	sudo launchctl load -w /Library/LaunchDaemons/mac_startup.plist

	tput setaf 3
	printf 'step%2s. %-25s init success\n' $((step++)) "launchd mac_startup"
	tput sgr0
    fi

    if [ -f /Library/LaunchAgents/user_startup.plist ]; then
	tput setaf 2
	printf 'step%2s. %-25s already have\n' $((step++)) "launchd user_startup"
	tput sgr0
    else
	sudo cp ~/my/bin/mac/user_startup.plist  /Library/LaunchAgents/
	sudo launchctl load -w /Library/LaunchAgents/user_startup.plist

	tput setaf 3
	printf 'step%2s. %-25s init success\n' $((step++)) "launchd user_startup"
	tput sgr0
    fi
}

fun_init_bash_for_ubuntu(){
    list_rc=(".bashrc" ".zshrc")
    for rc in ${list_rc[*]}
    do
	if [ -f $rc ]; then
	    ret=`cat $rc |grep -w wcq`
	    if [[ $ret != "" ]]; then
		tput setaf 2
		printf 'step%2s. %-25s already have\n' $((step++)) "/bin/bash"
		tput sgr0
	    else
		echo -e "\n# added by wcq"  >> $rc
		echo ". ~/my/bin/bash/bash_profile_ubuntu"    >> $rc

		tput setaf 3
		printf 'step%2s. %-25s init success\n' $((step++)) "/bin/bash"
		tput sgr0
	    fi
	fi
    done
}

#********************   git   ********************
fun_init_git(){
    git --version > /dev/null 2>&1
    bret=$?
    if [ $bret -ne  0 ];then
       tput setaf 2
       printf 'step%2s. %-25s init fail. no git found\n' $((step++)) "git env"
       tput sgr0
    else
	git config --global user.name "clay"
	git config --global user.email "x@gmail.com"

	tput setaf 3
	printf 'step%2s. %-25s init success\n' $((step++)) "git env"
	tput sgr0
    fi
}

#******************** bin.git ********************
fun_reset_bin_git_url(){
    cd $bin_dir
    git remote set-url origin git@github.com:clay9/bin.git

    tput setaf 3
    printf 'step%2s. %-25s init success\n' $((step++)) "bin.git set-url"
    tput sgr0
}

fun_help(){
    printf "usage: my_init.sh <command>

 command         说明
 -------    ----------------------------------------------
   *         init     bash, git
	     add      github_id_rsa
"
}

#******************** main  ********************
case $1 in
    h|help)
	fun_help ;;
    *)
	fun_set_file_mode
	fun_init_bash
	fun_init_git
	fun_reset_bin_git_url
	;;
esac
