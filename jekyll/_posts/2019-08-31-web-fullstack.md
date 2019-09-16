---
title: "浅谈Nim Web开发"
author: sheldon
---

浅谈Nim Web开发

    Nim is a statically typed compiled systems programming language. 
    It combines successful concepts from mature languages like Python,Ada and Modula.

    Nim是一种静态类型编译的系统编程语言。
    它结合了来自成熟语言（如Python、Ada和Modula）的成功概念。

Nim中文网站：[https://nim-lang-cn.org/](https://nim-lang-cn.org/)

下载页：[https://nim-lang-cn.org/install.html](https://nim-lang-cn.org/install.html)

## 目录

1. [背景](#背景)

2. [技术点](#技术点)
    
    2.1 [立即模式](#立即模式)
    
    2.2 [使用Javascript模块](#使用Javascript模块)
    
    2.3 [Karax的虚拟DOM实现](#karax的虚拟DOM实现)
    
    2.4 [Web后端](#web后端)

## 背景
2015年接触到Nim的时候被它既有高级抽象又能编译成C的特性吸引，
当时正感到Go操作底层硬件的无力，
不能满足软硬兼施，
从云端做到底层嵌入式的技术发展需求。
有了学习Go语言的经验，
拿到Nim源码先从标准库开始看，
到了`dom.nim`，
发现Nim可以做Web前端，
这样想做的领域就统一了。
直到Karax的诞生，
Web开发的场景被全面覆盖，
在有一些预见之后，我们开始了对Karax的尝试。

重写的项目来自于一个layui和ThinkPHP框架的上线产品，
前端开发使用Karax，
后端使用Jester做Web服务，
用Websocket做长连接API通信。

没有Karax的文档，
仅从example和源码中一点点理解buildHtml和虚拟DOM的实现，
Karax和它的代码一样轻量，机制、组件、生态需要从零构建，
让我坚持下来的是相信它会带来不一样的Web开发体验，
而且这些体验和经验对于Nim GUI在三端的统一至关重要。

## 技术点
本系列将从理论和实践上分别展开，
对解决问题过程中使用的方法一一讲解，
旨在希望能够让大家理解和学会使用Karax。

* 理论上的重点在立即模式、渲染机制、虚拟DOM与DOM的映射，
这部分将主要根据Karax中的源码进行梳理；
* 实践上的重点在Javascript原生模块导入；
* 机制上，实现登录、退出、路由、页面加载数据、页面间传值、工作流、必选字段；
* 组件上，实现表格的翻页，动态设置每页显示数量，全选和单选的逻辑关系，即时响应搜索，日历。
    

### 立即模式
立即模式（immediate mode）是GUI的概念，
和立即模式相对的是保留模式（retained mode）,
关于两个模式比较形象的解释：
[https://blog.csdn.net/cvper/article/details/86568245](https://blog.csdn.net/cvper/article/details/86568245)

这意味着浏览器渲染的每一帧变化，和你看到的桌面软件、视频、游戏的连续变化等，从操作系统的层面看没有什么不同。在立即模式下虚拟DOM节点成为无状态的(stateless)节点，使用diff算法更新，这与React的diff算法一致。Web前端是GUI的一种表现形式，可以借助Nim的特性和立即模式思想的指导下扩展到GUI开发，加深对计算机底层的理解。对这方面感兴趣的同学，可以研究下[https://github.com/yglukhov/nimx](https://github.com/yglukhov/nimx)



### 使用Javascript模块

可以把这些模块写成pure的组件，我们采用简单的方式直接使用Echarts的函数，这涉及到FFI，Nim使用importc和importcpp与其后端语言交互。根据不同的Javascript模块类型，导入浏览器全局变量和方法。文档和源码看起，这里主要描述如何通过Javascript模块源码将需要使用的函数导入Karax。如根据Echarts的源码：

```javascript

(function (global, factory) {
    if (typeof exports === 'object' && typeof module !== 'undefined'){
        factory(exports) 
    }else if(typeof define === 'function' && define.amd ){
        define(['exports'], factory);
    }else{
        factory((global.echarts = {}));
    }
}(this, (function (exports) { 'use strict';
//...
var echartsProto = ECharts.prototype;
//...
echartsProto.setOption = function (option, notMerge, lazyUpdate) {...}
//...
function init(dom, theme$$1, opts) {...}
//...
exports.init = init;
//...
})));
```
得出

```nim
type
      EChart* = ref object
proc setOption*(x: EChart; option: JsonNode) {.importcpp.}
proc echartsInit*(n: Element): EChart {.importc: "echarts.init".}
```

项目中使用的另一个Javascript模块是`cryptojs`，用于加密从浏览器向后端传输的敏感信息。

从`crypotojs/components/md5.js`中：

```javascript
(function (Math) {
    var C = CryptoJS;
    var C_algo = C.algo;
    //...
    var MD5 = C_algo.MD5 = Hasher.extend({...})
```

和`core.js`中：

```javascript
var WordArray = C_lib.WordArray = Base.extend({
    //...
    toString: function (encoder) {
                return (encoder || Hex).stringify(this);
            },
```

得到：

```nim
var CryptoJS*{.importc.}: JsObject
proc MD5*(obj: JsObject, message: cstring): JsObject {.importcpp: "#.MD5(#)".}
proc toString*(obj: JsObject): cstring {.importcpp: "#.toString()".}
```
Javascript对象在Nim中用JsObject表示，可以使用.操作符访问其字段和函数，函数需要导入为Nim过程；

```nim
#Nim文件中组成链式表达式
var hash = CryptoJS.MD5(password).toString()

```
Nim编译成的Javascript符合ECMAScript3规范，新规范不被支持。
Karax将所有Nim代码编译成一个js文件，通过
`<script src="xxx.js"></script>`，引入到index.html中。

### karax的虚拟DOM实现

```nim
# Karax虚拟DOM的实现入口，另一个setRenderer是没有RouterData的重载方法
var
  kxi*: KaraxInstance
  ...
proc setRenderer*(renderer: proc (data: RouterData): VNode,
                  root: cstring = "ROOT",
                  clientPostRenderCallback:
                    proc (data: RouterData) = nil): KaraxInstance {.
                    discardable.} = 
...
  kxi = result
  window.onload = init
  onhashChange = proc() = redraw()
...
```

该过程从`renderer`返回的`VNode`创建一个虚拟DOM树，
与id为`ROOT`的DOM节点相对应，
并提供一个渲染后的回调过程，
用于例如Echarts节点先渲染再填充的场景，
过程返回`KaraxInstance`，
它是Karax虚拟DOM与浏览器DOM之间的桥梁，
用全局变量`kxi`导出，
设置浏览器`window`对象加载时的方法为`init`,
并设置哈希改变的回调为`redraw()`。

```nim
proc reqFrame(callback: proc()): int {.importc: "window.requestAnimationFrame".}

proc redraw*(kxi: KaraxInstance = kxi) =
  # we buffer redraw requests:
  when false:
    if drawTimeout != nil:
      clearTimeout(drawTimeout)
    drawTimeout = setTimeout(dodraw, 30)
  elif true:
    if kxi.renderId == 0:
      kxi.renderId = reqFrame(proc () = kxi.dodraw)
  else:
    dodraw(kxi)

proc init(ev: Event) =
  kxi.renderId = reqFrame(proc () = kxi.dodraw)
```
`init`将`kxi.renderId`设置为浏览器window对象请求一次动画帧返回的句柄，
并设置请求动画帧的回调为`dodraw`。 如果`kxi.renderId`为零， `redraw`初始化`kxi.renderId`，否则执行`dodraw`。

```nim
proc dodraw(kxi: KaraxInstance) =
  if kxi.renderer.isNil: return
  let rdata = RouterData(hashPart: hashPart)
  let newtree = kxi.renderer(rdata)
  inc kxi.runCount
  newtree.id = kxi.rootId
  kxi.toFocus = nil
  if kxi.currentTree == nil:
    let asdom = toDom(newtree, useAttachedNode = true, kxi)
    replaceById(kxi.rootId, asdom)
  else:
    doAssert same(kxi.currentTree, document.getElementById(kxi.rootId))
    let olddom = document.getElementById(kxi.rootId)
    diff(newtree, kxi.currentTree, nil, olddom, kxi)
    ...
```
如果当前虚拟DOM树还没有创建，
则将新树转换为DOM树替换原`kxi.rootId`的内容；
如果已经存在，
先断言当前虚拟DOM树与浏览器DOM树是相同的，
否则发起异常，
然后获取`kxi.rootId`的DOM节点作为旧DOM树与新的虚拟DOM树进行diff算法，
得到补丁集，
根据等价、相似、不同三种结果，
对节点进行相应更新。

### web后端

Nim的Web后端可以使用`Jester`框架，
支持多线程异步，
涉及到websocket的，
可以使用[niv/websocket.nim](https://github.com/niv/websocket.nim)，
部署方面https要求websocket使用`wss`，具体将在后面讲解。


这里简单介绍了 *如何使用Javascript模块的类型*和*库函数*、*立即模式*，
根据源码讲解了*Karax虚拟DOM的实现机制*等理论知识，
后面将讲解这些特性在应用中的实践。

