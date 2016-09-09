# iOS原生和Web交互方案探讨
----

## UIWebView 
### 描述
我从事iOS的开发比较早，那个时候iOS开发使用原生控件是主流。但有时需要加载网页，那么此时就需要到了UIWebView。随着iOS开发的深入，以及多平台的兼容，很多App多少需要使用到Web。
> 网上有现成的方案[WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge)

### 使用方式
UIWebView中原生和Web的交互，可以使用两个方法来进行:

- 原生调用Web
 	`- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;`

- Web调用原生: 苹果没有提供直接的方案，添加一个隐藏的iframe设置URL，然后在UIWebViewDelegate中进行拦截(Cordova就是使用这种机制)
	`- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;`

### 源代码
- [Demo地址] (https://github.com/yincheng1988/WedNativeBridgeDemo/tree/master/WebViewDemo)

## JavaScriptCore
### 描述
iOS7以后，苹果推出了JavaScriptCore框架。将WebKit中的JavaScript引擎进行了封装。这样我们就可以调用一个运行JavaScript代码的环境了。

### 使用方式
- 协同UIWebView使用，在WebView加载成功后，获取运行环境JSContext
	`JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];`
- 通过`- (JSValue *)evaluateScript:(NSString *)script;`执行JavaScript代码。这样就完成了原生调用Web了。
- Web调用原生，OC代码中需要实现JSExport协议
	```
	// OC中定义
	JSContext[@"consoleLog"] = ^(NSString *str) {
    NSLog(@"%@", str);
  	};
  	// JS调用
  	consoleLog('test');
	```
- JSValue中提供了Web和原生中的对象的转换表

Objective-C type  |   JavaScript type
------------------|---------------------
 nil         |     undefined
NSNull       |        null
NSString      |       string
NSNumber      |   number, boolean
NSDictionary    |   Object object
NSArray       |    Array object
NSDate       |     Date object
NSBlock (1)   |   Function object (1)
  id (2)     |   Wrapper object (2)
Class (3)    | Constructor object (3)
        
- Note：Web调用原生后，所执行的Block是在子线程中，所以UI的操作，需要放入主线程中

### 源代码
- [Demo地址] (https://github.com/yincheng1988/WedNativeBridgeDemo/tree/master/WebViewDemo)

### 参考资料
- [NSHipster](http://nshipster.cn/javascriptcore/)

## WKWebView
### 描述
iOS8以后，推出了新框架WebKit和WKWebView，用于替代老旧的UIKit中的UIWebView。
官方在说明中强调WKWebView的优点：
> 1. 性能和稳定性上的极大提升；
2. 60fps的滚动刷新率以及内置手势；
3. 高效的app和web信息交换通道；
4. 使用和Safari相同的JavaScript 引擎；
5. 将UIWebView和UIWebViewDelegate在WKWebKit中重构成14个类以及3个协议；

### 使用方式
- 页面加载

	```
	- (WKNavigation *)loadRequest:(NSURLRequest *)request;
	- (WKNavigation *)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;
	
	// iOS9新增
	- (WKNavigation *)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL;
	- (WKNavigation *)loadData:(NSData *)data MIMEType:(NSString *)MIMEType characterEncodingName:(NSString *)characterEncodingName baseURL:(NSURL *)baseURL;
	
	// 示例
	[wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://baidu.com"]]];
	NSURL *URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"]];
	[wkWebView loadFileURL:URL allowingReadAccessToURL:[NSBundle mainBundle].resourceURL];
	```

- 访问历史

	> WKWebView新增了访问指定历史记录，在UIWebView中也有方案实现。
  参考[IMYWebView.m](https://github.com/wangyangcc/IMYWebView/blob/master/Classes/IMYWebView.m)实现

	```
	- (WKNavigation *)goToBackForwardListItem:(WKBackForwardListItem *)item;

	// UIWebView
	[UIWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.history.go(-%ld)", (long)index]];

	// WKWebView
	WKBackForwardListItem *item = WKWebView.backForwardList.backList[index];
	[WKWebView goToBackForwardListItem:item];
	```

- 调用JavaScript

	> UIWebView中调用JS的API是同步，而WKWebView中调用JS的API是异步。
	
	```
	// UIWeView
	- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
	
	// WKWebView
	- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *error))completionHandler;
```

- JavaScript与原生的通信

	- WebKit中提供了`WKUserScript`类来进行JS脚本注入
	- 原生通过注册`WKScriptMessageHandler`协议，让JavaScript与原生进行通信：`window.webkit.messageHandlers.{name}.postMessage({body})`
	
	```
	// 注入JS脚本
	NSString *jsString = @"function message(msg) { alert(msg); }";
	WKUserScript *script = [[WKUserScript alloc] initWithSource: jsString injectionTime:injectionTime forMainFrameOnly:YES];
	[WKWebView.userContentController addUserScript:script];
	
	// 注册通信协议消息
	[WKWebView.userContentController addScriptMessageHandler:id<WKScriptMessageHandler>handler name:@"message"];
	// JS与原生进行通信
	window.webkit.messageHandlers. message.postMessage('Test');
	```

- `WKNavigationDelegate`协议
	
	```
	// 页面开始加载时调用
	WKWebView: - (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation;
	UIWebView: - (void)webViewDidStartLoad:(UIWebView *)webView;

	// 当内容开始返回时调用
	WKWebView: - (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation;
	
	// 页面加载完成之后调用
	WKWebView: - (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;
	UIWebView: - (void)webViewDidFinishLoad:(UIWebView *)webView;

	// 页面加载失败时调用
	WKWebView: - (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation;
	UIWebView: - (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
	
	/// 页面跳转
	WKWebView:
	// 接收到服务器跳转请求之后调用
	- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation;
	// 在收到响应后，决定是否跳转
	- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;
	// 在发送请求之前，决定是否跳转
	- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
	
	UIWebView:
	- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
	```

- 加载进度`estimatedProgress`和标题`title`

	> 可以非常方便的通过KVO来进行监听

- `WKUIDelegate`协议

	> 通过此协议使用原生UI来定义Web中的Alert、Confirm、Prompt控件

- 注意事项

	- iOS9后提供`loadFileURL:allowingReadAccessToURL:`方式加载本地HTML。
	- 但是在iOS9之前使用`loadRequest:`方式加载本地HTML，会出现无法读取的问题。[解决方案](http://stackoverflow.com/questions/24882834/wkwebview-not-loading-local-files-under-ios-8 http://www.jianshu.com/p/ccb421c85b2e)

### 源代码
- [Demo地址] (https://github.com/yincheng1988/WedNativeBridgeDemo/tree/master/WebViewDemo)

### 参考资料
- [NSHipster](http://nshipster.cn/wkwebkit/)


### Cordova
### 描述
Cordova是一款比较成熟的Hybrid开发框架，由于推出时间较长，网上也有许多Cordova的教程。由于要考虑WKWebView，所以首选是Cordova的WKWebView插件，而这个插件是要求必须4.0版本开始，所以对于4.0以前的版本就不做了解了。

### 安装
- npm安装

```
npm install -g cordova #确保安装node，node安装命令brew install node
cordova create wkwvtest my.project.id wkwvtest
cordova platform add ios@4
cordova plugin add cordova-plugin-wkwebview-engine
```
- pod安装

```
	pod 'Cordova', '~> 4.0.0'
	pod 'cordova-plugin-wkwebview-engine', '~> 1.0.2' #要求的最低版本是iOS9.0
```

### 使用方式
- 配置文件设置config.xml(cordova默认配置文件，也可以指定其他配置文件)
	- 设置allow-intent和allow-navigation
	- 设置需要支持的插件
	- 设置支持WKWebView插件，添加下面配置：
	
	```
	<feature name="CDVWKWebViewEngine">
        <param name="ios-package" value="CDVWKWebViewEngine" />
    </feature>
    <preference name="CordovaWebViewEngine" value="CDVWKWebViewEngine" />
    ```
- 使用CDVWebViewEngineProtocol协议来操作JS
	> 4.0之前是UIWebView，4.0之后被重构了CDVWebViewEngineProtocol协议。(WKWebView的自动切换就是利用这个协议实现)
- 原生调用Web
```
	[self.webViewEngine evaluateJavaScript:script completionHandler:nil];
```
- Web调用原生
	- 通过以前的URL拦截方式进行，不过目前不能直接支持，我们还是需要修改源码才能完成
	- 使用cordova的插件
	
```
// 定义plugin-dialog.js
cordova.define("cordova-plugin-dialog-demo", function(require, exports, module) {
 var exec = require('cordova/exec'),
 cordova = require('cordova');
 
 var Dialog = function() {
 };
 
 Dialog.prototype.showMsg = function(successCallback, errorCallback, options) {
     var params = options || {};
     cordova.exec(null, null, 'DialogPlugin', 'showMessage', [params]);
 };
 
 module.exports = new Dialog();
});
// 引用dialog插件（cordova_plugins.js）
{
        "id": "cordova-plugin-dialog-demo",
        "file": "plugins/dialog/cordova_plugins_dialog.js",
        "clobbers": [
           "dialog"
        ]
    }
// 定义Dialog处理类
@interface DialogPlugin : CDVPlugin
- (void)showMessage:(CDVInvokedUrlCommand *)command;
@end

// html中调用
function test1() {
	dialog.showMsg(function(){}, function(){}, {'title':'hello world'});
}
```

- 目前Github上有需要已开发完成的插件，有需要的可以下载下来使用

### 源代码
- [Demo地址] (https://github.com/yincheng1988/WedNativeBridgeDemo/tree/master/CordovaWKWebViewDemo/CordovaWKWebViewDemo)

### 参考资料

- [官方iOS文档](http://cordova.apache.org/docs/en/latest/guide/platforms/ios/index.html)
- [Cordova-ios](https://github.com/apache/cordova-ios)
- [WKWebView插件](https://github.com/apache/cordova-plugin-wkwebview-engine)


### Crosswalk
### 描述
Crosswalk官方宣传是一款基于Chromium内核的web引擎，通过内置web引擎，提供统一的API，这样来达到多平台兼容。
查看官方的[iOS文档](https://crosswalk-project.org/documentation/ios.html)，发现基于WKWebView，而不是我们一开始理解的内置web引擎。
查看了下，发现crosswalk也提供了兼容Cordova的[插件](https://github.com/crosswalk-project/ios-extensions-crosswalk.git)。

### 安装
- 通过github上下载源码 [crosswalk-ios](https://github.com/crosswalk-project/crosswalk-ios)，[ios-extensions-crosswalk](https://github.com/crosswalk-project/ios-extensions-crosswalk.git)
- 通过cocoapods更新`pod 'crosswalk-ios', '~> 1.2.0'`
- 通过cocoapods更新cordova的crosswalk插件`pod 'crosswalk-extension-cordova', '~> 1.1'`
- 由于crosswalk-ios部分代码是使用Swift开发，所以pod的配置需要设置成framework方式，下面是我的Podfile

```
platform :ios, '8.0'
use_frameworks!
inhibit_all_warnings!

pod 'crosswalk-extension-cordova', '~> 1.1'
```

### 使用方式
- 使用XWalkView来进行承载
- crosswalk-ios依赖了一个第三方库[GCDWebServer](https://github.com/swisspol/GCDWebServer)，通过查看源码，发现是为了解决iOS8下WKWebView无法加载本地文件的问题。相对于[cordova-plugin-wkwebview-engine](https://github.com/apache/cordova-plugin-wkwebview-engine)插件的最低安装版本iOS9，做了更多的兼容。
- 原生调用Web

	> 使用XWalkView提供的`- (WKUserScript*)injectScript:(NSString*)code`方法。由于XWalkView继承自WKWebView，所以使用WKWebView的方法
- Web调用原生
	
	- 通过`- (void)loadExtension:(NSObject*)object namespace:(NSString*)ns`初始化extension
	- 将定义的extension和iOS代码中的类进行关联，通过配置extensions.plist进行
	- `XWalkReflection`类中定义了一些规则，比如`jsfunc_`。关联类中将需要被Web调用的函数名加上`jsfunc_`前缀即可。
	
	```	
	// 关联Dialog类，需要配置extensions.plist
	<plist version="1.0">
	<dict>
		<key>XWalkExtensions</key>
		<dict>
			<key> xwalk.demo.dialog </key>
			<string> Dialog </string>
		</dict>
	</dict>
	</plist>
	// 或者通过代码来进行关联绑定
	[XWalkExtensionFactory register:@"xwalk.demo.dialog" cls:NSClassFromString(@"Dialog")];

	// 设置extension名为 xwalk.demo.dialog
	id ext = [XWalkExtensionFactory createExtension:@"xwalk.demo.dialog"];
	[xwalkView loadExtension:ext namespace:name];
	
	// 定义类Dialog类继承XWalkExtension
	// 官方给的实例func jsfunc_echo(cid: UInt32, message: String, callback: UInt32)
	@interface Dialog : XWalkExtension
		- (void)jsfunc_showMsg:(UInt32)cid message:(NSString *)message callback:(UInt32)callback;
	@end
	
	//  web端调用native {extensionName}.{function}({params})
	xwalk.demo.dialog.showMsg('test', function(){});
	```

- 使用Cordova的crosswalk插件
	> Cordova从4.0开始的插件机制，非常方便了我们的开发，同样crosswalk也提供了相应的插件，通过上面介绍的可以进行安装。
	有了Cordova的支持，我们就使用Cordova的插件机制进行插件开发。这里应该是融合和Crosswalk和Cordova-plugin的开发方式。
	原生调用Web，和上面的相同，下面介绍的是Web调用原生。
	下面以我定义一个Dialog插件为例：
	
	```
	// JS dialog.js
	cordova.define("org.apache.cordova.demo.dialog", function(require, exports, module) {
   var exec = require('cordova/exec');
   cordova = require('cordova');
	
   function Dialog() {
   }
   Dialog.prototype.dialogMessage = function(params) {
       params = params || {};
       exec(null, null, "ObjectiveC_Dialog", "showMessage", [params]);
   }
   module.exports = new Dialog();
	});
	
	// Native DialogPlugin.h/m
	@interface DialogPlugin : CDVPlugin
		- (void)showMessage:(CDVInvokedUrlCommand *)command;
	@end
	
	// JS和native进行关联，系统默认配置文件是manifest.plist，需要下面定义
	<key>cordova_plugins</key>
	<array>
		<dict>
			<key>class</key>
			<string>DialogPlugin</string>
			<key>name</key>
			<string> ObjectiveC_Dialog </string>
		</dict>
	</array>
	
	// web端调用native
	dialog.dialogMessage({'title':'Hello'});
	```
### 注意事项
cordova-plugin-wkwebview-engine对cordova-ios的源码做过一些修改，所以会与cordova-ios有些不同。如果有需要的话必须等待原作者的维护和更新。

### 源代码
- [Demo地址] (https://github.com/yincheng1988/WedNativeBridgeDemo/tree/master/Crosswalk_CordovapulginDemo)

### 参考资料
- [Crosswalk](https://crosswalk-project.org/documentation/ios.html)
- [crosswalk-ios](https://github.com/crosswalk-project/crosswalk-ios)
- [ios-extensions-crosswalk](https://github.com/crosswalk-project/ios-extensions-crosswalk.git)