---
layout: page
title: Unix下的安装
css_class: install_unix
current: Install
---

<h1 class="text-centered page-title main-heading">在类Unix系统中安装Nim</h1>

# 使用``choosenim``安装

[``choosenim``](https://github.com/dom96/choosenim#choosenim)是一个Nim语言安装器。
它能帮助您轻松地在Nim的各个版本之间切换，无论是最新的稳定版本还是最新的开发版本。

使用``choosenim``安装Nim最新的稳定版本，
只需要在你的终端中运行下方的命令，然后根据屏幕上的说明操作即可：

```bash
curl https://nim-lang.org/choosenim/init.sh -sSf | sh
```

# 手动安装

## Linux的预构建二进制文件

<div class="center">
  <a href="{{ site.official_baseurl }}/download/nim-{{ site.nim_version }}-linux_x32.tar.xz"
    class="pure-button pure-button-primary download-button">
    <i class="fa fa-file-archive-o" aria-hidden="true"></i>
    下载x86压缩包
  </a>
  <a href="{{ site.official_baseurl }}/download/nim-{{ site.nim_version }}-linux_x32.tar.xz.sha256"
    class="pure-button">
    <i class="fa fa-file-text-o" aria-hidden="true"></i>
    SHA256
  </a>
</div>

<div class="center">
  <a href="{{ site.official_baseurl }}/download/nim-{{ site.nim_version }}-linux_x64.tar.xz"
    class="pure-button pure-button-primary download-button">
    <i class="fa fa-file-archive-o" aria-hidden="true"></i>
    下载x86_64压缩包
  </a>
  <a href="{{ site.official_baseurl }}/download/nim-{{ site.nim_version }}-linux_x64.tar.xz.sha256"
    class="pure-button">
    <i class="fa fa-file-text-o" aria-hidden="true"></i>
    SHA256
  </a>
</div>

## 从源码构建

<div class="center">
  <a href="{{ site.official_baseurl }}/download/nim-{{ site.nim_version }}.tar.xz"
    class="pure-button pure-button-primary download-button">
    <i class="fa fa-file-archive-o" aria-hidden="true"></i>
    下载源文件压缩包
  </a>
  <a href="{{ site.official_baseurl }}/download/nim-{{ site.nim_version }}.tar.xz.sha256"
    class="pure-button">
    <i class="fa fa-file-text-o" aria-hidden="true"></i>
    SHA256
  </a>
</div>

下载压缩的存档文件后，将其内容解压到所需的安装目录中。

在二进制发行版中提供了预先构建好的二进制文件。

如果是从源码自己构建的话，新打开一个命令行窗口，
使用``cd``命令进入到你刚才解压的文件夹，然后执行下面的命令以完成构建：

```bash
sh build.sh
bin/nim c koch
./koch tools
```

## 手动安装需要配置``PATH``环境变量

编译器和工具的二进制文件都位于``bin``目录中。
要使用Nim进行开发，需要在你的
[``PATH``环境变量](https://zh.wikipedia.org/wiki/PATH_(%E5%8F%98%E9%87%8F))
中添加以下两个目录：:

* Nim的二进制文件位于你解压的文件夹下的``bin``目录下，所以这个目录在环境变量中是必需的；
* ``~\.nimble\bin`` (``~``指的是你的HOME目录)

# 关于编译器依赖的说明

Nim编译器编译软件时需要一个C编译器。
您必须单独安装它，并确保它在您的``PATH``中。

## macOS

在Mac中，你可以简便地安装最新版本的``clang``。
就像这样:

* 新打开一个终端窗口
* 执行``xcode-select --install``
* 在出现的对话框中，点击"Install"按钮

**参考：** [Quora](https://www.quora.com/How-do-I-successfully-set-up-LLVM-clang-on-Mac-OS-X-El-Capitan/answer/James-McInnes-1?srid=hq2O)

## Linux

你可能已经安装了编译器。 
如果没有的话，用你的包管理器在
``gcc``和``clang``中选一个装上。

## Other依赖

下面展示了一个包含了其他依赖的列表，
你需要先确保安装了这些依赖，才能使用Nim。

* PCRE
* OpenSSL

必要时，可以使用包管理器安装这些依赖项。

# 使用包管理器安装

## Arch Linux

```
pacman -S nim
```

## Debian / Ubuntu

```
apt-get install nim
```

## Docker

社区管理的[Docker镜像](https://hub.docker.com/r/nimlang/nim/)
在Docker Hub上发布，包括了编译器和Nimble。
有独立脚本和Nimble包的镜像。

获取最新的**稳定**镜像：

```
docker pull nimlang/nim
```

获取最新的**开发**镜像：

```
docker pull nimlang/nim:devel
```

## Fedora

```
dnf install nim
```

## FreeBSD

```
pkg install nim
```

## macOS

```
brew install nim
```

## openSUSE

```
zypper in nim
```

## Void Linux

```
xbps-install -S nim
```
