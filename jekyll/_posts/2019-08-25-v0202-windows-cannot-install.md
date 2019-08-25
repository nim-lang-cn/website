---
title: "Windows下nim-lang 0.20版本安装，无法运行finish.exe的解决方案"
author: ch4o5
---

    Nim is a statically typed compiled systems programming language. 
    It combines successful concepts from mature languages like Python,Ada and Modula.

    它结合了来自成熟语言（如PYTHON、ADA和MODULA）的成功概念。

Nim中文网站：[https://nim-lang-cn.org/](https://nim-lang-cn.org/)

下载页：[https://nim-lang-cn.org/install.html](https://nim-lang-cn.org/install.html)

## 目录

1. [安装Nim](#安装步骤)
2. [无法运行finish.exe的解决方案](#无法运行finish_exe的解决方案)

## 安装步骤

1. 进入上方官方网站，
并根据你使用的操作系统，
下载最新的稳定版压缩包

2. 解压到任意你喜欢的目录下

3. 运行此目录下的finish.exe

4. 根据提示进行环境变量的配置

5. 根据提示进行MingW的下载和解压，
并配置目录下的bin目录到环境变量中，
所以无需解压到nim目录下

6. 在finish.exe引导安装完成之后 *（建议先重启电脑，防止环境变量不生效）* ，
打开一个命令行，
并输入：nim命令进行测试。
如果能够显示如下图像，
就说明安装成功了。

    ![]({{ site.baseurl }}/assets/img/posts/2019-08-25-v0202-windows-cannot-install-1.png)

但在0.20版本安装的过程中，出现了finish.exe无法运行的情况，点击之后没有反应，后来终于找到了解决方案，并亲测有效。

## 无法运行finish_exe的解决方案

### 一、查找问题

1. 在finish.exe同级目录下，
按住Shift键，同时右击文件夹的空白处，
选择在此处打开Poweshell（或者cmd）

2. 输入并运行.\finish.exe

3. 正常来说，有问题的话这里会直接抛出异常，并打印出错误原因；
没问题的话，这里会直接正常运行finish.exe

4. 然后就可以根据报错，去查找答案了。

### 二、解决问题
#### `Error: unhandled exception: file 'C:\user\xxx\.nimble\bin' does not exist [OSError]`

##### 参考资料：

[https://github.com/nim-lang/Nim/issues/11676#issuecomment-510780848](https://github.com/nim-lang/Nim/issues/11676#issuecomment-510780848) （这条回复我写的，欢迎follow我~）

##### 发生原因：
怀疑可能是因为`finish.exe`没有权限在【`我的文档`】
（姑且按Win7这么叫，
毕竟win8以后是用户名了，
其实正经应该叫`%User Home%`，
但是不知道该怎么翻译……）
中创建目录导致的。

##### 解决方法：
手动在`%User Home%`中创建`.nimble/`目录，然后再试试在命令行中运行`finish.exe`，还不行就把`.nimble/`下的`bin/`也创建了。

我的是在把这两个都创建了之后就好了。

---

目前没有碰到其他问题，
如果有朋友遇到了其他问题的话，
欢迎来[我的博客](https://blog.doylee.cn/)下面留言，
让我们一起帮助Nim快速成长（到1.0版本）！

    
 —— [博客原文](https://blog.doylee.cn/win-install-nim/)转自《[乱世之牙](https://blog.doylee.cn/)》
