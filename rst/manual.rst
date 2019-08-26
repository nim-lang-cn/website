==========
Nim手册
==========

:Authors: Andreas Rumpf, Zahary Karadjov
:Version: |nimversion|

.. contents::


  "复杂度"很像"能量": 你可以将它从最终用户转移到一个或多个其他玩家，但总量对于给定的任务保持不变。-- Ran


关于本文
===================

**注意** : 这份文件是草案，Nim的一些功能可能需要更精确的措辞。本手册不断发展为合适的规范。

**注意** : Nim的实验特性在 `这里 <manual_experimental.html>`_ 。

本文描述Nim语言的词汇、语法，和语义。

学习如何编译Nim程序和生成文档见 `Compiler User Guide <nimc.html>`_ 和 `DocGen Tools Guide <docgen.html>`_ 。

语言构造用扩展巴科斯范式（BNF）解释，其中 ``(a)*`` 表示 0 或者更多 ``a``, ``a+`` 表示1或更多 ``a``, 以及 ``(a)?`` 表示可选 *a* 。小括号用来对元素进行分组。

``&`` 是先行操作符; ``&a`` 表示需要 ``a`` 但不被消耗。它将在下列规则中消耗。

``|``, ``/`` 符号用于标记可选并且优先级最低。 ``/`` 是要求解析器尝试给定顺序的可选项的有序选择。 ``/`` 常用于确保语法没有歧义。

非终端符以小写字母开始，抽象终端符用大写。 

逐字终端符（包括关键字）用 ``'`` 引用。示例::

  ifStmt = 'if' expr ':' stmts ('elif' expr ':' stmts)* ('else' stmts)?

二元操作符 ``^*`` 用于由第二个实参分隔的0或多次出现的简写；不像 ``^+`` 表示1或多个出现: ``a ^+ b`` 是 ``a (b a)*`` 的简写
``a ^* b`` 是 ``(a (b a)*)?`` 的简写。示例::

  arrayConstructor = '[' expr ^* ',' ']'

Nim的其他部分，如作用域规则或运行时语义，都是非正式描述的。




定义
===========

Nim代码指定一个计算，该计算作用于由称为 `位置`:idx: 的组件组成的内存。 变量基本上是位置的名称。每个变量和位置都是某种 `类型`:idx: 。
变量类型叫做 `静态类型`:idx: ，位置的类型叫做 `动态类型`:idx: 。
如果静态类型和动态类型不一样，它是动态类型的一个超类型或子类型。

 `标识符`:idx: 是声明为变量，类型，过程等的名称的符号。
声明适用的程序区域叫做 `作用域`:idx: 。作用域可以嵌套。
标识符的含义由声明标识符的最小封闭范围确定，除非重载解析规则另有说明。

表达式指定生成值或位置的计算。产生位置的表达式叫 `左值`:idx: 。左值可以表示位置或位置包含的值，具体取决于上下文。

Nim `程序`:idx: 由一个或多个包含Nim代码的文本 `源文件`:idx: 构成。
它由Nim `编译器`:idx: 处理成一个 `可执行文件`:idx: 。
可执行文件的类型取决于编译器实现； 例如它可以是原生二进制或JavaScript源代码。

在典型的Nim程序中，多数代码编译成可执行文件。 但是，某些代码可以在 `编译期`:idx: 执行 。 
这可以包括宏定义使用的常量表达式，宏定义，和Nim过程。
编译期支持大部分Nim语言，但有一些限制 -- 详见 `Restrictions on Compile-Time Execution <#restrictions-on-compileminustime-execution>`_ 。
我们用术语 `进行时`:idx: 来涵盖可执行文件中的编译时执行和代码执行。

编译器把Nim源代码解析为称为 `抽象语法树`:idx: (`AST`:idx:) 的内部数据结构 。
然后，在执行代码或编译成可执行文件前，通过 `语义分析`:idx: 变换AST。 
这会添加语义信息，诸如表达式类型、标识符含义，以及某些情况下的表达式值。
语义分析期间的错误叫做 `静态错误`:idx: 。
未另行指定时，本手册中描述的错误是静态错误。

`运行时检查错误`:idx: 是实现在运行时检查并报告的错误。
报错此类错误的方法是通过 *引发异常* 或 *以致命错误退出* 。 
但是，该实现提供了禁用这些 `运行时检查`:idx: 的方法 . 
有关详细信息，请参阅 pragmas_ 部分。

检查的运行时错误是导致异常还是致命错误取决于实现。
因此以下程序无效；即使代码声称从越界数组访问中捕获 `IndexError` ，编译器也可以选择允许程序退出致命错误。

.. code-block:: nim
  var a: array[0..1, char]
  let i = 5
  try:
    a[i] = 'N'
  except IndexError:
    echo "invalid index"

`未经检查的运行时错误`:idx: 是一个不能保证被检测到的错误，并且可能导致任意的计算后续行为。
如果仅使用 `safe`:idx: 语言功能并且未禁用运行时检查，则不会发生未经检查的运行时错误。

`常量表达式`:idx: 是一个表达式，其值可以在出现的代码的语义分析期间计算。 
它不是左值也没有副作用。
常量表达式不仅限于语义分析的功能，例如常量折叠;他们可以使用编译时执行所支持的所有Nim语言功能。
由于常量表达式可以用作语义分析的输入（例如用于定义数组边界），因此这种灵活性要求编译器交错语义分析和编译时代码执行。


在源代码中从上到下和从左到右进行图像语义分析是非常准确的，在必要时交错编译时代码执行以计算后续语义分析所需的值。
我们将在本文档后面看到，宏调用不仅需要这种交错，而且还会产生语义分析不能完全从上到下，从左到右进行的情况。


词汇分析
================

编码
--------

所有Nim源文件都采用UTF-8编码（或其ASCII子集）。
其他编码不受支持。
可以使用任何标准平台行终端序列 - Unix使用ASCII LF（换行），Windows使用ASCII序列CR LF的（返回后跟换行），老的Macintosh使用ASCII CR（返回）字符。
无论什么平台，使用这些形式的效果是一样的。


缩进
-----------

Nim的标准语法描述了一个 `缩进敏感`:idx: 语言。
这意味着所有控制结构都可以通过缩进识别。
缩进仅由空格组成;制表符是不允许的。

缩进处理按如下方式实现：词法分析器使用前面的空格数注释以下标记;缩进不是一个单独的标记。
这个技巧允许只用1个先行标记解析Nim。

解析器使用由整数个空格组成的缩进堆栈级别。
缩进信息在解析器重要的位置上查询，否则被忽略：伪终端 ``IND{>}`` 表示由比在堆栈顶部更多的空格构成； ``IND{=}`` 缩进具有相同数量的空格。
``DED`` 是描述从堆栈弹出一个值的运作的伪代码， ``IND{>}`` 意味着推到栈上。

使用这种表示法，我们现在可以轻松定义语法的核心：一个语句块（简化示例）::

  ifStmt = 'if' expr ':' stmt
           (IND{=} 'elif' expr ':' stmt)*
           (IND{=} 'else' ':' stmt)?

  simpleStmt = ifStmt / ...

  stmt = IND{>} stmt ^+ IND{=} DED  # list of statements
       / simpleStmt                 # or a simple statement



注释
--------


注释从字符串或字符字面值外的任何地方开始，并带有哈希字符 ``#`` 。
注释包含 `注释片段` 的连接:idx: 。
评论文章以 `#` 开头，​​一直运行到行尾。
行尾字符属于该片段。
如果下一行只包含一个注释片段，而它与前一个片段之间没有其他符号，则它不会启动新注释：


.. code-block:: nim
  i = 0     # 这是跨行的单个注释。
    # 扫描器合并这个块。
    # 注释从这里继续。


`文档注释`:idx: 由两个开始 ``##`` 。
文档注释是符号；它们仅允许出现在输入文件的某个地方，因为它们属于语法树。


多行注释
------------------

从版本0.13.0开始，Nim支持多行注释。


.. code-block:: nim
  #[注释这里.
  多行
  不是问题。]#

多行注释支持嵌套：

.. code-block:: nim
  #[  #[ 在已经注释代码中的多行注释]#
  proc p[T](x: T) = discard
  ]#

多行文档注释并支持嵌套：

.. code-block:: nim
  proc foo =
    ##[长文档注释。
    ]##


标识符 & 关键字
----------------------

Nim中的标识符可以是任何以字母开头的数字、字母和下划线。不允许两个连续的下划线 ``__`` ::

  letter ::= 'A'..'Z' | 'a'..'z' | '\x80'..'\xff'
  digit ::= '0'..'9'
  IDENTIFIER ::= letter ( ['_'] (letter | digit) )*

目前，序数值> 127（非ASCII）的任何Unicode字符都被归类为 ``字母`` ，因此可能是标识符的一部分，但该语言的后续版本可能会指定某些Unicode字符来代替运算符字符。

下面预留的关键字不能用作标识符：

.. code-block:: nim
  addr and as asm
  bind block break
  case cast concept const continue converter
  defer discard distinct div do
  elif else end enum except export
  finally for from func
  if import in include interface is isnot iterator
  let
  macro method mixin mod
  nil not notin
  object of or out
  proc ptr
  raise ref return
  shl shr static
  template try tuple type
  using
  var
  when while
  xor
  yield

有些关键字未使用;它们是为语言的未来发展而保留的。


标识符相等性
-------------------

两个标识符被认为是相等的如果下列算法返回真：

.. code-block:: nim
  proc sameIdentifier(a, b: string): bool =
    a[0] == b[0] and
      a.replace("_", "").toLowerAscii == b.replace("_", "").toLowerAscii

这意味着只有首字母大小写敏感。
其他字母在ASCII范围内不区分大小写，并且忽略下划线。

这种相当不正统的标识符比较方法称为 `部分不区分大小写`:idx: 并且具有优于传统区分大小写的一些优点:

它允许程序员大多使用他们自己喜欢的拼写样式，无论是humpStyle还是snake_style，不同程序员编写的库不能使用不兼容的约定。
Nim感知编辑器或IDE可以将标识符显示为首选。
另一个优点是它使程序员不必记住标识符的确切拼写。关于第一个字母的例外允许明确地解析像 ``var foo：Foo`` 这样的公共代码。

请注意，此规则也适用于关键字，这意味着 ``notin`` 和 ``notIn`` 以及 ``not_in`` 是相同的， (全小写版本 (``notin``, ``isnot``) 是写关键字的首选方式)。

从历史上看，Nim是一种完全 `风格不敏感`:idx: 语言。 
这意味着它不区分大小写并且忽略了下划线，并且 ``foo`` 和 ``Foo`` 之间甚至没有区别。 


字符串字面值
---------------

语法中的终端符号: ``STR_LIT`` 。

字符串字面值可以通过匹配双引号来分隔，并且可以包含以下 `转义序列`:idx: :

==================         ===================================================
  转义序列                  含义
==================         ===================================================
  ``\p``                   平台特定的换行: CRLF on Windows,
                           LF on Unix
  ``\r``, ``\c``           `回车`:idx:
  ``\n``, ``\l``           `换行`:idx: (通常叫做 `新行`:idx:)
  ``\f``                   `换页`:idx:
  ``\t``                   `制表符`:idx:
  ``\v``                   `垂直制表符`:idx:
  ``\\``                   `反斜线`:idx:
  ``\"``                   `双引号`:idx:
  ``\'``                   `单引号`:idx:
  ``\`` '0'..'9'+          `十进制值的字符d`:idx:;
                           后跟的所有十进制数字都用于该字符
  ``\a``                   `告警`:idx:
  ``\b``                   `退格`:idx:
  ``\e``                   `退出`:idx: `[ESC]`:idx:
  ``\x`` HH                `带十六进制值的字符HH`:idx:;
                           只允许两位十六进制数字
  ``\u`` HHHH              `具有十六进制值的unicode代码点HHHH`:idx: ;
                           只允许四位十六进制数字
  ``\u`` {H+}              `unicode代码点`:idx:;
                           用 ``{}`` 括起来的所有十六进制数字都用于代码点
==================         ===================================================


Nim中的字符串可以包含任何8位值，甚至是嵌入的零。
但是，某些操作可能会将第一个二进制零解释为终止符。


三引用字符串字面值
-----------------------------

语法中的终端符号: ``TRIPLESTR_LIT``.

字符串字面值也可以用三个双引号分隔 ``"""`` ... ``"""`` 。
这种形式的字面值可能会持续几行，可能包含 ``"`` 并且不解释任何转义序列。
为方便起见，当开头的 ``"""`` 后面跟一个换行符 (开头 ``"""`` 和换行符之间可能有空格）时,换行符（和前面的空格）不包含在字符串。 
字符串字面值的结尾由模式定义 ``"""[^"]``, 所以:

.. code-block:: nim
  """"long string within quotes""""

生成::

  "long string within quotes"


原始字符串字面值
-------------------

语法中的终端符号: ``RSTR_LIT``.

还有原始字符串字面值，前面带有字母 ``r`` (or ``R``) 并通过匹配双引号（就像普通的字符串字面值一样）分隔并且不解释转义序列。
这对于正则表达式或Windows路径特别方便：

.. code-block:: nim

  var f = openFile(r"C:\texts\text.txt") # 原始字符串, 所以 ``\t`` 不是制表符。

为了在原始字符串中生成一个单独的 ``"`` , 必须使用两个:

.. code-block:: nim

  r"a""b"

Produces::

  a"b

``r""""`` 这个符号是不可能的，因为三个引号引用了三引号字符串字面值。
``r"""`` 与 ``"""`` 相同，因为三重引用的字符串字面值也不解释转义序列。


广义原始字符串字面值
-------------------------------

语法中的终端符号: ``GENERALIZED_STR_LIT``, ``GENERALIZED_TRIPLESTR_LIT`` 。

``标识符"字符串字面值"`` 这种构造(标识符和开始引号之间没有空格)是广义原始字符串。
这是 ``identifier(r"string literal")`` 的缩写， 所以它表示一个过程调用原始字符串字面值作为唯一的参数。 

广义原始字符串字面值特别便于将小型语言直接嵌入到Nim中（例如正则表达式）。

``标识符"""字符串字面值"""`` 也存在。它是 ``标识符("""字符串字面值""")`` 的缩写。


字符字面值
------------------

字符字面值用单引号 ``''`` 括起来，并且可以包含与字符串相同的转义序列 - 有一个例外：平台依赖的 `newline`:idx: (``\p``) 是不允许的，因为它可能比一个字符宽（通常是CR / LF对）。  
以下是对字符字面值有效的 `转义序列`:idx: :

==================         ===================================================
  转义序列                  含义
==================         ===================================================
  ``\r``, ``\c``           `回车`:idx:
  ``\n``, ``\l``           `换行`:idx:
  ``\f``                   `换页`:idx:
  ``\t``                   `制表符`:idx:
  ``\v``                   `垂直制表符`:idx:
  ``\\``                   `反斜杠`:idx:
  ``\"``                   `双引号`:idx:
  ``\'``                   `单引号`:idx:
  ``\`` '0'..'9'+          `十进制值的字符d`:idx:;
                           后跟的所有十进制数字都用于该字符
  ``\a``                   `告警`:idx:
  ``\b``                   `退格`:idx:
  ``\e``                   `退出`:idx: `[ESC]`:idx:
  ``\x`` HH                `十六进制字符HH`:idx:;
                           只允许两位数字
==================         ===================================================

字符不是Unicode字符，而是单个字节。

这样做的原因是效率：对于绝大多数用例，由于UTF-8是专门为此设计的，所得到的程序仍然可以正确处理UTF-8。
另一个原因是Nim因此可以依靠这个特性像其它算法一样有效地支持 ``array[char, int]`` 或 ``set[char]`` 。
`Rune` 类型用于Unicode字符，它可以表示任何Unicode字符。
``Rune`` 在 `unicode module <unicode.html>`_ 声明。


数值常量
-------------------

数值常量是单一类型，并具有以下形式::

  hexdigit = digit | 'A'..'F' | 'a'..'f'
  octdigit = '0'..'7'
  bindigit = '0'..'1'
  HEX_LIT = '0' ('x' | 'X' ) hexdigit ( ['_'] hexdigit )*
  DEC_LIT = digit ( ['_'] digit )*
  OCT_LIT = '0' 'o' octdigit ( ['_'] octdigit )*
  BIN_LIT = '0' ('b' | 'B' ) bindigit ( ['_'] bindigit )*

  INT_LIT = HEX_LIT
          | DEC_LIT
          | OCT_LIT
          | BIN_LIT

  INT8_LIT = INT_LIT ['\''] ('i' | 'I') '8'
  INT16_LIT = INT_LIT ['\''] ('i' | 'I') '16'
  INT32_LIT = INT_LIT ['\''] ('i' | 'I') '32'
  INT64_LIT = INT_LIT ['\''] ('i' | 'I') '64'

  UINT_LIT = INT_LIT ['\''] ('u' | 'U')
  UINT8_LIT = INT_LIT ['\''] ('u' | 'U') '8'
  UINT16_LIT = INT_LIT ['\''] ('u' | 'U') '16'
  UINT32_LIT = INT_LIT ['\''] ('u' | 'U') '32'
  UINT64_LIT = INT_LIT ['\''] ('u' | 'U') '64'

  exponent = ('e' | 'E' ) ['+' | '-'] digit ( ['_'] digit )*
  FLOAT_LIT = digit (['_'] digit)* (('.' digit (['_'] digit)* [exponent]) |exponent)
  FLOAT32_SUFFIX = ('f' | 'F') ['32']
  FLOAT32_LIT = HEX_LIT '\'' FLOAT32_SUFFIX
              | (FLOAT_LIT | DEC_LIT | OCT_LIT | BIN_LIT) ['\''] FLOAT32_SUFFIX
  FLOAT64_SUFFIX = ( ('f' | 'F') '64' ) | 'd' | 'D'
  FLOAT64_LIT = HEX_LIT '\'' FLOAT64_SUFFIX
              | (FLOAT_LIT | DEC_LIT | OCT_LIT | BIN_LIT) ['\''] FLOAT64_SUFFIX


从结果中可以看出，数值常数可以包含下划线以便于阅读。

整数和浮点字面值可以用十进制（无前缀），二进制（前缀 ``0b`` ），八进制（前缀 ``0o`` ）和十六进制（前缀 ``0x`` ）表示法给出。

每个定义的数字类型都有一个字面值。
以一撇开始的后缀 ('\'') 叫 `类型后缀`:idx: 。

没有类型后缀的字面值是整数类型，除非字面值包含点或 ``E|e`` ，在这种情况下它是 ``浮点`` 类型。
整数类型是 ``int`` 如果字面值在 ``low(i32)..high(i32)`` 范围，否则是 ``int64`` 。
为了符号方便，类型后缀的撇号是可选的，如果它没有歧义（只有具有类型后缀的十六进制浮点字面值可能是不明确的）。


类型后缀是:

=================    =========================
  类型后缀            字面值类型
=================    =========================
  ``'i8``            int8
  ``'i16``           int16
  ``'i32``           int32
  ``'i64``           int64
  ``'u``             uint
  ``'u8``            uint8
  ``'u16``           uint16
  ``'u32``           uint32
  ``'u64``           uint64
  ``'f``             float32
  ``'d``             float64
  ``'f32``           float32
  ``'f64``           float64
=================    =========================

浮点字面值也可以是二进制，八进制或十六进制表示法：
根据IEEE浮点标准， ``0B0_10001110100_0000101001000111101011101111111011000101001101001001'f64`` 约为 1.72826e35。

对字面值进行边界检查，以使它们适合数据类型。
非基数10字面值主要用于标志和位模式表示，因此边界检查是在位宽而非值范围上完成的。
如果字面值符合数据类型的位宽，则接受它。
因此：0b10000000'u8 == 0x80'u8 == 128，但是，0b10000000'i8 == 0x80'i8 == -1而不是导致溢出错误。

操作符
---------

Nim允许用户定义的运算符。运算符是以下字符的任意组合

       =     +     -     *     /     <     >
       @     $     ~     &     %     |
       !     ?     ^     .     :     \

这些关键字也是操作符:
``and or not xor shl shr div mod in notin is isnot of``.

`.`:tok: `=`:tok:, `:`:tok:, `::`:tok: 不作为一般操作符；它们用于其他符号用途。

``*:`` 是一个特殊情况，被看作是 `*`:tok: 和 `:`:tok: 两个标记(为了支持 ``var v*: T``)。

``not`` 关键字是一元操作符， ``a not b`` 解析成 ``a(not b)``, 不是 ``(a) not (b)`` 。


其它标记
------------

以下字符串表示其他标记::

    `   (    )     {    }     [    ]    ,  ;   [.    .]  {.   .}  (.  .)  [:


`切片`:idx: 运算符 `..`:tok: 优先于包含点的其它标记: `{..}`:tok: 是三个标记 `{`:tok:, `..`:tok:, `}`:tok: 而不是两个标记 `{.`:tok:, `.}`:tok: 。



句法
======


本节列出了Nim的标准语法。解析器如何处理缩进已在 `Lexical Analysis`_ 部分中描述。


Nim允许用户可定义的运算符。二元运算符具有11个不同的优先级。



结合律
-------------

第一个字符是 ``^`` 的二元运算符是右结合，所有其他二元运算符都是左结合。

.. code-block:: nim
  proc `^/`(x, y: float): float =
    # 右关联除法运算符
    result = x / y
  echo 12 ^/ 4 ^/ 8 # 24.0 (4 / 8 = 0.5, then 12 / 0.5 = 24.0)
  echo 12  / 4  / 8 # 0.375 (12 / 4 = 3.0, then 3 / 8 = 0.375)

 
----------

一元运算符总是比任何二元运算符优先: ``$a + b`` is ``($a) + b`` 而不是 ``$(a + b)`` 。

如果一元运算符的第一个字符是 ``@`` 它是 `符印样`:idx: 运算符，比 ``主后缀`` 优先: ``@x.abc`` 解析成 ``(@x).abc`` 而 ``$x.abc`` 解析成 ``$(x.abc)`` 。


对于非关键字的二元运算符，优先级由以下规则确定：

以 ``->``, ``~>`` or ``=>`` 结尾的运算符称为 `箭头形`:idx:, 优先级最低。

如果操作符以 ``=`` 结尾，并且它的第一个字符不是 ``<``, ``>``, ``!``, ``=``, ``~``, ``?``, 它是一个 *赋值运算符* 具有第二低的优先级。

否则优先级由第一个字符决定。


================  ===============================================  ==================  ===============
优先级             运算符                                           首字符                终端符号
================  ===============================================  ==================  ===============
 10 (highest)                                                      ``$  ^``            OP10
  9               ``*    /    div   mod   shl  shr  %``            ``*  %  \  /``      OP9
  8               ``+    -``                                       ``+  -  ~  |``      OP8
  7               ``&``                                            ``&``               OP7
  6               ``..``                                           ``.``               OP6
  5               ``==  <= < >= > !=  in notin is isnot not of``   ``=  <  >  !``      OP5
  4               ``and``                                                              OP4
  3               ``or xor``                                                           OP3
  2                                                                ``@  :  ?``         OP2
  1               *赋值运算符* (like ``+=``, ``*=``)                                    OP1
  0 (lowest)      *箭头形操作符* (like ``->``, ``=>``)                                  OP0
================  ===============================================  ==================  ===============


运算符是否使用前缀运算符也受前面的空格影响（此版本的修改随版本0.13.0引入）：

.. code-block:: nim
  echo $foo
  # 解析成
  echo($foo)


间距还决定了 ``(a, b)`` 是否被解析为调用的参数列表，或者它是否被解析为元组构造函数：

.. code-block:: nim
  echo(1, 2) # 传1和2给echo

.. code-block:: nim
  echo (1, 2) # 传元组(1, 2)给echo


语法
-------

语法的起始符号是 ``module``.

.. include:: grammar.txt
   :literal:



求值顺序
===================

求值顺序是从左到右、从内到外，和大多数其他典型的命令式编程语言一样：

.. code-block:: nim
    :test: "nim c $1"

  var s = ""

  proc p(arg: int): int =
    s.add $arg
    result = arg

  discard p(p(1) + p(2))

  doAssert s == "123"


赋值也不例外，左侧表达式在右侧之前进行求值：

.. code-block:: nim
    :test: "nim c $1"

  var v = 0
  proc getI(): int =
    result = v
    inc v

  var a, b: array[0..2, int]

  proc someCopy(a: var int; b: int) = a = b

  a[getI()] = getI()

  doAssert a == [1, 0, 0]

  v = 0
  someCopy(b[getI()], getI())

  doAssert b == [1, 0, 0]


基本原理：与重载赋值或赋值类操作的一致性 ``a = b`` 可以读作 ``performSomeCopy(a, b)``.


常量和常量表达式
==================================

`常量`:idx: 是一个与常量表达式值绑定的符号。
常量表达式仅限于依赖于以下类别的值和操作，因为它们要么构建在语言中，要么在对常量表达式进行语义分析之前进行声明和求值：

* 字面值
* 内置运算符
* 之前声明的常量和编译时变量
* 之前声明过的宏和模板
* 之前声明的过程除了可能修改编译时变量之外没有任何副作用

常量表达式可以包含可以在内部使用编译时支持的所有Nim功能的代码块（详见下一节）。
在这样的代码块中，可以声明变量然后稍后读取和更新它们，或者声明变量并将它们传递给修改它们的过程。
但是，此类块中的代码仍必须遵循上面列出的用于引用块外部的值和操作的限制。


访问和修改编译时变量的能力增加了常量表达式的灵活性。
例如，下面的代码在 **编译时** 打印Fibonacci数列的开头。
（这是对定义常量的灵活性的证明，而不是解决此问题的推荐样式！）

.. code-block:: nim
    :test: "nim c $1"
  import strformat

  var fib_n {.compileTime.}: int
  var fib_prev {.compileTime.}: int
  var fib_prev_prev {.compileTime.}: int

  proc next_fib(): int =
    result = if fib_n < 2:
      fib_n
    else:
      fib_prev_prev + fib_prev
    inc(fib_n)
    fib_prev_prev = fib_prev
    fib_prev = result

  const f0 = next_fib()
  const f1 = next_fib()

  const display_fib = block:
    const f2 = next_fib()
    var result = fmt"Fibonacci sequence: {f0}, {f1}, {f2}"
    for i in 3..12:
      add(result, fmt", {next_fib()}")
    result

  static:
    echo display_fib


编译期执行限制
======================================

将在编译时执行的Nim代码不能使用以下语言功能：

* 方法
* 闭包迭代器
* ``cast`` 运算符
* 引用(指针)类型
* 外部函数接口（FFI）

随着时间的推移，部分或全部这些限制可能会被取消。


类型
=====

所有表达式都具有在语义分析期间已知的类型。 Nim是静态类型的。可以声明新类型，这实际上定义了可用于表示此自定义类型的标识符。

这些是主要的类型：

* 序数类型（由整数，bool，字符，枚举（及其子范围）类型组成）
* 浮点类型
* 字符串类型
* 结构化类型
* 引用 (指针)类型
* 过程类型
* 泛型类型


序数类型
-------------
序数类型有以下特征：

- 序数类型是可数和有序的。该属性允许定义函数的操作 ``inc``, ``ord``, ``dec`` 。
- 序数值具有最小可能值。尝试进一步向下计数低于最小值会产生已检查的运行时或静态错误。
- 序数值具有最大可能值。尝试计数超过最大值会产生已检查的运行时或静态错误。

整数，bool，字符和枚举类型（以及这些类型的子范围）属于序数类型。
出于简化实现的原因，类型 ``uint`` 和 ``uint64`` 不是序数类型。 （这将在该语言的更高版本中更改。）

如果基类型是序数类型，则不同类型是序数类型。


预定义整数类型
-------------------------
这些整数类型是预定义的：

``int``
  通用有符号整数类型;它的大小取决于平台，并且与指针大小相同。
  一般应该使用这种类型。
  没有类型后缀的整数字面值是这种类型，如果它在 ``low(int32)... high(int32)`` 范围内，否则字面值的类型是 ``int64`` 。

intXX
  附加的有符号整数类型的XX位使用此命名方案（例如：int16是16位宽整数）。
  当前的实现支持 ``int8``, ``int16``, ``int32``, ``int64`` 。
  这些类型的字面值后缀为'iXX。

``uint``
  通用的 `无符号整型`:idx: ; 它的大小取决于平台，并且与指针大小相同。
  类型后缀为 ``'u`` 的整数字面值就是这种类型。

uintXX
  附加的无符号整数类型的XX位使用此命名方案（例如：uint16是16位宽的无符号整数）。
  当前的实现支持 ``uint8``, ``uint16``, ``uint32``, ``uint64`` 。
  这些类型的字面值具有后缀 'uXX 。
  无符号操作被全面封装; 不会导致上溢或下溢。



除了有符号和无符号整数的常用算术运算符 (``+ - *`` etc.) 之外，还有一些运算符正式处理 *整型* 整数但将它们的参数视为 *无符号*: 它们主要用于向后与缺少无符号整数类型的旧版本语言的兼容性。
有符号整数的这些无符号运算使用 ``%`` 后缀作为约定：


======================   ======================================================
操作符                    含义
======================   ======================================================
``a +% b``               无符号整型加法
``a -% b``               无符号整型减法
``a *% b``               无符号整型乘法
``a /% b``               无符号整型除法
``a %% b``               无符号整型取模
``a <% b``               无符号比较 ``a`` 和 ``b`` 
``a <=% b``              无符号比较 ``a`` 和 ``b`` 
``ze(a)``                用零填充 ``a`` 的位，直到它具有 ``int`` 类型的宽度
``toU8(a)``              8位无符号转换 ``a``  (仍然是 ``int8`` 类型)
``toU16(a)``             16位无符号转换 ``a``  (仍然是 ``int16`` 类型)
``toU32(a)``             32位无符号转换 ``a``  (仍然是 ``int32`` 类型)
======================   ======================================================

`自动类型转换`:idx: 在使用不同类型的整数类型的表达式中执行：较小的类型转换为较大的类型。

`缩小类型转换`:idx: 将较大的类型转换为较小的类型（例如 ``int32  - > int16`` 。 `扩展类型转换`:idx: 将较小的类型转换为较大的类型（例如 ``int16  - > int32`` ）。
Nim中只有扩展类型转型是 *隐式的*:

.. code-block:: nim
  var myInt16 = 5i16
  var myInt: int
  myInt16 + 34     # of type ``int16``
  myInt16 + myInt  # of type ``int``
  myInt16 + 2i32   # of type ``int32``


但是，如果字面值适合这个较小的类型并且这样的转换比其他隐式转换便宜，则 ``int`` 字面值可以隐式转换为较小的整数类型，因此 ``myInt16 + 34`` 产生 ``int16`` 结果。

有关详细信息，请参阅 `可转换关系 <#type-relations-convertible-relation>`_ 。


