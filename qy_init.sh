#!/bin/bash
# wcq 2022/11/30

### set docker && docker-compose env
### 说明
# 1. 安装git
# 2. 安装curl
#    docker, docker-compose安装时依赖
# 3. 安装docker
# 4. 安装docker-compose
## !! 只支持了ubuntu系统


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

#******************** qy install ********************
fun_install_git(){
    git --version > /dev/null 2>&1
    bret=$?
    if [ $bret -ne 0 ];then
       sudo apt install git
    fi

    git --version > /dev/null 2>&1
    bret=$?
    if [ $bret -eq 0 ];then
	tput setaf 3
	printf 'step%2s. %-25s init success\n' $((step++)) "git"
	tput sgr0
    else
	tput setaf 1
	printf 'step%2s. %-25s init fail\n' $((step++)) "git"
	tput sgr0
    fi
}
fun_install_curl(){
    curl --version > /dev/null 2>&1
    bret=$?
    if [ $bret -ne 0 ];then
	sudo apt install curl
    fi

    curl --version > /dev/null 2>&1
    bret=$?
    if [ $bret -eq 0 ];then
	tput setaf 3
	printf 'step%2s. %-25s init success\n' $((step++)) "curl"
	tput sgr0
    else
	tput setaf 1
	printf 'step%2s. %-25s init fail\n' $((step++)) "curl"
	tput sgr0
    fi
}

fun_install_docker(){
    docker --version > /dev/null 2>&1
    bret=$?
    if [ $bret -ne 0 ];then
	curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
    fi

    docker --version > /dev/null 2>&1
    bret=$?
    if [ $bret -eq 0 ];then
	tput setaf 3
	printf 'step%2s. %-25s init success\n' $((step++)) "docker"
	tput sgr0
    else
	tput setaf 1
	printf 'step%2s. %-25s init fail\n' $((step++)) "docker"
	tput sgr0
    fi
}

fun_install_docker_compose(){
    docker-compose --version > /dev/null 2>&1
    bret=$?
    if [ $bret -ne 0 ];then
	sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod 775 /usr/local/bin/docker-compose
    fi

    docker-compose --version > /dev/null 2>&1
    bret=$?
    if [ $bret -eq 0 ];then
	tput setaf 3
	printf 'step%2s. %-25s init success\n' $((step++)) "docker-compose"
	tput sgr0
    else
	tput setaf 1
	printf 'step%2s. %-25s init fail\n' $((step++)) "docker-compose"
	tput sgr0
    fi

}

fun_add_user_to_gdocker(){
    # 把用户加入到group::docker
    sudo gpasswd -a $USER docker >/dev/null 2>&1
    #sudo gpasswd -a $USER docker-compose

    # 切换group重新登陆;
    # 该命令会导致shell脚本退出
    newgrp docker
}

fun_help(){
    printf "usage: my_init.sh <command>

 command         说明
 -------    ----------------------------------------------
   *         install  git, curl, docker, dockercompose
	     add      user to group::docker
 ---------------------------------------------------------
 仅适配ubuntu, current os: ${os_type}
"
}

#******************** main  ********************
case $1 in
    h|help)
	fun_help ;;
    *)
	if [ $os_type = "ubuntu" ];then
	   fun_install_git
	   fun_install_curl
	   fun_install_docker
	   fun_install_docker_compose
	   fun_add_user_to_gdocker
       else
	   tput setaf 1
	   printf 'step%2s. %-25s fail. only for os: ubuntu (current:%s)\n' $((step++)) "install" ${os_type}
	   tput sgr0
	fi
	;;
esac
