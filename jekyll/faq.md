---
layout: page
title: 常见问题
css_class: faq
---

<h1 class="text-centered page-title main-heading">常见问题</h1>

# 常规问题

## 为什么不用其他编程语言而用Nim？

Nim是一种极少见的 _可编程_ 静态类型的，
并结合了C的速度和内存效率、凝练的语法、内存安全性和其他多种目标的语言。

## Nim稳定吗？

编译器和标准库正在积极开发中，并有一套测试用例来持续确保稳定性。
每三到六个月会定期发布一次稳定版，让稳定性要求高的系统可以得到保证。

很少出现不向后兼容的更新，
但每次出现我们都做了详细的[文档记录](/blog/2018/03/01/version-0180-released.html)，
让你可以轻松地进行管理。
编译器也会对已弃用的功能进行高亮显示，
以便为更新提供足够的提示和转换时间。


## 安全性和内存安全性如何？

Nim通过不执行指针运算、
可选[检查](/docs/manual.html#pragmas-compilation-option-pragmas)、
跟踪和非跟踪引用
以及可选的非可空类型来保证内存安全性。
它通过koch工具和污点分析对Valgrind提供支持。

## Nim遵循怎样的许可？

Nim编译器和库是MIT许可的。
这意味着你可以为你使用Nim开发的程序选取任何许可。

## 有对JVM和CLR的后端支持吗？

我们最近并没有计划对JVM/CLR提供支持。
但是由于这些VM支持FFI到C，
因此应该可以创建原生Nim桥接，
通过Nim强大的元编程功能，可以显式生成所有粘水代码。

- Visual Studio Code:
  - Extension written in Nim [https://marketplace.visualstudio.com/items?itemName=nimsaem.nimvscode](https://marketplace.visualstudio.com/items?itemName=nimsaem.nimvscode)
  - Original Extension written in TypeScript [https://marketplace.visualstudio.com/items?itemName=kosz78.nim](https://marketplace.visualstudio.com/items?itemName=kosz78.nim)
- VSCodium/OpenVSX: [https://open-vsx.org/extension/nimsaem/nimvscode](https://open-vsx.org/extension/nimsaem/nimvscode)
- Emacs: [https://github.com/nim-lang/nim-mode](https://github.com/nim-lang/nim-mode)
- Vim: [https://github.com/zah/nimrod.vim/](https://github.com/zah/nimrod.vim)
- QtCreator (4.1+): 通过一个实验性插件进行支持。
- Scite: 支持
- Gedit: The [Aporia .lang file](https://github.com/nim-lang/Aporia/blob/master/share/gtksourceview-2.0/language-specs/nim.lang).
- jEdit: [https://github.com/exhu/nimrod-misc/tree/master/jedit](https://github.com/exhu/nimrod-misc/tree/master/jedit)
- TextMate: [https://github.com/textmate/nim.tmbundle](https://github.com/textmate/nim.tmbundle)
- Sublime Text: [https://github.com/Varriount/NimLime](https://github.com/Varriount/NimLime)
- LiClipse: [http://www.liclipse.com/](http://www.liclipse.com/) (基于Eclipse的插件)
- Howl: 支持
- Notepad++: [https://github.com/jangko/nppnim/releases](https://github.com/jangko/nppnim/releases)
- Micro: 支持
- Atom: [https://atom.io/packages/nim](https://atom.io/packages/nim)
- JetBrains IDEs: [https://plugins.jetbrains.com/plugin/15128-nim](https://plugins.jetbrains.com/plugin/15128-nim)
- Kakoune: Included
- For editors with LSP (Language Server Protocol) support (requires a separate syntax/indenting plugin): [https://github.com/PMunch/nimlsp](https://github.com/PMunch/nimlsp)

## 语言设计主要受哪些其他语言的影响？

Nim大量借用了（按照受影响的顺序）：Modula 3, Delphi,
Ada, C++, Python, Lisp, Oberon.

## 为啥起名叫``proc``?

*过程*曾经是常用术语，而不是作为没有别的用的数学的*函数*实体。
而且在Nim中``func``确实是``proc {.noSideEffect.}``的语法糖。
还因为Nim提供了一个``iterator``和一个``method``关键字，而``def``代表``define``，
所以叫它``def``也就不可能了。


# 编译的常见问题

## 哪个选项编译的可执行文件最快？

对于标准的配置文件，``-d:danger`` 通过禁用 **所有** 运行时安全检查（包括边界检查、流程检查、空值检查等等），以尽最快速度构建二进制文件。
更多的情况下用``-d:release``就已经足以应付。
当然如果你的编译器支持，你也可以开启链接时优化来更快地构建一个可执行文件: 在 Nim 1.4 以上版本使用 ``--passc:-flto`` 或者 `-d:lto`

## 哪个选项可以构建出最小的可执行文件？

对于标配的文件, ``-d:danger -d:strip --opt:size`` 就能得到你想要的。
当然如果你的编译器支持，你也可以和上一个问题中描述的相同方式，开启链接时优化来构建一个更快的可执行文件

## 如何使用与默认编译器不同的C编译器？

打开并编辑``config/nim.cfg``文件。
将``cc``变量的值对照下方表格进行修改：

| 缩写 | C/C++ 编译器                          |
| ---------------- | --------------------------------------------|
|``gcc``           | GNU C编译器                              |
|``clang``         | Clang编译器                              |
|``vcc``           | 微软Visual C++                      |
|``icc``           | Intel C编译器                            |
|``llvm_gcc``      | LLVM-GCC编译器                           |
|``ucc``           | 通用UNIX C编译器                     |
|``tcc``           | 微型 C 编译器                             |
|``bcc``           | Borland C 编译器                          |
|``envcc``         | 你环境中的默认 C 编译器      |

其他的C编译器我们不进行官方支持，但是它可能也能用，大概吧。

如果你的C编译器不在上述列表中，
尝试使用 *环境中的默认 C 编译器* （``envcc``） 。
如果C编译器需要不同的命令行参数，可以尝试使用 ``--passc`` 和 ``--passl`` 进行切换。