子范围类型
--------------
子范围类型是序数或浮点类型（基本类型）的值范围。

要定义子范围类型，必须指定其限制值 - 类型的最低值和最高值。例如：

.. code-block:: nim
  type
    Subrange = range[0..5]
    PositiveFloat = range[0.0..Inf]


``Subrange`` 是整数的子范围，只能保存0到5的值。
``PositiveFloat`` 定义所有正浮点值的子范围。
NaN不属于任何浮点类型的子范围。
将任何其他值分配给类型为 ``Subrange`` 的变量是检查的运行时错误（如果可以在语义分析期间确定，则为静态错误）。
允许从基本类型到其子类型之一（反之亦然）的分配。

子范围类型与其基类型具有相同的大小（Subrange示例中的 ``int`` ）。


预定义浮点类型
--------------------------------

以下浮点类型是预定义的：

``float``
  通用浮点类型;它的大小曾经是平台相关的，但现在它总是映射到 ``float64`` 。一般应该使用这种类型。

floatXX
  实现可以使用此命名方案定义XX位的其他浮点类型（例如：float64是64位宽的浮点数）。
  当前的实现支持 ``float32`` 和 ``float64`` 。
  这些类型的字面值具有后缀 'fXX 。

执行具有不同类型浮点类型的表达式中的自动类型转换：有关更多详细信息，请参阅 `可转换关系` 。
在浮点类型上执行的算术遵循IEEE标准。
整数类型不会自动转换为浮点类型，反之亦然。

IEEE标准定义了五种类型的浮点异常：

* 无效: 使用数学上无效的操作数的操作, 例如 0.0/0.0, sqrt(-1.0), 和log(-37.8).
* 除以零：除数为零，且除数是有限的非零数，例如1.0 / 0.0。
* 溢出：操作产生的结果超出指数范围，例如MAXDOUBLE + 0.0000000000001e308。
* 下溢：操作产生的结果太小而无法表示为正常数字，例如，MINDOUBLE * MINDOUBLE。
* 不精确：操作产生的结果无法用无限精度表示，例如，输入中的2.0 / 3.0，log（1.1）和0.1。

IEEE异常在执行期间被忽略或映射到Nim异常: `FloatInvalidOpError`:idx:, `FloatDivByZeroError`:idx:, `FloatOverflowError`:idx:, `FloatUnderflowError`:idx:, 和 `FloatInexactError`:idx: 。
这些异常继承自 `FloatingPointError`:idx: 基类。

Nim提供了编译指示 `nanChecks`:idx: 和 `infChecks`:idx: 控制是否忽略IEEE异常或捕获Nim异常：

.. code-block:: nim
  {.nanChecks: on, infChecks: on.}
  var a = 1.0
  var b = 0.0
  echo b / b # raises FloatInvalidOpError
  echo a / b # raises FloatOverflowError

在当前的实现中， ``FloatDivByZeroError`` 和 ``FloatInexactError`` 永远不会被引发。
``FloatOverflowError`` 取代了 ``FloatDivByZeroError`` 。
还有一个 `floatChecks`:idx: 编译指示用作 ``nanChecks`` 和 ``infChecks`` 的快捷方式。 ``floatChecks`` 默认关闭。

受 ``floatChecks`` 编译指示影响的唯一操作是浮点类型的 ``+`` ， ``-`` ， ``*`` ， ``/`` 运算符。

在语义分析期间，实现应始终使用最大精度来评估浮点指针值; 
这表示在常量展开期间，表达式 ``0.09'f32 + 0.01'f32 == 0.09'f64 + 0.01'f64`` 求值为真。


布尔类型
------------
布尔类型在Nim中命名为 `bool`:idx: 并且可以是两个预定义值之一 ``true`` 和 ``false`` 。
``while``, ``if``, ``elif``, ``when`` 中的语句需要是 ``bool`` 类型。

这种情况成立::

  ord(false) == 0 and ord(true) == 1

布尔类型定义了运算符 ``not, and, or, xor, <, <=, >, >=, !=, ==`` 。 ``and`` 和 ``or`` 运算符执行短路求值。示例:

.. code-block:: nim

  while p != nil and p.name != "xyz":
    # 如果 p == nil， p.name不被求值。 
    p = p.next


bool类型的大小是一个字节。


字符类型
--------------
字符类型在Nim中被命名为 ``char`` 。它的大小是一字节。
因此，它不能代表UTF-8字符，而是它的一部分。
这样做是出于效率：对于绝大多数用例，由于UTF-8是专门为此设计的，所得到的程序仍然可以正确处理UTF-8。
另一个原因是Nim可以有效地支持 ``array[char,int]`` 或 ``set[char]`` ，因为许多算法依赖于这个特性。
`Rune` 类型用于Unicode字符，它可以表示任何Unicode字符。
``Rune`` 在 `unicode module <unicode.html>`_ 中声明。



枚举类型
-----------------

枚举类型定义一个新类型，其值由指定的值组成。这些值是有序的。例：

.. code-block:: nim

  type
    Direction = enum
      north, east, south, west


现在以下内容成立::

  ord(north) == 0
  ord(east) == 1
  ord(south) == 2
  ord(west) == 3

  # 也允许:
  ord(Direction.west) == 3

因此, north < east < south < west 。
比较运算符可以与枚举类型一起使用。
枚举值也可以使用它所在的枚举类型 ``Direction.nort`` 来限定，而不是 ``north`` 等。

为了更好地与其他编程语言连接，可以为枚举类型的字段分配显式序数值。
但是，序数值必须按升序排列。
未明确给出序数值的字段被赋予前一个字段+ 1的值。

显式有序枚举可以有 *洞* ：

.. code-block:: nim
  type
    TokenType = enum
      a = 2, b = 4, c = 89 # 洞是合法的

但是，它不再是序数，因此不可能将这些枚举用作数组的索引类型。 
过程 ``inc``, ``dec``, ``succ`` 和 ``pred`` 对于它们不可用。


编译器支持枚举的内置字符串化运算符 ``$`` 。
字符串化的结果可以通过显式给出要使用的字符串值来控制：

.. code-block:: nim

  type
    MyEnum = enum
      valueA = (0, "my value A"),
      valueB = "value B",
      valueC = 2,
      valueD = (3, "abc")

从示例中可以看出，可以通过使用元组指定字段的序数值及其字符串值。
也可以只指定其中一个。

枚举可以使用 ``pure`` 编译指示进行标记，以便将其字段添加到特定模块特定的隐藏作用域，该作用域仅作为最后一次尝试进行查询。
只有没有歧义的符号才会添加到此范围。
但总是可以通过写为 ``MyEnum.value`` 的类型限定来访问:

.. code-block:: nim

  type
    MyEnum {.pure.} = enum
      valueA, valueB, valueC, valueD, amb

    OtherEnum {.pure.} = enum
      valueX, valueY, valueZ, amb


  echo valueA # MyEnum.valueA
  echo amb    # 错误：不清楚它是MyEnum.amb还是OtherEnum.amb
  echo MyEnum.amb # OK.

要使用枚举实现位字段，请参阅 `Bit fields <#set-type-bit-fields>`_

字符串类型
-----------
所有字符串字面值都是 ``string`` 类型。
Nim中的字符串与字符序列非常相似。
但是，Nim中的字符串都是以零结尾的并且具有长度字段。
可以用内置的 ``len`` 过程检索长度;长度永远不会计算终止零。

除非首先将字符串转换为 ``cstring`` 类型，否则无法访问终止零。
终止零确保可以在O(1)中完成此转换，无需任何分配。

字符串的赋值运算符始终复制字符串。 ``&`` 运算符拼接字符串。

大多数原生Nim类型支持使用特殊的 ``$`` proc转换为字符串。

例如，当调用 ``echo`` proc时，会调用参数的内置字符串化操作：

.. code-block:: nim

  echo 3 # 为 `int` 调用 `$` 

每当用户创建一个专门的对象时，该过程的实现提供了 ``string`` 表示。

.. code-block:: nim
  type
    Person = object
      name: string
      age: int

  proc `$`(p: Person): string = # `$` 始终返回字符串
    result = p.name & " is " &
            $p.age & # we *need* the `$` in front of p.age which
                     # is natively an integer to convert it to
                     # a string
            " years old."

