=====================
Nim Tutorial (Part I)
=====================

:Author: Andreas Rumpf
:Version: |nimversion|

.. contents::

Introduction
============

.. raw:: html
  <blockquote><p>
  "Der Mensch ist doch ein Augentier -- sch&ouml;ne Dinge w&uuml;nsch ich mir."
  </p></blockquote>

本文是编程语言Nim的教程。该教程认为你熟悉基本的编程概念如变量、类型和语句但非常基础。`manual
<manual.html>`_ 包含更多的高级特性样例。本教程的代码样例和其它的Nim文档遵守`Nim style guide <nep1.html>`_。


第一个程序
=================
我们从一个修改过的"hello world"程序开始：

.. code-block:: Nim
    :test: "nim c $1"
  # 这是注释
  echo "What's your name? "
  var name: string = readLine(stdin)
  echo "Hi, ", name, "!"

保存到文件"greetings.nim"，编译运行：

  nim compile --run greetings.nim

用``--run`` `switch <nimc.html#compiler-usage-command-line-switches>`_ Nim在编译之后自动执行文件。你可以在文件名后给程序追加命令行参数
  nim compile --run greetings.nim arg1 arg2

经常使用的命令和开关有缩写，所以你可以用::

  nim c -r greetings.nim

编译发布版使用::

  nim c -d:release greetings.nim

Nim编译器默认生成大量运行时检查，旨在方便调试。用``-d:release`` 一些检查被`关闭并且打开了优化<nimc.html#compiler-usage-compile-time-symbols>`_。

尽管程序的作用很明显，但我会解释下语法：没有缩进的语句会在程序开始时执行。缩进是Nim语句进行分组的方式。缩进仅允许空格，不允许制表符。

字符串字面值用双引号括起来。``var``语句声明一个新的名为``name``，类型为``string``，值为`readLine <system.html#readLine,File>`_方法返回值的变量名。
因为编译器知道`readLine <system.html#readLine,File>`_返回一个字符串，你可以省略声明中的类型(这叫作 `local type inference`:idx: )。所以这样也可以：

.. code-block:: Nim
    :test: "nim c $1"
  var name = readLine(stdin)

请注意，这基本上是Nim中存在的唯一类型推导形式：它是简洁性和可读性之间的良好折衷。

"hello world"程序包括一些编译器已知的标识符：``echo``，`readLine <system.html#readLine,File>`_等。这些内置声名在 system_ 模块中，它通过其它模块隐式的导出。

词法元素
================

让我们看看Nim词法元素的更多细节：像其它编程语言一样，Nim由（字符串）字面值、标识符、关键字、注释、操作符、和其它标点符号构成。


字符串和字符字面值
-----------------------------

字符串字面值通过双引号括起来；字符字面值用单引号。特殊字符通过``\``转义: ``\n``表示换行，``\t``表示制表符等，还有*原始*字符串字面值：

.. code-block:: Nim
  r"C:\program files\nim"

在原始字面值中反斜杠不是转义字符。

第三种也是最后一种写字符串字面值的方法是*长字符串字面值*。用三引号``"""..."""``写，他们可以跨行并且``\``也不是转义字符。例如它们对嵌入HTML代码模板非常有用。


注释
--------

注释在任何字符串或字符字面值之外，以哈希字符``#``开始，文档以``##``开始：

.. code-block:: nim
    :test: "nim c $1"
  # 注释。

  var myVariable: int ## 文档注释


文档注释是令牌；它们只允许在输入文件中的某些位置，因为它们属于语法树！此功能可实现更简单的文档生成器。

多行注释以``#[``开始，以``]#``结束。多行注释也可以嵌套。

.. code-block:: nim
    :test: "nim c $1"
  #[
  You can have any Nim code text commented
  out inside this with no indentation restrictions.
        yes("May I ask a pointless question?")
    #[
       Note: these can be nested!!
    ]#
  ]#

你也可以和*长字符串字面值*一起使用`discard statement <#procedures-discard-statement>`_ 来构建块注释。

.. code-block:: nim
    :test: "nim c $1"
  discard """ You can have any Nim code text commented
  out inside this with no indentation restrictions.
        yes("May I ask a pointless question?") """


数字
-------

数字字面值与其它大多数语言一样。作为一个特别的地方，为了更好的可读性，允许使用下划线：``1_000_000`` (一百万)。
包含点（或者'e'或'E'）的数字是浮点字面值：``1.0e9`` （十亿）。十六进制字面值前缀是``0x``，二进制字面值用``0b``，八进制用``0o``。
单独一个前导零不产生八进制。


var语句
=================
var语句声明一个本地或全局变量:

.. code-block::
  var x, y: int # 声明x和y拥有类型``int``

缩进可以用在``var``关键字后来列一个变量段。

.. code-block::
    :test: "nim c $1"
  var
    x, y: int
    # 这也可以有注释
    a, b, c: string


赋值语句
========================

赋值语句为一个变量赋予新值或者更一般地，赋值到一个存储地址。

.. code-block::
  var x = "abc" # 引入一个新变量`x`并且赋值给它
  x = "xyz"     # 赋新值给`x`

``=``是*赋值操作符*. 赋值操作符可以重载。你可以用一个赋值语句声明多个变量并且所有的变量具有相同的类型：

.. code-block::
    :test: "nim c $1"
  var x, y = 3  # 给变量`x`和`y`赋值3
  echo "x ", x  # 输出 "x 3"
  echo "y ", y  # 输出 "y 3"
  x = 42        # 改变`x`为42而不改变`y`
  echo "x ", x  # 输出"x 42"
  echo "y ", y  # 输出"y 3"

注意用一个赋值声明多个变量调用方法可能有不可预见的结果：编译器将*展开*赋值并多次调用方法。如果方法的结果取决于副作用，你的变量可以有不同的值！为了安全起见，多赋值时使用没有副作用的方法。
Note that declaring multiple variables with a single assignment which calls a
procedure can have unexpected results: the compiler will *unroll* the
assignments and end up calling the procedure several times. If the result of
the procedure depends on side effects, your variables may end up having
different values! For safety use side-effect free procedures if making multiple
assignments.


常量
=========

常量是绑定在一个值上的符号。常量值不能改变。编译器必须能够在编译期对常量声明进行求值：

.. code-block:: nim
    :test: "nim c $1"
  const x = "abc" # 常量x包含字符串"abc"

缩进可以用在``const``关键字后来列一个常量段:

.. code-block::
    :test: "nim c $1"
  const
    x = 1
    # 这也可以有注释
    y = 2
    z = y + 5 # 计算是可能的


