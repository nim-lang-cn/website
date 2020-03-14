#!/bin/bash

cd ../rst
function read_dir(){
    for file in `ls $1|grep .rst` #注意此处这是两个反引号，表示运行系统命令
        do
        if [ -d $1"/"$file ] #注意此处之间一定要加上空格，否则会报错
            then
                read_dir $1"/"$file
            else
                nim rst2html $file
        fi
        done
} 
#读取第一个参数
read_dir $1