虽然也可以使用 ``$ p.name`` ，但字符串上的 ``$`` 操作什么都不做。
请注意，我们不能依赖于从 ``int`` 到 ``string` 的自动转换，就像 ``echo`` proc一样。

字符串按字典顺序进行比较。
所有比较运算符都可用。
字符串可以像数组一样索引（下限为0）。
与数组不同，它们可用于case语句：

.. code-block:: nim

  case paramStr(i)
  of "-v": incl(options, optVerbose)
  of "-h", "-?": incl(options, optHelp)
  else: write(stdout, "invalid command line option!\n")

按照惯例，所有字符串都是UTF-8字符串，但不强制执行。
例如，从二进制文件读取字符串时，它们只是一个字节序列。
索引操作 ``s[i]`` 表示 ``s`` 的第i个 *char* ，而不是第i个 *unichar* 。
来自 `unicode module <unicode.html>`_ 的迭代器 ``runes`` 可用于迭代所有Unicode字符。


cstring类型
------------

``cstring`` 类型意味着 `compatible string` 是编译后端的字符串的原生表示。
对于C后端，``cstring`` 类型表示一个指向零终止char数组的指针，该数组与Ansi C中的 ``char*`` 类型兼容。
其主要目的在于与C轻松互通。
索引操作 ``s [i]`` 表示 ``s`` 的第i个 *char*;但是没有执行检查 ``cstring`` 的边界，使索引操作不安全。

为方便起见，Nim中的 ``string`` 可以隐式转换为 ``cstring`` 。 
如果将Nim字符串传递给C风格的可变参数proc，它也会隐式转换为 ``cstring`` ：

.. code-block:: nim
  proc printf(formatstr: cstring) {.importc: "printf", varargs,
                                    header: "<stdio.h>".}

  printf("This works %s", "as expected")

即使转换是隐式的，它也不是 *安全的* ：垃圾收集器不认为 ``cstring`` 是根，并且可能收集底层内存。
然而在实践中，这几乎从未发生过，因为GC保守地估计堆栈根。
可以使用内置过程 ``GC_ref`` 和 ``GC_unref`` 来保持字符串数据在少数情况下保持活动状态。

为返回字符串的cstrings定义了 `$` proc。因此，从cstring获取一个nim字符串：

.. code-block:: nim
  var str: string = "Hello!"
  var cstr: cstring = str
  var newstr: string = $cstr

结构化类型
----------------
结构化类型的变量可以同时保存多个值。
结构化类型可以嵌套到无限级别。
数组、序列、元组、对象和集合属于结构化类型。

数组和序列类型
------------------------
数组是同类型的，这意味着数组中的每个元素都具有相同的类型。
数组总是具有指定为常量表达式的固定长度（开放数组除外）。
它们可以按任何序数类型索引。
参数 ``A`` 可以是 *开放数组* ，在这种情况下，它由0到 ``len（A）- 1`` 的整数索引。
数组表达式可以由数组构造函数 ``[]`` 构造。
数组表达式的元素类型是从第一个元素的类型推断出来的。
所有其他元素都需要隐式转换为此类型。

序列类似于数组，但动态长度可能在运行时期间发生变化（如字符串）。
序列实现为可增长的数组，在添加项目时分配内存块。
序列 ``S`` 始终用从0到 ``len(S)-1`` 的整数索引，并检查其边界。
序列可以由数组构造函数 ``[]`` 和数组一起构造，以序列运算符 ``@`` 。
为序列分配空间的另一种方法是调用内置的 ``newSeq`` 过程。

序列可以传递给 *开放数组* 类型的参数。

示例：

.. code-block:: nim

  type
    IntArray = array[0..5, int] # an array that is indexed with 0..5
    IntSeq = seq[int] # a sequence of integers
  var
    x: IntArray
    y: IntSeq
  x = [1, 2, 3, 4, 5, 6]  # [] is the array constructor
  y = @[1, 2, 3, 4, 5, 6] # the @ turns the array into a sequence

  let z = [1.0, 2, 3, 4] # the type of z is array[0..3, float]

数组或序列的下限可以由内置的proc ``low()`` 接收，上限由 ``high()`` 接收。
长度可以由 ``len()`` 接收。序列或开放数组的 ``low()`` 总是返回0，因为这是第一个有效索引。
可以使用 ``add()`` proc或 ``&`` 运算符将元素追加到序列中，并使用 ``pop()`` proc删除（并获取）序列的最后一个元素。

符号 ``x [i]`` 可用于访问 ``x`` 的第i个元素。

数组始终是边界检查（静态或运行时）。可以通过编译指示禁用这些检查，或使用 ``--boundChecks：off`` 命令行开关调用编译器。

数组构造函数可以具有可读的显式索引：

.. code-block:: nim

  type
    Values = enum
      valA, valB, valC

  const
    lookupTable = [
      valA: "A",
      valB: "B",
      valC: "C"
    ]

如果省略索引，则使用 ``succ(lastIndex)`` 作为索引值：

.. code-block:: nim

  type
    Values = enum
      valA, valB, valC, valD, valE

  const
    lookupTable = [
      valA: "A",
      "B",
      valC: "C",
      "D", "e"
    ]



开放数组（openarray）
-----------

通常，固定大小的数组太不灵活了;程序应该能够处理不同大小的数组。
`开放数组`:idx: 类型只能用于参数。
开放数组总是从位置0开始用 ``int`` 索引。
``len`` ， ``low`` 和 ``high`` 操作也可用于开放数组。
具有兼容基类型的任何数组都可以传递给开放数组形参，无关索引类型。
除了数组序列之外，还可以将序列传递给开放数组参数。

开放数组类型不能嵌套： 不支持多维开放数组，因为这种需求很少并且不能有效地完成。

.. code-block:: nim
  proc testOpenArray(x: openArray[int]) = echo repr(x)

  testOpenArray([1,2,3])  # array[]
  testOpenArray(@[1,2,3]) # seq[]

可变参数
-------

``varargs`` 参数是一个开放数组参数，它还允许将可变数量的参数传递给过程。
编译器隐式地将参数列表转换为数组：

.. code-block:: nim
  proc myWriteln(f: File, a: varargs[string]) =
    for s in items(a):
      write(f, s)
    write(f, "\n")

  myWriteln(stdout, "abc", "def", "xyz")
  # 转换成:
  myWriteln(stdout, ["abc", "def", "xyz"])

仅当varargs参数是过程头中的最后一个参数时，才会执行此转换。
也可以在此上下文中执行类型转换：

.. code-block:: nim
  proc myWriteln(f: File, a: varargs[string, `$`]) =
    for s in items(a):
      write(f, s)
    write(f, "\n")

  myWriteln(stdout, 123, "abc", 4.0)
  # 转换成:
  myWriteln(stdout, [$123, $"def", $4.0])

在这个例子中， ``$`` 应用于传递给参数 ``a`` 的任何参数。 （注意 ``$`` 对字符串是一个空操作。）


请注意，传递给 ``varargs`` 形参的显式数组构造函数不会隐式地构造另一个隐式数组：

.. code-block:: nim
  proc takeV[T](a: varargs[T]) = discard

  takeV([123, 2, 1]) # takeV的T是"int", 不是"int数组"

``varargs[typed]`` 被特别对待：它匹配任意类型的参数的变量列表，但 *始终* 构造一个隐式数组。 

这是必需的，以便内置的 ``echo`` proc执行预期的操作：

.. code-block:: nim
  proc echo*(x: varargs[typed, `$`]) {...}

  echo @[1, 2, 3]
  # 打印 "@[1, 2, 3]" 而不是 "123"


未检查数组
----------------
``UncheckedArray[T]`` 类型是一种特殊的 ``数组`` ，编译器不检查它的边界。
这对于实现定制灵活大小的数组通常很有用。
另外，未检查数组转换为不确定大小的C数组：

.. code-block:: nim
  type
    MySeq = object
      len, cap: int
      data: UncheckedArray[int]

大致生成C代码:

.. code-block:: C
  typedef struct {
    NI len;
    NI cap;
    NI data[];
  } MySeq;

未检查数组的基本类型可能不包含任何GC内存，但目前尚未检查。

**未来方向**: 应该在未经检查的数组中允许GC内存，并且应该有一个关于GC如何确定数组的运行时大小的显式注释。



元组和对象类型
-----------------------
元组或对象类型的变量是异构存储容器。
元组或对象定义类型的各种命名 *字段* 。
元组还定义了字段的 *顺序* 。
元组用于异构存储类型，没有开销和很少的抽象可能性。
构造函数 ``()`` 可用于构造元组。
构造函数中字段的顺序必须与元组定义的顺序相匹配。
如果它们以相同的顺序指定相同类型的相同字段，则不同的元组类型 *等效* 。字段的 *名称* 也必须相同。

元组的赋值运算符复制每个组件。
对象的默认赋值运算符复制每个组件。
在 `type-bound-operations-operator`_ 中描述了赋值运算符的重载。

.. code-block:: nim

  type
    Person = tuple[name: string, age: int] # 代表人的类型：人由名字和年龄组成
  var
    person: Person
  person = (name: "Peter", age: 30)
  # 一样，但不太可读：
  person = ("Peter", 30)

可以使用括号和尾随逗号构造具有一个未命名字段的元组：

.. code-block:: nim
  proc echoUnaryTuple(a: (int,)) =
    echo a[0]

  echoUnaryTuple (1,)


事实上，每个元组结构都允许使用尾随逗号。

实现将字段对齐以获得最佳访问性能。
对齐与C编译器的方式兼容。

为了与 ``object`` 声明保持一致， ``type`` 部分中的元组也可以用缩进而不是 ``[]`` 来定义：

.. code-block:: nim
  type
    Person = tuple   # 代表人的类型
      name: string   # 人由名字
      age: natural   # 和年龄组成

对象提供了元组不具备的许多功能。
对象提供继承和信息隐藏。
对象在运行时可以访问它们的类型，因此 ``of`` 运算符可用于确定对象的类型。
``of`` 运算符类似于Java中的 ``instanceof`` 运算符。

.. code-block:: nim
  type
    Person = object of RootObj
      name*: string   # *表示可以从其他模块访问`name`
      age: int        # 没有*表示该字段已隐藏

    Student = ref object of Person # 学生是人
      id: int                      # 有个id字段

  var
    student: Student
    person: Person
  assert(student of Student) # is true
  assert(student of Person) # also true

应该从定义模块外部可见的对象字段必须用 ``*`` 标记。
与元组相反，不同的对象类型永远不会 *等价* 。
没有祖先的对象是隐式的 ``final`` ，因此没有隐藏的类型字段。
可以使用 ``inheritable`` pragma来引入除 ``system.RootObj`` 之外的新根对象。


对象构造
-------------------

对象也可以使用 `对象构造表达式` 创建:idx:, 具有语法 ``T（fieldA：valueA，fieldB：valueB，...）`` 其中 ``T`` 是 ``object`` 类型或 ``ref object`` 类型：

.. code-block:: nim
  var student = Student(name: "Anton", age: 5, id: 3)

请注意，与元组不同，对象需要字段名称及其值。
对于 ``ref object`` 类型，``system.new`` 是隐式调用的。


对象变体
---------------
在需要简单变体类型的某些情况下，对象层次结构通常有点过了。
对象变体是通过用于运行时类型灵活性的枚举类型区分的标记联合，对照如在其他语言中找到的 *sum类型* 和 *代数数据类型(ADT)* 的概念。

一个示例：

.. code-block:: nim

  # 这是一个如何在Nim中建模抽象语法树的示例
  type
    NodeKind = enum  # 不同的节点类型
      nkInt,          # 带有整数值的叶节点
      nkFloat,        # 带有浮点值的叶节点
      nkString,       # 带有字符串值的叶节点
      nkAdd,          # 加法
      nkSub,          # 减法
      nkIf            # if语句
    Node = ref NodeObj
    NodeObj = object
      case kind: NodeKind  # ``kind`` 字段是鉴别字段
      of nkInt: intVal: int
      of nkFloat: floatVal: float
      of nkString: strVal: string
      of nkAdd, nkSub:
        leftOp, rightOp: Node
      of nkIf:
        condition, thenPart, elsePart: Node

  # 创建一个新case对象:
  var n = Node(kind: nkIf, condition: nil)
  # 访问n.thenPart是有效的，因为 ``nkIf`` 分支是活动的
  n.thenPart = Node(kind: nkFloat, floatVal: 2.0)

  # 以下语句引发了一个 `FieldError` 异常，因为n.kind的值不合适且 ``nkString`` 分支未激活：
  n.strVal = ""

  # 无效：会更改活动对象分支：
  n.kind = nkInt

  var x = Node(kind: nkAdd, leftOp: Node(kind: nkInt, intVal: 4),
                            rightOp: Node(kind: nkInt, intVal: 2))
  # valid：不更改活动对象分支：
  x.kind = nkSub

从示例中可以看出，对象层次结构的优点是不需要在不同对象类型之间进行转换。
但是，访问无效对象字段会引发异常。

对象声明中 ``case`` 的语法紧跟着 ``case`` 语句的语法： ``case`` 部分中的分支也可以缩进。

在示例中，``kind`` 字段称为 `鉴别字段`:idx: :
为安全起见，不能对其进行地址限制，并且对其赋值受到限制：新值不得导致活动对象分支发生变化。 
此外，在对象构造期间指定特定分支的字段时，必须将相应的鉴别字段值指定为常量表达式。


而不是更改活动对象分支，将内存中的旧对象完全替换为新对象：

.. code-block:: nim

  var x = Node(kind: nkAdd, leftOp: Node(kind: nkInt, intVal: 4),
                            rightOp: Node(kind: nkInt, intVal: 2))
  # 更改节点的内容：
  x[] = NodeObj(kind: nkString, strVal: "abc")


从版本0.20开始 ``system.reset`` 不能再用于支持对象分支的更改，因为这从来就不是完全内存安全的。

作为一项特殊规则，鉴别字段类型也可以使用 ``case`` 语句来限制。
如果 ``case`` 语句分支中的鉴别字段变量的可能值是所选对象分支的鉴别字段值的子集，则初始化被认为是有效的。
此分析仅适用于序数类型的不可变判别符，并忽略 ``elif`` 分支。

A small 示例：

.. code-block:: nim

  let unknownKind = nkSub

  # 无效：不安全的初始化，因为类型字段不是静态已知的：
  var y = Node(kind: unknownKind, strVal: "y")

  var z = Node()
  case unknownKind
  of nkAdd, nkSub:
    # valid：此分支的可能值是nkAdd / nkSub对象分支的子集：
    z = Node(kind: unknownKind, leftOp: Node(), rightOp: Node())
  else:
    echo "ignoring: ", unknownKind

集合类型
--------

.. include:: sets_fragment.txt

引用和指针类型
---------------------------
引用（类似于其他编程语言中的指针）是引入多对一关系的一种方式。
这意味着不同的引用可以指向并修改内存中的相同位置（也称为 ``别名``:idx:)。

Nim区分 `追踪`:idx:和 `未追踪`:idx: 引用。
未追踪引用也叫 *指针* 。 追踪引用指向垃圾回收堆中的对象，未追踪引用指向手动分配对象或内存中其它位置的对象。
因此，未追踪引用是 *不安全* 的。
然而，对于某些低级操作（访问硬件），未追踪引用是不可避免的。

使用 **ref** 关键字声明追踪引用，使用 **ptr** 关键字声明未追踪引用。
通常，`ptr T` 可以隐式转换为 `pointer` 类型。

空的下标 ``[]`` 表示法可以用来取代引用， ``addr`` 程序返回一个对象的地址。
地址始终是未经过引用的参考。
因此， ``addr`` 的使用是 *不安全的* 功能。

``.`` （访问元组和对象字段运算符）和 ``[]`` （数组/字符串/序列索引运算符）运算符对引用类型执行隐式解引用操作：

.. code-block:: nim

  type
    Node = ref NodeObj
    NodeObj = object
      le, ri: Node
      data: int

  var
    n: Node
  new(n)
  n.data = 9
  # 不必写n[].data; 实际上 n[].data是不推荐的！

还对过程调用的第一个参数执行自动解引用。
但是目前这个功能只能通过 ``{.experimental："implicitDeref".}`` 来启用：

.. code-block:: nim
  {.experimental: "implicitDeref".}

  proc depth(x: NodeObj): int = ...

  var
    n: Node
  new(n)
  echo n.depth
  # 也不必写n[].depth



为了简化结构类型检查，递归元组无效：

.. code-block:: nim
  # 无效递归
  type MyTuple = tuple[a: ref MyTuple]

同样， ``T = ref T`` 是无效类型。

作为语法扩展 ``object`` 类型，如果在类型部分中通过 ``ref object`` 或 ``ptr object`` 符号声明，则可以是匿名的。
如果对象只应获取引用语义，则此功能非常有用：

.. code-block:: nim

  type
    Node = ref object
      le, ri: Node
      data: int


要分配新的追踪对象，必须使用内置过程 ``new`` 。
为了处理未追踪的内存，可以使用过程 ``alloc`` ， ``dealloc`` 和 ``realloc`` 。
系统模块的文档包含更多信息。


Nil
---

如果引用指向 *nothing* ，则它具有值 ``nil`` 。 ``nil`` 也是所有 ``ref`` 和 ``ptr`` 类型的默认值。
解除引用 ``nil`` 是一个不可恢复的致命运行时错误。
解除引用操作 ``p []`` 意味着 ``p`` 不是nil。
这可以通过实现来利用，以优化代码，如：


.. code-block:: nim

  p[].field = 3
  if p != nil:
    # 如果p为nil，``p []`` 会导致崩溃，
    # 所以我们知道 ``p`` 总不是nil。
    action()

Into:

.. code-block:: nim

  p[].field = 3
  action()


*注意* ：这与用于解引用NULL指针的C的“未定义行为”不具有可比性。


将GC内存和 ``ptr`` 混用
--------------------------------

如果未追踪对象包含追踪对象（如追踪引用，字符串或序列），则需要特别小心：为了正确释放所有内容，必须在手动释放未追踪内存之前调用内置过程 ``GCunref`` ：

.. code-block:: nim
  type
    Data = tuple[x, y: int, s: string]

  # 为堆上的Data分配内存：
  var d = cast[ptr Data](alloc0(sizeof(Data)))

  # 在垃圾收集堆上创建一个新字符串：
  d.s = "abc"

  # 告诉GC不再需要该字符串：
  GCunref(d.s)

  # 释放内存:
  dealloc(d)

没有 ``GCunref`` 调用，为 ``d.s`` 字符串分配的内存永远不会被释放。
该示例还演示了低级编程的两个重要特性： ``sizeof`` proc以字节为单位返回类型或值的大小。
``cast`` 运算符可以绕过类型系统：编译器被强制处理``alloc0``调用的结果（返回一个无类型的指针），就好像它是 ``ptr Data`` 类型。
只有在不可避免的情况下才能进行强转：它会破坏类型安全性并且错误可能导致隐蔽的崩溃。

**注意**: 该示例仅起作用，因为内存初始化为零（ ``alloc0`` 而不是 ``alloc`` 执行此操作）： ``d.s`` 因此初始化为二进制零，字符串赋值可以处理。
在将垃圾收集数据与非托管内存混合时，需要知道这样的低级细节。

.. XXX finalizers for traced objects


Not nil注解
------------------

``nil`` 是有效值的所有类型都可以注释为使用 ``not nil`` 注释将 ``nil`` 排除：

.. code-block:: nim
  type
    PObject = ref TObj not nil
    TProc = (proc (x, y: int)) not nil

  proc p(x: PObject) =
    echo "not nil"

  # 编译器捕获:
  p(nil)

  # 和这个:
  var x: PObject
  p(x)

编译器确保每个代码路径初始化包含非空指针的变量。此分析的细节仍在此处指定。


过程类型
---------------
过程类型在内部是指向过程的指针。
``nil`` 是过程类型变量的允许值。
Nim使用过程类型来实现 `函数式`:idx: 编程技术。

Examples:

.. code-block:: nim

  proc printItem(x: int) = ...

  proc forEach(c: proc (x: int) {.cdecl.}) =
    ...

  forEach(printItem)  # 无法编译，因为调用约定不同


.. code-block:: nim

  type
    OnMouseMove = proc (x, y: int) {.closure.}

  proc onMouseMove(mouseX, mouseY: int) =
    # 有默认的调用约定
    echo "x: ", mouseX, " y: ", mouseY

  proc setOnMouseMove(mouseMoveEvent: OnMouseMove) = discard

  # 可以, 'onMouseMove'有默认的调用约定，它是兼容的
  # 到 'closure':
  setOnMouseMove(onMouseMove)

过程类型的一个微妙问题是过程的调用约定会影响类型兼容性：过程类型只有在具有相同的调用约定时才是兼容的。
作为一个特殊的扩展，调用约定 ``nimcall`` 的过程可以传递给一个参数，该参数需要调用约定 ``closure`` 的proc。

Nim支持这些 `调用约定`:idx:\：

`nimcall`:idx: 是用于Nim **proc** 的默认约定。它与 ``fastcall`` 相同，但仅适用于支持 ``fastcall`` 的C编译器。

`closure`:idx:
    是缺少任何pragma注释的 **过程类型** 的默认调用约定。
    它表示该过程具有隐藏的隐式形参（*环境*）。
    具有调用约定 ``closure`` 的过程变量占用两个机器字：一个用于proc指针，另一个用于指向隐式传递环境的指针。

`stdcall`:idx:
    这是微软指定的stdcall约定。生成的C过程使用 ``__stdcall`` 关键字声明。

`cdecl`:idx:
    cdecl约定意味着过程应使用与C编译器相同的约定。
    在Windows下，生成的C过程使用 ``__cdecl`` 关键字声明。

`safecall`:idx:
    这是微软指定的safecall约定。
    生成的C过程使用 ``__safecall`` 关键字声明。
    *安全* 一词指的是所有硬件寄存器都应被推送到硬件堆栈。

`inline`:idx:
    内联约定意味着调用者不应该调用该过程，而是直接内联其代码。
    请注意，Nim不是内联的，而是将其留给C编译器;它生成 ``__inline`` 程序。
    这只是编译器的一个提示：编译器可能完全忽略它，它可能内联没有标记为 ``inline`` 的过程。

`fastcall`:idx:
    Fastcall对不同的C编译器意味着不同的东西，不论C的 ``__fastcall`` 意义是什么。

`syscall`:idx:
    系统调用约定与C中的 ``__syscall`` 相同，用于中断。

`noconv`:idx:
    生成的C代码将没有任何显式调用约定，因此使用C编译器的默认调用约定。
    这是必需的，因为Nim对程序的默认调用约定是 ``fastcall`` 来提高速度。

大多数调用约定仅适用于Windows 32位平台。

默认调用约定是 ``nimcall`` ，除非它是内部proc（proc中的proc）。
对于内部过程，无论是否访问其环境，都会执行分析。
如果它这样做，它有调用约定 ``closure`` ，否则它有调用约定 ``nimcall`` 。


Distinct类型
-------------

``distinct`` 类型是从 `基类型`:idx:  派生的新类型与它的基类型不兼容。
特别是，它是一种不同类型的基本属性，它 *并不* 意味着它和基本类型之间的子类型关系。
允许从不同类型到其基本类型的显式类型转换，反之亦然。另请参阅 ``distinctBase`` 以获得逆操作。

如果基类型是序数类型，则不同类型是序数类型。


模拟货币
~~~~~~~~~~~~~~~~~~~~

可以使用不同的类型来模拟不同的物理 ``单位``:idx: 比如具有数字基类型。
以下示例模拟货币。

货币计算中不应混合不同的货币。
不同类型是模拟不同货币的完美工具：

.. code-block:: nim
  type
    Dollar = distinct int
    Euro = distinct int

  var
    d: Dollar
    e: Euro

  echo d + 12
  # 错误：无法添加没有单位的数字和 ``美元``

``d + 12.Dollar`` 也不允许，因为 ``+`` 为 ``int`` (在其它类型之中)定义, 而没有为 ``Dollar`` 定义。 
因此需要定义美元的 ``+`` ：

.. code-block::
  proc `+` (x, y: Dollar): Dollar =
    result = Dollar(int(x) + int(y))

将一美元乘以一美元是没有意义的，但可以不带单位相乘；对除法同样成立：

.. code-block::
  proc `*` (x: Dollar, y: int): Dollar =
    result = Dollar(int(x) * y)

  proc `*` (x: int, y: Dollar): Dollar =
    result = Dollar(x * int(y))

  proc `div` ...

这很快变得乏味。
实现是琐碎的，编译器不应该生成所有这些代码只是为了以后优化它 - 毕竟美元 ``+`` 应该生成与整型 ``+`` 相同的二进制代码。
编译指示 `borrow`:idx: 旨在解决这个问题；原则上它会生成以上的琐碎实现：

.. code-block:: nim
  proc `*` (x: Dollar, y: int): Dollar {.borrow.}
  proc `*` (x: int, y: Dollar): Dollar {.borrow.}
  proc `div` (x: Dollar, y: int): Dollar {.borrow.}

``borrow`` 编译指示使编译器使用与处理distinct类型的基类型的proc相同的实现，因此不会生成任何代码。


但似乎所有这些样板代码都需要为 ``欧元`` 货币重复。这可以通过 模板_ 解决。

.. code-block:: nim
    :test: "nim c $1"

  template additive(typ: typedesc) =
    proc `+` *(x, y: typ): typ {.borrow.}
    proc `-` *(x, y: typ): typ {.borrow.}

    # 一元运算符:
    proc `+` *(x: typ): typ {.borrow.}
    proc `-` *(x: typ): typ {.borrow.}

  template multiplicative(typ, base: typedesc) =
    proc `*` *(x: typ, y: base): typ {.borrow.}
    proc `*` *(x: base, y: typ): typ {.borrow.}
    proc `div` *(x: typ, y: base): typ {.borrow.}
    proc `mod` *(x: typ, y: base): typ {.borrow.}

  template comparable(typ: typedesc) =
    proc `<` * (x, y: typ): bool {.borrow.}
    proc `<=` * (x, y: typ): bool {.borrow.}
    proc `==` * (x, y: typ): bool {.borrow.}

  template defineCurrency(typ, base: untyped) =
    type
      typ* = distinct base
    additive(typ)
    multiplicative(typ, base)
    comparable(typ)

  defineCurrency(Dollar, int)
  defineCurrency(Euro, int)


借用编译指示还可用于注释不同类型以允许某些内置操作被提升：

.. code-block:: nim
  type
    Foo = object
      a, b: int
      s: string

    Bar {.borrow: `.`.} = distinct Foo

  var bb: ref Bar
  new bb
  # 字段访问有效
  bb.a = 90
  bb.s = "abc"

目前只有点访问符可以用这种方式借用。


避免SQL注入攻击
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

从Nim传递到SQL数据库的SQL语句可能被模拟为字符串。
但是，使用字符串模板并填充值很容易受到 `SQL注入攻击`:idx:\:

.. code-block:: nim
  import strutils

  proc query(db: DbHandle, statement: string) = ...

  var
    username: string

  db.query("SELECT FROM users WHERE name = '$1'" % username)
  # 可怕的安全漏洞，但编译没有问题

通过将包含SQL的字符串与不包含SQL的字符串区分开来可以避免这种情况。
不同类型提供了一种引入与 ``string`` 不兼容的新字符串类型 ``SQL`` 的方法：

.. code-block:: nim
  type
    SQL = distinct string

  proc query(db: DbHandle, statement: SQL) = ...

  var
    username: string

  db.query("SELECT FROM users WHERE name = '$1'" % username)
  # 静态错误：`query` 需要一个SQL字符串！


它是抽象类型的基本属性，它们 *并不* 意味着抽象类型与其基类型之间的子类型关系。
允许从 ``string`` 到 ``SQL`` 的显式类型转换：

.. code-block:: nim
  import strutils, sequtils

  proc properQuote(s: string): SQL =
    # 为SQL语句正确引用字符串
    return SQL(s)

  proc `%` (frmt: SQL, values: openarray[string]): SQL =
    # 引用每个论点：
    let v = values.mapIt(SQL, properQuote(it))
    # we need a temporary type for the type conversion :-(
    type StrSeq = seq[string]
    # 调用 strutils.`%`:
    result = SQL(string(frmt) % StrSeq(v))

  db.query("SELECT FROM users WHERE name = '$1'".SQL % [username])

现在我们有针对SQL注入攻击的编译时检查。
因为 ``"".SQL`` 转换为 ``SQL("")`` 不需要新的语法来获得漂亮的 ``SQL`` 字符串字面值。 
假设的 ``SQL`` 类型实际上存在于库中，作为 `db_sqlite <db_sqlite.html>`_ 等模块的 `TSqlQuery类型<db_sqlite.html＃TSqlQuery>`_ 。


自动类型
---------

``auto`` 类型只能用于返回类型和参数。
对于返回类型，它会使编译器从过程体中推断出类型：

.. code-block:: nim
  proc returnsInt(): auto = 1984

对于形参，它现在是创建隐式的泛型例程：

.. code-block:: nim
  proc foo(a, b: auto) = discard

同:

.. code-block:: nim
  proc foo[T1, T2](a: T1, b: T2) = discard

然而，该语言的更高版本可能会将其更改为从方法体 ``推断形参类型`` 。
然后上面的 ``foo`` 将被拒绝，因为形参的类型不能从空的 ``discard`` 语句中推断出来。


类型关系
==============

以下部分定义了描述编译器类型检查所需类型的几个关系。


类型相等性
-------------
Nim对大多数类型使用结构类型等价。
仅对于对象，枚举和不同类型使用名称等价。
*伪代码中* 的以下算法确定类型相等：

.. code-block:: nim
  proc typeEqualsAux(a, b: PType,
                     s: var HashSet[(PType, PType)]): bool =
    if (a,b) in s: return true
    incl(s, (a,b))
    if a.kind == b.kind:
      case a.kind
      of int, intXX, float, floatXX, char, string, cstring, pointer,
          bool, nil, void:
        # 叶类型: 类型等价; 不做更多检查
        result = true
      of ref, ptr, var, set, seq, openarray:
        result = typeEqualsAux(a.baseType, b.baseType, s)
      of range:
        result = typeEqualsAux(a.baseType, b.baseType, s) and
          (a.rangeA == b.rangeA) and (a.rangeB == b.rangeB)
      of array:
        result = typeEqualsAux(a.baseType, b.baseType, s) and
                 typeEqualsAux(a.indexType, b.indexType, s)
      of tuple:
        if a.tupleLen == b.tupleLen:
          for i in 0..a.tupleLen-1:
            if not typeEqualsAux(a[i], b[i], s): return false
          result = true
      of object, enum, distinct:
        result = a == b
      of proc:
        result = typeEqualsAux(a.parameterTuple, b.parameterTuple, s) and
                 typeEqualsAux(a.resultType, b.resultType, s) and
                 a.callingConvention == b.callingConvention

  proc typeEquals(a, b: PType): bool =
    var s: HashSet[(PType, PType)] = {}
    result = typeEqualsAux(a, b, s)

由于类型可以是有环图，因此上述算法需要辅助集合 ``s`` 来检测这种情况


类型相等与类型区分
-------------------------------------

以下算法（伪代码）确定两种类型是否相等而不是 ``不同`` 类型。
为简洁起见，省略了辅助集 ``s`` 的循环检查：

.. code-block:: nim
  proc typeEqualsOrDistinct(a, b: PType): bool =
    if a.kind == b.kind:
      case a.kind
      of int, intXX, float, floatXX, char, string, cstring, pointer,
          bool, nil, void:
        # leaf type: kinds identical; nothing more to check
        result = true
      of ref, ptr, var, set, seq, openarray:
        result = typeEqualsOrDistinct(a.baseType, b.baseType)
      of range:
        result = typeEqualsOrDistinct(a.baseType, b.baseType) and
          (a.rangeA == b.rangeA) and (a.rangeB == b.rangeB)
      of array:
        result = typeEqualsOrDistinct(a.baseType, b.baseType) and
                 typeEqualsOrDistinct(a.indexType, b.indexType)
      of tuple:
        if a.tupleLen == b.tupleLen:
          for i in 0..a.tupleLen-1:
            if not typeEqualsOrDistinct(a[i], b[i]): return false
          result = true
      of distinct:
        result = typeEqualsOrDistinct(a.baseType, b.baseType)
      of object, enum:
        result = a == b
      of proc:
        result = typeEqualsOrDistinct(a.parameterTuple, b.parameterTuple) and
                 typeEqualsOrDistinct(a.resultType, b.resultType) and
                 a.callingConvention == b.callingConvention
    elif a.kind == distinct:
      result = typeEqualsOrDistinct(a.baseType, b)
    elif b.kind == distinct:
      result = typeEqualsOrDistinct(a, b.baseType)


子类型关系
----------------
如果对象 ``a`` 继承自 ``b``, ``a`` 是 ``b`` 的类型。 
这种了类型关系扩展到 ``var``, ``ref``, ``ptr`` :

.. code-block:: nim
  proc isSubtype(a, b: PType): bool =
    if a.kind == b.kind:
      case a.kind
      of object:
        var aa = a.baseType
        while aa != nil and aa != b: aa = aa.baseType
        result = aa == b
      of var, ref, ptr:
        result = isSubtype(a.baseType, b.baseType)

.. XXX nil is a special value!

可转换关系
--------------------
类型 ``a`` 可 **隐式** 转换到类型 ``b`` 如果下列算法返回真：

.. code-block:: nim

  proc isImplicitlyConvertible(a, b: PType): bool =
    if isSubtype(a, b) or isCovariant(a, b):
      return true
    case a.kind
    of int:     result = b in {int8, int16, int32, int64, uint, uint8, uint16,
                               uint32, uint64, float, float32, float64}
    of int8:    result = b in {int16, int32, int64, int}
    of int16:   result = b in {int32, int64, int}
    of int32:   result = b in {int64, int}
    of uint:    result = b in {uint32, uint64}
    of uint8:   result = b in {uint16, uint32, uint64}
    of uint16:  result = b in {uint32, uint64}
    of uint32:  result = b in {uint64}
    of float:   result = b in {float32, float64}
    of float32: result = b in {float64, float}
    of float64: result = b in {float32, float}
    of seq:
      result = b == openArray and typeEquals(a.baseType, b.baseType)
    of array:
      result = b == openArray and typeEquals(a.baseType, b.baseType)
      if a.baseType == char and a.indexType.rangeA == 0:
        result = b == cstring
    of cstring, ptr:
      result = b == pointer
    of string:
      result = b == cstring


Nim为 ``范围`` 类型构造函数执行了隐式转换。

设 ``a0``, ``b0`` 为类型 ``T``.

设 ``A = range[a0..b0]`` 为实参类型, ``F`` 正式的形参类型。
从 ``A`` 到 ``F`` 存在隐式转换，如果 ``a0 >= low(F) 且 b0 <= high(F)`` 且 ``T`` 各 ``F`` 是有符号或无符号整型。

如果以下算法返回true，则类型 ``a``  可 **显式** 转换为类型 ``b`` ：

.. code-block:: nim
  proc isIntegralType(t: PType): bool =
    result = isOrdinal(t) or t.kind in {float, float32, float64}

  proc isExplicitlyConvertible(a, b: PType): bool =
    result = false
    if isImplicitlyConvertible(a, b): return true
    if typeEqualsOrDistinct(a, b): return true
    if isIntegralType(a) and isIntegralType(b): return true
    if isSubtype(a, b) or isSubtype(b, a): return true

可转换关系可以通过用户定义的类型 `converter`:idx: 来放宽。

.. code-block:: nim
  converter toInt(x: char): int = result = ord(x)

  var
    x: int
    chr: char = 'a'

  # 隐式转换发生在这里
  x = chr
  echo x # => 97
  # 你也可以使用显式转换
  x = chr.toInt
  echo x # => 97

如果 ``a`` 是左值并且 ``typeEqualsOrDistinct(T, type(a))`` 成立， 类型转换 ``T(a)`` 也是左值。


赋值兼容性
------------------------

表达式 ``b`` 可以赋给表达式 ``a`` 如果 ``a`` 是 `左值` 并且 ``isImplicitlyConvertible(b.typ, a.typ)`` 成立。


重载解析
======================

在调用 ``p(args)`` 中选择匹配最佳的例程 ``p`` 。 
如果多个例程同样匹配，则在语义分析期间报告歧义。

args中的每个arg都需要匹配。参数可以匹配的方式有多种不同的类别。
设 ``f`` 是形式参数的类型， ``a`` 是参数的类型。

1. 准确匹配: ``a`` 和 ``f`` 是相同类型。
2. 字面匹配: ``a`` is an integer literal of value ``v`` and ``f`` is a signed or unsigned integer type and ``v`` is in ``f``'s range. 
   Or:  ``a`` is a floating point literal of value ``v`` and ``f`` is a floating point type and ``v`` is in ``f``'s range.
3. 泛型匹配: ``f`` 是泛型类型且 ``a`` 匹配, 例如 ``a`` 是 ``int`` 且 ``f`` 是泛型限制 (受限) 形参类型 (像 ``[T]`` 或 ``[T: int|char]``.
4. 子范围或子类型匹配： ``a`` is a ``range[T]`` and ``T`` matches ``f`` exactly. Or: ``a`` is a subtype of ``f``.
5. 整数转换匹配: ``a`` 可转换为 ``f`` 且 ``f`` 和 ``a`` 是同样的整数或浮点类型。
6. 转换匹配: ``a`` 可能通过用户定义的转换器转换为 ``f`` 。

这些匹配类别具有优先级：完全匹配优于字面值匹配，并且优于通用匹配等。
在下面的 ``count(p, m)`` 计算 ``m`` 匹配过程 ``p`` 的匹配数。

A routine ``p`` matches better than a routine ``q`` if the following
algorithm returns true::

  for each matching category m in ["exact match", "literal match",
                                  "generic match", "subtype match",
                                  "integral match", "conversion match"]:
    if count(p, m) > count(q, m): return true
    elif count(p, m) == count(q, m):
      discard "continue with next category m"
    else:
      return false
  return "ambiguous"


一些示例：

.. code-block:: nim
  proc takesInt(x: int) = echo "int"
  proc takesInt[T](x: T) = echo "T"
  proc takesInt(x: int16) = echo "int16"

  takesInt(4) # "int"
  var x: int32
  takesInt(x) # "T"
  var y: int16
  takesInt(y) # "int16"
  var z: range[0..4] = 0
  takesInt(z) # "T"


如果算法返回 "歧义" 则执行进一步消歧:
如果参数 ``a`` 通过子类型关系匹配 ``p`` 的参数类型 ``f`` 和 ``q`` 的 ``g`` ，则考虑继承深度：

.. code-block:: nim
  type
    A = object of RootObj
    B = object of A
    C = object of B

  proc p(obj: A) =
    echo "A"

  proc p(obj: B) =
    echo "B"

  var c = C()
  # not ambiguous, calls 'B', not 'A' since B is a subtype of A
  # but not vice versa:
  p(c)

  proc pp(obj: A, obj2: B) = echo "A B"
  proc pp(obj: B, obj2: A) = echo "B A"

  # but this is ambiguous:
  pp(c, c)


同样，对于通用匹配，匹配的结果中首选最特化的泛型类型：

.. code-block:: nim
  proc gen[T](x: ref ref T) = echo "ref ref T"
  proc gen[T](x: ref T) = echo "ref T"
  proc gen[T](x: T) = echo "T"

  var ri: ref int
  gen(ri) # "ref T"


基于 'var T' 的重载
----------------------------

如果形式参数 ``f`` 是除了普通类型检查外的 ``var T`` 类型， 则检查实参是否 `左值`:idx: 。
``var T`` 比 ``T`` 更好地匹配。

.. code-block:: nim
  proc sayHi(x: int): string =
    # 匹配非var整型
    result = $x
  proc sayHi(x: var int): string =
    # 匹配var整型
    result = $(x + 10)

  proc sayHello(x: int) =
    var m = x # 可改变的x
    echo sayHi(x) # 匹配sayHi的非var版本
    echo sayHi(m) # 匹配sayHi的var版本

  sayHello(3) # 3
              # 13


无类型的延迟类型解析
--------------------------------

**注意**: `未解析`:idx: 表达式是为没有执行符号查找和类型检查的表达式。

由于未声明为 ``立即`` 的模板和宏参与重载分析，因此必须有一种方法将未解析的表达式传递给模板或宏。

.. code-block:: nim
  template rem(x: untyped) = discard

  rem unresolvedExpression(undeclaredIdentifier)

``untyped`` 类型的参数总是匹配任何参数（只要有任何参数传递给它）。


但是必须注意，因为其他重载可能触发参数的解析：

.. code-block:: nim
  template rem(x: untyped) = discard
  proc rem[T](x: T) = discard

  # 未声明的标识符：'unresolvedExpression'
  rem unresolvedExpression(undeclaredIdentifier)

``untyped`` 和 ``varargs [untyped]`` 是这种意义上唯一的惰性元类型，其他元类型 ``typed`` 和 ``typedesc`` 并不是惰性的。


可变参数匹配
----------------

见 `Varargs <#types-varargs>`_.


