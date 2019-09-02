---
layout: page
title: Windows下安装
css_class: install_windows
current: Install
---


<h1 class="text-centered page-title main-heading">在Windows下安装Nim</h1>

<div class="center">
  <a href="{{ site.official_baseurl }}/download/nim-{{ site.nim_version }}_x32.zip"
    class="pure-button pure-button-primary download-button">
    <i class="fa fa-file-archive-o" aria-hidden="true"></i>
    下载x86版本的zip包
  </a>
  <a href="{{ site.official_baseurl }}/download/nim-{{ site.nim_version }}_x32.zip.sha256"
    class="pure-button">
    <i class="fa fa-file-text-o" aria-hidden="true"></i>
    SHA256校验
  </a>
</div>

<div class="center">
  <a href="{{ site.official_baseurl }}/download/nim-{{ site.nim_version }}_x64.zip"
    class="pure-button pure-button-primary download-button">
    <i class="fa fa-file-archive-o" aria-hidden="true"></i>
    下载x64版本的zip包
  </a>
  <a href="{{ site.official_baseurl }}/download/nim-{{ site.nim_version }}_x64.zip.sha256"
    class="pure-button">
    <i class="fa fa-file-text-o" aria-hidden="true"></i>
    SHA256校验
  </a>
</div>

# 关于二进制文件安装的说明

使用提供的zip文件的安装应该相当简单。
只需将文件解压到所需的安装目录，
然后运行``finish.exe``，跟随指引一步步配置即可。

## 配置``PATH``环境变量


要使用Nim进行开发，需要在你的[``PATH``环境变量](https://zh.wikipedia.org/wiki/PATH_(%E5%8F%98%E9%87%8F))中添加以下两个目录：

* Nim的二进制文件位于你解压的文件夹下的``bin``目录下，所以这个目录在环境变量中是必需的；
* ``%USERPROFILE%\.nimble\bin`` (``%USERPROFILE%``指的是你的HOME目录，Win7以下是``我的文档``，也可能叫做``Administrator``之类的用户名)

下载的zip文件中包含了一个名为``finish.exe``的文件，
它会尝试在你的``PATH``中添加上面说的第一个目录，
此工具还会自动检查你的系统中是否存在C编译器，你可以通过它安装MingW（一个Windows的GNU C编译器集合）。

# 关于编译器依赖的说明

Nim编译器编译软件时需要一个C编译器，
你可以使用``finish.exe``来安装MingW。

以下版本的MingW可完美地与最新版本的Nim配合使用：

<!-- TODO: Instructions on what to do with these 7z files? -->

* 32位 - [mingw32-6.3.0.7z]({{ site.official_baseurl }}/download/mingw32-6.3.0.7z)
* 64位 - [mingw64-6.3.0.7z]({{ site.official_baseurl }}/download/mingw64-6.3.0.7z)

# 其他依赖

下面展示了一个包含了其他依赖的列表，
你需要先确保安装了这些依赖，才能使用Nim。

* PCRE
* OpenSSL

Windows用户可以通过[这个链接]({{ site.official_baseurl }}/download/dlls.zip)一次性下载这些必要的DLL，
并在`nim.exe`的同级目录下替换他们。
