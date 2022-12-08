#! /bin/bash
 
# 传入这次的版本号
version_string=$(date +%Y%m%d%H)
 
# build号  我们是使用前时间作为build号的 2016041517 即为16年4月15号17点
build_number=$(date +%Y%m%d%H)

# 进入要工作的文件夹
cd ~/Desktop/ios
  
# 下面是一些用到的变量给抽取出来了
# 打包项目名字
scheme_name=Unity-iPhone

# TODONOW 暂时不知道怎么玩
# 打包使用的证书 
#CODE_SIGN_IDENTITY="iPhone Developer: chengqing wang (HLTB4BCL47)"
# 打包使用的描述文件 这描述文件的名字不是自己命名的那个名字，而是对应的8b11ac11-xxxx-xxxx-xxxx-b022665db452这个名字
#PROVISIONING_PROFILE="94e4cd09-f3c5-4d6c-b765-ed661e50b76a.mobileprovision"

# 指定xxx.app的输出位置 也就是Demo中build文件夹的位置
build_path=~/Desktop/ios/build
rm -rf ${build_path} >> /dev/null
mkdir ${build_path}

# 指定.ipa的输出位置
ipa_path=~/Desktop/ipa
rm -rf ${ipa_path} >> /dev/null
mkdir ${ipa_path}

# project文件 --这个改动不知道会不会有大问题
project_file=~/Desktop/ios/Unity-iPhone.xcodeproj
rm -rf ${project_file} >> /dev/null
cp -R ~/bin/one_key_for_iphone/Unity-iPhone.xcodeproj ~/Desktop/ios/Unity-iPhone.xcodeproj

# info.plist 用之前设定好的替换
info_plist=~/Desktop/ios/Info.plist
rm ${info_plist} >> /dev/null
cp ~/bin/one_key_for_iphone/Info.plist ~/Desktop/ios/

#entitlements 文件
entitlements_file=~/Desktop/ios/Unity-iPhone/jxz.entitlements
rm ${entitlements_file} > /dev/null
cp ~/bin/one_key_for_iphone/jxz.entitlements ~/Desktop/ios/Unity-iPhone/

# 下面是读取.plist文件的位置然后修改版本号和build号，这点没有使用xcodebuild提供的命令，在上面也有叙述
# 修改版本号
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $version_string" ${info_plist}
 
# 修改build号
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $build_number" ${info_plist}

# 生成xxx.app, 在build_path路径下面
#xcodebuild -project Unity-iPhone.xcodeproj -scheme ${scheme_name} -configuration Release clean -sdk iphoneos build CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" PROVISIONING_PROFILE="${PROVISIONING_PROFILE}" SYMROOT="${build_path}"

xcodebuild archive -project Unity-iPhone.xcodeproj -scheme ${scheme_name} -configuration Release clean -sdk iphoneos build SYMROOT="${build_path}"
 
# 生成xxx.ipa, 在ipa_path路径下面
# 该方法已过世
#xcrun -sdk iphoneos -v PackageApplication ${build_path}/Release-iphoneos/jxz.app -o ${ipa_path}/jxz_${version_string}.ipa

#xcodebuild -exportArchive -archivePath ${build_path}/Release-iphoneos/jxz.app -exportPath ${ipa_path}/jxz_${version_string}.ipa  

