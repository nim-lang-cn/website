---
title: "实战Nim入门系列（一）——下载安装Nim环境"
author: ch4o5
---

自从在开源中国发了资讯之后，群里来了好多人啊😊
赶紧开始准备个目前版本(v0.20.2)的系列教程，帮助大家上手~

---

## 目录

   [Windows下的下载安装](#Windows)

​      [一、 64位环境常规安装](#一、64位环境常规安装)

​      [二、32位使用choosenim安装](#二、32位使用choosenim安装)

​      [三、常规安装步骤](#三、常规安装步骤)

   [类Unix环境下的下载安装](#Unix)

​		[一、使用choosenim进行安装](一、使用choosenim进行安装)

​		[二、常规方式安装](#二、常规方式安装)

​		[三、脚本一键安装](#三、脚本一键安装)

   [MacOS系统下的下载安装](#MacOS)

   [从源码编译](#从源码编译)


## Windows

### 一、64位环境常规安装

1. 访问[Nim中文社区](https://nim-lang-cn.org)中的[在Windows下安装Nim](https://nim-lang-cn.org/install_windows.html)页面

2. 点击 **下载x86版本的zip包** 下载最新版本的Nim

3. 将下载好的压缩包放在你想要的位置，并解压

4. 运行目录下的 `finish.exe` 

   *点击无响应的话，可以参考我发在中文社区的 [这篇文章](https://nim-lang-cn.org/blog/2019/08/25/v0202-windows-cannot-install.html)*

5. 之后按照 `finish.exe` 的提示，逐步进行

6. 完成后按 `win` + `r` ，输入 `cmd` 并回车

   在新打开的命令行窗口中，输入 `nim -v` 

如果显示` nim 不是内部或外部命令`balabala的，说明没有正确安装，请跳转到[第三章节](#三、常规安装步骤)

### 二、32位使用choosenim安装

`choosenim`是一个`nim`的版本管理器，类似于`nvm`之于`node`

使用`choosenim`之后，你可以方便的切换`nim`版本和更新`nim`

*在Windows下的`choosenim`只支持**32位**的下载，* 

*你可以在64位系统下进行安装，但是这样的话你的nim版本只能也使用32位的，否则会报错*

1. 安装 `choosenim`

   1. 访问[这个页面](https://github.com/dom96/choosenim/releases)下载最新版本`choosenim`的`.exe`格式文件
   2. 下载完成后直接双击运行
   3. 跟随屏幕指引进行操作即可

2. 安装最新稳定版本的`nim`

   ```powershell
   choosenim update stable
   ```

### 三、常规安装步骤

本安装步骤为Windows系统通用安装步骤，但是较为复杂，建议有一定的基础的使用者尝试，或者作为`finish.exe`无法正确安装的替代方案。

1. 在[Nim中文社区](https://nim-lang-cn.org)中的[在Windows下安装Nim](https://nim-lang-cn.org/install_windows.html)页面，下载你的系统对应版本的压缩包
2. 在解压完成后**配置环境变量**，添加以下两个目录：
   1. 你刚才解压出来的文件夹里的`bin/`目录
   2. `%USERPROFILE%\.nimble\bin` （`%USERPROFILE%`指的是你的HOME目录，Win7以下是`我的文档`，也可能叫做`Administrator`之类的用户名）

3. 下载安装C编译器`MingW`

   * 32位Nim - [mingw32-6.3.0.7z](https://nim-lang.org/download/mingw32-6.3.0.7z)
   * 64位Nim - [mingw64-6.3.0.7z](https://nim-lang.org/download/mingw64-6.3.0.7z)

4. 补全必要的依赖DLL

   - PCRE
   - OpenSSL

   1. 下载地址：[https://nim-lang.org/download/dlls.zip](https://nim-lang.org/download/dlls.zip)

   2. 下载之后解压在`nim.exe`的同级目录中

      *通常是`bin/`目录下*

5. 在终端中运行`nim -v`

如果本安装方式依然无法让`nim -v`在你的电脑中正确运行，你可以来[Nim开发集中营](https://jq.qq.com/?_wv=1027&k=5mGEIrV)QQ群中提问，我们很乐意帮助你！

## Unix

类Unix环境下，墙裂推荐使用`choosenim`进行版本控制，高效方便，省电低碳，省下时间做大事~

### 一、使用choosenim进行安装

使用`choosenim`安装Nim最新的稳定版本， 只需要在你的终端中运行下方的命令，然后根据屏幕上的说明操作即可：

```bash
curl https://nim-lang.org/choosenim/init.sh -sSf | sh
```

*注：可能需要root权限*

### 二、常规方式安装

再次说明，Linux环境中建议优先选择使用`choosenim`进行安装，此安装方式没有使用`choosenim`方式灵活和方便。

和楼上的Windows常规方法安装类似，只不过由于c编译器都已经系统自带了，所以省了一步

1. 在[Nim中文社区](https://nim-lang-cn.org)中的[在Unix下安装Nim](https://nim-lang-cn.org/install_unix.html)页面，下载你的系统对应版本的预构建二进制文件压缩包

2. 手动配置`PATH`环境变量

   编译器和工具的二进制文件都位于`bin`目录中。 要使用Nim进行开发，需要在你的 [`PATH`环境变量](https://zh.wikipedia.org/wiki/PATH_(变量)) 中添加以下两个目录：

   * 你解压的文件夹下的`bin`目录下
   * `~\.nimble\bin` (`~`指的是你的HOME目录)
   
3. 运行`nim -v`测试安装结果

### 三、脚本一键安装

从@Sheldon那里抄来的：

```sh
git clone https://github.com/nim-lang/Nim.git
cd Nim
sh build_all.sh
cat << EOF >> ~/.bashrc
export NIM=/root/Nim/bin
export NIMBLE_DIR=/root/.nimble
export PATH=$PATH:$NIM:$NIMBLE
EOF
source ~/.bashrc
```

## MacOS

原谅我穷。。并没有Mac。。

不过你可以去[中文社区](https://nim-lang-cn.org/install_unix.html)看看关于Mac安装的部分。

## 从源码编译

很惊讶你竟然选择了这么 Cooooooooool 的安装方式！！

我觉得你这么极客的人也不需要我带着你弄了，你还是去[中文社区](https://nim-lang-cn.org/install.html)看看吧~