let语句
=================
``let``语句像``var``语句一样但声明的符号是*一次性赋值*变量：初始化后它们的值将不能改变。

.. code-block::
  let x = "abc" # 引入一个新变量`x`并绑定一个值
  x = "xyz"     # 非法: 给`x`赋值

``let``和``const``的区别在于: ``let``引入一个变量不能重新赋值。 ``const``表示"强制编译期求值并放入一个数据段":

.. code-block::
  const input = readLine(stdin) # 错误: 需要常量表达式

.. code-block::
    :test: "nim c $1"
  let input = readLine(stdin)   # 可以


控制流语句
=======================

greetings程序由三个顺序执行的语句构成。只有最原始的程序可以不需要分支和循环。


If语句
------------

if语句是使控制流分叉的一种方法:

.. code-block:: nim
    :test: "nim c $1"
  let name = readLine(stdin)
  if name == "":
    echo "Poor soul, you lost your name?"
  elif name == "name":
    echo "Very funny, your name is name."
  else:
    echo "Hi, ", name, "!"

可以有零个或多个``elif``，并且``else``是可选的，``elif``关键字是``else if``的简写，并且避免过度缩进。（``""``是空字符串。它不包含字符。）


Case语句
--------------

另一个分支的方法是case语句。case语句是多分支：

.. code-block:: nim
    :test: "nim c $1"
  let name = readLine(stdin)
  case name
  of "":
    echo "Poor soul, you lost your name?"
  of "name":
    echo "Very funny, your name is name."
  of "Dave", "Frank":
    echo "Cool name!"
  else:
    echo "Hi, ", name, "!"

可以看到，对一个``of``分支，逗号分隔的多个值也是允许的。

case语句可以处理整型、其它序数类型和字符串。（序数类型后面会讲到）
对整型或序数类型值，范围也是可能的：

.. code-block:: nim
  # 这段语句将会在后面解释:
  from strutils import parseInt

  echo "A number please: "
  let n = parseInt(readLine(stdin))
  case n
  of 0..2, 4..7: echo "The number is in the set: {0, 1, 2, 4, 5, 6, 7}"
  of 3, 8: echo "The number is 3 or 8"

上面的代码不能编译: 原因是你必须覆盖每个``n``可能包含的值，但代码里只处理了``0..8``。因为列出来每个可能的值不现实(尽管范围表示法可以实现), 我们通过告诉编译器不处理其它值来修复它:

.. code-block:: nim
  ...
  case n
  of 0..2, 4..7: echo "The number is in the set: {0, 1, 2, 4, 5, 6, 7}"
  of 3, 8: echo "The number is 3 or 8"
  else: discard

空`discard statement`_ 是一个 *什么都不做* 的语句. 编译器知道有else的case语句不会出错因此错误消失了。注意，不可能覆盖所有可能的字符串值：所以字符串的情况总要一个``else``分支。



通常情况下，case语句用于枚举的子范围类型，其中编译器对检查您是否覆盖了任何可能的值有很大帮助。


While语句
---------------

while语句是一个简单的循环结构:

.. code-block:: nim
    :test: "nim c $1"

  echo "What's your name? "
  var name = readLine(stdin)
  while name == "":
    echo "Please tell me your name: "
    name = readLine(stdin)
    # no ``var``, because we do not declare a new variable here

样例使用while循环来不断的询问用户的名字，只要用户什么都没有输入（只按回车）。


For语句
-------------

``for``语句是一个在提供*迭代器*的元素上循环的结构。样例使用内置的 `countup <system.html#countup>`_ 迭代器:

.. code-block:: nim
    :test: "nim c $1"
  echo "Counting to ten: "
  for i in countup(1, 10):
    echo i
  # --> Outputs 1 2 3 4 5 6 7 8 9 10 on different lines

变量``i``通过``for``循环隐式的声明并具有 ``int``类型, 因为这里 `countup <system.html#countup>`_ 返回的. ``i`` 遍历 1, 2, .., 10。每个值被 ``echo``。 这段代码作用是一样的:

.. code-block:: nim
  echo "Counting to 10: "
  var i = 1
  while i <= 10:
    echo i
    inc(i) # increment i by 1
  # --> Outputs 1 2 3 4 5 6 7 8 9 10 on different lines


倒计数可以轻松实现 (但不常需要):

.. code-block:: nim
  echo "Counting down from 10 to 1: "
  for i in countdown(10, 1):
    echo i
  # --> Outputs 10 9 8 7 6 5 4 3 2 1 on different lines

因为计数在程序中经常出现，Nim有一个`..<system.html#...i,S,T>`_ 迭代器是一样的作用

.. code-block:: nim
  for i in 1..10:
    ...

零索引计数有两个简写``..<``和``..^``，为了简化计数到更高索引的前一位。

.. code-block:: nim
  for i in 0..<10:
    ...  # 0..9

or

.. code-block:: nim
  var s = "some string"
  for i in 0..<s.len:
    ...

其它有用的迭代器（如数组和序列）是* ``items``和``mitems``,提供不可改变和可改变元素，* ``pairs``和``mpairs``提供元素和索引数字。

.. code-block:: nim
    :test: "nim c $1"
  for index, item in ["a","b"].pairs:
    echo item, " at index ", index
  # => a at index 0
  # => b at index 1

作用域和块语句
------------------------------
控制流语句有一个还没有讲的特性: 它们有自己的作用域。这意味着在下面的样例中, ``x``在作用域外是不可访问的:

.. code-block:: nim
    :test: "nim c $1"
    :status: 1
  while false:
    var x = "hi"
  echo x # 不行

一个while(for)语句引入一个隐式块。标识符是只在它们声明的块内部可见。``block``语句可以用来显式地打开一个新块：

.. code-block:: nim
    :test: "nim c $1"
    :status: 1
  block myblock:
    var x = "hi"
  echo x # 不行

块的 *label* (本例中的``myblock`` ) 是可选的。


Break语句
---------------
块可以用一个``break``语句离开。break语句可以离开一个``while``, ``for``, 或``block``语句. 它离开最内层的结构, 除非给定一个块标签:

.. code-block:: nim
    :test: "nim c $1"
  block myblock:
    echo "entering block"
    while true:
      echo "looping"
      break # 离开循环,但不离开块
    echo "still in block"

  block myblock2:
    echo "entering block"
    while true:
      echo "looping"
      break myblock2 # 离开块 (和循环)
    echo "still in block"


Continue语句
------------------
像其它编程语言一样，``continue``语句立刻开始下一次迭代:

.. code-block:: nim
    :test: "nim c $1"
  while true:
    let x = readLine(stdin)
    if x == "": continue
    echo x