语句和表达式
==========================

Nim使用通用语句/表达式范例：与表达式相比，语句不会产生值。
但是，有些表达式是语句。

语句分为 `简单语句`:idx: 和 `复杂语句`:idx: 。
简单语句是不能包含像赋值，调用或者 ``return`` 的语句； 复杂语句可以包含其它语句。 
为了避免 `dangling else问题`:idx:, 复杂语句必须缩进。 
细节可以在语法中找到。


语句列表表达式
-------------------------
 
语句也可以出现在类似于 ``(stmt1; stmt2; ...; ex)`` 的表达式上下文中。
语句也可以出现在表达式上下文中。
这叫做语句列表表达式或 ``(;)`` 。
``(stmt1; stmt2; ...; ex)`` 的类型是 ``ex`` 的类型。
所有其他语句必须是 ``void`` 类型。  
(可以用 ``discard`` 生成 ``void`` 类型。) ``(;)`` 不引入新作用域。


Discard表达式
-----------------

示例:

.. code-block:: nim
  proc p(x, y: int): int =
    result = x + y

  discard p(3, 4) # 丢弃 `p` 的返回值

``discard`` 语句评估其副作用的表达式，并丢弃表达式的结果。

在不使用discard语句的情况下忽略过程的返回值是一个静态错误。

如果使用 `discardable`:idx: 编译指示声明了被调用的proc或iterator，则可以隐式忽略返回值：

.. code-block:: nim
  proc p(x, y: int): int {.discardable.} =
    result = x + y

  p(3, 4) # now valid

空 ``discard`` 语句通常用作null语句:

.. code-block:: nim
  proc classify(s: string) =
    case s[0]
    of SymChars, '_': echo "an identifier"
    of '0'..'9': echo "a number"
    else: discard


Void上下文
------------

在语句列表中，除最后一个表达式之外的每个表达式都需要具有类型 ``void`` 。
除了这个规则之外，对内置 ``result`` 符号的赋值也会触发后续表达式的强制 ``void`` 上下文：

.. code-block:: nim
  proc invalid*(): string =
    result = "foo"
    "invalid"  # 错误: 'string' 类型值必须丢弃

.. code-block:: nim
  proc valid*(): string =
    let x = 317
    "valid"


Var语句
-------------

Var语句声明新的局部变量和全局变量并初始化它们。
逗号分隔的变量列表可用于指定相同类型的变量：

.. code-block:: nim

  var
    a: int = 0
    x, y, z: int

如果给出初始值设定项，则可以省略该类型：该变量的类型与初始化表达式的类型相同。
如果没有初始化表达式，变量总是使用默认值初始化。
默认值取决于类型，并且在二进制中始终为零。

============================    ==============================================
类型                             默认值
============================    ==============================================
any integer type                0
any float                       0.0
char                            '\\0'
bool                            false
ref or pointer type             nil
procedural type                 nil
sequence                        ``@[]``
string                          ``""``
tuple[x: A, y: B, ...]          (default(A), default(B), ...)
                                (analogous for objects)
array[0..., T]                  [default(T), ...]
range[T]                        default(T); this may be out of the valid range
T = enum                        cast[T](0); this may be an invalid value
============================    ==============================================


出于优化原因，可以使用 `noinit`:idx: 编译指示来避免隐式初始化:

.. code-block:: nim
  var
    a {.noInit.}: array[0..1023, char]

如果一个proc用 ``noinit`` 编译指示注释，则指的是它隐含的 ``result`` 变量：

.. code-block:: nim
  proc returnUndefinedValue: int {.noinit.} = discard


隐式初始化可以用 `requiresInit`:idx: 类型编译指示阻止。 
编译器需要对对象及其所有字段进行显式初始化。
然而它执行 `控制流分析`:idx: 证明变量已经初始化并且不依赖于语法属性：

.. code-block:: nim
  type
    MyObject = object {.requiresInit.}

  proc p() =
    # 以下内容有效：
    var x: MyObject
    if someCondition():
      x = a()
    else:
      x = a()
    # use x


Let语句
-------------

``let`` 语句声明了新的本地和全局 `单次赋值`:idx: 变量并绑定值。
语法与 ``var`` 语句的语法相同，只是关键字 ``var`` 被替换为关键字 ``let`` 。
Let变量不是左值因此不能传递给 ``var`` 参数，也不能采用它们的地址。他们无法分配新值。

对于let变量，可以使用与普通变量相同的编译指示。


元组解包
---------------

在 ``var`` 或 ``let`` 语句中可以执行元组解包。 
特殊标识符 ``_`` 可以用来忽略元组的某些部分：

.. code-block:: nim
    proc returnsTuple(): (int, int, int) = (4, 2, 3)

    let (x, _, z) = returnsTuple()



常量段
-------------

const部分声明其值为常量表达式的常量：

.. code-block::
  import strutils
  const
    roundPi = 3.1415
    constEval = contains("abc", 'b') # computed at compile time!

声明后，常量符号可用作常量表达式。

详见 `Constants and Constant Expressions <#constants-and-constant-expressions>`_ 。

静态语句和表达式
---------------------------

静态语句/表达式显式需要编译时执行。
甚至一些具有副作用的代码也允许在静态块中：

.. code-block::

  static:
    echo "echo at compile time"

在编译时可以执行哪些Nim代码存在限制;
详见 `Restrictions on Compile-Time Execution <#restrictions-on-compileminustime-execution>`_ 。
如果编译器无法在编译时执行块，那么这是一个静态错误。


If语句
------------

示例：

.. code-block:: nim

  var name = readLine(stdin)

  if name == "Andreas":
    echo "What a nice name!"
  elif name == "":
    echo "Don't you have a name?"
  else:
    echo "Boring name..."

``if`` 语句是在控制流中创建分支的简单方法：计算关键字 ``if`` 之后的表达式，如果为真，则执行 ``:`` 之后的相应语句。
这一直持续到最后一个 ``elif`` 。
如果所有条件都失败，则执行 ``else`` 部分。
如果没有 ``else`` 部分，则继续执行下一个语句。

在 ``if`` 语句中，新的作用域在 ``if`` 或 ``elif`` 或 ``else`` 关键字之后立即开始，并在相应的 *then* 块之后结束。

出于可视化目的，作用域已包含在 ``{| |}`` 在以下示例中

示例：

.. code-block:: nim
  if {| (let m = input =~ re"(\w+)=\w+"; m.isMatch):
    echo "key ", m[0], " value ", m[1]  |}
  elif {| (let m = input =~ re""; m.isMatch):
    echo "new m in this scope"  |}
  else: {|
    echo "m not declared here"  |}

Case语句
--------------

示例:

.. code-block:: nim

  case readline(stdin)
  of "delete-everything", "restart-computer":
    echo "permission denied"
  of "go-for-a-walk":     echo "please yourself"
  else:                   echo "unknown command"

  # 允许分支缩进; 冒号也是可选的
  # 在选择表达式后:
  case readline(stdin):
    of "delete-everything", "restart-computer":
      echo "permission denied"
    of "go-for-a-walk":     echo "please yourself"
    else:                   echo "unknown command"


``case`` 语句类似于if语句，但它表示多分支选择。

评估关键字 ``case`` 之后的表达式，如果它的值在 *slicelist* 中，则执行在 ``of`` 关键字之后的相应语句。

如果该值不在任何给定的 *slicelist* 中，则执行 ``else`` 部分。
如果没有 ``else`` 部分而且 ``expr`` 可以保持在 ``slicelist`` 中的所有可能值，则会发生静态错误。
这仅适用于序数类型的表达式。
``expr`` 的“所有可能的值”由 ``expr`` 的类型决定。
为了阻止静态错误，应该使用带有空 ``discard`` 语句的 ``else`` 部分。

对于非序数类型，不可能列出每个可能的值，因此这些值总是需要 ``else`` 部分。

因为在语义分析期间检查case语句的详尽性，所以每个 ``of`` 分支中的值必须是常量表达式。
此限制还允许编译器生成更高性能的代码。

作为一种特殊的语义扩展，case语句的 ``of`` 分支中的表达式可以计算为集合或数组构造函数;然后将集合或数组扩展为其元素列表：

.. code-block:: nim
  const
    SymChars: set[char] = {'a'..'z', 'A'..'Z', '\x80'..'\xFF'}

  proc classify(s: string) =
    case s[0]
    of SymChars, '_': echo "an identifier"
    of '0'..'9': echo "a number"
    else: echo "other"

  # is equivalent to:
  proc classify(s: string) =
    case s[0]
    of 'a'..'z', 'A'..'Z', '\x80'..'\xFF', '_': echo "an identifier"
    of '0'..'9': echo "a number"
    else: echo "other"


When语句
--------------

示例：

.. code-block:: nim

  when sizeof(int) == 2:
    echo "running on a 16 bit system!"
  elif sizeof(int) == 4:
    echo "running on a 32 bit system!"
  elif sizeof(int) == 8:
    echo "running on a 64 bit system!"
  else:
    echo "cannot happen!"

``when`` 语句几乎与 ``if`` 语句完全相同，但有一些例外：

* 每个条件 (``expr``) 必须是一个类型为 ``bool`` 的常量表达式。
* 语句不打开新作用域。
* 属于计算结果为true的表达式的语句由编译器翻译，其他语句不检查语义。

``when`` 语句启用条件编译技术。
作为一种特殊的语法扩展，``when`` 结构也可以在 ``object`` 定义中使用。


When nimvm语句
--------------------

``nimvm`` 是一个特殊的符号，可以用作 ``when nimvm`` 语句的表达式来区分编译时和可执行文件之间的执行路径。

示例：

.. code-block:: nim
  proc someProcThatMayRunInCompileTime(): bool =
    when nimvm:
      # 编译时采用这个分支。
      result = true
    else:
      # 可执行文件中采用这个分支
      result = false
  const ctValue = someProcThatMayRunInCompileTime()
  let rtValue = someProcThatMayRunInCompileTime()
  assert(ctValue == true)
  assert(rtValue == false)

``when nimvm`` 语句必须满足以下要求：

* 它的表达式必须是 ``nimvm`` 。不允许更多的复杂表达式。
* 它必须不含有 ``elif`` 分支。
* 必须含有 ``else`` 分支。
* 分支中的代码不得影响 ``when nimvm`` 语句后面的代码的语义。例如它不能定义后续代码中使用的符号。

Return语句
----------------

示例：

.. code-block:: nim
  return 40+2

``return`` 语句结束当前过程的执行。

它只允许在程序中使用。如果有一个 ``expr`` ，这是一个语法糖：

.. code-block:: nim
  result = expr
  return result


如果proc有返回类型，没有表达式的 ``return`` 是 ``return result`` 的简短表示法。
`result`:idx: 变量始终是过程的返回值。
它由编译器自动声明。
作为所有变量， ``result`` 被初始化为（二进制）零：

.. code-block:: nim
  proc returnZero(): int =
    # 隐式返回0


Yield语句
---------------

示例：

.. code-block:: nim
  yield (1, 2, 3)

在迭代器中使用 ``yield`` 语句而不是 ``return`` 语句。
它仅在迭代器中有效。执行返回到调用迭代器的for循环体。
Yield不会结束迭代过程，但是如果下一次迭代开始，则执行会返回到迭代器。
有关更多信息，请参阅有关迭代器 (`迭代器和for语句`_) 的部分。


Block语句
---------------

示例：

.. code-block:: nim
  var found = false
  block myblock:
    for i in 0..3:
      for j in 0..3:
        if a[j][i] == 7:
          found = true
          break myblock # 离开两个for循环块
  echo found

块语句是一种将语句分组到（命名） ``block`` 的方法。
在块内，允许 ``break`` 语句立即离开块。
``break`` 语句可以包含周围块的名称，以指定要离开的块。


Break语句
---------------

示例：

.. code-block:: nim
  break

``break``语句用于立即离开块。
如果给出 ``symbol`` ，则它是要离开的封闭块的名称。
如果不存在，则离开最里面的块。


While语句
---------------

示例：

.. code-block:: nim
  echo "Please tell me your password:"
  var pw = readLine(stdin)
  while pw != "12345":
    echo "Wrong password! Next try:"
    pw = readLine(stdin)

执行 ``while`` 语句直到 ``expr`` 计算结果为false。
无尽的循环没有错误。
``while`` 语句打开一个 '隐式块'，这样它们就可以用 ``break`` 语句离开。


Continue语句
------------------

一个 ``continue`` 语句导致周围循环结构的下一次迭代。
它只允许在一个循环中。 continue语句是嵌套块的语法糖：

.. code-block:: nim
  while expr1:
    stmt1
    continue
    stmt2

Is equivalent to:

.. code-block:: nim
  while expr1:
    block myBlockName:
      stmt1
      break myBlockName
      stmt2


汇编语句
-------------------

不安全的 ``asm`` 语句支持将汇编程序代码直接嵌入到Nim代码中。

汇编程序代码中引用Nim标识符的标识符应包含在特殊字符中，该字符可在语句的编译指示中指定。默认的特殊字符是 ``'`'``  ：

.. code-block:: nim
  {.push stackTrace:off.}
  proc addInt(a, b: int): int =
    # a in eax, and b in edx
    asm """
        mov eax, `a`
        add eax, `b`
        jno theEnd
        call `raiseOverflow`
      theEnd:
    """
  {.pop.}

如果使用GNU汇编器，则会自动插入引号和换行符：

.. code-block:: nim
  proc addInt(a, b: int): int =
    asm """
      addl %%ecx, %%eax
      jno 1
      call `raiseOverflow`
      1:
      :"=a"(`result`)
      :"a"(`a`), "c"(`b`)
    """

替代:

.. code-block:: nim
  proc addInt(a, b: int): int =
    asm """
      "addl %%ecx, %%eax\n"
      "jno 1\n"
      "call `raiseOverflow`\n"
      "1: \n"
      :"=a"(`result`)
      :"a"(`a`), "c"(`b`)
    """

Using语句
---------------

using语句在模块中反复使用相同的参数名称和类型提供了语法上的便利。
Instead of:

.. code-block:: nim
  proc foo(c: Context; n: Node) = ...
  proc bar(c: Context; n: Node, counter: int) = ...
  proc baz(c: Context; n: Node) = ...

可以告诉编译器关于名称 ``c`` 的参数应默认键入 ``Context`` ，``n`` 应该默认为 ``Node`` 等的约定：

.. code-block:: nim
  using
    c: Context
    n: Node
    counter: int

  proc foo(c, n) = ...
  proc bar(c, n, counter) = ...
  proc baz(c, n) = ...

  proc mixedMode(c, n; x, y: int) =
    # 'c' 被推断为 'Context' 类型
    # 'n' 被推断为 'Node' 类型
    # 'x' and 'y' 是 'int' 类型。

``using`` 部分使用相同的基于缩进的分组语法作为 ``var`` 或 ``let`` 部分。

请注意， ``using`` 不适用于 ``template`` ，因为无类型模板参数默认为类型 ``system.untyped`` 。

应该使用 ``using`` 声明和明确键入的参数混合参数，它们之间需要分号。


If表达式
-------------

`if表达式` 几乎就像一个if语句，但它是一个表达式。
示例：

.. code-block:: nim
  var y = if x > 8: 9 else: 10

if表达式总是会产生一个值，所以 ``else`` 部分是必需的。 ``Elif`` 部分也是允许的。

When表达式
---------------

就像 `if表达式` ，但对应于when语句。

Case表达式
---------------

`case表达式` 与case语句非常相似：

.. code-block:: nim
  var favoriteFood = case animal
    of "dog": "bones"
    of "cat": "mice"
    elif animal.endsWith"whale": "plankton"
    else:
      echo "I'm not sure what to serve, but everybody loves ice cream"
      "ice cream"

如上例所示，case表达式也可以引入副作用。
当为分支给出多个语句时，Nim将使用最后一个表达式作为结果值。

Block表达式
----------------

`block表达式` 几乎就像一个块语句，但它是一个表达式，它使用块下的最后一个表达式作为值。
它类似于语句列表表达式，但语句列表表达式不会打开新的块作用域。

.. code-block:: nim
  let a = block:
    var fib = @[0, 1]
    for i in 0..10:
      fib.add fib[^1] + fib[^2]
    fib

Table构造函数
-----------------

表构造函数是数组构造函数的语法糖：

.. code-block:: nim
  {"key1": "value1", "key2", "key3": "value2"}

  # is the same as:
  [("key1", "value1"), ("key2", "value2"), ("key3", "value2")]


空表可以写成 ``{:}`` （与 ``{}`` 的空集相反，这是另一种写为空数组构造函数 ``[]`` 的方法。
这种略微不同寻常的支持表的方式有很多优点：

* 保留了（键，值）对的顺序，因此很容易支持有序的字典，例如 ``{key：val}.newOrderedTable`` 。
* 表字面值可以放入 ``const`` 部分，编译器可以很容易地将它放入可执行文件的数据部分，就像数组一样，生成的数据部分需要最少的内存。
* 每个表实现在语法上都是一样的。
* 除了最小的语法糖之外，语言核心不需要了解表。


类型转换
----------------
语法上， `类型转换` 类似于过程调用，但类型名称替换过程名称。

类型转换总是安全的，因为将类型转换为另一个类型失败会导致异常（如果无法静态确定）。

普通的procs通常比Nim中的类型转换更受欢迎：例如， ``$`` 是 ``toString`` 运算符，而 ``toFloat`` 和 ``toInt`` 可用于从浮点转换为整数，反之亦然。

类型转换也可用于消除重载例程的歧义：

.. code-block:: nim

  proc p(x: int) = echo "int"
  proc p(x: string) = echo "string"

  let procVar = (proc(x: string))(p)
  procVar("a")


类型强转
----------
示例：

.. code-block:: nim
  cast[int](x)

类型强转是一种粗暴的机制，用于解释表达式的位模式，就好像它将是另一种类型一样。
类型强转仅用于低级编程，并且本质上是不安全的。


addr操作符
-----------------

``addr`` 运算符返回左值的地址。
如果位置的类型是 ``T`` ，则 `addr` 运算符结果的类型为 ``ptr T`` 。
地址是未追踪引用。
获取驻留在堆栈上的对象的地址是 *不安全的* ，因为指针可能比堆栈中的对象存在更久，因此可以引用不存在的对象。

可以获取变量的地址，但是不能在通过 ``let`` 语句声明的变量上使用它：

.. code-block:: nim

  let t1 = "Hello"
  var
    t2 = t1
    t3 : pointer = addr(t2)
  echo repr(addr(t2))
  # --> ref 0x7fff6b71b670 --> 0x10bb81050"Hello"
  echo cast[ptr string](t3)[]
  # --> Hello
  # 下面的行不能编译：
  echo repr(addr(t1))
  # 错误: 表达式没有地址


unsafeAddr操作符
-----------------------

为了更容易与其他编译语言（如C）的互操作性，检索 ``let`` 变量的地址，参数或 ``for`` 循环变量，可以使用 ``unsafeAddr`` 操作：

.. code-block:: nim

  let myArray = [1, 2, 3]
  foreignProcThatTakesAnAddr(unsafeAddr myArray)


过程
==========

大多数编程语言称之为 `methods`:idx: 或 `functions`:idx: 在Nim中称为 `过程`:idx: 。
过程声明由标识符，零个或多个形式参数，返回值类型和代码块组成。

正式参数声明为由逗号或分号分隔的标识符列表。
形参由 ``: 类型名称`` 给出一个类型。 

该类型适用于紧接其之前的所有参数，直到达到参数列表的开头，分号分隔符或已经键入的参数。

分号可用于使类型和后续标识符的分隔更加清晰。

.. code-block:: nim
  # 只使用逗号
  proc foo(a, b: int, c, d: bool): int

  # 使用分号进行视觉区分
  proc foo(a, b: int; c, d: bool): int

  # 会失败：a是无类型的，因为 ';' 停止类型传播。
  proc foo(a; b: int; c, d: bool): int

可以使用默认值声明参数，如果调用者没有为参数提供值，则使用该默认值。

.. code-block:: nim
  # b is optional with 47 as its default value
  proc foo(a: int, b: int = 47): int

参数可以声明为可变的，因此允许proc通过使用类型修饰符 `var` 来修改这些参数。

.. code-block:: nim
  # 通过第二个参数 ``返回`` 一个值给调用者
  # 请注意，该函数根本不使用实际返回值（即void）
  proc foo(inp: int, outp: var int) =
    outp = inp + 47

如果proc声明没有正文，则它是一个 `前向`:idx: 声明。
如果proc返回一个值，那么过程体可以访问一个名为 `result` 的隐式声明的变量。

过程可能会重载。
重载解析算法确定哪个proc是参数的最佳匹配。

示例：

.. code-block:: nim

  proc toLower(c: char): char = # toLower for characters
    if c in {'A'..'Z'}:
      result = chr(ord(c) + (ord('a') - ord('A')))
    else:
      result = c

  proc toLower(s: string): string = # 字符串toLower
    result = newString(len(s))
    for i in 0..len(s) - 1:
      result[i] = toLower(s[i]) # calls toLower for characters; no recursion!

调用过程可以通过多种方式完成：

.. code-block:: nim
  proc callme(x, y: int, s: string = "", c: char, b: bool = false) = ...

  # call with positional arguments      # parameter bindings:
  callme(0, 1, "abc", '\t', true)       # (x=0, y=1, s="abc", c='\t', b=true)
  # call with named and positional arguments:
  callme(y=1, x=0, "abd", '\t')         # (x=0, y=1, s="abd", c='\t', b=false)
  # call with named arguments (order is not relevant):
  callme(c='\t', y=1, x=0)              # (x=0, y=1, s="", c='\t', b=false)
  # call as a command statement: no () needed:
  callme 0, 1, "abc", '\t'              # (x=0, y=1, s="abc", c='\t', b=false)

过程可以递归地调用自身。

`运算符`:idx: 是具有特殊运算符符号作为标识符的过程：

.. code-block:: nim
  proc `$` (x: int): string =
    # 将整数转换为字符串;这是一个前缀运算符。
    result = intToStr(x)

具有一个参数的运算符是前缀运算符，具有两个参数的运算符是中缀运算符。
（但是，解析器将这些与运算符在表达式中的位置区分开来。）
没有办法声明后缀运算符：所有后缀运算符都是内置的，并由语法显式处理。

任何运算符都可以像普通的proc一样用 '`opr`' 表示法调用。（因此运算符可以有两个以上的参数）：

.. code-block:: nim
  proc `*+` (a, b, c: int): int =
    # Multiply and add
    result = a * b + c

  assert `*+`(3, 4, 6) == `+`(`*`(a, b), c)


导出标记
-------------

如果声明的符号标有 `asterisk`:idx: 它从当前模块导出：

.. code-block:: nim

  proc exportedEcho*(s: string) = echo s
  proc `*`*(a: string; b: int): string =
    result = newStringOfCap(a.len * b)
    for i in 1..b: result.add a

  var exportedVar*: int
  const exportedConst* = 78
  type
    ExportedType* = object
      exportedField*: int


方法调用语法
------------------

对于面向对象的编程，可以使用语法 ``obj.method(args)`` 而不是 ``method(obj, args)`` 。

如果没有剩余的参数，则可以省略括号： ``obj.len`` (而不是 ``len(obj)`` )。

此方法调用语法不限于对象，它可用于为过程提供任何类型的第一个参数：

.. code-block:: nim

  echo "abc".len # 与echo len"abc"相同
  echo "abc".toUpper()
  echo {'a', 'b', 'c'}.card
  stdout.writeLine("Hallo") # 与相同writeLine(stdout，"Hallo")

