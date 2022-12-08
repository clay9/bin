#!/bin/bash

# 客户端子游戏复制脚本
#
# 使用说明: 
# 在当前工程根目录下执行, 输入old游戏的kindID, 输入新游戏的kindID
# 比如 ./guid.sh 9 10
# 技术原因, 第一次执行完, unity编译完后, 需要再次执行该脚本

# 1. 根据old dir 构造 new dir
# 2. 修改new dir的scene文件 和 script的命名空间
# 3. 读取old 目录中的guid
# 4. 读取new 目录中的guid
# 5. 替换new scene场景文件中old guid 为new guid


##################################################################################
##   遍历new目录, 修改命名空间
##################################################################################
function scandir_new_namespace() {
    cd $1
    for dirlist in $(ls $(pwd))
    do	 
        if [ -d ${dirlist} ]; then
            scandir_new_namespace $(pwd)/${dirlist}  $2  $3
            cd ..
        else	 
	    if [ ${dirlist##*.}x = "cs"x ]; then
		gsed -i "s/com.QH.QPGame.Sub$2/com.QH.QPGame.Sub$3/g" $dirlist
	    fi

	    #protobuf文件
	    if [ ${dirlist##*.}x = "proto"x ]; then
		gsed -i "s/ProtoBuf.Message.SubGame$2/ProtoBuf.Message.SubGame$3/g" $dirlist
	    fi

        fi
    done
}



##################################################################################
##   遍历目录, 找guid匹配的meta文件 
##################################################################################
declare -a old_file_map=()
declare -a old_guid_map=()
old_key=0

function scandir_old() {
    cd $1
    for dirlist in $(ls $(pwd))
    do	 
        if [ -d ${dirlist} ]; then
            scandir_old $(pwd)/${dirlist}
            cd ..
        else
	    if [ ${dirlist##*.}x = "meta"x ]; then
		while read line
		do
		    ## 找到scene中的guid
		    position_old=$(expr "$line" : ".*guid: ")
		    
		    ## 如果没找到, 就continue
		    if [ $position_old -eq 0 ];then
			continue
		    else
			guid_temp_old=${line:$position_old:32}

			old_file_map[$old_key]=$dirlist
			old_guid_map[$old_key]=$guid_temp_old
			old_key=$[$old_key+1]
		    fi
		done < $dirlist

	    fi
        fi
    done
}



##################################################################################
##   遍历目录, 找new meta文件的guid
##################################################################################
declare -a new_file_map=()
declare -a new_guid_map=()
new_key=0

function scandir_new() {
    
    cd $1
    for dirlist in $(ls $(pwd))
    do	 
        if [ -d ${dirlist} ]; then
            scandir_new $(pwd)/${dirlist}
            cd ..
        else
	    if [ ${dirlist##*.}x = "meta"x ]; then
		while read line
		do
		    ## 找到scene中的guid
		    position_new=$(expr "$line" : ".*guid: ")
		    
		    ## 如果没找到, 就continue
		    if [ $position_new -eq 0 ];then
			continue
		    else
			guid_temp_new=${line:$position_new:32}

			new_file_map[$new_key]=$dirlist
			new_guid_map[$new_key]=$guid_temp_new
			new_key=$[$new_key+1]
		    fi
		done < $dirlist
            fi
	fi
    done
}


##################################################################################
##  main
##################################################################################
code_path='Assets/Code/games@hotfix'
prefab_path='Assets/Resource/Runtime/SubGames'

function main(){
    ## 校验 入参$1 $2
    if [ "$1" = "" ];then
	echo "Error 请输入old kind编号"
	return
    fi

    if [ "$2" = "" ]; then
	echo "Error 请输入new kind编号"
	return
    fi 

  
    ## 1. 找到old根目录
    root_dir=$(pwd)
    
    if [ ! -d ${code_path}/$1 ]; then
	echo "Error 未找到old code目录, 请确认后重试"
	return
    fi

    if [ ! -f $prefab_path/sub_game_$1.prefab ]; then
	echo "Error 未找到old prefab目录, 请确认后重试"
	return
    fi	

    ## 2. 创建new目录
    if [ -d $code_path/$2 ];then
	echo "new code目录存在..."
    else
	echo "生成new code目录..."
	cp -R $code_path/$1 $root_dir/$code_path/$2
    fi

    ## 3. 构造new目录
    ## 3.1 修改场景文件的名字
    if [ -f $prefab_path/sub_game_$2.prefab ];then
	echo "new prefab目录存在..."
	new_scene_file=$root_dir/$prefab_path/sub_game_$2.prefab

    else
	echo "生成new prefab目录..."
	cp $prefab_path/sub_game_$1.prefab $root_dir/$prefab_path/sub_game_$2.prefab
    fi

    ## 修改图集名称
    if [ -f $code_path/$2/Atlas/sub_$1.prefab ];then
	mv $code_path/$2/Atlas/sub_$1.prefab $code_path/$2/Atlas/sub_$2.prefab
	mv $code_path/$2/Atlas/sub_$1_puke.prefab $code_path/$2/Atlas/sub_$2_puke.prefab
    fi

    ## 修改protobuf名称
    if [ -f $code_path/$2/Scripts/Protobuf/STR_SubGame$1.proto ]; then
	mv $code_path/$2/Scripts/Protobuf/STR_SubGame$1.proto $code_path/$2/Scripts/Protobuf/STR_SubGame$2.proto
    fi

    ## 3.2 修改命名空间
    echo "构造new script..."
    scandir_new_namespace $root_dir/$code_path/$2/Scripts  $1 $2
    
    ## 1. 获取old目录下所有脚本的map
    echo -e "获取old目录脚本..."
    old_key=0
    scandir_old $root_dir/$code_path/$1

    ## 2. 获取new目录下所有脚本的map
    echo -e "获取new目录脚本..."
    new_key=0
     scandir_new $root_dir/$code_path/$2

    ## 3. 判断是否一致
    if [ "$old_key" != "$new_key" ]; then
	echo "old new脚本数目不匹配 $old_key $new_key"
	return
    else
	echo "脚本获取完毕, 总数量: $old_key"
    fi

    ## 4. 替换old guid 为 new guid
    echo "脚本替换中"
    for((i=0;i<=$old_key-1;i++));
    do
	#echo -e "\n"
	#echo -n "${old_guid_map[$i]} -- ${new_guid_map[$i]}"
	echo -n "."
	$(gsed -i "s/${old_guid_map[$i]}/${new_guid_map[$i]}/g" $new_scene_file)
    done

    echo -e "\nEverything is OK. Enjoy it"
}


main $1 $2