When语句
--------------

Example:

.. code-block:: nim
    :test: "nim c $1"

  when system.hostOS == "windows":
    echo "running on Windows!"
  elif system.hostOS == "linux":
    echo "running on Linux!"
  elif system.hostOS == "macosx":
    echo "running on Mac OS X!"
  else:
    echo "unknown operating system"

``when``语句几乎等价于``if``语句, 但有以下区别:

* 每个条件必须是常量表达式，因为它被编译器求值。
* 分支内的语句不打开新作用域。
* 编译器检查语义并*仅*为属于第一个求值为true的条件生成代码。

``when``语句在写平台特定代码时有用，类似于C语言中的``#ifdef``结构。


语句和缩进
==========================

既然我们覆盖了基本的控制流语句, 让我们回到Nim缩进规则。

在Nim中*简单语句*和*复杂语句*有区别。*简单语句*不能包含其它语句：属于简单语句的赋值, 过程调用或``return``语句。 *复杂语句*像``if``、``when``、``for``、``while``可以包含其它语句。
为了避免歧义，复杂语句必须缩进, 但单个简单语句不必:

.. code-block:: nim
  # 单个赋值语句不需要缩进:
  if x: x = false

  # 嵌套if语句需要缩进:
  if x:
    if y:
      y = false
    else:
      y = true

  # 需要缩进, 因为条件后有两个语句：
  if x:
    x = false
    y = false


*表达式*是语句通常有一个值的部分。 例如，一个if语句中的条件是表达式。表达式为了更好的可读性可以在某些地方缩进：

.. code-block:: nim

  if thisIsaLongCondition() and
      thisIsAnotherLongCondition(1,
         2, 3, 4):
    x = true

根据经验，表达式中的缩进允许在操作符、开放的小括号和逗号后。

用小括号和分号 ``(;)`` 可以在只允许表达式的地方使用语句：

.. code-block:: nim
    :test: "nim c $1"
  # 编译期计算fac(4) :
  const fac4 = (var x = 1; for i in 1..4: x *= i; x)


过程
==========

为了在样例中定义如 `echo <system.html#echo>`_ 和 `readLine <system.html#readLine,File>`_ 的新命令, 需要`procedure`的概念。(一些语言叫*方法*或*函数*。) 在Nim中新的过程用``proc``关键字定义:

.. code-block:: nim
    :test: "nim c $1"
  proc yes(question: string): bool =
    echo question, " (y/n)"
    while true:
      case readLine(stdin)
      of "y", "Y", "yes", "Yes": return true
      of "n", "N", "no", "No": return false
      else: echo "Please be clear: yes or no"

  if yes("Should I delete all your important files?"):
    echo "I'm sorry Dave, I'm afraid I can't do that."
  else:
    echo "I think you know what the problem is just as well as I do."

这个样例展示了一个名叫``yes``的过程，它问用户一个``question``并返回true如果他们回答"yes"（或类似的回答），返回false当他们回答"no"（或类似的回答）。一个``return``语句立即离开过程。
``(question: string): bool``语法描述过程需要一个名为``question``，类型为``string``的变量，并且返回一个``bool``值。``bool``类型是内置的：合法的值只有``true``和``false``。
if或while语句中的条件必须是``bool``类型。

一些术语: 样例中``question``叫做一个(形) *参*,
``"Should I..."``叫做*实参*传递给这个参数。


Result变量
---------------
一个返回值的过程有一个隐式``result``变量声明代表返回值。一个没有表达式的``return``语句是``return result``的简写。 ``result``总在过程的结尾自动返回如果退出时没有``return``语句.

.. code-block:: nim
    :test: "nim c $1"
  proc sumTillNegative(x: varargs[int]): int =
    for i in x:
      if i < 0:
        return
      result = result + i

  echo sumTillNegative() # echos 0
  echo sumTillNegative(3, 4, 5) # echos 12
  echo sumTillNegative(3, 4 , -1 , 6) # echos 7

``result``变量已经隐式地声明在函数的开头，那么比如再次用'var result'声明， 将用一个相同名字的普通变量遮蔽它。result变量也已经用返回类型的默认值初始化过。
注意引用数据类型将是``nil``在过程的开头，因此可能需要手动初始化。


参数
----------
参数在过程体中不可改变。默认地，它们的值不能被改变因为这允许编译器以最高效的方式实现参数传递。如果在一个过程内需要可以改变的变量，它必须在过程体中用``var``声明。 遮蔽参数名是可能的，实际上是一个习语：

.. code-block:: nim
    :test: "nim c $1"
  proc printSeq(s: seq, nprinted: int = -1) =
    var nprinted = if nprinted == -1: s.len else: min(nprinted, s.len)
    for i in 0 .. <nprinted:
      echo s[i]

如果过程需要为调用者修改参数，可以用``var``参数:

.. code-block:: nim
    :test: "nim c $1"
  proc divmod(a, b: int; res, remainder: var int) =
    res = a div b        # 整除
    remainder = a mod b  # 整数取模操作

  var
    x, y: int
  divmod(8, 5, x, y) # 修改x和y
  echo x
  echo y

样例中, ``res``和``remainder``是`var parameters`。Var参数可以被过程修改，改变对调用者可见。注意上面的样例用一个元组作为返回类型而不是var参数会更好。


Discard语句
-----------------
调用仅为其副作用返回值并忽略返回值的过程, **必须**用``discard``语句。Nim不允许静默地扔掉一个返回值：

.. code-block:: nim
  discard yes("May I ask a pointless question?")


返回类型可以被隐式地忽略如果调用的方法、迭代器已经用``discardable``pragma声明过。
The return value can be ignored implicitly if the called proc/iterator has
been declared with the ``discardable`` pragma:

.. code-block:: nim
    :test: "nim c $1"
  proc p(x, y: int): int {.discardable.} =
    return x + y

  p(3, 4) # now valid

在`Comments`_ 段中描述``discard``语句也可以用于创建块注释。


命名参数
---------------

通常一个过程有许多参数而且参数的顺序不清晰。这在构造一个复杂数据类型时尤为突出。因此可以对传递给过程的实参命名，以便于看清哪个实参属于哪个形参：

.. code-block:: nim
  proc createWindow(x, y, width, height: int; title: string;
                    show: bool): Window =
     ...

  var w = createWindow(show = true, title = "My Application",
                       x = 0, y = 0, height = 600, width = 800)

既然我们使用命名实参来调用``createWindow``实参的顺序不再重要。有序实参和命名实参混合起来用也没有问题，但不是很好读：

