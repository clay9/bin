#!/bin/bash

# 说明
## 1. 删除docker中的qy image && container

step=1
#******************** fun ********************
fun_make_sure(){
    ## 删除之前确认1遍
    yes_time=1
    while ((yes_time--))
    do
	tput setaf 1
	read -p "Are you sure to delete? [yes/*n] " input
	tput sgr0
	case $input in
	    yes) ;;
	    *)   exit 0 ;;
	esac
    done
}
fun_help(){
    printf 'usage: my_delete.sh <command>

 command           des
------------     ---------------------------------------------
   *               delete all qy-images && qy-containers
'
}

#******************** qygame ********************
fun_delete_qy(){
    # 1. 删除所有qy-*的container
    docker ps -a |grep qy- | awk '{print $1}' |xargs docker rm -f

    tput setaf 2
    printf 'step%2s delete all qy_containers\n' $((step++))
    tput sgr0

    # 2. 删除所有qy_*的image
    docker images |grep qy_ |awk '{print $3}' |xargs docker image rm -f

    tput setaf 2
    printf 'step%2s delete qy_images\n' $((step++))
    tput sgr0
}

#******************** main ********************
case $1 in
    h|help) fun_help;;
    *)
	fun_make_sure
	fun_delete_qy
	;;
esac
