==============================================
Nim增强建议书 #1 - 标准库风格指南
==============================================
:Author: Clay Sweetser, Dominik Picheta
:Version: |nimversion|

.. contents::


序言
============

尽管Nim支持多种代码和格式样式，但是社区的努力（例如标准库）在适当时应遵循一套一致的样式准则，这是有好处的。

此增强建议旨在列出标准库应遵循的一系列指南。

请注意，这些规则可能会有例外。 Nim尽可能灵活，该样式指南的某些部分在某些情况下不成立。

此外，就像Python的样式指南 `<http://legacy.python.org/dev/peps/pep-0008/>`_ 随着时间的推移而变化一样，该样式指南也将随之变化。

仅对Nim代码库和官方项目（例如Nim编译器，标准库以及各种官方工具，例如C2Nim）的贡献强制执行这些规则。

----------------
风格指南
----------------

空格和空白字符约定
-----------------------------------

- 每行不能超过80个字符。限制每一行的信息量将使代码更具可读性-读取需要处理的块较小。

- 块的缩进应使用两个空格；禁止使用制表符（编译器强制执行此操作）。 
  使用空格意味着代码的外观在各个编辑器之间更加一致。 
  与空格不同，制表符宽度在不同的编辑器中都不同，并且并非所有编辑器都提供更改此宽度的方法。

- 除了指南允许的空白符，实践中应谨慎使用其它空白符。
  不是所有编辑器支持代码段自动对齐，手动重新对齐长代码段很快变得乏味。

  .. code-block:: nim
    # 这不好, 下次有人编辑这个代码块，必须再次重新对齐所有赋值：
    type
      WordBool*    = int16
      CalType*     = int
      ... # 5 lines later
      CalId*       = int
      LongLong*    = int64
      LongLongPtr* = ptr LongLong


命名约定
------------------
注意：虽然下面概述的规则是 *当前* 命名约定，但这些约定并非始终存在。
以前，标识符的命名约定遵循Pascal前缀的传统，后者表示标识符的基本类型-PFoo用于指针和引用类型，TFoo用于值类型，EFoo用于异常，等等。
尽管此后发生了变化，但标准库中仍有许多地方仍在使用此约定。 
这种样式纯粹是出于遗留原因而保留，并且将来会更改。

- 类型标识符应使用Pascal命名法。所有其他标识符都应使用驼峰命名法， *可以* 使用Pascal命名法但并非必需的常量除外。

  .. code-block:: nim
    # 常量可以以小写或大写字母开头。
    const aConstant = 42
    const FooBar = 4.2

    var aVariable = "Meep" # 变量必须以小写字母开头。

    # 类型必须以大写字母开头
    type
      FooBar = object

  对C/C++封装的常量，允许全大写，但不好看。


- 在命名值、指针、引用类型时, 为最常用的使用常规命名，给其它类型加上 "Obj", "Ref", 或 "Ptr" 后缀。 
如果没有单个变量用的较多，则仅将后缀添加到指针变量中。 
同样适用于C/C++封装。

  .. code-block:: nim
    type
      Handle = object # 使用较多
        fd: int64
      HandleRef = ref Handle # 使用较少

- 异常和错误类型应当有"Error"后缀。

  .. code-block:: nim
    type
      UnluckyError = object of Exception

- 除非用 `{.pure.}` 标记，枚举成员应当有标识前缀，比如枚举的名称缩写。

  .. code-block:: nim
    type
      PathComponent = enum
        pcDir
        pcLinkToDir
        pcFile
        pcLinkToFile

- 不纯的枚举值应当使用驼峰命名法，纯枚举值应当使用Pascal命名法。

  .. code-block:: nim
    type
      PathComponent {.pure.} = enum
        Dir
        LinkToDir
        File
        LinkToFile

- 在HTTP, HTML, FTP, TCP, IP, UTF, WWW年代，全大写来表示特殊含义的做法是愚蠢的。
把它们当做真实的单词。所以是 ``parseUrl`` 而不是 ``parseURL``, ``checkHttpHeader`` 而不是 ``checkHTTPHeader`` 等等。