.. code-block:: nim
  var w = createWindow(0, 0, title = "My Application",
                       height = 600, width = 800, true)

编译器检查每个形参只接收一个实参。


默认值
--------------
为了使``createWindow``方法更易于使用，它应当提供`默认值`；这些值在调用者没有指定时用作实参：

.. code-block:: nim
  proc createWindow(x = 0, y = 0, width = 500, height = 700,
                    title = "unknown",
                    show = true): Window =
     ...

  var w = createWindow(title = "My Application", height = 600, width = 800)

现在调用 call to ``createWindow`` only needs to set the values that differ
from the defaults.

现在形参可以由默认值进行类型推导；例如，没有必要写``title: string = "unknown"``。


重载过程
---------------------
Nim提供类似C++的过程重载能力：

.. code-block:: nim
  proc toString(x: int): string = ...
  proc toString(x: bool): string =
    if x: result = "true"
    else: result = "false"

  echo toString(13)   # calls the toString(x: int) proc
  echo toString(true) # calls the toString(x: bool) proc

(注意``toString``通常是Nim中的`$ <system.html#$>`_ 。) 编译器为``toString``调用选择最恰当的过程。 
重载解析算法不在这里讨论（会在手册中具体说明）。 不论如何，它不会导致令人讨厌的意外，并且基于一个非常简单的统一算法。有歧义的调用会作为错误报告。