查看方法调用语法的另一种方法是它提供了缺少的后缀表示法。

方法调用语法与显式泛型实例化冲突：
``p[T](x)`` 不能写为 ``x.p[T]`` 因为 ``x.p[T]`` 总是被解析为 ``(x.p)[T]`` 。

见: `Limitations of the method call syntax <#templates-limitations-of-the-method-call-syntax>`_ 。

``[:]`` 符号旨在缓解这个问题： ``xp[:T]`` 由解析器重写为 ``p[T](x)`` ， ``xp[:T](y)`` 被重写为 ``p[T](x,y)`` 。
注意 ``[:]`` 没有AST表示，重写直接在解析步骤中执行。


属性
----------

Nim不需要 *get-properties* ：使用 *方法调用语法* 调用的普通get-procedure达到相同目的。
但设定值是不同的;为此需要一个特殊的setter语法：

.. code-block:: nim
  # 模块asocket
  type
    Socket* = ref object of RootObj
      host: int # 无法从模块外部访问

  proc `host=`*(s: var Socket, value: int) {.inline.} =
    ## hostAddr的setter.
    ##它访问'host'字段并且不是对 ``host =`` 的递归调用，如果内置的点访问方法可用，则首选点访问：
    s.host = value

  proc host*(s: Socket): int {.inline.} =
    ## hostAddr的getter
    ##它访问'host'字段并且不是对 ``host`` 的递归调用，如果内置的点访问方法可用，则首选点访问：
    s.host

.. code-block:: nim
  # 模块 B
  import asocket
  var s: Socket
  new s
  s.host = 34  # 同`host=`(s, 34)

定义为 ``f=`` 的proc（尾随 ``=`` ）被称为 `setter`:idx: 。 

可以通过常见的反引号表示法显式调用setter：

.. code-block:: nim

  proc `f=`(x: MyObject; value: string) =
    discard

  `f=`(myObject, "value")

``f=`` 可以在模式 ``xf = value`` 中隐式调用，当且仅当 ``x`` 的类型没有名为 ``f`` 的字段或者 ``f`` 时在当前模块中不可见。
这些规则确保对象字段和访问者可以具有相同的名称。
在模块 ``x.f`` 中总是被解释为字段访问，在模块外部它被解释为访问器proc调用。


命令调用语法
-------------------------

如果调用在语法上是一个语句，则可以在没有 ``()`` 的情况下调用例程。
这种限制意味着 ``echo f 1, f 2`` 被解析为 ``echo(f(1), f(2))`` 而不是 ``echo(f(1, f(2)))`` 。

在这种情况下，方法调用语法可用于提供一个或多个参数：

.. code-block:: nim
  proc optarg(x: int, y: int = 0): int = x + y
  proc singlearg(x: int): int = 20*x

  echo optarg 1, " ", singlearg 2  # 打印 "1 40"

  let fail = optarg 1, optarg 8   # 错误。命令调用的参数太多
  let x = optarg(1, optarg 8)  # 传统过程调用2个参数
  let y = 1.optarg optarg 8    # 与上面相同，没有括号
  assert x == y

命令调用语法也不能将复杂表达式作为参数。
例如： (`匿名过程`_), ``if``, ``case`` 或 ``try`` 。
没有参数的函数调用仍需要()来区分调用和函数本身作为第一类值。


闭包
--------

过程可以出现在模块的顶层以及其他范围内，在这种情况下，它们称为嵌套过程。
嵌套的proc可以从其封闭的范围访问局部变量，如果它这样做，它就变成了一个闭包。
任何捕获的变量都存储在闭包（它的环境）的隐藏附加参数中，并且它们通过闭包及其封闭范围的引用来访问（即，对它们进行的任何修改在两个地方都是可见的）。

如果编译器确定这是安全的，则可以在堆上或堆栈上分配闭包环境。

在循环中创建闭包
~~~~~~~~~~~~~~~~~~~~~~~~~~

由于闭包通过引用捕获局部变量，因此在循环体内通常不需要行为。
有关如何更改此行为的详细信息，请参阅 `closureScope <system.html#closureScope>`_ 。

匿名过程
---------------

Procs也可以被视为表达式，在这种情况下，它允许省略proc的名称。

.. code-block:: nim
  var cities = @["Frankfurt", "Tokyo", "New York", "Kyiv"]

  cities.sort(proc (x,y: string): int =
      cmp(x.len, y.len))


Procs as表达式既可以作为嵌套proc，也可以作为顶级可执行代码。


函数
----

The ``func`` 关键字为 `noSideEffect`:idx: 的过程引入了一个快捷方式。

.. code-block:: nim
  func binarySearch[T](a: openArray[T]; elem: T): int

是它的简写:

.. code-block:: nim
  proc binarySearch[T](a: openArray[T]; elem: T): int {.noSideEffect.}



不可重载的内置
------------------------

由于实现简单，它们不能重载以下内置过程（它们需要专门的语义检查）:

  declared, defined, definedInScope, compiles, sizeOf,
  is, shallowCopy, getAst, astToStr, spawn, procCall

因此，它们更像关键词而非普通标识符;然而，与关键字不同，重新定义可能是 `shadow`:idx: ``system`` 模块中的定义。
从这个列表中不应该用点符号 ``x.f`` 写，因为 ``x`` 在传递给 ``f`` 之前不能进行类型检查：

  declared, defined, definedInScope, compiles, getAst, astToStr


Var形参
--------------
参数的类型可以使用 ``var`` 关键字作为前缀：

.. code-block:: nim
  proc divmod(a, b: int; res, remainder: var int) =
    res = a div b
    remainder = a mod b

  var
    x, y: int

  divmod(8, 5, x, y) # modifies x and y
  assert x == 1
  assert y == 3

在示例中， ``res`` 和 ``remainder`` 是 `var parameters` 。
可以通过过程修改Var参数，并且调用者可以看到更改。
传递给var参数的参数必须是左值。
Var参数实现为隐藏指针。
上面的例子相当于：

.. code-block:: nim
  proc divmod(a, b: int; res, remainder: ptr int) =
    res[] = a div b
    remainder[] = a mod b

  var
    x, y: int
  divmod(8, 5, addr(x), addr(y))
  assert x == 1
  assert y == 3

在示例中，var参数或指针用于提供两个返回值。
这可以通过返回元组以更干净的方式完成：

.. code-block:: nim
  proc divmod(a, b: int): tuple[res, remainder: int] =
    (a div b, a mod b)

  var t = divmod(8, 5)

  assert t.res == 1
  assert t.remainder == 3

可以使用 `元组解包`:idx: 来访问元组的字段：

.. code-block:: nim
  var (x, y) = divmod(8, 5) # 元组解包
  assert x == 1
  assert y == 3


**注意**: ``var`` 参数对于有效的参数传递永远不是必需的。
由于无法修改非var参数，因此如果编译器认为可以加快执行速度，则编译器始终可以通过引用自由传递参数。


Var返回类型
---------------

proc，转换器或迭代器可能返回一个 ``var`` 类型，这意味着返回的值是一个左值，并且可以由调用者修改：

.. code-block:: nim
  var g = 0

  proc writeAccessToG(): var int =
    result = g

  writeAccessToG() = 6
  assert g == 6

如果隐式引入的指针可用于访问超出其生命周期的位置，则这是一个静态错误：

.. code-block:: nim
  proc writeAccessToG(): var int =
    var g = 0
    result = g # Error!

For iterators, a component of a tuple return type can have a ``var`` type too:

.. code-block:: nim
  iterator mpairs(a: var seq[string]): tuple[key: int, val: var string] =
    for i in 0..a.high:
      yield (i, a[i])

在标准库中，返回 ``var`` 类型的例程的每个名称都以每个约定的前缀 ``m`` 开头。


.. include:: manual/var_t_return.rst

未来的方向
~~~~~~~~~~~~~~~~~

Nim的更高版本可以使用如下语法更准确地了解借用规则：

.. code-block:: nim
  proc foo(other: Y; container: var X): var T from container

这里 ``var T from container`` 明确地暴露了该位置不同于第二个形参（在本例中称为'container'）。
语法 ``var T from p`` 指定一个类型 ``varTy [T,2]`` ，它与 ``varTy [T,1]`` 不兼容。



下标操作符重载
-------------------------------------

数组/开放数组/序列的 ``[]`` 下标运算符可以重载。


多方法
=============

**注意：** 从Nim 0.20开始，要使用多方法，必须在编译时明确传递 ``--multimethods：on`` 。

程序总是使用静态调度。多方法使用动态调度。
要使动态分派处理对象，它应该是引用类型。

.. code-block:: nim
  type
    Expression = ref object of RootObj ## abstract base class for an expression
    Literal = ref object of Expression
      x: int
    PlusExpr = ref object of Expression
      a, b: Expression

  method eval(e: Expression): int {.base.} =
    # 重写基方法
    quit "to override!"

  method eval(e: Literal): int = return e.x

  method eval(e: PlusExpr): int =
    # 当心: 依赖动态绑定
    result = eval(e.a) + eval(e.b)

  proc newLit(x: int): Literal =
    new(result)
    result.x = x

  proc newPlus(a, b: Expression): PlusExpr =
    new(result)
    result.a = a
    result.b = b

  echo eval(newPlus(newPlus(newLit(1), newLit(2)), newLit(4)))

在示例中，构造函数 ``newLit`` 和 ``newPlus`` 是procs因为它们应该使用静态绑定，但 ``eval`` 是一种方法，因为它需要动态绑定。

从示例中可以看出，基本方法必须使用 `base`:idx: 编译指示进行注释。
``base`` 编译指示还可以提醒程序员使用基本方法 ``m`` 作为基础来确定调用 ``m`` 可能导致的所有效果。


**注意**: 编译期执行不支持方法。

**注意**: 从Nim 0.20开始，不推荐使用泛型方法。


通过procCall禁止动态方法解析
-----------------------------------------------

可以通过内置的 `system.procCall`:idx: 来禁止动态方法解析。
这有点类似于传统OOP语言提供的 `super`:idx: 关键字。

.. code-block:: nim
    :test: "nim c $1"

  type
    Thing = ref object of RootObj
    Unit = ref object of Thing
      x: int

  method m(a: Thing) {.base.} =
    echo "base"

  method m(a: Unit) =
    # Call the base method:
    procCall m(Thing(a))
    echo "1"


迭代器和for语句
===============================
`for`:idx: 语句是一种迭代容器元素的抽象机制。
它依赖于 `iterator`:idx:这样做。就像 ``while`` 语句一样， ``for`` 语句打开一个 `隐式块`:idx:，这样它们就可以留下一个 ``break`` 语句。

``for`` 循环声明迭代变量 - 它们的范围一直到循环体的末尾。
迭代变量的类型由迭代器的返回类型推断。

迭代器类似于一个过程，除了它可以在 ``for`` 循环的上下文中调用。
迭代器提供了一种指定抽象类型迭代的方法。
执行 ``for`` 循环的关键作用是在被调用的迭代器中播放 ``yield`` 语句。
每当达到 ``yield`` 语句时，数据就会被绑定到 ``for`` 循环变量，并且控制在 ``for`` 循环的主体中继续。
迭代器的局部变量和执行状态在调用之间自动保存。


示例：

.. code-block:: nim
  # 该定义存在于系统模块中
  iterator items*(a: string): char {.inline.} =
    var i = 0
    while i < len(a):
      yield a[i]
      inc(i)

  for ch in items("hello world"): # `ch` is an iteration variable
    echo ch

编译器生成代码就像程序员编写的那样：

.. code-block:: nim
  var i = 0
  while i < len(a):
    var ch = a[i]
    echo ch
    inc(i)

如果迭代器产生一个元组，那么迭代变量可以与元组中的组件一样多。
第i个迭代变量的类型是第i个组件的类型。
换句话说，支持for循环上下文中的隐式元组解包。

隐式items和pairs调用
-------------------------------

如果for循环表达式 ``e`` 不表示迭代器而for循环正好有1个变量，则for循环表达式被重写为 ``items(e)`` ;即隐式调用 ``items`` 迭代器：

.. code-block:: nim
  for x in [1,2,3]: echo x

如果for循环恰好有2个变量，则隐式调用 ``pairs`` 迭代器。

在重写步骤之后执行标识符 ``items`` 或 ``pairs`` 的符号查找，以便考虑所有 ``items`` 或 ``pairs`` 的重载。


第一类迭代器
---------------------

Nim中有两种迭代器： *inline* 和 *closure* 迭代器。
一个 `内联迭代器`:idx: 是一个迭代器，总是由编译器内联，导致抽象的开销为零，但可能导致代码大小的大量增加。

注意：内联迭代器上的for循环体被内联到迭代器代码中出现的每个 ``yield`` 语句中，因此理想情况下，代码应该被重构为包含单个yield，以避免代码膨胀。

内联迭代器是二等公民;
它们只能作为参数传递给其他内联代码工具，如模板、宏和其他内联迭代器。

与此相反， `闭包迭代器`:idx: 可以更自由地传递：

.. code-block:: nim
  iterator count0(): int {.closure.} =
    yield 0

  iterator count2(): int {.closure.} =
    var x = 1
    yield x
    inc x
    yield x

  proc invoke(iter: iterator(): int {.closure.}) =
    for x in iter(): echo x

  invoke(count0)
  invoke(count2)

闭包迭代器和内联迭代器有一些限制：

1. 目前，闭包迭代器无法在编译时执行。
2. 在闭包迭代器中允许 ``return`` 但在内联迭代器中不允许（但很少有用）并结束迭代。
3. 内联和闭包迭代器都不能递归。
4. 内联和闭包迭代器都没有特殊的 ``result`` 变量。
5. js后端不支持闭包迭代器。

迭代器既没有标记为 ``{.closure.}`` 也不是 ``{.inline.}`` 则显式默认内联，但这可能会在未来版本的实现中发生变化。

``iterator`` 类型总是隐式调用约定 ``closure`` ;以下示例显示如何使用迭代器实现 `协作任务`:idx: 系统:

.. code-block:: nim
  # 简单任务:
  type
    Task = iterator (ticker: int)

  iterator a1(ticker: int) {.closure.} =
    echo "a1: A"
    yield
    echo "a1: B"
    yield
    echo "a1: C"
    yield
    echo "a1: D"

  iterator a2(ticker: int) {.closure.} =
    echo "a2: A"
    yield
    echo "a2: B"
    yield
    echo "a2: C"

  proc runTasks(t: varargs[Task]) =
    var ticker = 0
    while true:
      let x = t[ticker mod t.len]
      if finished(x): break
      x(ticker)
      inc ticker

  runTasks(a1, a2)

内置的 ``system.finished`` 可用于确定迭代器是否已完成其操作;尝试调用已完成其工作的迭代器时不会引发异常。

注意使用``system.finished``容易出错，因为它只在迭代器完成下一次迭代返回 ``true`` ：

.. code-block:: nim
  iterator mycount(a, b: int): int {.closure.} =
    var x = a
    while x <= b:
      yield x
      inc x

  var c = mycount # 实例化迭代器
  while not finished(c):
    echo c(1, 3)

  # 生成
  1
  2
  3
  0

而是必须使用此代码：

.. code-block:: nim
  var c = mycount # 实例化迭代器
  while true:
    let value = c(1, 3)
    if finished(c): break # 并且丢弃 'value'!
    echo value

它用于迭代器返回一对 ``(value，done)`` 和 ``finished`` 用于访问隐藏的 ``done`` 字段。

闭包迭代器是 *可恢复函数* ，因此必须为每个调用提供参数。
为了解决这个限制，可以捕获外部工厂proc的参数：

.. code-block:: nim
  proc mycount(a, b: int): iterator (): int =
    result = iterator (): int =
      var x = a
      while x <= b:
        yield x
        inc x

  let foo = mycount(1, 4)

  for f in foo():
    echo f



转换器
==========

转换器就像普通的过程，除了它增强了 ``隐式可转换`` 类型关系（参见 `可转换关系`_ ）：

.. code-block:: nim
  # 不好的风格：Nim不是C。
  converter toBool(x: int): bool = x != 0

  if 4:
    echo "compiles"



还可以显式调用转换器以提高可读性。
请注意，不支持隐式转换器链接：如果存在从类型A到类型B的转换器以及从类型B到类型C的转换器，则不提供从A到C的隐式转换。


Type段
=============

示例：

.. code-block:: nim
  type # 演示相互递归类型的示例
    Node = ref object  # 垃圾收集器管理的对象（r​​ef）
      le, ri: Node     # 左右子树
      sym: ref Sym     # 叶节点含有Sym的引用

    Sym = object       # 一个符号
      name: string     # 符号名
      line: int        # 声明符号的行
      code: Node       # 符号的抽象语法树

类型部分以 ``type`` 关键字开头。
它包含多个类型定义。
类型定义将类型绑定到名称。
类型定义可以是递归的，甚至可以是相互递归的。
相互递归类型只能在单个 ``type`` 部分中使用。
像 ``objects`` 或 ``enums`` 这样的标称类型只能在 ``type`` 部分中定义。



异常处理
==================

Try语句
-------------

示例：

.. code-block:: nim
  # 读取应包含数字的文本文件的前两行并尝试添加
  var
    f: File
  if open(f, "numbers.txt"):
    try:
      var a = readLine(f)
      var b = readLine(f)
      echo "sum: " & $(parseInt(a) + parseInt(b))
    except OverflowError:
      echo "overflow!"
    except ValueError:
      echo "could not convert string to integer"
    except IOError:
      echo "IO error!"
    except:
      echo "Unknown exception!"
    finally:
      close(f)


``try`` 之后的语句按顺序执行，除非引发异常 ``e`` 。
如果 ``e`` 的异常类型匹配 ``except`` 子句中列出的任何类型，则执行相应的语句。
``except`` 子句后面的语句称为 `异常处理程序`:idx: 。

如果存在未列出的异常，则执行空的 `except`:idx: 子句。
它类似于 ``if`` 语句中的 ``else`` 子句。

如果有一个 `finally`:idx: 子句，它总是在异常处理程序之后执行。

异常处理程序中的 *consume* 异常。
但是，异常处理程序可能会引发另一个异常。
如果未处理异常，则通过调用堆栈传播该异常。
这意味着程序不在 ``finally`` 子句中的其余部分通常不会被执行（如果发生异常）。


Try表达式
--------------

尝试也可以用作表达式;然后 ``try`` 分支的类型需要适合 ``except`` 分支的类型，但 ``finally`` 分支的类型总是必须是 ``void`` ：

.. code-block:: nim
  let x = try: parseInt("133a")
          except: -1
          finally: echo "hi"


