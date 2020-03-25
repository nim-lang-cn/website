---
title: "使用Visual Studio Code调试Nim语言"
author: 包菜（Nim中文社区）
expert: "由于Nim语言没有官方的IDE，开发程序起来会非常麻烦，
    虽然也有人喜欢用纯文本编辑器来写程序，但项目大一些的话，还是IDE使用起来更方便。
    好在Visual Studio Code十分强大，可以满足Nim开发的需求。"
---

    由于Nim语言没有官方的IDE，开发程序起来会非常麻烦，
    虽然也有人喜欢用纯文本编辑器来写程序，但项目大一些的话，还是IDE使用起来更方便。
    好在Visual Studio Code十分强大，可以满足Nim开发的需求。

## 第一部分：安装Nim， 以windows平台为例

1. 从官方网站上下载Nim程序：[https://nim-lang.org/install.html]()，选择合适版本下载，解压到合适位置，比如：D:\nim。

2. 将D:\nim\bin文件夹添加到PATH环境变量中。

3. 运行D:\nim\finish.exe程序，按照提示下载mingw，将下载的7z格式文件移动到D:\nim\dist目录下。

4. finish.exe文件会自动解压7z文件，按照提示完成finish.exe的所有流程。

5. 打开cmd，输入命令：nim --version，如果没有提示错误，那么安装完成。

6. 将D:\nim\dist\mingw64\bin文件夹添加到PATH环境变量中，调试的时候需要gcc，刚好这里面已经有了。

## 第二部分：设置Visual Studio Code

1. 下载安装Visual Studio Code，安装插件Nim。

2. 创建项目，在项目下创建.vscode文件夹，里面创建一个tasks.json文件，写入一下内容： 

    ```json
    {
        // See https://go.microsoft.com/fwlink/?LinkId=733558
        // for the documentation about the tasks.json format
        "version": "2.0.0",
        "tasks": [
            {
                "label": "Run app.nim",
                "type": "shell",
                "command": "nim",
                "args": ["c", "app.nim"],
                "options": {
                    "cwd": "${workspaceRoot}"
                },
                "group": {
                    "kind": "build",
                    "isDefault": true
                }
            }
        ]
    }
    ```

3. 在.vscode目录下创建launch.json文件，写入一下内容： 

    ```json
    {
        // Use IntelliSense to learn about possible attributes.
        // Hover to view descriptions of existing attributes.
        // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
        "version": "0.2.0",
        "configurations": [
            {
                "name": "启动",
                "type": "cppvsdbg",
                "request": "launch",
                "program": "${workspaceFolder}/app.exe",
                "args": [],
                "preLaunchTask": "${defaultBuildTask}",
                "stopAtEntry": false,
                "cwd": "${workspaceFolder}",
                "environment": [],
                "externalConsole": false
            }
        ]
    }
    ```

4. 在项目下创建app.nim，输入echo "hi nim"，保存，按下F5开始编译和调试程序。

---
原文链接：[http://liuguang.site/代码/11.html]()

    注：已经原作者授权，转载请注明出处