操作符
---------
Nim库重度使用重载，一个原因是每个像``+``的操作符就是一个重载过程。解析器让你在`中缀标记` (``a + b``)或`前缀标记` (``+ a``)中使用操作符。
一个中缀操作符总是有两个实参，一个前缀操作符总是一个。(后缀操作符是不可能的，因为这有歧义：``a @ @ b``表示``(a) @ (@b)``还是``(a@) @ (b)``？它总是表示``(a) @ (@b)``, 
因为Nim中没有后缀操作符。

除了几个内置的关键字操作符如``and``、``or``、``not``，操作符总是由以下符号构成：``+  -  *  \  /  <  >  =  @  $  ~  &  %  !  ?  ^  .  |``

允许用户定义的操作符。没有什么阻止你定义自己的``@!?+~``操作符，但这么做降低了可读性。

操作符优先级由第一个字符决定。细节可以在手册中找到。

用反引号"``"括起来定义一个新操作符：

.. code-block:: nim
  proc `$` (x: myDataType): string = ...
  # 现在$操作符对myDataType生效，重载解析确保$对内置类型像之前一样工作。

"``"标记也可以来用调用一个像任何其它过程的操作符:

.. code-block:: nim
    :test: "nim c $1"
  if `==`( `+`(3, 4), 7): echo "True"


前向声明
--------------------

每个变量、过程等，需要使用前声明。（这样做的原因是，在像Nim那样广泛支持元编程的语言中避免这种需求是非常重要的。）这不能通过互相递归的过程做到：

.. code-block:: nim
  # 前向声明:
  proc even(n: int): bool

.. code-block:: nim
  proc odd(n: int): bool =
    assert(n >= 0) # 确保我们没有遇到负递归
    if n == 0: false
    else:
      n == 1 or even(n-1)

  proc even(n: int): bool =
    assert(n >= 0) # 确保我们没有遇到负递归
    if n == 1: false
    else:
      n == 0 or odd(n-1)

这里``odd``取决于``even``反之亦然。因此``even``需要在完全定义前引入到编译器。前向声明的语法很简单：直接忽略``=``和过程体。``assert``只添加边界条件，将在`Modules`_ 段中讲到。

语言的后续版本将弱化前向声明的要求。

样例也展示了一个过程体可以由一个表达式构成，其值之后被隐式返回。


迭代器
=========

让我们回到简单的计数样例：

.. code-block:: nim
    :test: "nim c $1"
  echo "Counting to ten: "
  for i in countup(1, 10):
    echo i

一个`countup <system.html#countup>`_过程可以支持这个循环吗？让我们试试：

.. code-block:: nim
  proc countup(a, b: int): int =
    var res = a
    while res <= b:
      return res
      inc(res)

这不行。问题在于过程不应当只``return``，但是迭代器后的return和**continue** 已经完成。这*return and continue*叫做`yield`语句。现在只剩下用``iterator``替换``proc``关键字，它来了——我们的第一个迭代器：

.. code-block:: nim
    :test: "nim c $1"
  iterator countup(a, b: int): int =
    var res = a
    while res <= b:
      yield res
      inc(res)

迭代器看起来像过程，但有几点重要的差异：

* 迭代器只能从循环中调用。
* 迭代器不能包含``return``语句（过程不能包含``yield``语句）。
* 迭代器没有隐式``result``变量。
* 迭代器不支持递归。
* 迭代器不能前向声明，因为编译器必须能够内联迭代器。（这个限制将在编译器的未来版本中消失。）

你也可以用``closure``迭代器得到一个不同的限制集合。详见`一等迭代器<manual.html#iterators-and-the-for-statement-first-class-iterators>`_。 迭代器可以和过程有同样的名字和形参，因为它们有自己的命名空间。
因此，通常的做法是将迭代器包装在同名的proc中，这些迭代器会累积结果并将其作为序列返回, 像`strutils module<strutils.html>`_中的``split``。


基本类型
===========

本章处理基本内置类型和它们的操作细节。

布尔值
--------

Nim的布尔类型叫做``bool``，由两个预先定义好的值``true``和``false``构成。while、if、elif和when语句中的条件必须是布尔类型。

为布尔类型定义操作符``not, and, or, xor, <, <=, >, >=, !=, ==``。``and``和``or``操作符执行短路求值。例如：

.. code-block:: nim

  while p != nil and p.name != "xyz":
    # p.name is not evaluated if p == nil
    p = p.next


字符
----------
字符类型叫做``char``。大小总是一字节，所以不能表示大多数UTF-8字符；但可以表示组成多字节UTF-8字符的一个字节。原因是为了效率：对于绝大多数用例，程序依然可以正确处理UTF-8因为UTF-8是专为此设计的。
字符字面值用单引号括起来。

字符可以用``==``, ``<``, ``<=``, ``>``, ``>=``操作符比较。``$``操作符将一个``char``转换成一个``string``。字符不能和整型混合；用``ord``过程得到一个``char``的序数值。
从整型到``char``转换使用``chr``过程。


字符串
-------
String variables are **mutable**, so appending to a string
is possible, and quite efficient. Strings in Nim are both zero-terminated and have a
length field. A string's length can be retrieved with the builtin ``len``
procedure; the length never counts the terminating zero. Accessing the
terminating zero is an error, it only exists so that a Nim string can be converted
to a ``cstring`` without doing a copy.

The assignment operator for strings copies the string. You can use the ``&``
operator to concatenate strings and ``add`` to append to a string.

Strings are compared using their lexicographical order. All the comparison operators
are supported. By convention, all strings are UTF-8 encoded, but this is not
enforced. For example, when reading strings from binary files, they are merely
a sequence of bytes. The index operation ``s[i]`` means the i-th *char* of
``s``, not the i-th *unichar*.

A string variable is initialized with the empty string ``""``.


整型
--------
Nim has these integer types built-in:
``int int8 int16 int32 int64 uint uint8 uint16 uint32 uint64``.

The default integer type is ``int``. Integer literals can have a *type suffix*
to specify a non-default integer type:


.. code-block:: nim
    :test: "nim c $1"
  let
    x = 0     # x is of type ``int``
    y = 0'i8  # y is of type ``int8``
    z = 0'i64 # z is of type ``int64``
    u = 0'u   # u is of type ``uint``

Most often integers are used for counting objects that reside in memory, so
``int`` has the same size as a pointer.

The common operators ``+ - * div mod  <  <=  ==  !=  >  >=`` are defined for
integers. The ``and or xor not`` operators are also defined for integers, and
provide *bitwise* operations. Left bit shifting is done with the ``shl``, right
shifting with the ``shr`` operator. Bit shifting operators always treat their
arguments as *unsigned*. For `arithmetic bit shifts`:idx: ordinary
multiplication or division can be used.

Unsigned operations all wrap around; they cannot lead to over- or under-flow
errors.

Lossless `Automatic type conversion`:idx: is performed in expressions where different
kinds of integer types are used. However, if the type conversion
would cause loss of information, the `EOutOfRange`:idx: exception is raised (if the error
cannot be detected at compile time).


浮点
------
Nim has these floating point types built-in: ``float float32 float64``.

The default float type is ``float``. In the current implementation,
``float`` is always 64-bits.

Float literals can have a *type suffix* to specify a non-default float
type:

.. code-block:: nim
    :test: "nim c $1"
  var
    x = 0.0      # x is of type ``float``
    y = 0.0'f32  # y is of type ``float32``
    z = 0.0'f64  # z is of type ``float64``

The common operators ``+ - * /  <  <=  ==  !=  >  >=`` are defined for
floats and follow the IEEE-754 standard.

Automatic type conversion in expressions with different kinds of floating
point types is performed: the smaller type is converted to the larger. Integer
types are **not** converted to floating point types automatically, nor vice
versa. Use the `toInt <system.html#toInt>`_ and `toFloat <system.html#toFloat>`_
procs for these conversions.


类型转换
---------------
Conversion between numerical types is performed by using the
type as a function:

.. code-block:: nim
    :test: "nim c $1"
  var
    x: int32 = 1.int32   # same as calling int32(1)
    y: int8  = int8('a') # 'a' == 97'i8
    z: float = 2.5       # int(2.5) rounds down to 2
    sum: int = int(x) + int(y) + int(z) # sum == 100


内部类型表示
============================

As mentioned earlier, the built-in `$ <system.html#$>`_ (stringify) operator
turns any basic type into a string, which you can then print to the console
using the ``echo`` proc. However, advanced types, and your own custom types,
won't work with the ``$`` operator until you define it for them.
Sometimes you just want to debug the current value of a complex type without
having to write its ``$`` operator.  You can use then the `repr
<system.html#repr>`_ proc which works with any type and even complex data
graphs with cycles. The following example shows that even for basic types
there is a difference between the ``$`` and ``repr`` outputs:

.. code-block:: nim
    :test: "nim c $1"
  var
    myBool = true
    myCharacter = 'n'
    myString = "nim"
    myInteger = 42
    myFloat = 3.14
  echo myBool, ":", repr(myBool)
  # --> true:true
  echo myCharacter, ":", repr(myCharacter)
  # --> n:'n'
  echo myString, ":", repr(myString)
  # --> nim:0x10fa8c050"nim"
  echo myInteger, ":", repr(myInteger)
  # --> 42:42
  echo myFloat, ":", repr(myFloat)
  # --> 3.1400000000000001e+00:3.1400000000000001e+00


高级类型
==============

In Nim new types can be defined within a ``type`` statement:

.. code-block:: nim
    :test: "nim c $1"
  type
    biggestInt = int64      # biggest integer type that is available
    biggestFloat = float64  # biggest float type that is available

Enumeration and object types may only be defined within a
``type`` statement.


枚举
------------
A variable of an enumeration type can only be assigned one of the enumeration's specified values.
These values are a set of ordered symbols. Each symbol is mapped
to an integer value internally. The first symbol is represented
at runtime by 0, the second by 1 and so on. For example:

.. code-block:: nim
    :test: "nim c $1"

  type
    Direction = enum
      north, east, south, west

  var x = south     # `x` is of type `Direction`; its value is `south`
  echo x            # writes "south" to `stdout`

All the comparison operators can be used with enumeration types.

An enumeration's symbol can be qualified to avoid ambiguities:
``Direction.south``.

The ``$`` operator can convert any enumeration value to its name, and the ``ord``
proc can convert it to its underlying integer value.

For better interfacing to other programming languages, the symbols of enum
types can be assigned an explicit ordinal value. However, the ordinal values
must be in ascending order.


序数类型
-------------
Enumerations, integer types, ``char`` and ``bool`` (and
subranges) are called ordinal types. Ordinal types have quite
a few special operations:

-----------------     --------------------------------------------------------
Operation             Comment
-----------------     --------------------------------------------------------
``ord(x)``            returns the integer value that is used to
                      represent `x`'s value
``inc(x)``            increments `x` by one
``inc(x, n)``         increments `x` by `n`; `n` is an integer
``dec(x)``            decrements `x` by one
``dec(x, n)``         decrements `x` by `n`; `n` is an integer
``succ(x)``           returns the successor of `x`
``succ(x, n)``        returns the `n`'th successor of `x`
``pred(x)``           returns the predecessor of `x`
``pred(x, n)``        returns the `n`'th predecessor of `x`
-----------------     --------------------------------------------------------

The `inc <system.html#inc>`_, `dec <system.html#dec>`_, `succ
<system.html#succ>`_ and `pred <system.html#pred>`_ operations can fail by
raising an `EOutOfRange` or `EOverflow` exception. (If the code has been
compiled with the proper runtime checks turned on.)


子范围
---------
A subrange type is a range of values from an integer or enumeration type
(the base type). Example:

.. code-block:: nim
    :test: "nim c $1"
  type
    MySubrange = range[0..5]


``MySubrange`` is a subrange of ``int`` which can only hold the values 0
to 5. Assigning any other value to a variable of type ``MySubrange`` is a
compile-time or runtime error. Assignments from the base type to one of its
subrange types (and vice versa) are allowed.

The ``system`` module defines the important `Natural <system.html#Natural>`_
type as ``range[0..high(int)]`` (`high <system.html#high>`_ returns the
maximal value). Other programming languages may suggest the use of unsigned
integers for natural numbers. This is often **unwise**: you don't want unsigned
arithmetic (which wraps around) just because the numbers cannot be negative.
Nim's ``Natural`` type helps to avoid this common programming error.


集合
----

.. include:: sets_fragment.txt

数组
------
An array is a simple fixed length container. Each element in
an array has the same type. The array's index type can be any ordinal type.

Arrays can be constructed using ``[]``:

.. code-block:: nim
    :test: "nim c $1"

  type
    IntArray = array[0..5, int] # an array that is indexed with 0..5
  var
    x: IntArray
  x = [1, 2, 3, 4, 5, 6]
  for i in low(x)..high(x):
    echo x[i]

The notation ``x[i]`` is used to access the i-th element of ``x``.
Array access is always bounds checked (at compile-time or at runtime). These
checks can be disabled via pragmas or invoking the compiler with the
``--bound_checks:off`` command line switch.

Arrays are value types, like any other Nim type. The assignment operator
copies the whole array contents.

The built-in `len <system.html#len,TOpenArray>`_ proc returns the array's
length. `low(a) <system.html#low>`_ returns the lowest valid index for the
array `a` and `high(a) <system.html#high>`_ the highest valid index.

.. code-block:: nim
    :test: "nim c $1"
  type
    Direction = enum
      north, east, south, west
    BlinkLights = enum
      off, on, slowBlink, mediumBlink, fastBlink
    LevelSetting = array[north..west, BlinkLights]
  var
    level: LevelSetting
  level[north] = on
  level[south] = slowBlink
  level[east] = fastBlink
  echo repr(level)  # --> [on, fastBlink, slowBlink, off]
  echo low(level)   # --> north
  echo len(level)   # --> 4
  echo high(level)  # --> west

The syntax for nested arrays (multidimensional) in other languages is a matter
of appending more brackets because usually each dimension is restricted to the
same index type as the others. In Nim you can have different dimensions with
different index types, so the nesting syntax is slightly different. Building on
the previous example where a level is defined as an array of enums indexed by
yet another enum, we can add the following lines to add a light tower type
subdivided in height levels accessed through their integer index:

.. code-block:: nim
  type
    LightTower = array[1..10, LevelSetting]
  var
    tower: LightTower
  tower[1][north] = slowBlink
  tower[1][east] = mediumBlink
  echo len(tower)     # --> 10
  echo len(tower[1])  # --> 4
  echo repr(tower)    # --> [[slowBlink, mediumBlink, ...more output..
  # The following lines don't compile due to type mismatch errors
  #tower[north][east] = on
  #tower[0][1] = on

Note how the built-in ``len`` proc returns only the array's first dimension
length.  Another way of defining the ``LightTower`` to better illustrate its
nested nature would be to omit the previous definition of the ``LevelSetting``
type and instead write it embedded directly as the type of the first dimension:

.. code-block:: nim
  type
    LightTower = array[1..10, array[north..west, BlinkLights]]

It is quite common to have arrays start at zero, so there's a shortcut syntax
to specify a range from zero to the specified index minus one:

.. code-block:: nim
    :test: "nim c $1"
  type
    IntArray = array[0..5, int] # an array that is indexed with 0..5
    QuickArray = array[6, int]  # an array that is indexed with 0..5
  var
    x: IntArray
    y: QuickArray
  x = [1, 2, 3, 4, 5, 6]
  y = x
  for i in low(x)..high(x):
    echo x[i], y[i]


序列
---------
Sequences are similar to arrays but of dynamic length which may change
during runtime (like strings). Since sequences are resizable they are always
allocated on the heap and garbage collected.

Sequences are always indexed with an ``int`` starting at position 0.  The `len
<system.html#len,seq[T]>`_, `low <system.html#low>`_ and `high
<system.html#high>`_ operations are available for sequences too.  The notation
``x[i]`` can be used to access the i-th element of ``x``.

Sequences can be constructed by the array constructor ``[]`` in conjunction
with the array to sequence operator ``@``. Another way to allocate space for
a sequence is to call the built-in `newSeq <system.html#newSeq>`_ procedure.

A sequence may be passed to an openarray parameter.

Example:

.. code-block:: nim
    :test: "nim c $1"

  var
    x: seq[int] # a reference to a sequence of integers
  x = @[1, 2, 3, 4, 5, 6] # the @ turns the array into a sequence allocated on the heap

Sequence variables are initialized with ``@[]``.

The ``for`` statement can be used with one or two variables when used with a
sequence. When you use the one variable form, the variable will hold the value
provided by the sequence. The ``for`` statement is looping over the results
from the `items() <system.html#items.i,seq[T]>`_ iterator from the `system
<system.html>`_ module.  But if you use the two variable form, the first
variable will hold the index position and the second variable will hold the
value. Here the ``for`` statement is looping over the results from the
`pairs() <system.html#pairs.i,seq[T]>`_ iterator from the `system
<system.html>`_ module.  Examples:

.. code-block:: nim
    :test: "nim c $1"
  for value in @[3, 4, 5]:
    echo value
  # --> 3
  # --> 4
  # --> 5

  for i, value in @[3, 4, 5]:
    echo "index: ", $i, ", value:", $value
  # --> index: 0, value:3
  # --> index: 1, value:4
  # --> index: 2, value:5


开放数组
-----------
**Note**: Openarrays can only be used for parameters.

Often fixed size arrays turn out to be too inflexible; procedures should be
able to deal with arrays of different sizes. The `openarray`:idx: type allows
this. Openarrays are always indexed with an ``int`` starting at position 0.
The `len <system.html#len,TOpenArray>`_, `low <system.html#low>`_ and `high
<system.html#high>`_ operations are available for open arrays too.  Any array
with a compatible base type can be passed to an openarray parameter, the index
type does not matter.

.. code-block:: nim
    :test: "nim c $1"
  var
    fruits:   seq[string]       # reference to a sequence of strings that is initialized with '@[]'
    capitals: array[3, string]  # array of strings with a fixed size

  capitals = ["New York", "London", "Berlin"]   # array 'capitals' allows assignment of only three elements
  fruits.add("Banana")          # sequence 'fruits' is dynamically expandable during runtime
  fruits.add("Mango")

  proc openArraySize(oa: openArray[string]): int =
    oa.len

  assert openArraySize(fruits) == 2     # procedure accepts a sequence as parameter
  assert openArraySize(capitals) == 3   # but also an array type

The openarray type cannot be nested: multidimensional openarrays are not
supported because this is seldom needed and cannot be done efficiently.


可变参数
-------

A ``varargs`` parameter is like an openarray parameter. However, it is
also a means to implement passing a variable number of
arguments to a procedure. The compiler converts the list of arguments
to an array automatically:

.. code-block:: nim
    :test: "nim c $1"
  proc myWriteln(f: File, a: varargs[string]) =
    for s in items(a):
      write(f, s)
    write(f, "\n")

  myWriteln(stdout, "abc", "def", "xyz")
  # is transformed by the compiler to:
  myWriteln(stdout, ["abc", "def", "xyz"])

This transformation is only done if the varargs parameter is the
last parameter in the procedure header. It is also possible to perform
type conversions in this context:

.. code-block:: nim
    :test: "nim c $1"
  proc myWriteln(f: File, a: varargs[string, `$`]) =
    for s in items(a):
      write(f, s)
    write(f, "\n")

  myWriteln(stdout, 123, "abc", 4.0)
  # is transformed by the compiler to:
  myWriteln(stdout, [$123, $"abc", $4.0])

In this example `$ <system.html#$>`_ is applied to any argument that is passed
to the parameter ``a``. Note that `$ <system.html#$>`_ applied to strings is a
nop.


切片
------

Slices look similar to subranges types in syntax but are used in a different
context. A slice is just an object of type Slice which contains two bounds,
`a` and `b`. By itself a slice is not very useful, but other collection types
define operators which accept Slice objects to define ranges.

.. code-block:: nim
    :test: "nim c $1"

  var
    a = "Nim is a progamming language"
    b = "Slices are useless."

  echo a[7..12] # --> 'a prog'
  b[11..^2] = "useful"
  echo b # --> 'Slices are useful.'

In the previous example slices are used to modify a part of a string. The
slice's bounds can hold any value supported by
their type, but it is the proc using the slice object which defines what values
are accepted.

To understand some of the different ways of specifying the indices of
strings, arrays, sequences, etc., it must be remembered that Nim uses
zero-based indices.

So the string ``b`` is of length 19, and two different ways of specifying the
indices are

.. code-block:: nim

  "Slices are useless."
   |          |     |
   0         11    17   using indices
  ^19        ^8    ^2   using ^ syntax

where ``b[0..^1]`` is equivalent to ``b[0..b.len-1]`` and ``b[0..<b.len]``, and it
can be seen that the ``^1`` provides a short-hand way of specifying the ``b.len-1``.

In the above example, because the string ends in a period, to get the portion of the
string that is "useless" and replace it with "useful".

``b[11..^2]`` is the portion "useless", and ``b[11..^2] = "useful"`` replaces the
"useless" portion with "useful", giving the result "Slices are useful."

Note: alternate ways of writing this are ``b[^8..^2] = "useful"`` or
as ``b[11..b.len-2] = "useful"`` or as ``b[11..<b.len-1] = "useful"``.

对象
-------

The default type to pack different values together in a single
structure with a name is the object type. An object is a value type,
which means that when an object is assigned to a new variable all its
components are copied as well.

Each object type ``Foo`` has a constructor ``Foo(field: value, ...)``
where all of its fields can be initialized. Unspecified fields will
get their default value.

.. code-block:: nim
  type
    Person = object
      name: string
      age: int

  var person1 = Person(name: "Peter", age: 30)

  echo person1.name # "Peter"
  echo person1.age  # 30

  var person2 = person1 # copy of person 1

  person2.age += 14

  echo person1.age # 30
  echo person2.age # 44


  # the order may be changed
  let person3 = Person(age: 12, name: "Quentin")

  # not every member needs to be specified
  let person4 = Person(age: 3)
  # unspecified members will be initialized with their default
  # values. In this case it is the empty string.
  doAssert person4.name == ""


Object fields that should be visible from outside the defining module have to
be marked with ``*``.

.. code-block:: nim
    :test: "nim c $1"

  type
    Person* = object # the type is visible from other modules
      name*: string  # the field of this type is visible from other modules
      age*: int

元组
------

Tuples are very much like what you have seen so far from objects. They
are value types where the assignment operator copies each component.
Unlike object types though, tuple types are structurally typed,
meaning different tuple-types are *equivalent* if they specify fields of
the same type and of the same name in the same order.

The constructor ``()`` can be used to construct tuples. The order of the
fields in the constructor must match the order in the tuple's
definition. But unlike objects, a name for the tuple type may not be
used here.


Like the object type the notation ``t.field`` is used to access a
tuple's field. Another notation that is not available for objects is
``t[i]`` to access the ``i``'th field. Here ``i`` must be a constant
integer.

.. code-block:: nim
    :test: "nim c $1"
  type
    # type representing a person:
    # A person consists of a name and an age.
    Person = tuple
      name: string
      age: int

    # Alternative syntax for an equivalent type.
    PersonX = tuple[name: string, age: int]

    # anonymous field syntax
    PersonY = (string, int)

  var
    person: Person
    personX: PersonX
    personY: PersonY

  person = (name: "Peter", age: 30)
  # Person and PersonX are equivalent
  personX = person

  # Create a tuple with anonymous fields:
  personY = ("Peter", 30)

  # A tuple with anonymous fields is compatible with a tuple that has
  # field names.
  person = personY
  personY = person

  # Usually used for short tuple initialization syntax
  person = ("Peter", 30)

  echo person.name # "Peter"
  echo person.age  # 30

  echo person[0] # "Peter"
  echo person[1] # 30

  # You don't need to declare tuples in a separate type section.
  var building: tuple[street: string, number: int]
  building = ("Rue del Percebe", 13)
  echo building.street

  # The following line does not compile, they are different tuples!
  #person = building
  # --> Error: type mismatch: got (tuple[street: string, number: int])
  #     but expected 'Person'

Even though you don't need to declare a type for a tuple to use it, tuples
created with different field names will be considered different objects despite
having the same field types.

Tuples can be *unpacked* during variable assignment (and only then!). This can
be handy to assign directly the fields of the tuples to individually named
variables. An example of this is the `splitFile <os.html#splitFile>`_ proc
from the `os module <os.html>`_ which returns the directory, name and
extension of a path at the same time. For tuple unpacking to work you must
use parentheses around the values you want to assign the unpacking to,
otherwise you will be assigning the same value to all the individual
variables! For example:

.. code-block:: nim
    :test: "nim c $1"

  import os

  let
    path = "usr/local/nimc.html"
    (dir, name, ext) = splitFile(path)
    baddir, badname, badext = splitFile(path)
  echo dir      # outputs `usr/local`
  echo name     # outputs `nimc`
  echo ext      # outputs `.html`
  # All the following output the same line:
  # `(dir: usr/local, name: nimc, ext: .html)`
  echo baddir
  echo badname
  echo badext

Fields of tuples are always public, they don't need to be explicity
marked to be exported, unlike for example fields in an object type.

引用和指针类型
---------------------------
References (similar to pointers in other programming languages) are a
way to introduce many-to-one relationships. This means different references can
point to and modify the same location in memory.

Nim distinguishes between `traced`:idx: and `untraced`:idx: references.
Untraced references are also called *pointers*. Traced references point to
objects in a garbage collected heap, untraced references point to
manually allocated objects or to objects elsewhere in memory. Thus
untraced references are *unsafe*. However for certain low-level operations
(e.g., accessing the hardware), untraced references are necessary.

Traced references are declared with the **ref** keyword; untraced references
are declared with the **ptr** keyword.

The empty ``[]`` subscript notation can be used to *derefer* a reference,
meaning to retrieve the item the reference points to. The ``.`` (access a
tuple/object field operator) and ``[]`` (array/string/sequence index operator)
operators perform implicit dereferencing operations for reference types:

.. code-block:: nim
    :test: "nim c $1"

  type
    Node = ref object
      le, ri: Node
      data: int
  var
    n: Node
  new(n)
  n.data = 9
  # no need to write n[].data; in fact n[].data is highly discouraged!

To allocate a new traced object, the built-in procedure ``new`` must be used.
To deal with untraced memory, the procedures ``alloc``, ``dealloc`` and
``realloc`` can be used. The `system <system.html>`_
module's documentation contains further details.

If a reference points to *nothing*, it has the value ``nil``.


过程类型
---------------
A procedural type is a (somewhat abstract) pointer to a procedure.
``nil`` is an allowed value for a variable of a procedural type.
Nim uses procedural types to achieve `functional`:idx: programming
techniques.

Example:

.. code-block:: nim
    :test: "nim c $1"
  proc echoItem(x: int) = echo x

  proc forEach(action: proc (x: int)) =
    const
      data = [2, 3, 5, 7, 11]
    for d in items(data):
      action(d)

  forEach(echoItem)

A subtle issue with procedural types is that the calling convention of the
procedure influences the type compatibility: procedural types are only compatible
if they have the same calling convention. The different calling conventions are
listed in the `manual <manual.html#types-procedural-type>`_.

Distinct类型
-------------
A Distinct type allows for the creation of new type that "does not imply a
subtype relationship between it and its base type".
You must **explicitly** define all behaviour for the distinct type.
To help with this, both the distinct type and its base type can cast from one
type to the other.
Examples are provided in the `manual <manual.html#types-distinct-type>`_.

模块
=======
Nim supports splitting a program into pieces with a module concept.
Each module is in its own file. Modules enable `information hiding`:idx: and
`separate compilation`:idx:. A module may gain access to the symbols of another
module by using the `import`:idx: statement. Only top-level symbols that are marked
with an asterisk (``*``) are exported:

.. code-block:: nim
  # Module A
  var
    x*, y: int

  proc `*` *(a, b: seq[int]): seq[int] =
    # allocate a new sequence:
    newSeq(result, len(a))
    # multiply two int sequences:
    for i in 0..len(a)-1: result[i] = a[i] * b[i]

  when isMainModule:
    # test the new ``*`` operator for sequences:
    assert(@[1, 2, 3] * @[1, 2, 3] == @[1, 4, 9])

The above module exports ``x`` and ``*``, but not ``y``.

A module's top-level statements are executed at the start of the program.
This can be used to initialize complex data structures for example.

Each module has a special magic constant ``isMainModule`` that is true if the
module is compiled as the main file. This is very useful to embed tests within
the module as shown by the above example.

A symbol of a module *can* be *qualified* with the ``module.symbol`` syntax. And if
a symbol is ambiguous, it *must* be qualified. A symbol is ambiguous
if it is defined in two (or more) different modules and both modules are
imported by a third one:

.. code-block:: nim
  # Module A
  var x*: string

.. code-block:: nim
  # Module B
  var x*: int

.. code-block:: nim
  # Module C
  import A, B
  write(stdout, x) # error: x is ambiguous
  write(stdout, A.x) # okay: qualifier used

  var x = 4
  write(stdout, x) # not ambiguous: uses the module C's x


But this rule does not apply to procedures or iterators. Here the overloading
rules apply:

.. code-block:: nim
  # Module A
  proc x*(a: int): string = $a

.. code-block:: nim
  # Module B
  proc x*(a: string): string = $a

.. code-block:: nim
  # Module C
  import A, B
  write(stdout, x(3))   # no error: A.x is called
  write(stdout, x(""))  # no error: B.x is called

  proc x*(a: int): string = discard
  write(stdout, x(3))   # ambiguous: which `x` is to call?


排除符号
-----------------

The normal ``import`` statement will bring in all exported symbols.
These can be limited by naming symbols which should be excluded with
the ``except`` qualifier.

.. code-block:: nim
  import mymodule except y


From语句
--------------

We have already seen the simple ``import`` statement that just imports all
exported symbols. An alternative that only imports listed symbols is the
``from import`` statement:

.. code-block:: nim
  from mymodule import x, y, z

The ``from`` statement can also force namespace qualification on
symbols, thereby making symbols available, but needing to be qualified
to be used.

.. code-block:: nim
  from mymodule import x, y, z

  x()           # use x without any qualification

.. code-block:: nim
  from mymodule import nil

  mymodule.x()  # must qualify x with the module name as prefix

  x()           # using x here without qualification is a compile error

Since module names are generally long to be descriptive, you can also
define a shorter alias to use when qualifying symbols.

.. code-block:: nim
  from mymodule as m import nil

  m.x()         # m is aliasing mymodule


Include语句
-----------------
The ``include`` statement does something fundamentally different than
importing a module: it merely includes the contents of a file. The ``include``
statement is useful to split up a large module into several files:

.. code-block:: nim
  include fileA, fileB, fileC



Part 2
======

So, now that we are done with the basics, let's see what Nim offers apart
from a nice syntax for procedural programming: `Part II <tut2.html>`_


.. _strutils: strutils.html
.. _system: system.html
