---
title: "V1.0.6 发布！"
author: Nim 团队
---

Nim 团队很高兴为大家带来 1.0.6 版本发布的消息！这是我们在 Nim 1.0.0 之后带来的第三个补丁。

想了解更多关于 1.0.0 版本的信息，可以查阅
[v1.0 发布说明](https://nim-cn.com/blog/2019/09/23/version-100-released.html).

本次的版本发布于前一个版本发布两个月之后，
包含了将近 [60 次提交](https://github.com/nim-lang/Nim/compare/v1.0.4...v1.0.6)，
新修复了 15 个已知的错误、一些其他的 bug 修复、和文档优化，
这些都让我们的 1.0 发行版变得更好。

没有安全性相关的问题，但我们正努力保证每两个月发布一个新 1.0.x 版本的稳定周期。


<div class="sidebarblock">
  <div class="content">
    <div class="paragraph">
      提个醒：如果你还没有参加我们的 
      <a href="https://nim-lang.org/blog/2019/12/20/community-survey-2019.html">Nim 社区调研</a>或者<a href="https://nim-cn.com/blog/2019/12/24/china-community-survey-2019.html">Nim 中文社区调研</a>，就赶紧来参加吧！我们非常希望能听到您的意见！
    </div>
  </div>
</div>



## 安装 1.0.6

如果你已经使用 ``choosenim`` 安装了之前版本的 Nim ，升级到 1.0.6 版本会非常简单：

```bash
$ choosenim update stable
```

如果没有的话，你可以通过
[这些教程](https://github.com/dom96/choosenim)来安装 ``choosenim``，
当然你也可以根据网站 [安装页](https://nim-cn.com/install.html) 的说明直接安装 Nim 。


## 更新日志

### Bug 修复

#### 修复的 issues

- 修复了"当使用 --styleCheck:error 命令造成的 Nim 标准库样式的问题"
  ([#12687](https://github.com/nim-lang/Nim/issues/12687))
- 修复了"new (ref MyObject) 无法在编译时工作的问题"
  ([#12488](https://github.com/nim-lang/Nim/issues/12488))
- 修复了"当访问虚拟机 (VM) 中错误的变量字段时，不会触发相应错误消息的问题"
  ([#11727](https://github.com/nim-lang/Nim/issues/11727))
- 修复了"使用没有初始化的 table 造成 orderedTable.del 函数崩溃的问题"
  ([#12798](https://github.com/nim-lang/Nim/issues/12798))
- 修复了"负数 * 0 导致的常量折叠 (Semfold) 的问题"
  ([#12783](https://github.com/nim-lang/Nim/issues/12783))
- 修复了"nimsuggest use command 不能返回 symbol 所有实例的问题"
  ([#12832](https://github.com/nim-lang/Nim/issues/12832))
- 修复了"allPathsAsgnResult 中的代码生成 (codegen) ICE 的问题"
  ([#12827](https://github.com/nim-lang/Nim/issues/12827))
- 修复了"for 循环中，同时出现 Static[T] 和 语法错误造成编译器崩溃的问题"
  ([#12148](https://github.com/nim-lang/Nim/issues/12148))
- 修复了"在 templates 和 tables 中出现未使用导入库的警告 (Incorrect unused import warning)"
  ([#12885](https://github.com/nim-lang/Nim/issues/12885))
- 修复"回归问题 (Regression) (1.0.4): 未声明的标识符: 'readLines' 和另一个回归问题"
  ([#13013](https://github.com/nim-lang/Nim/issues/13013))
- 修复了"`nim doc` 错误地处理导出局部符号 (`export localSymbol`) 的问题" 
  ([#13100](https://github.com/nim-lang/Nim/issues/13100))
- 修复了"语法 (grammar) 中未定义的符号的问题"
  ([#10665](https://github.com/nim-lang/Nim/issues/10665))
- 修复了"所有发行版本都缺少 nimp-gdb 工具的问题"
  ([#13104](https://github.com/nim-lang/Nim/issues/13104))
- 修复了"[JS] 后端未定义 Move 标识符的问题"
  ([#9674](https://github.com/nim-lang/Nim/issues/9674))
- 修复"Error: usage of 'isNil' is a user-defined error 的提示信息"
  ([#11440](https://github.com/nim-lang/Nim/issues/11440))


#### 其他错误修复

- 使 addQuoted 在 nimscript 上工作  (#12717) 
- 修复了在 db_mysql getRow() 函数中，当列 (column) 为空导致的错误
- 修复了在构造之前，对象 (object) 被错误清零的问题 (#12814) 
- 添加了 cstrutils (#12858): 修复了热代码重载 (hotcodereloading) 造成的"csuCmpIgnoreStyle"错误
- 更好的 clang_cl 支持 (#12896) 
- 修复了影响 nimBetterRun 正确性的命令行错误 (#12933) 
- 修复了无法同时使用 sugar.collect 和 for 循环宏的错误
- --out 和 --outdir 支持路径替换 (#12796) 
- 修复了 nim.cfg 中错误符号导致的崩溃 (#13073) 
- 允许 `buildIndex` 使用 `-o` 选项 (#13037) 
- 删除了错位 (misplaced) 的分隔符 (#13085): 因为错位 (misplaced) 的分隔符不断破坏 Nim 在 Haiku 操作系统上的编译，所以被- 删除了。
- 修复 asyncftpclient 的错误 (#13096) 
- 修复 ftp store 函数读取本地文件的错误 (#13108) 
- 修复全局 (global) 范围内 varargs 的 rtti sizeof 的问题 (#13125) 
- 当关键字被设置为零时，可以正确地从 CountTable 中删除关键字
- 修复了 distros.nim 中的回归问题 (regression) 
- 修复了在 IRC 上报告的 times.nim 模块中出现的重要问题
- c_fflush() the rawrite() 缓冲 (buffer) 


#### 文档改进

- 修复了"Nim 可用工具 (Tools available with Nim)"中缺少"Documentation, Testament"的问题
  ([#12251](https://github.com/nim-lang/Nim/issues/12251))
- 手册 (Manual) 更新: 自定义异常 (#12847)
- times/getClockStr(): 修复文档中的错误
- 修复了"lib/pure/parseutils.nim"代码块中的错误并改进了文档
