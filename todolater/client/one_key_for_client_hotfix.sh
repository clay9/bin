#!/bin/bash

g_source='/Users/clay/qy/client/Assets/StreamingAssets/publish'
g_target='/Users/clay/qy/qy-hotfix'


for dirlist in $(ls ${g_source})
do
    if [ -d $g_source/$dirlist ]; then
	if [ -d $g_target/$dirlist ]; then
	    rm -rf $g_target/$dirlist
	fi
	cp -r $g_source/$dirlist $g_target
    fi
done

#2.上传到github
#git add .
#git commit -m "anthor auto-hotfix"
#git push
