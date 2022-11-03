//
//  SwiftyAdaptable.swift
//  SwifterKnife
//
//  Created by 李阳 on 2022/11/3.
//

import Foundation

/*
public struct AnyDimension {
    public let reference: CGFloat
    public let standard: CGFloat
}
//
public protocol SwiftyAdaptable {
    func fit(_ value: CGFloat, using screenDimension: AnyDimension) -> CGFloat
}
extension SwiftyAdaptable {
    public func fit(_ value: CGFloat, using dimension: AnyDimension) -> CGFloat {
        (dimension.standard / dimension.reference * value).pix
    }
}
 
public struct ScreenDimension<T: SwiftyAdaptable> {
    /// 设计稿参考尺寸 比如设计稿按iPhoneX出，就是375
    public let reference: CGFloat
    /// 实际尺寸 比如屏幕宽度
    public let standard: CGFloat
    public let value: T
    
    private func map(_ val: CGFloat) -> CGFloat {
        value.fit(val, using: dimension)
    }
    private var dimension: AnyDimension {
        .init(reference: reference, standard: standard)
    }
}
 */
public protocol SwiftyAdaptable {
}
public struct ScreenDimension<T> {
    /// 设计稿参考尺寸 比如设计稿按iPhoneX出，就是375
    public let reference: CGFloat
    /// 实际尺寸 比如屏幕宽度
    public let standard: CGFloat
    public let value: T
    
    public func map(_ val: CGFloat) -> CGFloat {
        (standard / reference * val).pix
    }
}

extension ScreenDimension where T: CGFloatConvertable {
    public var fit: CGFloat {
        map(value.cgfloatValue)
    }
}
extension ScreenDimension where T == CGPoint {
    public var fit: CGPoint {
        return CGPoint(x: map(value.x), y: map(value.y))
    }
}
extension ScreenDimension where T == CGSize {
    public var fit: CGSize {
        return CGSize(width: map(value.width), height: map(value.height))
    }
}
extension ScreenDimension where T == CGRect {
    public var fit: CGRect {
        return CGRect(
            x: map(value.origin.x),
            y: map(value.origin.y),
            width: map(value.size.width),
            height: map(value.size.height))
    }
}
extension ScreenDimension where T == UIEdgeInsets {
    public var fit: UIEdgeInsets {
        return UIEdgeInsets(
            top: map(value.top),
            left: map(value.left),
            bottom: map(value.bottom),
            right: map(value.right))
    }
}
extension ScreenDimension where T == UIFont {
    public var fit: UIFont {
        return value.withSize(round(map(value.pointSize)))
    }
}
public extension SwiftyAdaptable {
    // iPhone X Width
    var wx: ScreenDimension<Self> {
        .init(reference: 375, standard: Screen.width, value: self)
    }
    // iPhone X Height
    var hx: ScreenDimension<Self> {
        .init(reference: 812, standard: Screen.height, value: self)
    }
    // iPhone X Height Without Status Bar
    var tx: ScreenDimension<Self> {
        .init(reference: 768, standard: Screen.withoutHeaderH, value: self)
    }
    // iPhone X Height Without Status Bar and home indicator
    var cx: ScreenDimension<Self> {
        .init(reference: 734, standard: Screen.bodyH, value: self)
    }
}
extension Int: SwiftyAdaptable {}
extension Double: SwiftyAdaptable {}
extension Float: SwiftyAdaptable {}
extension CGPoint: SwiftyAdaptable {}
extension CGSize: SwiftyAdaptable {}
extension CGRect: SwiftyAdaptable {}
extension UIEdgeInsets: SwiftyAdaptable {}
extension UIFont: SwiftyAdaptable {}
/*
 */
/*
public extension ScreenDimension {
    // iPhone X Width
    static var wx: ScreenDimension {
        .init(reference: 375, standard: Screen.width)
    }
    // iPhone X Height
    static var hx: ScreenDimension {
        .init(reference: 812, standard: Screen.height)
    }
    // iPhone X Height Without Status Bar
    static var tx: ScreenDimension {
        .init(reference: 768, standard: Screen.withoutHeaderH)
    }
    // iPhone X Height Without Status Bar and home indicator
    static var cx: ScreenDimension {
        .init(reference: 734, standard: Screen.bodyH)
    }
}
 
public extension ScreenDimension {
    func fit(_ value: CGFloatConvertable) -> CGFloat {
        (standard / reference * value.cgfloatValue).pix
    }
}
 */
