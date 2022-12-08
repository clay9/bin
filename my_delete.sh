#!/bin/bash

### 说明
## 1. 删除所有git仓库. 直接删除了my和qy 目录


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
   *               delete all git-reps in ~/my && ~/qy
'
}

#******************** git repository ********************
fun_delete_my(){
    # ssh-add中的私钥删除一下
    ssh-add -D
    tput setaf 2
    printf 'step%2s ssh-add -D\n' $((step++))
    tput sgr0

    #
    rm -rf ~/my
    rm -rf ~/qy
    tput setaf 2
    printf 'step%2s delete git repository\n' $((step++))
    tput sgr0
}


#******************** main ********************
case $1 in
    h|help) fun_help ;;
    *)
	fun_make_sure
	fun_delete_my
	;;
esac
