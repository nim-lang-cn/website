#!/bin/bash

target="/home/travis/build/nim-lang-cn/website"
# target="/tmp"

# 将已翻译的部分
cp -r ${target}/lib_doc/* .

nim_doc_lib_generator(){
    for file in `ls $1|grep .nim` #注意此处这是两个反引号，表示运行系统命令
        do
        if [ -d $1"/"$file ] #注意此处之间一定要加上空格，否则会报错
            then
                nim_doc_lib_generator $1"/"$file
            else
                nim doc $file
                file_name="${file%.*}"
                cp -f ${file_name}.html ${target}/jekyll/_site/docs/
        fi
        done
} 

#读取第一个参数
nim_doc_lib_generator $1
