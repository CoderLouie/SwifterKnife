


`SwifterKnife` is a collection of Swift extension method and some tools that often use in develop project, with them you might build project faster and more efficient.

[![Platform](https://img.shields.io/badge/platforms-iOS-lightgrey.svg)](https://cocoapods.org/pods/SwifterKnife)
[![Swift](https://img.shields.io/badge/Swift-5.3-orange.svg)](https://swift.org)
[![MIT](https://img.shields.io/badge/License-MIT-red.svg)](https://opensource.org/licenses/MIT)



## Contents

- **Base**
		为其他组件所共用。包含[Then](https://github.com/devxoul/Then)协议
	
- **Extension**
		`iOS`开发中常用的扩展。融合修改了[wifterSwift](https://github.com/SwifterSwift/SwifterSwift)部分功能，以及自己心添加的一些功能
	
- **Utility**
		`iOS`开发中常用的工具类。
		`Console` 日志打印工具
		`SandBox` 沙盒文件工具
		`Builtlns` 一些内置的数据结构。包括栈、队列、双端队列、优先级队列、弱引用表、位域等
		`Localize` 多语言工具
		`Protocol` 常用的协议。融合修改了[ExCodable](https://github.com/iwill/ExCodable)，以及其他一些协议

- **Views**
		`iOS`开发中常用的自定义视图，依赖[SnapKit](https://github.com/search?q=SnapKit)
		`LayoutView` 方便快速进行布局
		`CarouselView` 无限循环滚动控件


## Requirements
- **iOS** 10.0+ 
- Swift 5.0+


## Installation

<details>
<summary>CocoaPods</summary>
</br>
<p>To integrate SwifterKnife into your Xcode project using <a href="http://cocoapods.org">CocoaPods</a>, specify it in your <code>Podfile</code>:</p>

<h4>- Integrate All components (recommended):</h4>
<pre><code class="ruby language-ruby">pod 'SwifterKnife'</code></pre>

<h4>- Integrate Base components only:</h4>
<pre><code class="ruby language-ruby">pod 'SwifterKnife/Base'</code></pre>

<h4>- Integrate Extension components only:</h4>
<pre><code class="ruby language-ruby">pod 'SwifterKnife/Extension'</code></pre>

<h4>- Integrate Utility components only:</h4>
<pre><code class="ruby language-ruby">pod 'SwifterKnife/Utility'</code></pre>

<h4>- Integrate Views components only:</h4>
<pre><code class="ruby language-ruby">pod 'SwifterKnife/Views'</code></pre>

</details>


## Thanks

Special thanks to: 
[devxoul/Then: ✨ Super sweet syntactic sugar for Swift initializers](https://github.com/devxoul/Then)
[SwifterSwift/SwifterSwift: A handy collection of more than 500 native Swift extensions to boost your productivity.](https://github.com/SwifterSwift/SwifterSwift)
[AliSoftware/Reusable: A Swift mixin for reusing views easily and in a type-safe way (UITableViewCells, UICollectionViewCells, custom UIViews, ViewControllers, Storyboards…)](https://github.com/AliSoftware/Reusable)
[LinXunFeng/SwiftyFitsize: 📱 Swifty screen adaptation solution (Support Objective-C and Swift)](https://github.com/LinXunFeng/SwiftyFitsize)
[iwill/ExCodable: Key-Mapping Extensions for Swift Codable](https://github.com/iwill/ExCodable)
[SwiftyJSON/Alamofire-SwiftyJSON: Alamofire extension for serialize NSData to SwiftyJSON](https://github.com/SwiftyJSON/Alamofire-SwiftyJSON)


## License

SwifterKnife is available under the MIT license. See the LICENSE file for more info.