- 像 ``mitems`` 或 ``mpairs`` 操作(或现已废弃的 ``mget``) 允许  一些数据结构的 *可修改视图*  应当以 ``m`` 开头。
- 有原地修改和 '返回变换副本' 时，后者是前者的过去分词:

  - reverse and reversed in algorithm
  - sort and sorted
  - rotate and rotated

- 当 '返回变换副本' 版本已经存在如 ``strutils.replace`` 原地版本应当使用 ``-In`` 后缀 (此例是 ``replaceIn`` ).


标准库API为 **易于使用** 和一致性设计。易于使用通过实现具体的高级行为的调用次数来衡量。终极目标是程序员可以 *猜到* 命名。

库使用简单命名方案，利用常用缩写来保持简短但明确的命名。


-------------------     ------------   --------------------------------------
英文单词                使用            注释
-------------------     ------------   --------------------------------------
initialize              initT          ``init`` 用于创建值类型 ``T``
new                     newP           ``new`` 用于创建引用类型 ``P``
find                    find           应当返回找到的位置; 对于bool结果用 ``contains``
contains                contains       ``find() >= 0`` 简写
append                  add            用 ``add`` 替换 ``append``
compare                 cmp            应当返回 ``< 0`` ``== 0`` 或 ``> 0`` 语义整型值;
                                       bool结果使用 ``sameXYZ``
put                     put, ``[]=``   put考虑重载 ``[]=`` 
get                     get, ``[]``    get考虑重载 ``[]`` ;
                                       考虑不使用 ``get`` 作为前缀: ``len`` 代替 ``getLen``
length                  len            也用于 *元素个数*
size                    size, len      size应当指字节大小
capacity                cap
memory                  mem            意味着低级操作
items                   items          一个集合的默认迭代器
pairs                   pairs          迭代键值对
delete                  delete, del    del比delete快, 因为它没有保持顺序; delete会保持顺序
remove                  delete, del    现在不一致
include                 incl
exclude                 excl
command                 cmd
execute                 exec
environment             env
variable                var
value                   value, val     首选val, 现在不一致
executable              exe
directory               dir
path                    path           path是字符串 "/usr/bin" (举例), dir是"/usr/bin"的内容; 现在不一致
extension               ext
separator               sep
column                  col, column    首选col, 现在不一致
application             app
configuration           cfg
message                 msg
argument                arg
object                  obj
parameter               param
operator                opr
procedure               proc
function                func
coordinate              coord
rectangle               rect
point                   point
symbol                  sym
literal                 lit
string                  str
identifier              ident
indentation             indent
-------------------     ------------   --------------------------------------


代码约定
------------------

- 'return' 语句应当用于使用控制流属性时。尽可能使用过程的隐式'result'变量，改善可读性。

  .. code-block:: nim
    proc repeat(text: string, x: int): string =
      result = ""

      for i in 0 .. x:
        result.add($i)

- 尽可能使用 proc，仅在必要时使用强大的宏、模板、迭代器和转换器。

- 当声明变量在作用域内不改变时，使用 ``let`` 语句 (不是 ``var`` 语句) 。 使用 ``let`` 语句确保变量不可修改，让读代码的人更清晰地了解代码的目的。


多行语句与表达式约定
-----------------------------------------------------

- 超过一行的元组应当对齐上面的形参。

  .. code-block:: nim
    type
      LongTupleA = tuple[wordyTupleMemberOne: int, wordyTupleMemberTwo: string,
                         wordyTupleMemberThree: float]

- 类似地，任何超过一行的过程和过程类型声明应当按照同样的方式对齐。

  .. code-block:: nim
    type
      EventCallback = proc (timeReceived: Time, errorCode: int, event: Event,
                            output: var string)

    proc lotsOfArguments(argOne: string, argTwo: int, argThree: float
                         argFour: proc(), argFive: bool): int
                        {.heyLookALongPragma.} =

- 多行过程调用应当在小括号的同列继续 (如多行过程声明)。

  .. code-block:: nim
    startProcess(nimExecutable, currentDirectory, compilerArguments
                 environment, processOptions)
