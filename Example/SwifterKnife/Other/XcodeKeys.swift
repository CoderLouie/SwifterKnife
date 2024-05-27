/*
 https://juejin.cn/post/6913888065937211399
 https://mp.weixin.qq.com/s/92cXUXHtegxAL9qWKiKahQ
 1. 快速自动缩进
 当你的代码没有对齐时，这个快捷键非常有用。

 control + i / ⌃ + i
 
 2. 重命名变量名
 command + control + e / ⌘ + ⌃ + e
 
 4. 查找变量名
 下一个
 option + control + e / ⌥ + ⌃ + e
 
 上一个
 shift + option + control + e / ⇧ + ⌥ + ⌃ + e
 
 5. 代码块向上或向下移动
 向上移动：
 option + command + [ / ⌥ + ⌘ + [

 向下移动：
 option + command + ] / ⌥ + ⌘ + ]
 
 6. 多行光标（使用鼠标）
 有时你需要在文件的不同部分中写入相同的内容
 shift + control + click / ⇧ + ⌃ + click
 
 7. 多行光标（使用键盘）
 shift + control + up or down /⇧ + ⌃ + ↑ or ↓
 
 8. 快速创建带有多个参数的初始化（init）函数
 control + option + command + i
 
 9. 返回光标之前所在的位置
 option + command + L / ⌥ + ⌘ + L
 */


/*
 键盘
 fn+1(my mbp)/fn+2(mac mini)/fn+3(iphone12)可在3台设备间切换
 开关调至bluetooth，长按fn+1/2/3保持3s，进入匹配模式
 fn+灯打开/关闭键盘背光
 
 鼠标
 蓝灯表示使用蓝牙连接
 绿灯表示使用USB接受连接
 按下按钮3s可通过蓝牙和其他设备配对。开始闪烁蓝灯和绿灯时表示已经进入配对模式
 */



/*
 Swift Unknown
 
 Dictionary 有两个副作 用：它会去掉重复的键，并且会将所有键重新排序。如果你想要使用像是 [key: value] 这样的字 面量语法，而又不想引入 Dictionary 的这两个副作用的话，就可以使用 DictionaryLiteral。 DictionaryLiteral 是对于键值对数组 (比如 [(key, value)]) 的很好的替代，它不会引入字典的副 作用，同时让调用者能够使用更加便捷的 [:] 语法。
 
 */


/// Evaluates the specified closure when the result of this `DataResponse` is a success, passing the unwrapped
/// result value as a parameter.
///
/// - Note: xxx
/// Use the `map` method with a closure that does not throw. For example:
///
///     let possibleData: DataResponse<Data> = ...
///     let possibleInt = possibleData.map { $0.count }
///
/// - parameter transform: A closure **MUST** that takes the success value of the instance's result.
///
/// - returns: A `DataResponse` whose result wraps the value returned by the given closure. If this instance's
///            result is a failure, returns a response wrapping the same failure.
