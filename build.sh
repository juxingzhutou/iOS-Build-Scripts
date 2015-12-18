#!/bin/sh

#  build.sh
#
#  Created by juxingzhutou on 15/12/18.
#  Copyright (c) 2015年 bluntsword. All rights reserved.

#############################
#
#   修改脚本参数
#
#############################

project_path=`dirname $0`/../../                            #项目文件的路径，将编译脚本放在项目目录中可以使用相对路径
adhoc_macro_setting='${inherited} ADHOC=1'                  #adhoc模式下的宏定义
adhoc_profile="XXX_Adhoc"                                   #adhoc模式下使用的provision文件
development_macro_setting='${inherited} DEVELOPMENT=1'      #develoment模式下的宏定义
develoment_profile="XXX_Dev"                                #development模式下使用的provision文件
appstore_macro_setting='${inherited} APP_STORE=1'           #appstore模式下的宏定义
appstore_profile="XXX_App_Store"                            #appstore模式下使用的provision文件

app_name="APP_NAME"                         #应用名字
scheme="SCHEME_NAME"                        #工程文件中应用的scheme名字（一般和target名字相同）
workspace="XXXX.xcworkspace"                #工程文件的名字

############################


read -p "请输入打包类型（adhoc或development或appstore）" mode

if [ $mode = "adhoc" ] ;  then
# 内测发布模式
echo "内测发布模式"
macro_setting="$adhoc_macro_setting"
profile="$adhoc_profile"

elif [ $mode = "development" ] ; then
# 开发模式
echo "开发模式"
macro_setting="$development_macro_setting"
profile="$develoment_profile"

elif [ $mode = "appstore" ] ; then
#APP STORE模式
    read -p "你是否确认已正确地修改了APP的版本号与Build Number?(y/n)" confirm
    if [ $confirm != "y" ] ;  then
        echo "请正确修改后重试"
        exit 1
    fi

macro_setting="$appstore_macro_setting"
profile="$appstore_profile"

else
echo "模式无法识别！"
exit 1

fi

cd "$project_path"

#clear export dir
export_path=exports
rm -rf $export_path
mkdir $export_path

#archive and export ipa
archive_path=$export_path/"$app_name".xcarchive
app_path=$export_path/"$app_name".ipa

xcodebuild -scheme "$scheme" archive -archivePath $archive_path -workspace "$workspace" GCC_PREPROCESSOR_DEFINITIONS="${macro_setting}"
xcodebuild -exportArchive -exportFormat ipa -archivePath $archive_path -exportPath $app_path -exportProvisioningProfile "$profile"

#############################
#
#   发布到分发平台
#
#############################

# 发布到fir
fir_user_key="xxxxx"
fir p $app_path -T "$fir_user_key"

#发布到pre.im
pre_im_user_key="xxx"
curl -F "file=@${app_path}" -F "user_key=${pre_im_user_key}" -F "update_notify=1" -F "app_resign=1" http://pre.im/api/v1/app/upload

# 发布到蒲公英
uKey="xxxxx"
apiKey="xxxx"
password="xxxx"
curl -F "file=@${app_path}" -F "uKey=${uKey}" -F "_api_key=${apiKey}" -F "publishRange=2" -F "password=${password}" http://www.pgyer.com/apiv1/app/upload