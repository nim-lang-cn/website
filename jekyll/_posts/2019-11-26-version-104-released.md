---
title: "1.0.4 版本现已发布！"
author: Nim 开发团队
excerpt: "Nim 团队很高兴为大家带来 1.0.4 版本发布的消息！这是我们在 Nim 1.0.0 之后发布的第二个补丁版本。"
---

> 以下由中文社区翻译，能力有限，如有翻译错误，欢迎加入 QQ 群指正！

Nim 团队很高兴为大家带来 1.0.4 版本发布的消息，
这是我们在 Nim 1.0.0 之后发布的第二个补丁版本。

想要了解更多关于 1.0.0 版本的细节，可以查看我们两个月前
[版本发布说明](/blog/2019/09/23/version-100-released.html)。

距离前一个版本的发布尽管只是过去了一个月的时间，
但这次的版本已经包含了超过 [70 次新的提交](https://github.com/nim-lang/Nim/compare/v1.0.2...v1.0.4),
新修复了 20 个问题，
让我们的 1.0 版本变成了更好的样子。


## 安装 1.0.4

如果你已经用 ``choosenim`` 安装了之前版本的 Nim ，
升级到 Nim 的 1.0.4 版本会非常简单:

```bash
$ choosenim update stable
```

如果你还没有安装 ``choosenim`` ，
你可以通过
[这些说明](https://github.com/dom96/choosenim) 来下载和安装 ``choosenim``，
当然你也可以按照我们的
[安装](/install.html) 页面直接安装。


## 更新日志

你可以
[在我们的 GitHub 仓库中](https://github.com/nim-lang/Nim/blob/version-1-0/changelogs/changelog_1_0_4.md)
查阅此版本的变更日志以及 Nim 的其余源码。

---
附《更新日志》
## 语言层面的变更

* 模仿早期版本的 Nim ，在运行时取消了对无符号整数转换的检查。
文档中已针对这一改进做出了说明。查看 [https://github.com/nim-lang/RFCs/issues/175]() 了解更多细节 (#12688)
* 添加了 `or detectOs(Manjaro)`，这样当检测到系统为 Manjaro 时，调用原生的包管理器会使用 `pacman` 进行包管理 ([#12587](https://github.com/nim-lang/Nim/pull/12587))
* `--os:ios` 编译指令现在也代表了 macosx ([#12585](https://github.com/nim-lang/Nim/pull/12585))
* 导出了 nim.cfg 解析器，现在其他工具也可以调用 `readConfigFile` 了 ([#12602](https://github.com/nim-lang/Nim/pull/12602
))

## BUG 修复

* 修复了 “在 OSX 上多次调用后，`gorgeEx()` 失败”的问题 ([#12337](https://github.com/nim-lang/Nim/issues/12337))
* 优化和加强了 posix 模块 （[#10723](https://github.com/nim-lang/Nim/issues/10723)）
* 修复了 “Nim 的语法检查 允许使用 `gorgeEx()`，但不允许 `writeFile()`” 的问题，现在这两个都被提示 *don't run staticExec for 'nim suggest* 了 ([#12491](https://github.com/nim-lang/Nim/issues/12491))
* 修复了 “一个算数的低级错误： -3 mod 7 == 3” （[#12514](https://github.com/nim-lang/Nim/issues/12514)）
* 修复了 “后端集成文档中 c2nim 链接失效” 的问题（[#12537](https://github.com/nim-lang/Nim/issues/12537)）
* 修复了 “‎具有默认值的泛型参数会导致不正确的泛型类型解析‎” 的问题 （[#12528](https://github.com/nim-lang/Nim/issues/12528)）
* 修复了 "再次出现的问题: compiler/vmgen.nim(354, 20) `false` leaking temporary 10 slotTempInt [AssertionError] 
([#12547](https://github.com/nim-lang/Nim/issues/12547))
* 修复了 "Windows 上的 64 位(只有在 64 位上有问题) nim 编译/链接断开" ([#12536](https://github.com/nim-lang/Nim/issues/12536))
* 修复了 "除了最新的 devel 版本No =destroy for elements of closure environments other than for latest devel --gc:destructors" ([#12577](https://github.com/nim-lang/Nim/issues/12577))
* 修复了 "[1.0.0] 无法使用 --cpu:avr 进行编译" ([#12395](https://github.com/nim-lang/Nim/issues/12395))
* 修复了 "使用无效的对象变体会导致编译器崩溃" ([#12379](https://github.com/nim-lang/Nim/issues/12379))
* 修复了 "import 之前写的编译指示会被静默忽略" ([#5050](https://github.com/nim-lang/Nim/issues/5050))
* 修复了 " strformat + asyncdispatch + const 同时使用会报错" 的问题 ([#12612](https://github.com/nim-lang/Nim/issues/12612))
* 修复了 "`--nimblePath` 是附加的，需要一个无痛的解决方案" ([#12601](https://github.com/nim-lang/Nim/issues/12601))
* 修复了 "nim.cfg 中 --define:FOO:VAL 的语法没有文档或者缺失" ([#12367](https://github.com/nim-lang/Nim/issues/12367))
* 修复了 "使用宏生成的 vm 字符串无法正常使用" ([#12670](https://github.com/nim-lang/Nim/issues/12670))
* 修复了 "`staticRead()` 引入的静态文件变更时，会强制触发重新编译。" (#12663)
* 修复了终止处理程序中调用 `throw` 引发的崩溃 ([#12572](https://github.com/nim-lang/Nim/pull/12572))
* 修复了用于 具有字符串字段的对象 的 newLit ([#12542](https://github.com/nim-lang/Nim/pull/12542))

## 文档更新
* 给 Math 模块添加了文档 ([#12460](https://github.com/nim-lang/Nim/pull/12460))
* 修复了许多无效的链接，尽量将链接替换为了链接到文档内部 ([#12463](https://github.com/nim-lang/Nim/pull/12463))
* sequtils：在示例中替换掉了已经遗弃的 'random' 用法 ([#12515](https://github.com/nim-lang/Nim/pull/12515))
* 给整型添加了文档 ([#12513](https://github.com/nim-lang/Nim/pull/12513))
* 修复了代码风格的错误 ([#12545](https://github.com/nim-lang/Nim/pull/12545))
* 修正文档和注释中的几个错误 ([#12553](https://github.com/nim-lang/Nim/pull/12553))
* 添加文档以更好地区分 `getProjectPath`, `getCurrentDir` 和 `currentSourcePath` (#12565)
* doc/tut3.rst: 修复了介绍中的错别字 ([#12607](https://github.com/nim-lang/Nim/pull/12607))
* 添加了指向 `packaging` 和 `distro` 页面的链接 ([#12603](https://github.com/nim-lang/Nim/pull/12603))
* 修复了 `$`*(dt: DateTime) 的说明 ([#12660](https://github.com/nim-lang/Nim/pull/12660/files))
* 在 manual.rst 中对 `experimental` / `parallel` 加入了示例以明确区别  ([#12472](https://github.com/nim-lang/Nim/pull/12472))
* 修复手册中错误的章节层级关系 ([#12724](https://github.com/nim-lang/Nim/pull/12724))
