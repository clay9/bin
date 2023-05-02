#!/bin/bash
# wcq 2021/9/20

## 说明
# 所有仓库的管理脚本, 需要管理的仓库可以添加到最下面
# 已有功能, 使用./my_git -h 查看

## TODONOW
# 1. [ ] 所有的命令<pull, push, log...>之后增加主体参数<clay9/emacs, clay9/bin, qygame/docker..>

# 修改记录
# 1. 使用ssh代替token. token跟随https协议,pull或push的时候总是失败

#******************** basic ********************
# 获取时间
date=$(date "+%Y-%m-%d %H:%M:%S");
step=1

fun_auto(){
    case $3 in
	pull)   fun_auto_pull $@    ;;
	push)   fun_auto_push $@    ;;
	clone)  fun_auto_clone $@   ;;
	status) fun_status $@       ;;
	log)    fun_log $@          ;;
	tag)    fun_tag $@          ;;
	rtag)   fun_remote_tag $@   ;;

	addtag) fun_add_tag $@      ;;
	*)      return 0            ;;
    esac
}

fun_auto_push(){
    if ! [ -d $1 ]; then
	return 0
    fi

    str=$1
    dir_show='~'${str#~}
    cd $1

    # 如果有未保存的内容, 则先commit, 然后再push
    git add . > /dev/null
    git commit -m "Auto Push $date" > /dev/null

    # 如果log_msg为空, 说明本地没有修改, 不需要push
    #cbranch=`git branch --show-current`
    cbranch=`git symbolic-ref --short HEAD`
    log_msg=`git log --pretty=oneline ${cbranch}...origin/${cbranch}`
    if [[ $log_msg == "" ]]; then
	return 0
    else
	# push的时候不管成功与否 都不想获得提示; 后面会统一查看status, 找到push失败的工程
	git push -q 2>&1
	cbranch=`git symbolic-ref --short HEAD`
	ret_msg=`git log --pretty=oneline ${cbranch}...origin/${cbranch}`
	if [[ $ret_msg == "" ]]; then
	    tput setaf 3
	    printf 'step%2s. %-25s =>   %-25s push success\n' $((step++)) $2 $dir_show
	    tput sgr0
	else
	    tput setaf 1
	    printf 'step%2s. %-25s =>   %-25s push fail\n' $((step++)) $2 $dir_show
	    tput sgr0

	    ## err-log
	    tar_dir=~/my/bin/log
	    tar_file=my_git.log
	    mkdir -p $tar_dir
	    echo -e "\n\n--------------------------------------"  >> $tar_dir/$tar_file
	    echo -e "$date" >> $tar_dir/$tar_file
	    echo -e "push $dir_show fail" >> $tar_dir/$tar_file
	fi
    fi
}

fun_auto_pull(){
    if ! [ -d $1 ]; then
	return 0
    fi

    str=$1
    dir_show='~'${str#~}

    cd $1

    # pull的时候不需要先commit本地修改
    #git add . > /dev/null
    #git commit -m "Auto Push $date" > /dev/null

    # 先fetch, 更新本地的远端信息
    git fetch -q

    # 查看本地到远端HEAD的距离
    #cbranch=`git branch --show-current`
    cbranch=`git symbolic-ref --short HEAD`
    log_msg=`git log --pretty=oneline ${cbranch}..origin/${cbranch}`
    # 先判断是否需要pull
    if [[ $log_msg == "" ]]; then
	return 0
    else
	# pull的时候不管成功与否 都不想获得提示; 后面会统一查看status, 找到push失败的工程
	ret_msg=`git pull -q 2>&1`
	if [[ $ret_msg == "" ]]; then ##sucess
	    tput setaf 3
	    printf 'step%2s. %-25s =>   %-25s pull success\n' $((step++)) $2 $dir_show
	    tput sgr0
	else
	    tput setaf 1
	    printf 'step%2s. %-25s =>   %-25s pull fail\n' $((step++)) $2 $dir_show
	    tput sgr0

	    ## err-log
	    tar_dir=~/my/bin/log
	    tar_file=my_git.log
	    mkdir -p $tar_dir
	    echo -e "\n\n--------------------------------------"  >> $tar_dir/$tar_file
	    echo -e "$date\n" >> $tar_dir/$tar_file
	    echo -e "pull repository:: $dir_show\n$ret_msg" >> $tar_dir/$tar_file
	fi
    fi
}

fun_clone(){
    str=$1
    dir_show='~'${str#~}

    if ! [ -d $1 ]; then
	git clone --branch master git@github.com:$2.git $1

	if [ -d $1 ]; then
	    tput setaf 3
	    printf 'step%2s. %-25s =>   %-25s clone success\n' $((step++)) $2 $dir_show
	    tput sgr0
	else
	    tput setaf 1
	    printf 'step%2s. %-25s =>   %-25s clone fail\n' $((step++)) $2 $dir_show
	    tput sgr0
	fi

    else
	tput setaf 2
	printf 'step%2s. %-25s =>   %-25s already have\n' $((step++)) $2 $dir_show
	tput sgr0
    fi
}

fun_auto_clone(){
    cd ~
    str=$1
    dir_show='~'${str#~}

    # 先判断状态
    if [[ -d $1 && $4 == "-f" ]]; then
	cd $1
	msg=`git status -s`
	if  [[ $msg != "" ]];then
	    tput setaf 2
	    printf '%-25s ===> \n' $dir_show
	    tput sgr0
	    git status -s
	    echo -e ""

	    # 需要确认输入才继续删除
	    read -p "Are you sure to continue? [y/n] " input
	    case $input in
		y) ;;
		*) return 0 ;;
	    esac
	fi

	# clay9/bin <clay0/bin> 这个不能强制clone, 否则会导致脚本无法运行
	if [[ $2 == clay9/bin ]];then
	    return 0
	fi

	cd ~
	rm -rf $1
    fi

    fun_clone $@
}

fun_status(){
    if ! [ -d $1 ]; then
	return 0
    fi

    str=$1
    dir_show='~'${str#~}
    cd $1

    # 查看本地是否有远端未有的commit信息
    #cbranch=`git branch --show-current` # mac xcode-git not realize
    cbranch=`git symbolic-ref --short HEAD`
    log_msg=`git log --pretty=oneline --abbrev-commit origin/${cbranch}..${cbranch}`
    msg=`git status -s`

    # 无修改 不显示
    if [[ $log_msg == "" && $msg == "" ]]; then
	return 0
    fi

    tput setaf 2
    printf 'step%2s. %-25s =>   %-25s status:\n' $((step++)) $2 $dir_show
    tput sgr0


    # 非master分支, 先打印branch
    if ! [[ "$cbranch" == "master" ]];then
	echo "branch: ${cbranch}"
    fi
    # 再打印commit信息
    if ! [[ $log_msg == "" ]]; then
	echo $log_msg
    fi
    # 再打印 working tree中修改
    if ! [[ $msg == "" ]];then
	git status -s
    fi

    echo -e ""
}

fun_log(){
    if ! [ -d $1 ]; then
	return 0
    fi

    str=$1
    dir_show='~'${str#~}
    cd $1

    if [[ $4 == "" ]];then
	num=3
    else
	num=$4
    fi

    tput setaf 2
    printf 'step%2s. %-25s =>   %-25s log:\n' $((step++)) $2 $dir_show
    tput sgr0

    IFSBK=$IFS
    IFS=$'\n'
    for line in `git log -$num --pretty=oneline --abbrev-commit`
    do
	echo "$line"
    done
    echo -e ""
    IFS=$IFSBK
}

fun_tag(){
    if ! [ -d $1 ]; then
	return 0
    fi

    str=$1
    dir_show='~'${str#~}
    cd $1

    tput setaf 2
    printf 'step%2s. %-25s =>   %-25s tag:\n' $((step++)) $2 $dir_show
    tput sgr0

    IFSBK=$IFS
    IFS=$'\n'
    for line in `git tag -l`
    do
	echo "$line"
    done
    echo -e ""
    IFS=$IFSBK
}

fun_remote_tag(){
    if ! [ -d $1 ]; then
	return 0
    fi

    str=$1
    dir_show='~'${str#~}
    cd $1

    tput setaf 2
    printf 'step%2s. %-25s =>   %-25s remote-tag:\n' $((step++)) $2 $dir_show
    tput sgr0

    IFSBK=$IFS
    IFS=$'\n'
    for line in `git ls-remote -q --tags --refs`
    do
	echo "$line"
    done
    echo -e ""
    IFS=$IFSBK
}

fun_add_tag(){
    ## 只对qygame下面的git-rep打tag
    # svr-*
    # protol
    # client    待添加
    # database  待添加

    cd ~
    rep=$2
    tag=$4
    tag_info=$5

    # tag校验
    if [[ $tag == "" ]];then
	return 0
    fi

    if [[ $tag_info == "" ]];then
	tag_info="qyproject $tag"
    fi

    # 过滤非qygame组织的
    if ! [[ $rep =~ "qygame" ]];then
	return 0
    fi

    # 过滤仓库
    rep_list=(svr- protocol client database)
    bfound=0
    for tag_rep in ${rep_list[@]}
    do
	if [[ $rep =~ $tag_rep ]];then
	    bfound=1
	    break
	fi
    done

    if [ $bfound == 0 ];then
	return 0
    fi

    # 判断文件是否存在, 如果目标dir不存在, 则clone
    if ! [ -d $1 ];then
	fun_clone $@
    fi
    # clone之后还是不存在
    if ! [ -d $1 ]; then
	echo "$1 not exisit and clone it fail"
	return 0
    fi

    cd $1

    git fetch -q # 这里需要获取所有的分支+tag, 用来进行判断
    # check remote是否已经有该tag
    for line in `git ls-remote --tags 2>&1 |awk '{print $2}'`
    do
	if [[ $line == "refs/tags/$tag" ]];then
	    tput setaf 1
	    printf "add tag<$tag> => $2, remote already exist\n"
	    tput sgr0
	    return 0
	fi
    done

    # add tag; 只要远端没有就行, 本地的不需要在意
    git tag -f $tag -m "$tag_info" remotes/origin/master >/dev/null

    # push tag => remote
    msg=`git push -q origin $tag` #只推送这一个

    if [[ $msg == "" ]];then
	tput setaf 3
	printf "add tag<$tag> => $2\n"
	tput sgr0
    else
	tput setaf 1
	printf "add tag<$tag> => $2 push fail: $msg\n"
	tput sgr0
    fi
}

fun_help(){
    printf 'usage: my_git <command>

 command    缩写     参数             说明                                              使用对象
 -------   -----  ------------    ----------------------------------------------      --------------
   all      a                      先pull, 再push;
   pull                            pull
   push                            push之前会自动commit
   clone           -f              clone; 参数-f会删除旧目录,重新clone
   status   s                      已经commit的这里不会显示
   log      l      num             查看log信息; 参数为数字,显示多少条记录, 默认为3
   tag                             查看tag信息
   rtag                            查看remote tag信息
   addtag          tag, tag_info   为qygame组织中的仓库打tag并且push到github
'
}

#******************** main ********************
case $1 in
    a|all)     cmd_list="pull push" ;;
    pull)      cmd_list="pull"      ;;
    push)      cmd_list="push"      ;;
    clone)     cmd_list="clone"     ;;
    s|status)  cmd_list="status"    ;;
    l|log)     cmd_list="log"       ;;
    tag)       cmd_list="tag"       ;;
    rtag)      cmd_list="rtag"      ;;

    addtag)    #校验tag
	       if [[ $2 == "" ]];then
		   tput setaf 1
		   printf 'invalid input, need tag\n'
		   tput sgr0
	       fi
	       cmd_list="addtag"    ;;
    *)         fun_help             ;;
esac

## 所需要管理的仓库
for cmd in $cmd_list
do
    # 使用$cmd代替$1
    opt=$@
    opt=${opt#$1}
    opt="$cmd $opt"

    # check git.cfg
    if [ ! -f ~/my/bin/git.cfg ]; then
	cp ~/my/bin/git_default.cfg  ~/my/bin/git.cfg
	tput setaf 1
	printf 'please custome git.cfg first\n'
	tput sgr0
    fi

    # 使用mygit.cfg中的配置
    while IFS=' ' read  t u
    do
	# 忽略所有以井号开头的行
	if [[ ! $t =~ ^#.* ]] ;then
	   t=$HOME${t#'~'}
	   fun_auto $t $u $opt
	fi
    done < ~/my/bin/git.cfg
done
