# 剪切与复制命令

title: 剪切与复制命令
toc: true
dropcap: false
date: 2015-05-09 14:16:32
author: clover_4l
tags:
- javascript
- cut-and-copy
- execcommand
---

by [Matt Gaunt](http://www.html5rocks.com/profiles/#mattgaunt)
发布时间： 2015年4月15日
更新时间： 2015年4月15日

IE10和其之后的版本添加了对「剪切」和「复制」命令的支持，通过 [Document.execCommand()](https://www.google.com/url?q=https%3A%2F%2Fdeveloper.mozilla.org%2Fen-US%2Fdocs%2FWeb%2FAPI%2FDocument%2FexecCommand&sa=D&sntz=1&usg=AFQjCNGXS6fCPqMRGr1_NECYZuxIOyVURg) 方法。从Chrome 43开始，这些命令也被Chrome支持了。

当这些命令被执行后，在浏览器中被选中的文本就会被剪切或复制到用户的剪贴板中。这让你可以为用户提供一种简单的方式：选中部分文本并复制进剪贴板中。

尤其是当你把它与 [Selection API](https://developer.mozilla.org/en-US/docs/Web/API/Selection) 一起使用，选中一段文本进行剪切或复制时，这将变得极其实用。这正是接下来我们在这篇文章中要介绍的详细内容。

## 简单示例

我们在 HTML 中添加了一个 email 地址和一个用于点击后进行复制的按钮。

```html
<p>Email me at <a class="js-emaillink" href="mailto:matt@example.co.uk">matt@example.co.uk</a></p>

<p><button class="js-emailcopybtn"><img src="./images/copy-icon.png" /></button></p>
```

下面在 JavaScript中，我们为按钮添加了一个点击事件的处理器，来用于选中 `js-emaillink` 锚点中的 email 地址，并执行复制命令，email 地址被复制进剪贴板，然后取消选中，这样用户就不会看到选区光标。

```javascript
var copyEmailBtn = document.querySelector('.js-emailcopybtn');  
copyEmailBtn.addEventListener('click', function(event) {  
  // 选中 email 链接的文本  
  var emailLink = document.querySelector('.js-emaillink');  
  var range = document.createRange();  
  range.selectNode(emailLink);  
  window.getSelection().addRange(range);  
    
  try {  
    // 我们已经选中了文本，下面执行「复制」命令  
    var successful = document.execCommand('copy');  
    var msg = successful ? 'successful' : 'unsuccessful';  
    console.log('Copy email command was ' + msg);  
  } catch(err) {  
    console.log('Oops, unable to copy');  
  }  
    
  // 移除选区 - 注意: 浏览器支持的话应该使用 removeRange(range)  
  window.getSelection().removeAllRanges();  
});
```

我们这里使用了 [Selection API](https://developer.mozilla.org/en-US/docs/Web/API/Selection) 的一个方法，用 [window.getSelection](https://developer.mozilla.org/en-US/docs/Web/API/Window/getSelection)  来选中我们要复制进用户剪贴板的锚点中的文本。在调用 `document.execCommand` 之后，我们可以通过调用 [window.getSelection().removeAllRanges()](https://developer.mozilla.org/en-US/docs/Web/API/Selection/removeAllRanges) 来移除掉选区。


如果你想要确认执行效果是否如你所愿，你可以检查 `document.execCommand()` 的返回值; 如果这个命令不被支持或没有被设置为打开的话它将返回 `false`。我们可以将 `execCommand()` 写进 try-catch 中来处理某些场景中在执行「剪切」和「复制」命令时[抛出的错误](https://dvcs.w3.org/hg/editing/raw-file/tip/editing.html#the-copy-command)。


「剪切」命令用于你想要删除文本框中的文本，并使它们可通过剪贴板访问的场景。

在HTML中使用 `textarea` 和 `button`：

```html
<p><textarea class="js-cuttextarea">Hello I'm some text</textarea></p>
  
<p><button class="js-textareacutbtn" disable>Cut Textarea</button></p>
```

我们可以通过如下方式剪切内容:

```javascript
var cutTextareaBtn = document.querySelector('.js-textareacutbtn');

cutTextareaBtn.addEventListener('click', function(event) {  
  var cutTextarea = document.querySelector('.js-cuttextarea');  
  cutTextarea.select();

  try {  
    var successful = document.execCommand('cut');  
    var msg = successful ? 'successful' : 'unsuccessful';  
    console.log('Cutting text command was ' + msg);  
  } catch(err) {  
    console.log('Oops, unable to cut');  
  }  
});
```

## queryCommandSupported 和 queryCommandEnabled

在调用 `document.execCommand()` 之前，你应该通过 [document.queryCommandSupported()](https://developer.mozilla.org/en-US/docs/Web/API/Document/queryCommandSupported) 方法确保这个API是可用的。在我们的示例中，我们可以按照命令的支持状况来设置按钮的可用状态，比如：

```javascript
copyEmailBtn.disabled = !document.queryCommandSupported('copy');
```

至于 [document.queryCommandSupported()](https://dvcs.w3.org/hg/editing/raw-file/tip/editing.html#querycommandsupported()) 和 [document.queryCommandEnable()](https://dvcs.w3.org/hg/editing/raw-file/tip/editing.html#querycommandenabled()) 之间的区别，一个用于检测「剪切」和「复制」是否被浏览器支持，另一个则是，如果当前没有文本被选中，那么这个命令就不是「enabled」的。在你要执行这些命令时，没有选中文本想要显示一条信息给用户时，这个方法特别有用。

## 浏览器支持状况

IE 10+、Chrome 43+、和 Opera 29+ 支持这些命令。

火狐支持这些命令，但需要进行配置变更（[具体看这里](https://developer.mozilla.org/en-US/docs/Web/API/Document/execCommand)）。如果不修改配置火狐将会报错。

Safari 不支持这些命令。

## 已知 Bugs

* 调用 `queryCommadSupported()` 来查询「剪切」和「复制」命令[总是返回 `false`直到用户进行了交互之后](http://crbug.com/476508)。这导致你不能把你的 UI 设置为「disabled」来表示浏览器不支持这个命令。
* [通过开发者工具调用 `queryCommandSupported()` 总是返回 `false`](http://crbug.com/475868)。
* 目前[「剪切」只有在你通过编程手段选中文本的情况下才工作](http://crbug.com/476848)。