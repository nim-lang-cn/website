---
layout: page
title: Windows下安装
css_class: install_windows
current: Install
---


<h1 class="text-centered page-title main-heading">在Windows下安装Nim</h1>

# 手动安装

If you are not sure which version (64-bit or 32-bit) to pick, it is very likely
that you want the 64-bit version (x86\_64):

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

If you know what you are doing and you are sure you need a 32-bit version,
you can download it below:

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

The installation using the provided zip files should be fairly
straightforward. Simply extract the files into the desired installation
directory, and run ``finish.exe``.

## 配置``PATH``环境变量


要使用Nim进行开发，需要在你的[``PATH``环境变量](https://zh.wikipedia.org/wiki/PATH_(%E5%8F%98%E9%87%8F))中添加以下两个目录：

The zip file includes a simple application called ``finish.exe`` that can
attempt to add both directories to your ``PATH``.
This tool also checks for the presence of a C compiler and can install ``MingW``,
the GNU C compiler collection for Windows.

## Compiler dependencies

Nim编译器编译软件时需要一个C编译器，
你可以使用``finish.exe``来安装MingW。

以下版本的MingW可完美地与最新版本的Nim配合使用：

<!-- TODO: Instructions on what to do with these 7z files? -->

* 32位 - [mingw32.7z]({{ site.official_baseurl }}/download/mingw32.7z)
* 64位 - [mingw64.7z]({{ site.official_baseurl }}/download/mingw64.7z)


# 使用 ``choosenim`` 进行安装

[``choosenim``](https://github.com/dom96/choosenim#choosenim) is an
installer for the Nim programming language. It allows you
to easily switch between versions of Nim, whether that is the latest stable
release or the latest development version.