为了防止令人困惑的代码，有一个解析限制，如果 ``try`` 跟在一个 ``(`` 它必须写成一行：

.. code-block:: nim
  let x = (try: parseInt("133a") except: -1)


排除从句
--------------

在 ``except`` 子句中，可以使用以下语法访问当前异常：

.. code-block:: nim
  try:
    # ...
  except IOError as e:
    # Now use "e"
    echo "I/O error: " & e.msg

或者，可以使用 ``getCurrentException`` 来检索已经引发的异常：

.. code-block:: nim
  try:
    # ...
  except IOError:
    let e = getCurrentException()
    # 现在使用"e"

注意 ``getCurrentException`` 总是返回一个 ``ref Exception`` 类型。

如果需要一个正确类型的变量（在上面的例子中，``IOError`` ），必须明确地转换它：

.. code-block:: nim
  try:
    # ...
  except IOError:
    let e = (ref IOError)(getCurrentException())
    # "e"现在是合适的类型

但是，这很少需要。
最常见的情况是从 ``e`` 中提取错误消息，对于这种情况，使用 ``getCurrentExceptionMsg`` 就足够了：

.. code-block:: nim
  try:
    # ...
  except:
    echo getCurrentExceptionMsg()


Defer语句
---------------

可以使用 ``defer`` 语句而不是 ``try finally`` 语句。

当前块中　``defer`` 之后的任何语句都将被视为隐式try块：

.. code-block:: nim
    :test: "nim c $1"

  proc main =
    var f = open("numbers.txt")
    defer: close(f)
    f.write "abc"
    f.write "def"

被重写为：

.. code-block:: nim
    :test: "nim c $1"

  proc main =
    var f = open("numbers.txt")
    try:
      f.write "abc"
      f.write "def"
    finally:
      close(f)

不支持顶级 ``defer`` 语句，因为不清楚这样的语句应该引用什么。


Raise语句
---------------

示例：

.. code-block:: nim
  raise newEOS("operating system failed")

除了数组索引，内存分配等内置操作之外，``raise`` 语句是引发异常的唯一方法。

.. XXX document this better!

如果没有给出异常名称，则当前异常会 `re-raised`:idx: 。
如果没有异常重新加注，则引发 `ReraiseError`:idx:异常。
因此， ``raise`` 语句 *总是* 引发异常。


异常层级
-------------------

异常树在 `system <system.html>`_ 模块中定义。
每个异常都继承自 ``system.Exception`` 。
表示编程错误的异常继承自``system.Defect``（它是``Exception``的子类型）并严格地说是不可捕获的，因为它们也可以映射到终止整个过程的操作。
表示可以捕获的任何其他运行时错误的异常继承自 ``system.CatchableError``（这是 ``Exception`` 的子类型）。


导入的异常
-------------------

可以引发和捕获导入的C++异常。
使用 `importcpp` 导入的类型可以被引发或捕获。例外是通过值引发并通过引用捕获。

示例：

.. code-block:: nim

  type
    std_exception {.importcpp: "std::exception", header: "<exception>".} = object

  proc what(s: std_exception): cstring {.importcpp: "((char *)#.what())".}

  try:
    raise std_exception()
  except std_exception as ex:
    echo ex.what()



效应系统
=============

异常跟踪
------------------

Nim支持异常跟踪。 `raises`:idx: 编译器可用于显式定义允许proc/iterator/method/converter引发的异常。编译器验证这个：

.. code-block:: nim
    :test: "nim c $1"

  proc p(what: bool) {.raises: [IOError, OSError].} =
    if what: raise newException(IOError, "IO")
    else: raise newException(OSError, "OS")

一个空的 ``raises`` 列表（ ``raises：[]`` ）意味着不会引发任何异常：

.. code-block:: nim
  proc p(): bool {.raises: [].} =
    try:
      unsafeCall()
      result = true
    except:
      result = false

``raises`` 列表也可以附加到proc类型。这会影响类型兼容性：

.. code-block:: nim
    :test: "nim c $1"
    :status: 1

  type
    Callback = proc (s: string) {.raises: [IOError].}
  var
    c: Callback

  proc p(x: string) =
    raise newException(OSError, "OS")

  c = p # 类型错误

对于例程 ``p`` ，编译器使用推理规则来确定可能引发的异常集;算法在 ``p`` 的调用图上运行：

1.通过某些proc类型 ``T`` 的每个间接调用都被假定为引发 ``system.Exception`` （异常层次结构的基本类型），因此除非 ``T`` 有明确的 ``raises`` 列表。
   但是如果调用的形式是 ``f(...)`` 其中 ``f`` 是当前分析的例程的参数，则忽略它。
   乐观地认为该呼叫没有效果。规则2补偿了这种情况。
2.假定在一个不是调用本身（而不是nil）的调用中的某些proc类型的每个表达式都以某种方式间接调用，因此它的引发列表被添加到 ``p`` 的引发列表中。
3.对前向声明或 ``importc`` 编译指示的未知proc ``q`` 的每次调用，假定会引发 ``system.Exception``，除非 ``q`` 有一个明确的 ``raises`` 列表。
4.每次对方法 ``m`` 的调用都会被假定为引发 ``system.Exception`` ，除非 ``m`` 有一个明确的 ``raises`` 列表。
5.对于每个其他调用，分析可以确定一个确切的 ``raises`` 列表。
6.为了确定 ``raises`` 列表，考虑 ``p`` 的 ``raise`` 和 ``try`` 语句。

规则1-2确保下面的代码正常工作：

.. code-block:: nim
  proc noRaise(x: proc()) {.raises: [].} =
    # 可能引发任何异常的未知调用, 但这是合法的:
    x()

  proc doRaise() {.raises: [IOError].} =
    raise newException(IOError, "IO")

  proc use() {.raises: [].} =
    # 不能编译! 可能引发IOError!
    noRaise(doRaise)

因此，在许多情况下，回调不会导致编译器在其效果分析中过于保守。


Tag跟踪
------------

异常跟踪是Nim ``效应系统``:idx: 的一部分。
引发异常是 *效应* 。
其他效应也可以定义。
用户定义的效应是 *标记* 例程并对此标记执行检查的方法：

.. code-block:: nim
    :test: "nim c $1"
    :status: 1

  type IO = object ## input/output effect
  proc readLine(): string {.tags: [IO].} = discard

  proc no_IO_please() {.tags: [].} =
    # the compiler prevents this:
    let x = readLine()

标签必须是类型名称。一个 ``tags`` 列表 - 就像一个 ``raises`` 列表 - 也可以附加到一个proc类型。
这会影响类型兼容性。

标签跟踪的推断类似于异常跟踪的推断。



Effects编译指示
--------------
``effects`` 编译指示旨在帮助程序员进行效果分析。
这是一个声明，使编译器将所有推断的效果输出到 ``effects`` 的位置：

.. code-block:: nim
  proc p(what: bool) =
    if what:
      raise newException(IOError, "IO")
      {.effects.}
    else:
      raise newException(OSError, "OS")

编译器生成一条提示消息，可以引发 ``IOError`` 。
未列出 ``OSError`` ，因为它不能在分支中引发 ``effects`` 编译指示。


泛型
========
泛型是Nim用 `类型形参`:idx: 参数化过程、迭代器或类型的方法 。
根据上下文，括号用于引入类型形参或实例化泛型过程、迭代器或类型。


以下示例显示了可以建模的通用二叉树：

.. code-block:: nim
    :test: "nim c $1"

  type
    BinaryTree*[T] = ref object # 二叉树是左右子树带有泛型形参 ``T`` 的泛型类型，其值可能为nil
      le, ri: BinaryTree[T]     
      data: T                   # 数据存储在节点中。

  proc newNode*[T](data: T): BinaryTree[T] =
    # 构造一个节点
    result = BinaryTree[T](le: nil, ri: nil, data: data)

  proc add*[T](root: var BinaryTree[T], n: BinaryTree[T]) =
    # 把节点插入到一颗树
    if root == nil:
      root = n
    else:
      var it = root
      while it != nil:
        # 比较数据项;使用泛型 ``cmp`` proc，适用于任何具有``==``和````运算符的类型
        var c = cmp(it.data, n.data)
        if c < 0:
          if it.le == nil:
            it.le = n
            return
          it = it.le
        else:
          if it.ri == nil:
            it.ri = n
            return
          it = it.ri

  proc add*[T](root: var BinaryTree[T], data: T) =
    # 便利过程:
    add(root, newNode(data))

  iterator preorder*[T](root: BinaryTree[T]): T =
    # 前序遍历二叉树
    # 由于递归迭代器尚未实现，因此它使用显式堆栈（因为更高效）：
    var stack: seq[BinaryTree[T]] = @[root]
    while stack.len > 0:
      var n = stack.pop()
      while n != nil:
        yield n.data
        add(stack, n.ri)  # 将右子树推入堆栈
        n = n.le          # 跟着左指针

  var
    root: BinaryTree[string] # 使用 ``string`` 实例化二叉树
  add(root, newNode("hello")) # 实例化 ``newNode`` 和 ``add``
  add(root, "world")          # 实例化第二个 ``add`` proc
  for str in preorder(root):
    stdout.writeLine(str)

``T`` 被称为 `泛型类型形参` :idx: 或 `类型变量`:idx: 。


Is操作符
-----------

在语义分析期间评估 ``is`` 运算符以检查类型等价。
因此，它对于泛型代码中的类型特化非常有用：

.. code-block:: nim
  type
    Table[Key, Value] = object
      keys: seq[Key]
      values: seq[Value]
      when not (Key is string): # 用于优化的字符串的空值
        deletedKeys: seq[bool]


类型类别
------------

类型类是一种特殊的伪类型，可用于匹配重载决策或 ``is`` 运算符中的类型。
Nim支持以下内置类型类：

==================   ===================================================
类型                  匹配
==================   ===================================================
``object``           任意对象类型
``tuple``            任意元组类型

``enum``             任意枚举
``proc``             任意过程类型
``ref``              任意 ``ref`` 类型
``ptr``              任意 ``ptr`` 类型
``var``              任意 ``var`` 类型
``distinct``         任意distinct类型
``array``            任意数组array类型
``set``              任意set类型
``seq``              任意seq类型
``auto``             任意类型
``any``              distinct auto (见下方)
==================   ===================================================

此外，每个泛型类型都会自动创建一个与通用类型的任何实例化相匹配的相同名称的类型类。

可以使用标准布尔运算符组合类型类，以形成更复杂的类型类：

.. code-block:: nim
  # 创建一个匹配所有元组和对象类型的类型类
  type RecordType = tuple or object

  proc printFields(rec: RecordType) =
    for key, value in fieldPairs(rec):
      echo key, " = ", value

以这种方式使用类型类的过程被认为是 ``隐式通用的``:idx: 。
对于程序中使用的每个唯一的param类型组合，它们将被实例化一次。

虽然类型类的语法看起来类似于ML的语言中的ADT /代数数据类型，但应该理解类型类是类型实例化时强制执行的静态约束。
类型类不是真正的类型，而是一个提供通用“检查”的系统，最终将 *解析* 为某种单一类型。
与对象变体或方法不同，类型类不允许运行时类型动态。

例如，以下内容无法编译：

.. code-block:: nim
  type TypeClass = int | string
  var foo: TypeClass = 2 # foo的类型在这里解析为int
  foo = "this will fail" # 错误在这里，因为foo是一个int

Nim允许将类型类和常规类型指定为 `类型限制`:idx: 泛型类型参数：

.. code-block:: nim
  proc onlyIntOrString[T: int|string](x, y: T) = discard

  onlyIntOrString(450, 616) # 合法
  onlyIntOrString(5.0, 0.0) # 类型不匹配
  onlyIntOrString("xy", 50) # 不合法因为 'T' 不能同时是两种类型


默认情况下，在重载解析期间，每个命名类型类将仅绑定到一个具体类型。
我们称这样的类类为 `绑定一次`:idx: 类型。
以下是直接从系统模块中抽取的用于展示的示例：

.. code-block:: nim
  proc `==`*(x, y: tuple): bool =
    ## 要求 `x` and `y` 是同样的元组类型
    ## 从 `x` 和 `y` 部分中提升的元组泛型 ``==`` 操作符。
    result = true
    for a, b in fields(x, y):
      if a != b: result = false

或者，可以将 ``distinct`` 类型修饰符应用于类型类，以允许与类型类匹配的每个参数绑定到不同的类型。
这种类型类称为 `绑定多次`:idx: 类型

使用隐式通用样式编写的过程通常需要引用匹配泛型类型的类型参数。
可以使用点语法轻松访问它们：

.. code-block:: nim
  type Matrix[T, Rows, Columns] = object
    ...

  proc `[]`(m: Matrix, row, col: int): Matrix.T =
    m.data[col * high(Matrix.Columns) + row]

或者，当使用匿名或不同类型类时，可以在proc参数上使用 `type` 运算符以获得类似的效果。

当使用类型类而不是具体类型实例化泛型类型时，这会产生另一个更具体的类型类：

.. code-block:: nim
  seq[ref object]  # 存储任意对象类型引用的序列

  type T1 = auto
  proc foo(s: seq[T1], e: T1)
    # seq[T1]与 `seq` 相同，但T1允许当签名匹配时绑定到单个类型

  Matrix[Ordinal] # 任何使用整数值的矩阵实例化

如前面的例子所示，在这样的实例化中，没有必要提供泛型类型的所有类型参数，因为任何缺失的参数都将被推断为具有 `any` 类型的等价物，因此它们将匹配任何类型而不受歧视。


泛型推导限制
------------------------------

类型 ``var T`` 和 ``typedesc [T]`` 不能在泛型实例中推断出来。以下是不允许的：

.. code-block:: nim
    :test: "nim c $1"
    :status: 1

  proc g[T](f: proc(x: T); x: T) =
    f(x)

  proc c(y: int) = echo y
  proc v(y: var int) =
    y += 100
  var i: int

  # 允许：推断 'T' 为 'int' 类型
  g(c, 42)

  # 无效：'T'不推断为'var int'类型
  g(v, i)

  # 也不允许：通过'var int'进行显式实例化
  g[var int](v, i)



泛型符号查找
-------------------------

开放和封闭的符号
~~~~~~~~~~~~~~~~~~~~~~~

泛型中的符号绑定规则比较微妙：有“开放”和“封闭”符号。
“封闭”符号不能在实例化上下文中重新绑定，“开放”符号可以。
默认重载符号是打开的，每个其他符号都是关闭的。

在两个不同的上下文中查找开放符号：定义上下文和实例化时的上下文都被考虑：

.. code-block:: nim
    :test: "nim c $1"

  type
    Index = distinct int

  proc `==` (a, b: Index): bool {.borrow.}

  var a = (0, 0.Index)
  var b = (0, 0.Index)

  echo a == b # 可以了

在示例中，元组的通用 ``==`` （在系统模块中定义）使用元组组件的 ``==`` 运算符。
但是， ``Index`` 类型的 ``==`` 是在元组的 ``==``  *之后* 定义的;然而，该示例编译为实例化也将当前定义的符号考虑在内。

Mixin语句
---------------

可以通过 `mixin`:idx: 强制打开符号声明:

.. code-block:: nim
    :test: "nim c $1"

  proc create*[T](): ref T =
    # 这里没有重载'init'，所以我们需要明确说明它是一个开放的符号：
    mixin init
    new result
    init result

``mixin`` 语句只在模板和泛型中有意义。


Bind语句
--------------

``bind`` 语句是 ``mixin`` 语句的对应语句。
它可以用于显式声明应该提前绑定的标识符（即标识符应该在模板/泛型定义的范围内查找）：

.. code-block:: nim
  # 模块A
  var
    lastId = 0

  template genId*: untyped =
    bind lastId
    inc(lastId)
    lastId

.. code-block:: nim
  # 模块B
  import A

  echo genId()

但是 ``bind`` 很少有用，因为符号绑定默认来自定义的作用域。
``bind`` 语句只在模板和泛型中有意义。


模板
=========

模板是宏的一种简单形式：它是一种简单的替换机制，可以在Nim的抽象语法树上运行。
它在编译器的语义传递中处理。

*调用* 模板的语法与调用过程相同。

示例：

.. code-block:: nim
  template `!=` (a, b: untyped): untyped =
    # 此定义存在于系统模块中
    not (a == b)

  assert(5 != 6) # 编译器将其重写为：: assert(not (5 == 6))

``!=``, ``>``, ``>=``, ``in``, ``notin``, ``isnot`` 运算符实际上是模板：

| ``a > b`` 变换成 ``b < a``.
| ``a in b`` 变换成 ``contains(b, a)``.
| ``notin`` 和 ``isnot`` 见名知意。


模板的“类型”可以是符号 ``untyped`` ， ``typed`` 或 ``typedesc`` 。
这些是“元类型”，它们只能在某些上下文中使用。
也可以使用常规类型;这意味着需要 ``typed`` 表达式。


类型化和无类型形参
---------------------------

``无类型`` 参数表示在将表达式传递给模板之前不执行符号查找和类型解析。
这意味着例如 *未声明* 标识符可以传递给模板：

.. code-block:: nim
    :test: "nim c $1"

  template declareInt(x: untyped) =
    var x: int

  declareInt(x) # 有效
  x = 3


.. code-block:: nim
    :test: "nim c $1"
    :status: 1

  template declareInt(x: typed) =
    var x: int

  declareInt(x) # 无效，因为x尚未声明，因此没有类型

每个参数都是 ``无类型`` 的模板称为 `立即`:idx: 模板。
由于历史原因模板可以使用 ``立即`` 编译指示进行显式注释，然后这些模板不会参与重载分辨率，编译器会 *忽略* 参数的类型。
现在不推荐使用显式立即模板。

**注意**: 由于历史原因 ``stmt`` 是类型化 ``typed`` 的别名， ``expr`` 是无类型 ``untyped`` 的别名, 但他们被移除了。


向模板传代码块
----------------------------------

您可以在特殊的 ``:`` 语法之后将一个语句块作为最后一个参数传递给模板：

.. code-block:: nim
    :test: "nim c $1"

  template withFile(f, fn, mode, actions: untyped): untyped =
    var f: File
    if open(f, fn, mode):
      try:
        actions
      finally:
        close(f)
    else:
      quit("cannot open: " & fn)

  withFile(txt, "ttempl3.txt", fmWrite):  # 特殊冒号
    txt.writeLine("line 1")
    txt.writeLine("line 2")

在这个例子中，两个 ``writeLine`` 语句绑定到 ``actions`` 参数。


通常将一块代码传递给模板，接受块的参数需要是“untyped”类型。
因为符号查找会延迟到模板实例化时间：

.. code-block:: nim
    :test: "nim c $1"
    :status: 1

  template t(body: typed) =
    block:
      body

  t:
    var i = 1
    echo i

  t:
    var i = 2  # '尝试重新声明i'失败
    echo i

上面的代码因已经声明了 ``i`` 的错误信息失败。
原因是 ``var i = ...`` 需要在传递给 ``body`` 参数之前进行类型检查，而Nim中的类型检查意味着符号查找。
为了使符号查找成功，需要将 ``i`` 添加到当前（即外部）范围。
在类型检查之后，这些对符号表的添加不会回滚（无论好坏）。
同样的代码可以用 ``untyped`` ，因为传递的主体不需要进行类型检查：

.. code-block:: nim
    :test: "nim c $1"

  template t(body: untyped) =
    block:
      body

  t:
    var i = 1
    echo i

  t:
    var i = 2  # 编译
    echo i


无类型可变参数
------------------

除了 ``untyped`` 元类型防止类型检查之外，``varargs[untyped]`` 甚至连参数的数量都可以不确定：

.. code-block:: nim
    :test: "nim c $1"

  template hideIdentifiers(x: varargs[untyped]) = discard

  hideIdentifiers(undeclared1, undeclared2)

但是，由于模板无法通过varargs进行迭代，因此该功能通常对宏非常有用。


模板符号绑定
---------------------------

模板是 `卫生`:idx: 宏，它打开了一个新的作用域。大多数符号都是从模板的定义作用域绑定的：

.. code-block:: nim
  # 模块A
  var
    lastId = 0

  template genId*: untyped =
    inc(lastId)
    lastId

.. code-block:: nim
  # 模块B
  import A

  echo genId() # 'lastId'已被'genId'的定义作用域所约束

在泛型中，``mixin`` 或 ``bind`` 语句可以影响符号绑定。

标识符构造
-----------------------

在模板中，可以使用反引号表示法构造标识符：

.. code-block:: nim
    :test: "nim c $1"

  template typedef(name: untyped, typ: typedesc) =
    type
      `T name`* {.inject.} = typ
      `P name`* {.inject.} = ref `T name`

  typedef(myint, int)
  var x: PMyInt

示例中 ``name`` 用 ``myint`` 实例化，所以 \`T name\` 变为 ``Tmyint`` 。


模板形参查询规则
------------------------------------
模板中的参数 ``p`` 甚至在表达式 ``x.p`` 中被替换。
因此，模板参数可以用作字段名称，也可以使用相同的参数名称对限定的全局符号进行隐藏：

.. code-block:: nim
  # 模块'm'

  type
    Lev = enum
      levA, levB

  var abclev = levB

  template tstLev(abclev: Lev) =
    echo abclev, " ", m.abclev

  tstLev(levA)
  # 生成: 'levA levA'

但是可以通过 ``bind`` 语句正确捕获全局符号：

.. code-block:: nim
  # 模块'm'

  type
    Lev = enum
      levA, levB

  var abclev = levB

  template tstLev(abclev: Lev) =
    bind m.abclev
    echo abclev, " ", m.abclev

  tstLev(levA)
  # 生成: 'levA levB'


模板卫生
--------------------
每个默认模板是 `卫生的`:idx:\: 
无法在实例化上下文中访问模板中声明的本地标识符：

.. code-block:: nim
    :test: "nim c $1"

  template newException*(exceptn: typedesc, message: string): untyped =
    var
      e: ref exceptn  # e is implicitly gensym'ed here
    new(e)
    e.msg = message
    e

  # 所以这是可以的:
  let e = "message"
  raise newException(IoError, e)

是否在模板中声明的符号是否暴露给实例化范围由 `inject`:idx: 和 `gensym`:idx: 编译指示控制，gensym的符号不会暴露而是注入。
``type``, ``var``, ``let`` 和 ``const`` 的实体符号默认是 ``gensym`` ，``proc``, ``iterator``, ``converter``, ``template``, ``macro`` 是 ``inject``. 
但是，如果实体的名称作为模板参数传递，则它是一个注入符号：

.. code-block:: nim
  template withFile(f, fn, mode: untyped, actions: untyped): untyped =
    block:
      var f: File  # since 'f' is a template param, it's injected implicitly
      ...

  withFile(txt, "ttempl3.txt", fmWrite):
    txt.writeLine("line 1")
    txt.writeLine("line 2")


``inject`` 和 ``gensym`` 编译指示是二等注释;它们在模板定义之外没有语义，不能被抽象：

.. code-block:: nim
  {.pragma myInject: inject.}

  template t() =
    var x {.myInject.}: int # 不行


为了摆脱模板中的卫生，可以为模板使用 `dirty`:idx: 编译指示。
``inject`` 和 ``gensym`` 在 ``dirty`` 模板中没有意义。



方法调用语法限制
-------------------------------------

``x.f`` 中的表达式 ``x`` 需要进行语义检查（即符号查找和类型检查），然后才能确定需要将其重写为 ``f（x）`` 。
因此，当用于调用模板/宏时，点语法有一些限制：

.. code-block:: nim
    :test: "nim c $1"
    :status: 1

  template declareVar(name: untyped) =
    const name {.inject.} = 45

  # 不能编译:
  unknownIdentifier.declareVar


另一个常见的例子是：

.. code-block:: nim
    :test: "nim c $1"
    :status: 1

  from sequtils import toSeq

  iterator something: string =
    yield "Hello"
    yield "World"

  var info = something().toSeq

这里的问题是编译器已经决定 ``something()`` 作为迭代器在 ``toSeq`` 将其转换为序列之前不可调用。


宏
======

宏是在编译时执行的特殊函数。
通常，宏的输入是传递给它的代码的抽象语法树（AST）。
然后，宏可以对其进行转换并返回转换后的AST。
这可用于添加自定义语言功能并实现 `领域特定语言（DSL）`:idx: 。


宏调用是一种语义分析 *不* 会完全从上到下，从左到右进行的情况。相反，语义分析至少发生两次：

* 语义分析识别并解析宏调用。
* 编译器执行宏体（可以调用其他触发器）。
* 它将宏调用的AST替换为宏返回的AST。
* 它重复了代码区域的语义分析。
* 如果宏返回的AST包含其他宏调用，则此过程将进行迭代。

虽然宏启用了高级编译时代码转换，但它们无法更改Nim的语法。
但是，这并不是真正的限制因为Nim的语法无论如何都足够灵活。

Debug示例
-------------

以下示例实现了一个强大的 ``debug`` 命令，该命令接受可变数量的参数：

.. code-block:: nim
    :test: "nim c $1"

  # 使用Nim语法树，我们需要一个在``macros``模块中定义的API：
  import macros

  macro debug(args: varargs[untyped]): untyped =
    # `args` is a collection of `NimNode` values that each contain the
    # AST for an argument of the macro. A macro always has to
    # return a `NimNode`. A node of kind `nnkStmtList` is suitable for
    # this use case.
    result = nnkStmtList.newTree()
    # iterate over any argument that is passed to this macro:
    for n in args:
      # add a call to the statement list that writes the expression;
      # `toStrLit` converts an AST to its string representation:
      result.add newCall("write", newIdentNode("stdout"), newLit(n.repr))
      # add a call to the statement list that writes ": "
      result.add newCall("write", newIdentNode("stdout"), newLit(": "))
      # add a call to the statement list that writes the expressions value:
      result.add newCall("writeLine", newIdentNode("stdout"), n)

  var
    a: array[0..10, int]
    x = "some string"
  a[0] = 42
  a[1] = 45

  debug(a[0], a[1], x)

The macro call expands to:

.. code-block:: nim
  write(stdout, "a[0]")
  write(stdout, ": ")
  writeLine(stdout, a[0])

  write(stdout, "a[1]")
  write(stdout, ": ")
  writeLine(stdout, a[1])

  write(stdout, "x")
  write(stdout, ": ")
  writeLine(stdout, x)


传递给 ``varargs`` 参数的参数包含在数组构造函数表达式中。
这就是为什么 ``debug`` 遍历所有 ``n`` 的子节点。


BindSym
-------

上面的 ``debug`` 宏依赖于 ``write`` ， ``writeLine`` 和 ``stdout`` 在系统模块中声明的事实，因此在实例化的上下文中可见。
有一种方法可以使用绑定标识符（又名 `符号`:idx:)而不是使用未绑定的标识符。
内置的 ``bindSym`` 可以用于：

.. code-block:: nim
    :test: "nim c $1"

  import macros

  macro debug(n: varargs[typed]): untyped =
    result = newNimNode(nnkStmtList, n)
    for x in n:
      # we can bind symbols in scope via 'bindSym':
      add(result, newCall(bindSym"write", bindSym"stdout", toStrLit(x)))
      add(result, newCall(bindSym"write", bindSym"stdout", newStrLitNode(": ")))
      add(result, newCall(bindSym"writeLine", bindSym"stdout", x))

  var
    a: array[0..10, int]
    x = "some string"
  a[0] = 42
  a[1] = 45

  debug(a[0], a[1], x)

宏调用扩展为：

.. code-block:: nim
  write(stdout, "a[0]")
  write(stdout, ": ")
  writeLine(stdout, a[0])

  write(stdout, "a[1]")
  write(stdout, ": ")
  writeLine(stdout, a[1])

  write(stdout, "x")
  write(stdout, ": ")
  writeLine(stdout, x)

但是，符号 ``write`` ， ``writeLine`` 和 ``stdout`` 已经绑定，不再被查找。如示例所示， ``bindSym`` 可以隐式地处理重载符号。

Case-Of宏
-------------

在Nim中，可以使用具有 *case-of* 表达式的语法的宏，区别在于所有分支都传递给宏实现并由宏实现处理。
然后是宏实现将 *of-branches* 转换为有效的Nim语句。
以下示例应显示如何将此功能用于词法分析器。

.. code-block:: nim
  import macros

  macro case_token(args: varargs[untyped]): untyped =
    echo args.treeRepr
    # 从正则表达式创建词法分析器
    # ... (implementation is an exercise for the reader ;-)
    discard

  case_token: # 这个冒号告诉解析器它是一个宏语句
  of r"[A-Za-z_]+[A-Za-z_0-9]*":
    return tkIdentifier
  of r"0-9+":
    return tkInteger
  of r"[\+\-\*\?]+":
    return tkOperator
  else:
    return tkUnknown

**风格注释** ：为了代码可读性，最好使用功能最少但仍然足够的编程结构。所以“检查清单”是：

(1) 如果可能，请使用普通的proc和iterator。
(2) 否则：如果可能，使用泛型的proc和iterator。
(3) 否则：如果可能，请使用模板。
(4) 否则：使用宏。


Macros用作编译指示
-----------------

整个例程（procs，iterators等）也可以通过编译指示表示法传递给模板或宏：

.. code-block:: nim
  template m(s: untyped) = discard

  proc p() {.m.} = discard

这是一个简单的语法转换：

.. code-block:: nim
  template m(s: untyped) = discard

  m:
    proc p() = discard


For循环宏
--------------

一个宏作为唯一的输入参数，特殊类型 ``system.ForLoopStmt`` 的表达式可以重写整个 ``for`` 循环：

.. code-block:: nim
    :test: "nim c $1"

  import macros
  {.experimental: "forLoopMacros".}

  macro enumerate(x: ForLoopStmt): untyped =
    expectKind x, nnkForStmt
    # we strip off the first for loop variable and use
    # it as an integer counter:
    result = newStmtList()
    result.add newVarStmt(x[0], newLit(0))
    var body = x[^1]
    if body.kind != nnkStmtList:
      body = newTree(nnkStmtList, body)
    body.add newCall(bindSym"inc", x[0])
    var newFor = newTree(nnkForStmt)
    for i in 1..x.len-3:
      newFor.add x[i]
    # transform enumerate(X) to 'X'
    newFor.add x[^2][1]
    newFor.add body
    result.add newFor
    # now wrap the whole macro in a block to create a new scope
    result = quote do:
      block: `result`

  for a, b in enumerate(items([1, 2, 3])):
    echo a, " ", b

  # 没有将宏包装在一个块中，我们需要在这里为`a`和`b`选择不同的名称以避免重定义错误
  for a, b in enumerate([1, 2, 3, 5]):
    echo a, " ", b


目前，必须通过 ``{.experimental: "forLoopMacros".}`` 显式启用循环宏。


特殊类型
=============

static[T]
---------

顾名思义，静态参数必须是常量表达式：

.. code-block:: nim

  proc precompiledRegex(pattern: static string): RegEx =
    var res {.global.} = re(pattern)
    return res

  precompiledRegex("/d+") # 用预编译的正则表达式替换调用，存储在全局变量中

  precompiledRegex(paramStr(1)) # 错误，命令行选项不是常量表达式


出于代码生成的目的，所有静态参数都被视为通用参数 -  proc将针对每个唯一提供的值（或值的组合）单独编译。

静态参数也可以出现在泛型类型的签名中：

.. code-block:: nim

  type
    Matrix[M,N: static int; T: Number] = array[0..(M*N - 1), T]
      # 注意 `Number` 在这里只是一个类型约束，而 `static int` 要求我们提供一个int值

    AffineTransform2D[T] = Matrix[3, 3, T]
    AffineTransform3D[T] = Matrix[4, 4, T]

  var m1: AffineTransform3D[float]  # 正确
  var m2: AffineTransform2D[string] # 错误 `string`不是`Number`

Please note that ``static T`` is just a syntactic convenience for the underlying generic type ``static[T]``. 
The type param can be omitted to obtain the type class of all constant expressions. 
A more specific type class can be created by instantiating ``static`` with another type class.

You can force an expression to be evaluated at compile time as a constant expression by coercing it to a corresponding ``static`` type:

.. code-block:: nim
  import math

  echo static(fac(5)), " ", static[bool](16.isPowerOfTwo)

The complier will report any failure to evaluate the expression or a possible type mismatch error.

typedesc[T]
-----------

在许多情况下，Nim允许您将类型的名称视为常规值。
这些值仅在编译阶段存在，但由于所有值必须具有类型，因此 ``typedesc`` 被视为其特殊类型。

``typedesc`` 就像一个通用类型。例如，符号 ``int`` 的类型是 ``typedesc [int]`` 。
就像常规泛型类型一样，当泛型参数被省略时，``typedesc``表示所有类型的类型类。
作为一种语法方便，您还可以使用``typedesc``作为修饰符。

具有 ``typedesc`` 参数的过程被认为是隐式通用的。
它们将针对提供的类型的每个唯一组合进行实例化，并且在proc的主体内，每个参数的名称将引用绑定的具体类型：

.. code-block:: nim

  proc new(T: typedesc): ref T =
    echo "allocating ", T.name
    new(result)

  var n = Node.new
  var tree = new(BinaryTree[int])

当存在多种类型的参数时，它们将自由地绑定到不同类型。
要强制绑定一次行为，可以使用显式通用参数：

.. code-block:: nim
  proc acceptOnlyTypePairs[T, U](A, B: typedesc[T]; C, D: typedesc[U])

绑定后，类型参数可以出现在proc签名的其余部分中：

.. code-block:: nim
    :test: "nim c $1"

  template declareVariableWithType(T: typedesc, value: T) =
    var x: T = value

  declareVariableWithType int, 42

通过约束与类型参数匹配的类型集，可以进一步影响重载解析。
这在实践中通过模板将属性附加到类型。
约束可以是具体类型或类型类。


.. code-block:: nim
    :test: "nim c $1"

  template maxval(T: typedesc[int]): int = high(int)
  template maxval(T: typedesc[float]): float = Inf

  var i = int.maxval
  var f = float.maxval
  when false:
    var s = string.maxval # error, maxval is not implemented for string

  template isNumber(t: typedesc[object]): string = "Don't think so."
  template isNumber(t: typedesc[SomeInteger]): string = "Yes!"
  template isNumber(t: typedesc[SomeFloat]): string = "Maybe, could be NaN."

  echo "is int a number? ", isNumber(int)
  echo "is float a number? ", isNumber(float)
  echo "is RootObj a number? ", isNumber(RootObj)

传递 ``typedesc`` 几乎完全相同，只是因为宏没有一般地实例化。
类型表达式简单地作为 ``NimNode`` 传递给宏，就像其他所有东西一样。

.. code-block:: nim

  import macros

  macro forwardType(arg: typedesc): typedesc =
    # ``arg`` is of type ``NimNode``
    let tmp: NimNode = arg
    result = tmp

  var tmp: forwardType(int)

typeof操作符
---------------

**注意**: ``typeof(x)`` 由于历史原因也可以写成 ``type(x)`` ，但不鼓励。

您可以通过从中构造一个``typeof``值来获取给定表达式的类型（在许多其他语言中，这被称为 `typeof`:idx: 操作符):

.. code-block:: nim

  var x = 0
  var y: typeof(x) # y has type int


如果 ``typeof`` 用于确定proc/iterator/converter ``c(X)`` 调用的结果类型（其中``X``代表可能为空的参数列表），首选将 ``c`` 解释为迭代器，这种可以通过将 ``typeOfProc`` 作为第二个参数传递给 ``typeof`` 来改变：

.. code-block:: nim
    :test: "nim c $1"

  iterator split(s: string): string = discard
  proc split(s: string): seq[string] = discard

  # 因为迭代器是首选解释，`y` 的类型为 ``string`` ：
  assert typeof("a b c".split) is string

  assert typeof("a b c".split, typeOfProc) is seq[string]

模块
=======
Nim supports splitting a program into pieces by a module concept.
Each module needs to be in its own file and has its own `namespace`:idx:.
Modules enable `information hiding`:idx: and `separate compilation`:idx:.
A module may gain access to symbols of another module by the `import`:idx: statement. 
`Recursive module dependencies`:idx: are allowed, but slightly subtle. 
Only top-level symbols that are marked with an asterisk (``*``) are exported. 
A valid module name can only be a valid Nim identifier (and thus its filename is ``identifier.nim``).

The algorithm for compiling modules is:

- compile the whole module as usual, following import statements recursively

- if there is a cycle only import the already parsed symbols (that are
  exported); if an unknown identifier occurs then abort

这可以通过一个例子来说明：

.. code-block:: nim
  # Module A
  type
    T1* = int  # Module A exports the type ``T1``
  import B     # the compiler starts parsing B

  proc main() =
    var i = p(3) # works because B has been parsed completely here

  main()


.. code-block:: nim
  # Module B
  import A  # A is not parsed here! Only the already known symbols
            # of A are imported.

  proc p*(x: A.T1): A.T1 =
    # this works because the compiler has already
    # added T1 to A's interface symbol table
    result = x + 1


Import语句
~~~~~~~~~~~~~~~~

After the ``import`` statement a list of module names can follow or a single module name followed by an ``except`` list to prevent some symbols to be imported:

.. code-block:: nim
    :test: "nim c $1"
    :status: 1

  import strutils except `%`, toUpperAscii

  # doesn't work then:
  echo "$1" % "abc".toUpperAscii


It is not checked that the ``except`` list is really exported from the module.
This feature allows to compile against an older version of the module that does not export these identifiers.


Include语句
~~~~~~~~~~~~~~~~~
The ``include`` statement does something fundamentally different than importing a module: it merely includes the contents of a file. 
The ``include`` statement is useful to split up a large module into several files:

.. code-block:: nim
  include fileA, fileB, fileC



导入的模块名
~~~~~~~~~~~~~~~~~~~~~~~

A module alias can be introduced via the ``as`` keyword:

.. code-block:: nim
  import strutils as su, sequtils as qu

  echo su.format("$1", "lalelu")

The original module name is then not accessible. The notations
``path/to/module`` or ``"path/to/module"`` can be used to refer to a module
in subdirectories:

.. code-block:: nim
  import lib/pure/os, "lib/pure/times"

Note that the module name is still ``strutils`` and not ``lib/pure/strutils``
and so one **cannot** do:

.. code-block:: nim
  import lib/pure/strutils
  echo lib/pure/strutils.toUpperAscii("abc")

Likewise the following does not make sense as the name is ``strutils`` already:

.. code-block:: nim
  import lib/pure/strutils as strutils


从目录中集体导入
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The syntax ``import dir / [moduleA, moduleB]`` can be used to import multiple modules
from the same directory.

Path names are syntactically either Nim identifiers or string literals. If the path
name is not a valid Nim identifier it needs to be a string literal:

.. code-block:: nim
  import "gfx/3d/somemodule" # in quotes because '3d' is not a valid Nim identifier


Pseudo import/include paths
~~~~~~~~~~~~~~~~~~~~~~~~~~~

A directory can also be a so called "pseudo directory". They can be used to
avoid ambiguity when there are multiple modules with the same path.

There are two pseudo directories:

1. ``std``: The ``std`` pseudo directory is the abstract location of Nim's standard
library. For example, the syntax ``import std / strutils`` is used to unambiguously
refer to the standard library's ``strutils`` module.
2. ``pkg``: The ``pkg`` pseudo directory is used to unambiguously refer to a Nimble
package. However, for technical details that lie outside of the scope of this document
its semantics are: *Use the search path to look for module name but ignore the standard
library locations*. In other words, it is the opposite of ``std``.


From import语句
~~~~~~~~~~~~~~~~~~~~~

After the ``from`` statement a module name follows followed by
an ``import`` to list the symbols one likes to use without explicit
full qualification:

.. code-block:: nim
    :test: "nim c $1"

  from strutils import `%`

  echo "$1" % "abc"
  # always possible: full qualification:
  echo strutils.replace("abc", "a", "z")

It's also possible to use ``from module import nil`` if one wants to import
the module but wants to enforce fully qualified access to every symbol
in ``module``.


Export语句
~~~~~~~~~~~~~~~~

An ``export`` statement can be used for symbol forwarding so that client
modules don't need to import a module's dependencies:

.. code-block:: nim
  # module B
  type MyObject* = object

.. code-block:: nim
  # module A
  import B
  export B.MyObject

  proc `$`*(x: MyObject): string = "my object"


.. code-block:: nim
  # module C
  import A

  # B.MyObject has been imported implicitly here:
  var x: MyObject
  echo $x

When the exported symbol is another module, all of its definitions will
be forwarded. You can use an ``except`` list to exclude some of the symbols.

Notice that when exporting, you need to specify only the module name:

.. code-block:: nim
  import foo/bar/baz
  export baz



作用域规则
-----------
Identifiers are valid from the point of their declaration until the end of
the block in which the declaration occurred. The range where the identifier
is known is the scope of the identifier. The exact scope of an
identifier depends on the way it was declared.

块作用域
~~~~~~~~~~~
The *scope* of a variable declared in the declaration part of a block
is valid from the point of declaration until the end of the block. If a
block contains a second block, in which the identifier is redeclared,
then inside this block, the second declaration will be valid. Upon
leaving the inner block, the first declaration is valid again. An
identifier cannot be redefined in the same block, except if valid for
procedure or iterator overloading purposes.


元组或对象作用域
~~~~~~~~~~~~~~~~~~~~~
The field identifiers inside a tuple or object definition are valid in the
following places:

* To the end of the tuple/object definition.
* Field designators of a variable of the given tuple/object type.
* In all descendant types of the object type.

模块作用域
~~~~~~~~~~~~
All identifiers of a module are valid from the point of declaration until
the end of the module. Identifiers from indirectly dependent modules are *not*
available. The `system`:idx: module is automatically imported in every module.

If a module imports an identifier by two different modules, each occurrence of
the identifier has to be qualified, unless it is an overloaded procedure or
iterator in which case the overloading resolution takes place:

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
  write(stdout, A.x) # no error: qualifier used

  var x = 4
  write(stdout, x) # not ambiguous: uses the module C's x

代码重排
~~~~~~~~~~~~~~~

**Note**: Code reordering is experimental and must be enabled via the``{.experimental.}`` pragma.

The code reordering feature can implicitly rearrange procedure, template, and
macro definitions along with variable declarations and initializations at the top
level scope so that, to a large extent, a programmer should not have to worry
about ordering definitions correctly or be forced to use forward declarations to
preface definitions inside a module.

..
   NOTE: The following was documentation for the code reordering precursor,
   which was {.noForward.}.

   In this mode, procedure definitions may appear out of order and the compiler
   will postpone their semantic analysis and compilation until it actually needs
   to generate code using the definitions. In this regard, this mode is similar
   to the modus operandi of dynamic scripting languages, where the function
   calls are not resolved until the code is executed. Here is the detailed
   algorithm taken by the compiler:

   1. When a callable symbol is first encountered, the compiler will only note
   the symbol callable name and it will add it to the appropriate overload set
   in the current scope. At this step, it won't try to resolve any of the type
   expressions used in the signature of the symbol (so they can refer to other
   not yet defined symbols).

   2. When a top level call is encountered (usually at the very end of the
   module), the compiler will try to determine the actual types of all of the
   symbols in the matching overload set. This is a potentially recursive process
   as the signatures of the symbols may include other call expressions, whose
   types will be resolved at this point too.

   3. Finally, after the best overload is picked, the compiler will start
   compiling the body of the respective symbol. This in turn will lead the
   compiler to discover more call expressions that need to be resolved and steps
   2 and 3 will be repeated as necessary.

   Please note that if a callable symbol is never used in this scenario, its
   body will never be compiled. This is the default behavior leading to best
   compilation times, but if exhaustive compilation of all definitions is
   required, using ``nim check`` provides this option as well.

示例：

.. code-block:: nim

  {.experimental: "codeReordering".}

  proc foo(x: int) =
    bar(x)

  proc bar(x: int) =
    echo(x)

  foo(10)

Variables can also be reordered as well. Variables that are *initialized* (i.e.
variables that have their declaration and assignment combined in a single
statement) can have their entire initialization statement reordered. Be wary of
what code is executed at the top level:

.. code-block:: nim
  {.experimental: "codeReordering".}

  proc a() =
    echo(foo)

  var foo = 5

  a() # outputs: "5"

..
   TODO: Let's table this for now. This is an *experimental feature* and so the
   specific manner in which ``declared`` operates with it can be decided in
   eventuality, because right now it works a bit weirdly.

   The values of expressions involving ``declared`` are decided *before* the
   code reordering process, and not after. As an example, the output of this
   code is the same as it would be with code reordering disabled.

   .. code-block:: nim
     {.experimental: "codeReordering".}

     proc x() =
       echo(declared(foo))

     var foo = 4

     x() # "false"

It is important to note that reordering *only* works for symbols at top level
scope. Therefore, the following will *fail to compile:*

.. code-block:: nim
  {.experimental: "codeReordering".}

  proc a() =
    b()
    proc b() =
      echo("Hello!")

  a()

编译器消息
=================

The Nim compiler emits different kinds of messages: `hint`:idx:,
`warning`:idx:, and `error`:idx: messages. An *error* message is emitted if
the compiler encounters any static error.



编译指示
=======

Pragmas are Nim's method to give the compiler additional information /
commands without introducing a massive number of new keywords. Pragmas are
processed on the fly during semantic checking. Pragmas are enclosed in the
special ``{.`` and ``.}`` curly brackets. Pragmas are also often used as a
first implementation to play with a language feature before a nicer syntax
to access the feature becomes available.


deprecated 编译指示
-----------------

The deprecated pragma is used to mark a symbol as deprecated:

.. code-block:: nim
  proc p() {.deprecated.}
  var x {.deprecated.}: char

This pragma can also take in an optional warning string to relay to developers.

.. code-block:: nim
  proc thing(x: bool) {.deprecated: "use thong instead".}


noSideEffect 编译指示
-------------------

The ``noSideEffect`` pragma is used to mark a proc/iterator to have no side
effects. This means that the proc/iterator only changes locations that are
reachable from its parameters and the return value only depends on the
arguments. If none of its parameters have the type ``var T``
or ``ref T`` or ``ptr T`` this means no locations are modified. It is a static
error to mark a proc/iterator to have no side effect if the compiler cannot
verify this.

As a special semantic rule, the built-in `debugEcho <system.html#debugEcho>`_
pretends to be free of side effects, so that it can be used for debugging
routines marked as ``noSideEffect``.

``func`` is syntactic sugar for a proc with no side effects:

.. code-block:: nim
  func `+` (x, y: int): int


To override the compiler's side effect analysis a ``{.noSideEffect.}``
pragma block can be used:

.. code-block:: nim

  func f() =
    {.noSideEffect.}:
      echo "test"


compileTime 编译指示
------------------
The ``compileTime`` pragma is used to mark a proc or variable to be used only
during compile-time execution. No code will be generated for it. Compile-time
procs are useful as helpers for macros. Since version 0.12.0 of the language, a
proc that uses ``system.NimNode`` within its parameter types is implicitly
declared ``compileTime``:

.. code-block:: nim
  proc astHelper(n: NimNode): NimNode =
    result = n

Is the same as:

.. code-block:: nim
  proc astHelper(n: NimNode): NimNode {.compileTime.} =
    result = n


noReturn 编译指示
---------------
The ``noreturn`` pragma is used to mark a proc that never returns.


acyclic 编译指示
--------------
The ``acyclic`` pragma applies to type declarations. It is deprecated and
ignored.


final 编译指示
------------
The ``final`` pragma can be used for an object type to specify that it
cannot be inherited from. Note that inheritance is only available for
objects that inherit from an existing object (via the ``object of SuperType``
syntax) or that have been marked as ``inheritable``.


shallow 编译指示
--------------
The ``shallow`` pragma affects the semantics of a type: The compiler is
allowed to make a shallow copy. This can cause serious semantic issues and
break memory safety! However, it can speed up assignments considerably,
because the semantics of Nim require deep copying of sequences and strings.
This can be expensive, especially if sequences are used to build a tree
structure:

.. code-block:: nim
  type
    NodeKind = enum nkLeaf, nkInner
    Node {.shallow.} = object
      case kind: NodeKind
      of nkLeaf:
        strVal: string
      of nkInner:
        children: seq[Node]


pure 编译指示
-----------
An object type can be marked with the ``pure`` pragma so that its type field
which is used for runtime type identification is omitted. This used to be
necessary for binary compatibility with other compiled languages.

An enum type can be marked as ``pure``. Then access of its fields always
requires full qualification.


asmNoStackFrame 编译指示
----------------------
A proc can be marked with the ``asmNoStackFrame`` pragma to tell the compiler
it should not generate a stack frame for the proc. There are also no exit
statements like ``return result;`` generated and the generated C function is
declared as ``__declspec(naked)`` or ``__attribute__((naked))`` (depending on
the used C compiler).

**Note**: This pragma should only be used by procs which consist solely of
assembler statements.

error 编译指示
------------
The ``error`` pragma is used to make the compiler output an error message
with the given content. Compilation does not necessarily abort after an error
though.

The ``error`` pragma can also be used to
annotate a symbol (like an iterator or proc). The *usage* of the symbol then
triggers a static error. This is especially useful to rule out that some
operation is valid due to overloading and type conversions:

.. code-block:: nim
  ## check that underlying int values are compared and not the pointers:
  proc `==`(x, y: ptr int): bool {.error.}


fatal 编译指示
------------
The ``fatal`` pragma is used to make the compiler output an error message
with the given content. In contrast to the ``error`` pragma, compilation
is guaranteed to be aborted by this pragma. 示例：

.. code-block:: nim
  when not defined(objc):
    {.fatal: "Compile this program with the objc command!".}

warning 编译指示
--------------
The ``warning`` pragma is used to make the compiler output a warning message
with the given content. Compilation continues after the warning.

hint 编译指示
-----------
The ``hint`` pragma is used to make the compiler output a hint message with
the given content. Compilation continues after the hint.

line 编译指示
-----------
The ``line`` pragma can be used to affect line information of the annotated
statement as seen in stack backtraces:

.. code-block:: nim

  template myassert*(cond: untyped, msg = "") =
    if not cond:
      # change run-time line information of the 'raise' statement:
      {.line: instantiationInfo().}:
        raise newException(EAssertionFailed, msg)

If the ``line`` pragma is used with a parameter, the parameter needs be a
``tuple[filename: string, line: int]``. If it is used without a parameter,
``system.InstantiationInfo()`` is used.


linearScanEnd 编译指示
--------------------
The ``linearScanEnd`` pragma can be used to tell the compiler how to
compile a Nim `case`:idx: statement. Syntactically it has to be used as a
statement:

.. code-block:: nim
  case myInt
  of 0:
    echo "most common case"
  of 1:
    {.linearScanEnd.}
    echo "second most common case"
  of 2: echo "unlikely: use branch table"
  else: echo "unlikely too: use branch table for ", myInt

In the example, the case branches ``0`` and ``1`` are much more common than
the other cases. Therefore the generated assembler code should test for these
values first, so that the CPU's branch predictor has a good chance to succeed
(avoiding an expensive CPU pipeline stall). The other cases might be put into a
jump table for O(1) overhead, but at the cost of a (very likely) pipeline
stall.

The ``linearScanEnd`` pragma should be put into the last branch that should be
tested against via linear scanning. If put into the last branch of the
whole ``case`` statement, the whole ``case`` statement uses linear scanning.


computedGoto 编译指示
-------------------
The ``computedGoto`` pragma can be used to tell the compiler how to
compile a Nim `case`:idx: in a ``while true`` statement.
Syntactically it has to be used as a statement inside the loop:

.. code-block:: nim

  type
    MyEnum = enum
      enumA, enumB, enumC, enumD, enumE

  proc vm() =
    var instructions: array[0..100, MyEnum]
    instructions[2] = enumC
    instructions[3] = enumD
    instructions[4] = enumA
    instructions[5] = enumD
    instructions[6] = enumC
    instructions[7] = enumA
    instructions[8] = enumB

    instructions[12] = enumE
    var pc = 0
    while true:
      {.computedGoto.}
      let instr = instructions[pc]
      case instr
      of enumA:
        echo "yeah A"
      of enumC, enumD:
        echo "yeah CD"
      of enumB:
        echo "yeah B"
      of enumE:
        break
      inc(pc)

  vm()

As the example shows ``computedGoto`` is mostly useful for interpreters. If
the underlying backend (C compiler) does not support the computed goto
extension the pragma is simply ignored.


unroll 编译指示
-------------
The ``unroll`` pragma can be used to tell the compiler that it should unroll
a `for`:idx: or `while`:idx: loop for execution efficiency:

.. code-block:: nim
  proc searchChar(s: string, c: char): int =
    for i in 0 .. s.high:
      {.unroll: 4.}
      if s[i] == c: return i
    result = -1

In the above example, the search loop is unrolled by a factor 4. The unroll
factor can be left out too; the compiler then chooses an appropriate unroll
factor.

**Note**: Currently the compiler recognizes but ignores this pragma.


immediate 编译指示
----------------

The immediate pragma is obsolete. See `Typed vs untyped parameters`_.


compilation option pragmas
--------------------------
The listed pragmas here can be used to override the code generation options
for a proc/method/converter.

The implementation currently provides the following possible options (various
others may be added later).

===============  ===============  ============================================
pragma           allowed values   description
===============  ===============  ============================================
checks           on|off           Turns the code generation for all runtime
                                  checks on or off.
boundChecks      on|off           Turns the code generation for array bound
                                  checks on or off.
overflowChecks   on|off           Turns the code generation for over- or
                                  underflow checks on or off.
nilChecks        on|off           Turns the code generation for nil pointer
                                  checks on or off.
assertions       on|off           Turns the code generation for assertions
                                  on or off.
warnings         on|off           Turns the warning messages of the compiler
                                  on or off.
hints            on|off           Turns the hint messages of the compiler
                                  on or off.
optimization     none|speed|size  Optimize the code for speed or size, or
                                  disable optimization.
patterns         on|off           Turns the term rewriting templates/macros
                                  on or off.
callconv         cdecl|...        Specifies the default calling convention for
                                  all procedures (and procedure types) that
                                  follow.
===============  ===============  ============================================

示例：

.. code-block:: nim
  {.checks: off, optimization: speed.}
  # compile without runtime checks and optimize for speed


push and pop 编译指示
--------------------
The `push/pop`:idx: pragmas are very similar to the option directive,
but are used to override the settings temporarily. 示例：

.. code-block:: nim
  {.push checks: off.}
  # compile this section without runtime checks as it is
  # speed critical
  # ... some code ...
  {.pop.} # restore old settings


register 编译指示
---------------
The ``register`` pragma is for variables only. It declares the variable as
``register``, giving the compiler a hint that the variable should be placed
in a hardware register for faster access. C compilers usually ignore this
though and for good reasons: Often they do a better job without it anyway.

In highly specific cases (a dispatch loop of a bytecode interpreter for
example) it may provide benefits, though.


global 编译指示
-------------
The ``global`` pragma can be applied to a variable within a proc to instruct
the compiler to store it in a global location and initialize it once at program
startup.

.. code-block:: nim
  proc isHexNumber(s: string): bool =
    var pattern {.global.} = re"[0-9a-fA-F]+"
    result = s.match(pattern)

When used within a generic proc, a separate unique global variable will be
created for each instantiation of the proc. The order of initialization of
the created global variables within a module is not defined, but all of them
will be initialized after any top-level variables in their originating module
and before any variable in a module that imports it.

pragma 编译指示
-------------

The ``pragma`` pragma can be used to declare user defined pragmas. This is
useful because Nim's templates and macros do not affect pragmas. User
defined pragmas are in a different module-wide scope than all other symbols.
They cannot be imported from a module.

示例：

.. code-block:: nim
  when appType == "lib":
    {.pragma: rtl, exportc, dynlib, cdecl.}
  else:
    {.pragma: rtl, importc, dynlib: "client.dll", cdecl.}

  proc p*(a, b: int): int {.rtl.} =
    result = a+b

In the example a new pragma named ``rtl`` is introduced that either imports
a symbol from a dynamic library or exports the symbol for dynamic library
generation.

Disabling certain messages
--------------------------
Nim generates some warnings and hints ("line too long") that may annoy the
user. A mechanism for disabling certain messages is provided: Each hint
and warning message contains a symbol in brackets. This is the message's
identifier that can be used to enable or disable it:

.. code-block:: Nim
  {.hint[LineTooLong]: off.} # turn off the hint about too long lines

This is often better than disabling all warnings at once.


used 编译指示
-----------

Nim produces a warning for symbols that are not exported and not used either.
The ``used`` pragma can be attached to a symbol to suppress this warning. This
is particularly useful when the symbol was generated by a macro:

.. code-block:: nim
  template implementArithOps(T) =
    proc echoAdd(a, b: T) {.used.} =
      echo a + b
    proc echoSub(a, b: T) {.used.} =
      echo a - b

  # no warning produced for the unused 'echoSub'
  implementArithOps(int)
  echoAdd 3, 5



experimental 编译指示
-------------------

The ``experimental`` pragma enables experimental language features. Depending
on the concrete feature this means that the feature is either considered
too unstable for an otherwise stable release or that the future of the feature
is uncertain (it may be removed any time).

示例：

.. code-block:: nim
  {.experimental: "parallel".}

  proc useParallel() =
    parallel:
      for i in 0..4:
        echo "echo in parallel"


As a top level statement, the experimental pragma enables a feature for the
rest of the module it's enabled in. This is problematic for macro and generic
instantiations that cross a module scope. Currently these usages have to be
put into a ``.push/pop`` environment:

.. code-block:: nim

  # client.nim
  proc useParallel*[T](unused: T) =
    # use a generic T here to show the problem.
    {.push experimental: "parallel".}
    parallel:
      for i in 0..4:
        echo "echo in parallel"

    {.pop.}


.. code-block:: nim

  import client
  useParallel(1)


特定实现的编译指示
===============================

This section describes additional pragmas that the current Nim implementation
supports but which should not be seen as part of the language specification.

Bitsize 编译指示
--------------

The ``bitsize`` 编译指示 is for object field members. It declares the field as
a bitfield in C/C++.

.. code-block:: Nim
  type
    mybitfield = object
      flag {.bitsize:1.}: cuint

generates:

.. code-block:: C
  struct mybitfield {
    unsigned int flag:1;
  };


Volatile 编译指示
---------------
The ``volatile`` pragma is for variables only. It declares the variable as
``volatile``, whatever that means in C/C++ (its semantics are not well defined
in C/C++).

**Note**: This pragma will not exist for the LLVM backend.


NoDecl 编译指示
-------------
The ``noDecl`` pragma can be applied to almost any symbol (variable, proc,
type, etc.) and is sometimes useful for interoperability with C:
It tells Nim that it should not generate a declaration for the symbol in
the C code. For 示例：

.. code-block:: Nim
  var
    EACCES {.importc, noDecl.}: cint # pretend EACCES was a variable, as
                                     # Nim does not know its value

However, the ``header`` pragma is often the better alternative.

**Note**: This will not work for the LLVM backend.


Header编译指示
-------------
The ``header`` pragma is very similar to the ``noDecl`` pragma: It can be
applied to almost any symbol and specifies that it should not be declared
and instead the generated code should contain an ``#include``:

.. code-block:: Nim
  type
    PFile {.importc: "FILE*", header: "<stdio.h>".} = distinct pointer
      # import C's FILE* type; Nim will treat it as a new pointer type

The ``header`` pragma always expects a string constant. The string contant
contains the header file: As usual for C, a system header file is enclosed
in angle brackets: ``<>``. If no angle brackets are given, Nim
encloses the header file in ``""`` in the generated C code.

**Note**: This will not work for the LLVM backend.


IncompleteStruct 编译指示
-----------------------
The ``incompleteStruct`` pragma tells the compiler to not use the
underlying C ``struct`` in a ``sizeof`` expression:

.. code-block:: Nim
  type
    DIR* {.importc: "DIR", header: "<dirent.h>",
           pure, incompleteStruct.} = object


Compile编译指示
--------------
The ``compile`` 编译指示 can be used to compile and link a C/C++ source file
with the project:

.. code-block:: Nim
  {.compile: "myfile.cpp".}

**Note**: Nim computes a SHA1 checksum and only recompiles the file if it
has changed. You can use the ``-f`` command line option to force recompilation
of the file.


Link编译指示
-----------
The ``link`` 编译指示 can be used to link an additional file with the project:

.. code-block:: Nim
  {.link: "myfile.o".}


PassC编译指示
------------
The ``passC`` 编译指示 can be used to pass additional parameters to the C
compiler like you would using the commandline switch ``--passC``:

.. code-block:: Nim
  {.passC: "-Wall -Werror".}

Note that you can use ``gorge`` from the `system module <system.html>`_ to embed parameters from an external command that will be executed during semantic analysis:

.. code-block:: Nim
  {.passC: gorge("pkg-config --cflags sdl").}

PassL编译指示
------------
The ``passL`` 编译指示 can be used to pass additional parameters to the linker
like you would using the commandline switch ``--passL``:

.. code-block:: Nim
  {.passL: "-lSDLmain -lSDL".}

Note that you can use ``gorge`` from the `system module <system.html>`_ to
embed parameters from an external command that will be executed
during semantic analysis:

.. code-block:: Nim
  {.passL: gorge("pkg-config --libs sdl").}


Emit编译指示
-----------
The ``emit`` 编译指示 can be used to directly affect the output of the
compiler's code generator. So it makes your code unportable to other code
generators/backends. Its usage is highly discouraged! However, it can be
extremely useful for interfacing with `C++`:idx: or `Objective C`:idx: code.

示例：

.. code-block:: Nim
  {.emit: """
  static int cvariable = 420;
  """.}

  {.push stackTrace:off.}
  proc embedsC() =
    var nimVar = 89
    # access Nim symbols within an emit section outside of string literals:
    {.emit: ["""fprintf(stdout, "%d\n", cvariable + (int)""", nimVar, ");"].}
  {.pop.}

  embedsC()

``nimbase.h`` defines ``NIM_EXTERNC`` C macro that can be used for
``extern "C"`` code to work with both ``nim c`` and ``nim cpp``, eg:

.. code-block:: Nim
  proc foobar() {.importc:"$1".}
  {.emit: """
  #include <stdio.h>
  NIM_EXTERNC
  void fun(){}
  """.}

For backwards compatibility, if the argument to the ``emit`` statement
is a single string literal, Nim symbols can be referred to via backticks.
This usage is however deprecated.

For a toplevel emit statement the section where in the generated C/C++ file
the code should be emitted can be influenced via the
prefixes ``/*TYPESECTION*/`` or ``/*VARSECTION*/`` or ``/*INCLUDESECTION*/``:

.. code-block:: Nim
  {.emit: """/*TYPESECTION*/
  struct Vector3 {
  public:
    Vector3(): x(5) {}
    Vector3(float x_): x(x_) {}
    float x;
  };
  """.}

  type Vector3 {.importcpp: "Vector3", nodecl} = object
    x: cfloat

  proc constructVector3(a: cfloat): Vector3 {.importcpp: "Vector3(@)", nodecl}


ImportCpp编译指示
----------------

**注意**: `c2nim <https://github.com/nim-lang/c2nim/blob/master/doc/c2nim.rst>`_ 可以解析C++子集并且知道 ``importcpp`` 编译指示模式语言。 
没有必要知道这里描述的所有细节。


和 `importc pragma for C <#foreign-function-interface-importc-pragma>`_ 类似, ``importcpp`` 编译指示一般可以用于引入 `C++`:idx: 方法或C++符号。 
生成的代码会使用C++方法调用的语法: ``obj->method(arg)`` 。

结合 ``header`` 和 ``emit`` 编译指示，这允许与C++库的 *草率* 接口：  

.. code-block:: Nim
  # Horrible example of how to interface with a C++ engine ... ;-)

  {.link: "/usr/lib/libIrrlicht.so".}

  {.emit: """
  using namespace irr;
  using namespace core;
  using namespace scene;
  using namespace video;
  using namespace io;
  using namespace gui;
  """.}

  const
    irr = "<irrlicht/irrlicht.h>"

  type
    IrrlichtDeviceObj {.header: irr,
                        importcpp: "IrrlichtDevice".} = object
    IrrlichtDevice = ptr IrrlichtDeviceObj

  proc createDevice(): IrrlichtDevice {.
    header: irr, importcpp: "createDevice(@)".}
  proc run(device: IrrlichtDevice): bool {.
    header: irr, importcpp: "#.run(@)".}

需要告诉编译器生成C++（命令 ``cpp`` ）才能使其工作。
当编译器发射C++代码时，会定义条件符号 ``cpp`` 。


命名空间
~~~~~~~~~~

*草率接口* 示例使用 ``.emit`` 来生成 ``using namespace`` 声明。
通过 ``命名空间::标识符`` 符号来引用导入的名称通常要好得多：

.. code-block:: nim
  type
    IrrlichtDeviceObj {.header: irr,
                        importcpp: "irr::IrrlichtDevice".} = object


枚举Importcpp
~~~~~~~~~~~~~~~~~~~

当 ``importcpp`` 应用于枚举类型时，数字枚举值用C++枚举类型注释, 像这个示例： ``((TheCppEnum)(3))`` 。
（事实证明这是实现它的最简单方法。）


过程Importcpp
~~~~~~~~~~~~~~~~~~~

请注意，procs的 ``importcpp`` 变体使用了一种有点神秘的模式语言，以获得最大的灵活性：

- 哈希 ``#`` 符号被第一个或下一个参数替换。
哈希 ``#.`` 后面的一个点表示该调用应使用C++的点或箭头表示法。
- 符号 ``@`` 被剩下的参数替换，用逗号分隔。

示例：

.. code-block:: nim
  proc cppMethod(this: CppObj, a, b, c: cint) {.importcpp: "#.CppMethod(@)".}
  var x: ptr CppObj
  cppMethod(x[], 1, 2, 3)

Produces:

.. code-block:: C
  x->CppMethod(1, 2, 3)

作为一个特殊的规则来保持与旧版本的 ``importcpp`` 编译指示的向后兼容性，如果没有特殊的模式字符（任何一个 ``#'@`` ），那么认为是C++的点或箭头符号，所以上面的例子也可以写成：

.. code-block:: nim
  proc cppMethod(this: CppObj, a, b, c: cint) {.importcpp: "CppMethod".}

请注意，模式语言自然也涵盖了C++的运算符重载功能：

.. code-block:: nim
  proc vectorAddition(a, b: Vec3): Vec3 {.importcpp: "# + #".}
  proc dictLookup(a: Dict, k: Key): Value {.importcpp: "#[#]".}


- An apostrophe ``'`` followed by an integer ``i`` in the range 0..9
  is replaced by the i'th parameter *type*. The 0th position is the result
  type. This can be used to pass types to C++ function templates. Between
  the ``'`` and the digit an asterisk can be used to get to the base type
  of the type. (So it "takes away a star" from the type; ``T*`` becomes ``T``.)
  Two stars can be used to get to the element type of the element type etc.

示例：

.. code-block:: nim

  type Input {.importcpp: "System::Input".} = object
  proc getSubsystem*[T](): ptr T {.importcpp: "SystemManager::getSubsystem<'*0>()", nodecl.}

  let x: ptr Input = getSubsystem[Input]()

Produces:

.. code-block:: C
  x = SystemManager::getSubsystem<System::Input>()


- ``#@`` is a special case to support a ``cnew`` operation. 
  It is required so that the call expression is inlined directly, without going through a temporary location. 
  This is only required to circumvent a limitation of the current code generator.

For example C++'s ``new`` operator can be "imported" like this:

.. code-block:: nim
  proc cnew*[T](x: T): ptr T {.importcpp: "(new '*0#@)", nodecl.}

  # constructor of 'Foo':
  proc constructFoo(a, b: cint): Foo {.importcpp: "Foo(@)".}

  let x = cnew constructFoo(3, 4)

Produces:

.. code-block:: C
  x = new Foo(3, 4)

However, depending on the use case ``new Foo`` can also be wrapped like this instead:

.. code-block:: nim
  proc newFoo(a, b: cint): ptr Foo {.importcpp: "new Foo(@)".}

  let x = newFoo(3, 4)


封装构造函数
~~~~~~~~~~~~~~~~~~~~~

Sometimes a C++ class has a private copy constructor and so code like ``Class c = Class(1,2);`` must not be generated but instead ``Class c(1,2);``.
For this purpose the Nim proc that wraps a C++ constructor needs to be annotated with the `constructor`:idx: pragma. 
This pragma also helps to generate faster C++ code since construction then doesn't invoke the copy constructor:

.. code-block:: nim
  # 更好的'Foo'构建函数：
  proc constructFoo(a, b: cint): Foo {.importcpp: "Foo(@)", constructor.}


封装析构函数
~~~~~~~~~~~~~~~~~~~~
封装destruct由于Nim直接生成C++，所以任何析构函数都由C++编译器在作用域出口处隐式调用。
这意味着通常人们可以完全没有包装析构函数！
但是当需要显式调用它时，需要将其包装起来。
模式语言提供了所需的一切：

.. code-block:: nim
  proc destroyFoo(this: var Foo) {.importcpp: "#.~Foo()".}


对象的Importcpp
~~~~~~~~~~~~~~~~~~~~~

泛型 ``importcpp`` 的对象映射成C++模板。这意味着您可以轻松导入C++的模板，而无需对象类型的模式语言：

.. code-block:: nim
  type
    StdMap {.importcpp: "std::map", header: "<map>".} [K, V] = object
  proc `[]=`[K, V](this: var StdMap[K, V]; key: K; val: V) {.
    importcpp: "#[#] = #", header: "<map>".}

  var x: StdMap[cint, cdouble]
  x[6] = 91.4


Produces:

.. code-block:: C
  std::map<int, double> x;
  x[6] = 91.4;


- If more precise control is needed, the apostrophe ``'`` can be used in the
  supplied pattern to denote the concrete type parameters of the generic type.
  See the usage of the apostrophe operator in proc patterns for more details.

.. code-block:: nim

  type
    VectorIterator {.importcpp: "std::vector<'0>::iterator".} [T] = object

  var x: VectorIterator[cint]


Produces:

.. code-block:: C

  std::vector<int>::iterator x;


ImportObjC编译指示
-----------------
Similar to the `importc pragma for C <#foreign-function-interface-importc-pragma>`_ , the ``importobjc`` pragma can
be used to import `Objective C`:idx: methods.  The generated code then uses the
Objective C method calling syntax: ``[obj method param1: arg]``.
In addition with the ``header`` and ``emit`` pragmas this
allows *sloppy* interfacing with libraries written in Objective C:

.. code-block:: Nim
  # horrible example of how to interface with GNUStep ...

  {.passL: "-lobjc".}
  {.emit: """
  #include <objc/Object.h>
  @interface Greeter:Object
  {
  }

  - (void)greet:(long)x y:(long)dummy;
  @end

  #include <stdio.h>
  @implementation Greeter

  - (void)greet:(long)x y:(long)dummy
  {
    printf("Hello, World!\n");
  }
  @end

  #include <stdlib.h>
  """.}

  type
    Id {.importc: "id", header: "<objc/Object.h>", final.} = distinct int

  proc newGreeter: Id {.importobjc: "Greeter new", nodecl.}
  proc greet(self: Id, x, y: int) {.importobjc: "greet", nodecl.}
  proc free(self: Id) {.importobjc: "free", nodecl.}

  var g = newGreeter()
  g.greet(12, 34)
  g.free()

The compiler needs to be told to generate Objective C (command ``objc``) for
this to work. The conditional symbol ``objc`` is defined when the compiler
emits Objective C code.


CodegenDecl编译指示
------------------

The ``codegenDecl`` 编译指示 can be used to directly influence Nim's code
generator. It receives a format string that determines how the variable
or proc is declared in the generated code.

For variables $1 in the format string represents the type of the variable
and $2 is the name of the variable.

The following Nim code:

.. code-block:: nim
  var
    a {.codegenDecl: "$# progmem $#".}: int

will generate this C code:

.. code-block:: c
  int progmem a

For procedures $1 is the return type of the procedure, $2 is the name of
the procedure and $3 is the parameter list.

The following nim code:

.. code-block:: nim
  proc myinterrupt() {.codegenDecl: "__interrupt $# $#$#".} =
    echo "realistic interrupt handler"

will generate this code:

.. code-block:: c
  __interrupt void myinterrupt()


InjectStmt编译指示
-----------------

The ``injectStmt`` 编译指示can be used to inject a statement before every other statement in the current module. 
It is only supposed to be used for debugging:

.. code-block:: nim
  {.injectStmt: gcInvariants().}

  # ... complex code here that produces crashes ...

编译期定义的编译指示
---------------------------

此处列出的编译指示可用于在编译时选择接受-d /--define选项中的值。

该实现目前提供以下可能的选项（稍后可以添加各种其他选项）。

=================  ============================================
pragma             description
=================  ============================================
`intdefine`:idx:   读取构建时定义为整数
`strdefine`:idx:   读取构建时定义为字符串
`booldefine`:idx:  读取构建时定义为bool
=================  ============================================

.. code-block:: nim
   const FooBar {.intdefine.}: int = 5
   echo FooBar

::
   nim c -d:FooBar=42 foobar.nim

In the above example, providing the -d flag causes the symbol
``FooBar`` to be overwritten at compile time, printing out 42. If the
``-d:FooBar=42`` were to be omitted, the default value of 5 would be
used. To see if a value was provided, `defined(FooBar)` can be used.

The syntax `-d:flag` is actually just a shortcut for `-d:flag=true`.

自定义标注
------------------
It is possible to define custom typed pragmas. Custom pragmas do not effect
code generation directly, but their presence can be detected by macros.
Custom pragmas are defined using templates annotated with pragma ``pragma``:

.. code-block:: nim
  template dbTable(name: string, table_space: string = "") {.pragma.}
  template dbKey(name: string = "", primary_key: bool = false) {.pragma.}
  template dbForeignKey(t: typedesc) {.pragma.}
  template dbIgnore {.pragma.}


Consider stylized example of possible Object Relation Mapping (ORM) implementation:

.. code-block:: nim
  const tblspace {.strdefine.} = "dev" # switch for dev, test and prod environments

  type
    User {.dbTable("users", tblspace).} = object
      id {.dbKey(primary_key = true).}: int
      name {.dbKey"full_name".}: string
      is_cached {.dbIgnore.}: bool
      age: int

    UserProfile {.dbTable("profiles", tblspace).} = object
      id {.dbKey(primary_key = true).}: int
      user_id {.dbForeignKey: User.}: int
      read_access: bool
      write_access: bool
      admin_acess: bool

In this example custom pragmas are used to describe how Nim objects are
mapped to the schema of the relational database. Custom pragmas can have
zero or more arguments. In order to pass multiple arguments use one of
template call syntaxes. All arguments are typed and follow standard
overload resolution rules for templates. Therefore, it is possible to have
default values for arguments, pass by name, varargs, etc.

Custom pragmas can be used in all locations where ordinary pragmas can be
specified. It is possible to annotate procs, templates, type and variable
definitions, statements, etc.

Macros module includes helpers which can be used to simplify custom pragma
access `hasCustomPragma`, `getCustomPragmaVal`. Please consult macros module
documentation for details. These macros are no magic, they don't do anything
you cannot do yourself by walking AST object representation.

More examples with custom pragmas:

- Better serialization/deserialization control:

.. code-block:: nim
  type MyObj = object
    a {.dontSerialize.}: int
    b {.defaultDeserialize: 5.}: int
    c {.serializationKey: "_c".}: string

- Adopting type for gui inspector in a game engine:

.. code-block:: nim
  type MyComponent = object
    position {.editable, animatable.}: Vector3
    alpha {.editRange: [0.0..1.0], animatable.}: float32




外部函数接口
==========================

Nim的 `FFI`:idx: (外部函数接口) 非常广泛，这里只记载扩展到其它未来后端的部分 (如 LLVM/JavaScript后端)。


Importc编译指示
--------------
``importc`` 编译指示提供了一种从C导入proc或变量的方法。
可选参数是包含C标识符的字符串。
如果缺少参数，则C名称与Nim标识符 *拼写完全相同* ：

.. code-block::
  proc printf(formatstr: cstring) {.header: "<stdio.h>", importc: "printf", varargs.}

请注意，此pragma有点用词不当：其他后端确实在同一名称下提供相同的功能。

此外，如果一个人正在与C++接口，那么 `ImportCpp pragma <manual.html＃implementation-specific-pragmas-importcpp-pragma>`_ 并与Objective-C连接 `importObjC pragma <manual.html＃implementation-specific-pragmas- importobjc-pragma>`_ 可以使用。

传递给``importc``的字符串字面值可以是格式字符串：

.. code-block:: Nim
  proc p(s: cstring) {.importc: "prefix$1".}

在示例中，``p`` 的外部名称设置为 ``prefixp`` 。
只有 ``$1`` 可用，字面值美元符号必须写成 ``$$`` 。


Exportc编译指示
--------------
The ``exportc`` pragma provides a means to export a type, a variable, or a procedure to C. 
Enums and constants can't be exported. 
The optional argument is a string containing the C identifier.  
If the argument is missing, the C name is the Nim identifier *exactly as spelled*:

.. code-block:: Nim
  proc callme(formatstr: cstring) {.exportc: "callMe", varargs.}

Note that this pragma is somewhat of a misnomer: Other backends do provide
the same feature under the same name.

The string literal passed to ``exportc`` can be a format string:

.. code-block:: Nim
  proc p(s: string) {.exportc: "prefix$1".} =
    echo s

In the example the external name of ``p`` is set to ``prefixp``. 
Only ``$1`` is available and a literal dollar sign must be written as ``$$``.



Extern编译指示
-------------
Like ``exportc`` or ``importc``, the ``extern`` pragma affects name
mangling. The string literal passed to ``extern`` can be a format string:

.. code-block:: Nim
  proc p(s: string) {.extern: "prefix$1".} =
    echo s

In the example the external name of ``p`` is set to ``prefixp``. Only ``$1``
is available and a literal dollar sign must be written as ``$$``.



Bycopy编译指示
-------------

``bycopy`` 编译指示可以应用于对象或元组类型，并指示编译器按类型将类型传递给procs：

.. code-block:: nim
  type
    Vector {.bycopy.} = object
      x, y, z: float


Byref编译指示
------------

``byref`` 编译指示可以应用于对象或元组类型，并指示编译器通过引用（隐藏指针）将类型传递给procs。


Varargs编译指示
--------------
``varargs`` 编译指示只适用于过程 (和过程类型)。 
它告诉Nim proc可以在最后指定的参数获取可变数量的参数。
Nim字符串值将自动转换为C字符串：

.. code-block:: Nim
  proc printf(formatstr: cstring) {.nodecl, varargs.}

  printf("hallo %s", "world") # "world"将作为C字符串传递


Union编译指示
------------
``union`` 编译指示适用于任何 ``对象`` 类型。 这意味着所有对象的字段在内存中是重叠的。 
这会在生成的C / C ++代码中生成一个 ``union`` 而不是 ``struct`` 。
然后，对象声明不能使用继承或任何GC的内存，但目前尚不做检查。

**未来方向**: 应该允许在联合中使用GC内存并且GC应当保守地扫描联合。

Packed编译指示
-------------
``packed`` 编译指示适用于任何 ``对象`` 类型。
它确保对象的字段打包在连续的内存中。 
将数据包或消息存储到网络或硬件驱动程序以及与C的互操作性非常有用。
没有定义packed编译指示的继承用法，且不应该与GC的内存（ref）一起使用。

**未来方向**: 在packed pragma中使用GC内存将导致静态错误。应该定义和记录继承的用法。


用于导入的Dynlib编译指示
------------------------
使用 ``dynlib`` 编译指示，可以从动态库（Windows的 ``.dll`` 文件，UNIX的 ``lib*.so`` 文件）导入过程或变量。

.. code-block:: Nim
  proc gtk_image_new(): PGtkWidget
    {.cdecl, dynlib: "libgtk-x11-2.0.so", importc.}

通常，导入动态库不需要任何特殊的链接器选项或链接到导入库。
这也意味着不需要安装 *开发* 包。

``dynlib`` 导入机制支持版本控制方案：

.. code-block:: nim
  proc Tcl_Eval(interp: pTcl_Interp, script: cstring): int {.cdecl,
    importc, dynlib: "libtcl(|8.5|8.4|8.3).so.(1|0)".}

在运行时，按此顺序搜索动态库

  libtcl.so.1
  libtcl.so.0
  libtcl8.5.so.1
  libtcl8.5.so.0
  libtcl8.4.so.1
  libtcl8.4.so.0
  libtcl8.3.so.1
  libtcl8.3.so.0

``dynlib`` 编译指示不仅支持常量字符串作为参数，还支持字符串表达式：

.. code-block:: nim
  import os

  proc getDllName: string =
    result = "mylib.dll"
    if existsFile(result): return
    result = "mylib2.dll"
    if existsFile(result): return
    quit("could not load dynamic library")

  proc myImport(s: cstring) {.cdecl, importc, dynlib: getDllName().}

**注意**: 形如 ``libtcl(|8.5|8.4).so`` 只支持常量字符串，因为它们需要预编译。

**注意**: 传变量给 ``dynlib`` pragma 在进行时会失败，因为初始化问题的顺序。

**注意**: ``dynlib`` 导入可以用 ``--dynlibOverride:name`` 命令行选项重写。
编译器用户指南包括更多信息。


用于导出的Dynlib编译指示
------------------------

过程可以用 ``dynlib`` 编译指示导出到一个动态库。
编译指示没有实参而且必须和 ``exportc`` 拼接在一起:

.. code-block:: Nim
  proc exportme(): int {.cdecl, exportc, dynlib.}

这只有当程序通过 ``--app:lib`` 命令行选项编译为动态库时有用。
此编译指示仅对Windows目标上的代码生成有影响，因此当忘写并且仅在Mac和/或Linux上测试动态库时，不会出现错误。
在Windows上，这个编译指示在函数声明中添加了 ``__declspec(dllexport)`` 。



线程
=======

要启用线程支持，需要使用 ``--threads:on`` 命令行开关。
然后 ``system`` 模块包含几个线程原语。
请参阅低级线程API `threads <threads.html>`_ 和 `channels <channels.html>`_  模块。
还有高级并行结构可用。见 `spawn <manual_experimental.html#parallel-amp-spawn>`_ 更多细节。

Nim's memory model for threads is quite different than that of other common programming languages (C, Pascal, Java): Each thread has its own (garbage collected) heap and sharing of memory is restricted to global variables. 
This helps to prevent race conditions. GC efficiency is improved quite a lot, because the GC never has to stop other threads and see what they reference.


Thread编译指示
-------------

A proc that is executed as a new thread of execution should be marked by the ``thread`` pragma for reasons of readability. 
The compiler checks for violations of the `no heap sharing restriction`:idx:\: This restriction implies that it is invalid to construct a data structure that consists of memory allocated from different (thread local) heaps.

A thread proc is passed to ``createThread`` or ``spawn`` and invoked indirectly; so the ``thread`` pragma implies ``procvar``.


GC安全
---------
我们称过程 ``p`` `GC安全`:idx: ，当它不通过调用GC不安全的过程直接或间接访问任何含有GC内存的全局变量(``string``, ``seq``, ``ref`` 或闭包)。

The `gcsafe`:idx: annotation can be used to mark a proc to be gcsafe, otherwise this property is inferred by the compiler. 
Note that ``noSideEffect`` implies ``gcsafe``. The only way to create a thread is via ``spawn`` or ``createThread``. 
The invoked proc must not use ``var`` parameters nor must any of its parameters contain a ``ref`` or ``closure`` type. 
This enforces the *no heap sharing restriction*.

Routines that are imported from C are always assumed to be ``gcsafe``.
To disable the GC-safety checking the ``--threadAnalysis:off`` command line switch can be used. 
This is a temporary workaround to ease the porting effort from old code to the new threading model.

To override the compiler's gcsafety analysis a ``{.gcsafe.}`` pragma block can be used:

.. code-block:: nim

  var
    someGlobal: string = "some string here"
    perThread {.threadvar.}: string

  proc setPerThread() =
    {.gcsafe.}:
      deepCopy(perThread, someGlobal)


Future directions:

- A shared GC'ed heap might be provided.


Threadvar编译指示
----------------

变量可以用 ``threadvar`` 编译指示标记，使它成为 `thread-local`:idx: 变量; 
另外，这意味着 ``global`` 编译指示的所有效果。

.. code-block:: nim
  var checkpoints* {.threadvar.}: seq[string]

由于实现限制，无法在 ``var`` 部分中初始化线程局部变量。
（在创建线程时需要复制每个线程局部变量。）


线程和异常
----------------------

线程和异常之间的交互很简单：一个线程中的 *处理过的* 异常不会影响任何其他线程。但是，一个线程中的 *未处理的* 异常终止整个 *进程* ！

