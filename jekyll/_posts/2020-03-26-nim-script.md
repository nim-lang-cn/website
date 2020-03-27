---
title: NimScript初体验
author: 星之轨迹（Nim开发集中营）
excerpt: "这两天刚接触Nim，这里分享一下关于NimScript的心得"
---

<!--
create time: 2020-03-26 18:59:16
Author: <TODO: 请写上你的名字>

This file is created by Marboo<http://marboo.io> template file $MARBOO_HOME/.media/starts/default.md
本文件由 Marboo<http://marboo.io> 模板文件 $MARBOO_HOME/.media/starts/default.md 创建
-->

Nim 是一种静态类型的、编译型、系统编程语言。它结合了其他成熟语言的成功概念。
它具有接近Python的语法，和接近C语言的运行速度。就在2020年1月24日，它发布了自己的v1.0.6版本。

官方网站：[https://nim-lang.org/](https://nim-lang.org/)  
中文网站：[https://nim-cn.com/](https://nim-cn.com/)

Nim语言有一大堆的优点，开发简单、语法丰富、性能优秀。不必像忍受Go语言那样去忍受它固执单一的语法。但是目前来讲，使用该语言也有一定的风险，那就是它不够成熟，周边的库不够丰富，遇到问题可能会难以解决。

这两天刚接触Nim，这里分享一下关于NimScript的心得。

## NimScript
关于如何安装和使用Nim这里略过，只简单介绍下它的脚本用法。以下所有测试，都基于 Nim v1.0.6，运行于MacOS 10.15.4。 Nim的安装目录"/usr/local/Cellar/nim/1.0.6/nim"

Nim虽然是一个静态、编译型的语言，但是它提供了脚本的执行方式，官方称它为"NimScript"。  
Nim脚本的后缀必须为 .nims。

运行方式1: `nim test.nims`（有没有感觉跟python很像,`python test.py`）  
运行方式2: `./test.nims` （前提是赋予test.nims执行权限，并且在脚本首行写上`#!/usr/bin/env nim`）

test.nims脚本内容为（首行的`--hits:off`，是要求脚本执行的时候不要打印Hint信息，可以省略）

```
#!/usr/bin/env nim --hints:off


echo("Hello World!")
```

这是一个最简单的Nim脚本。在这个脚本里面，可以使用Nim的语法写代码（语法跟Python差不多），然后像执行Python一样去执行这个脚本。执行起来性能却跟C语言差不多，这听起来很完美对不对。

NimScript的官方介绍：[https://nim-lang.org/docs/nims.html](https://nim-lang.org/docs/nimscript.html)  
NimScript直接支持的函数方法介绍：[https://nim-lang.org/docs/nimscript.html](https://nim-lang.org/docs/nimscript.html)

## 遇到的问题
没有什么是完美的，当我尝试写第一个小Nim脚本的时候就遇到了各种问题。

脚本的目的很简单：遍历一个目录下面的所有文件，然后读取里面的文件。
按照 [https://nim-lang.org/docs/nimscript.html](https://nim-lang.org/docs/nimscript.html) 的官方介绍，我很快找到了 `listDirs()`函数和`listFiles()`函数。`listDirs()`只能列出指定目录下的“文件夹”，`listFiles()`函数只能列出指定目录下的“文件”。 

```
#!/usr/bin/env nim

var baseDir = "./"
for childDirName in listDirs(basedir):
    for filePath in listFiles(childDirName):
        echo(filePath)
        #var f = open(filePath)

```
打印出这个

```
dir2/test2.md
dir1/test1.md
```

然后当我想读取文件内容的时候（把最后一行注释打开），编译报错了：

```
/usr/local/Cellar/nim/1.0.6/nim/lib/system/io.nim(525, 20) Error: cannot 'importc' variable at compile time; fopen
```
研究了一番，最终在官方解释中得到了结论。官方的原话是

```
Strictly speaking, NimScript is the subset of Nim that can be evaluated by Nim's builtin virtual machine (VM). 
NimScript is subject to some limitations caused by the implementation of the VM (virtual machine):
Nim's FFI (foreign function interface) is not available in NimScript. This means that any stdlib module which relies on importc can not be used in the VM.
```
翻译一下就是：

```
严格地说，NimScript是通过Nim内建的虚拟机(VM)来执行的，NimScript是Nim的一个子集。由于VM的实现问题，导致了NimScript运行的时候有一些限制，具体如下：
Nim语言的 FFI（外部函数接口）在NimScript中不能用。这意味着标准库中所有依赖importc的模块都不能在VM中使用。
```

GG，读写文件的open()函数依赖`importc`能力，所以读写文件不能在NimScript中使用。

## 可以使用的模块
Nim官方很贴心的列出了其他可以在NimScript中使用的标准库模块，列表如下：

* macros
* os
* strutils
* math
* distros
* sugar
* algorithm
* base64
* bitops
* chains
* colors
* complex
* htmlgen
* httpcore
* lenientops
* mersenne
* options
* parseutils
* punycode
* random
* stats
* strformat
* strmisc
* strscans
* unicode
* uri
* std/editdistance
* std/wordwrap
* std/sums

文件读写的open()相关函数在io库中，不在上述列表，所以不能用了……  
不过考虑到还是有很多其他标准库可以用的，所以还是能写出一些功能强大的脚本的。虽然不能替代python，不过应该以替代shell脚本吧…… 

## 进一步挖掘
进入Nim的安装目录`/usr/local/Cellar/nim/1.0.6/nim/`。  
涉及NimScript的文件主要就是`compiler/scriptconfig.nim`，这文件定义了NimScript中直接支持的各个函数接口，包括上面用到的listDirs()和listFiles()。 这些接口底层还是调用标准库来实现。

而Nim的标准库等实现，都存放在lib/目录中。研究分析这些代码，都有助于我们对Nim的理解。


## 小结
NimScript的功能还是有一些限制的，不过Nim自身的语法已经很简洁了，NimScript仅仅是尝鲜，用Nim直接写代码就不会遇到这些功能限制了。 直接用Nim实现列目录的话，只需要用`os.walkDir()`即可

```
import os

for a in os.walkDir("./"):
    echo(a[1])
```

刚接触Nim两天的的新手，不免会有认知上的错误，望指正，也希望Nim越来越完善。

---

    注：本站首发，已经原作者授权，转载请注明出处
