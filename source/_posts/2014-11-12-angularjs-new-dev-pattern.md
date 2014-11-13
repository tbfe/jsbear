title: 内部平台静态开发方案2.0
toc: true
dropcap: false
feature: asset/common/img/posts/angular.png
categories: 文档
date: 2014-11-12 20:16:39
author: wayou
tags:
- angularjs
- 开发
---

感谢前人「刘凯，洪堂」的成果，站在巨人的肩上继续走得更远！

基于自己开发的开发过程，和收集的各种不便，内部平台现对之前的静态开发方案进行了一次升级。
这次改进是尝试性的，为是探求更好的开发方式，改进现有工作流程，提升效率和使开发更方便。

同时也作为新开发方式的一种探索和实践，为新版脚手架提供参考。

<!-- more -->

# 文件引用
之前使用异步拉取每个部分视图`controller`的方式在特殊需要时会有顺序的问题，以至于好多逻辑只能折中写到`app.js`文件里。现将之前异步方式改为同步，去掉`requirejs`，一次性将AngularJS程序的js文件引入。

并且Angular模块只会在调用时被实例化，所以提前到页面也不会浪费资源。


# 目录结构

![](/asset/posts/2014-11-12-angularjs-new-dev-pattern/angular.png)

上图只列出了与静态文案相关的目录及文件，现描述如下：


##control

control 文件与原来的一样

##template 

 `template 文件`里引用 `devplatcommon 基础库` 模块的部分与原来一样，只是引用项目启动文件的方式进行了改变。

 fis配置中将会在 `static/project_name/ ` 下生成一个 `app_all.js` 文件，在template里面将原来引用`app.js`的地方替换为引用此文件。


```php before
<?php
/**
 * 如下代码用将由框架负责处理js资源加载到页面
 */
echo HTML::js('project_name/app.js', "module_name");
?>
```  

```php after
<?php
/**
 * 如下代码用将由框架负责处理js资源加载到页面
 */
echo HTML::js('project_name/app_all.js', "module_name");
?>
```

区别在于之前在template里引用的是AngularJS的主程序入口文件，而现在的`app_all.js`是整个AngularJS程序所有文件合并的结果。

##static 文件夹

static里面项目的组织有变化。

先是一个`app文件夹`，以将AngularJS程序与其他静态文件区分开。

app下面是以项目为单位分开的文件夹，里面存放项目主要的静态文件，主要是:

- `app.js` AngularJS程序的主入口文件
- `views`文件夹，存放部分视图`HTML` 文件及视图对应的`Controller` 文件
- `services` 文件夹，存放本项目公用服务
- `directives` 文件夹，存放项目公用`directive`
- `resources` 文件夹，存放本项目公用`resource`文件
- `filters` 文件夹，存放本项目公用`filters`

###app.js

app.js为angular程序主入口文件，与原来的app.js文件有较大区别。

这里开始定义的JS文件未采用`require`方式定义模块，而是直接通过AngularJS方式定义。

先是定义项目主模块并注入基础服务：

```js
var module = angular.module('project_name', [
    'ngRoute',
    'ngResource',
    'ui.bootstrap',
    'ngCommon'
]);
```

之后是对项目进行初始配置,主要是设置路由。
由于不用异步拉取相应部分视图的`controller`文件，所以不用像`ngCommon` 库里面定义的`routeResolverProvider`服务那样去手动处理，而是通过AngularJS原生的方式来配置路由及指定`controller`。

```js before
module.config([
    '$routeProvider',
    'routeResolverProvider',
    '$httpProvider',
    function($routeProvider, routeResolverProvider, $httpProvider) {
        var route = routeResolverProvider.route;
        $routeProvider

        .when('/view1', route.resolve({
            templateUrl: __uri('./view/view1/view1.html'),
            controllerUrl: __uri('./view/view1_controller.js')
        }))

        .when('/view2', route.resolve({
            templateUrl: __uri('./view2/view2.html'),
            controllerUrl: __uri('./view2/view2_controller.js')
        }))

        .otherwise({
            redirectTo: '/view1'
        });

    }
]);

// Dynamic loading controller register setup.
angular.module('ngCommon').setupRegister(module);

angular.bootstrap(document, [module.name]);

```

```js after
module.config([
    '$routeProvider',
    '$httpProvider',
    function($routeProvider, $httpProvider) {
        $routeProvider
            .when('/view1', {
                templateUrl: __uri('./views/view1/view1.html'),
                controller: 'View1Ctrl'
            })
            .when('/view2', {
                templateUrl: __uri('./views/view2/view2.html'),
                controller: 'View2Ctrl'
            })

        .otherwise({
            redirectTo: '/view1'
        });
    }
]);
//启动Angular程序
angular.bootstrap(document, [module.name]);
```

其中在`controller` 里指定controller名称,而不是对应的文件路径。同时也不需要原先`app.js` 中最后两行注册模块及启动程序的代码。


### `views`文件夹

此文件夹下存放部分视图`HTML` 文件及视图对应的`Controller` 文件，按功能或者说按页面进行划分。

- view1
- view2
- ...

如果还需要本部分视图单独使用的`filter`,`service` 或`resource`等，将单独的js文件放到对应部分视图目录下即可。

- view1.html
- view1_controller.js
- ...

其中，现在的开发方式不需要在`view.html` 中指定`ng-congtroller`, 因为这个工作已经在路由配置时做了。

### `services` 文件夹

存放本项目公用服务。进行复杂业务逻辑的处理或繁杂运算等。

### `directives` 文件夹

存放本项目公用的`directive`,一般是一些页面的组件。

### `resources` 文件夹

存放本项目公用`resource`文件, 用于与后端交互，获取及提交数据。

### `filters` 文件夹

存放本项目公用`filters`。控制页面显示，特别是一些需要处理数字文本转换，控制日期格式等的场景，还有就是页面上需要进行条件性的展示。

# fis-conf.js

利用fis将所有AngularJS程序需要的JS文件打包成一个，之后再引入到`template` 文件里。

```js
//配置要合并的代码，即之前的__merge_conf.php配置的内容
fis.config.merge({
    pack: {
        'static/project1/app_all.js': [
            /static\/project1\/.*.js/
        ],
        'static/project2/app_all.js': [
            /static\/project2\/.*.js/
        ]
    }
});
```


# 总结

除了以上变更，其他部分与之前的设计是一样的。对于开发者来说，使用起来没有额外的学习成本，只需专注开发部分视图部分，如果后期脚架支持，则开发者完全感受不到变化。
升级文案的落实过程中，遇到一些文件加载的问题，经过多次尝试努力后成功，感谢东伟的帮助，段君的提议等。

祝同学们开发愉快! Happy Coding~


