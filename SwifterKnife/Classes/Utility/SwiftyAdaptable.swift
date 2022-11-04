//
//  SwiftyAdaptable.swift
//  SwifterKnife
//
//  Created by 李阳 on 2022/11/3.
//

import UIKit
 
// MARK: - Pixel
public enum PixelAligment: Int {
    case floor, round, ceil
}
public extension CGFloat {
    /// 像素化对齐
    var pix: CGFloat { pixel(.round) }
    var pixRound: CGFloat { pixel(.round) }
    var pixFloor: CGFloat { pixel(.floor) }
    var pixCeil: CGFloat { pixel(.ceil) }
    
    func pixel(_ aligment: PixelAligment) -> CGFloat {
        let scale = Screen.scale
        switch aligment {
        case .floor:
            return Darwin.floor(self * scale) / scale
        case .round:
            return Darwin.round(self * scale) / scale
        case .ceil:
            return Darwin.ceil(self * scale) / scale
        }
    }
}

// MARK: - CGFloatConvertable
public protocol CGFloatConvertable {
    var cgfloatValue: CGFloat { get }
}

extension Int: CGFloatConvertable {
    public var cgfloatValue: CGFloat { CGFloat(self) }
}
extension Double: CGFloatConvertable {
    public var cgfloatValue: CGFloat { CGFloat(self) }
}
extension Float: CGFloatConvertable {
    public var cgfloatValue: CGFloat { CGFloat(self) }
}
extension CGFloat: CGFloatConvertable {
    public var cgfloatValue: CGFloat { return self }
}

// MARK: - SwiftyAdaptable
public protocol SwiftyAdaptable {
    associatedtype TargetType
    func adaptive(tramsform: (CGFloat) -> CGFloat) -> TargetType
}

extension SwiftyAdaptable where Self: CGFloatConvertable {
    public func adaptive(tramsform: (CGFloat) -> CGFloat) -> CGFloat {
        tramsform(cgfloatValue)
    }
}

extension Int: SwiftyAdaptable {}
extension Double: SwiftyAdaptable {}
extension Float: SwiftyAdaptable {}
extension CGFloat: SwiftyAdaptable {}

extension CGPoint: SwiftyAdaptable {
    public func adaptive(tramsform: (CGFloat) -> CGFloat) -> CGPoint {
        CGPoint(x: tramsform(x),
                y: tramsform(y))
    }
}
extension CGSize: SwiftyAdaptable {
    public func adaptive(tramsform: (CGFloat) -> CGFloat) -> CGSize {
        CGSize(width: tramsform(width),
               height: tramsform(height))
    }
}
extension CGRect: SwiftyAdaptable {
    public func adaptive(tramsform: (CGFloat) -> CGFloat) -> CGRect {
        CGRect(x: tramsform(origin.x),
               y: tramsform(origin.y),
               width: tramsform(size.width),
               height: tramsform(size.height))
    }
}
extension UIEdgeInsets: SwiftyAdaptable {
    public func adaptive(tramsform: (CGFloat) -> CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: tramsform(top),
            left: tramsform(left),
            bottom: tramsform(bottom),
            right: tramsform(right))
    }
}
extension UIFont: SwiftyAdaptable {
    public func adaptive(tramsform: (CGFloat) -> CGFloat) -> UIFont {
        withSize(round(tramsform(pointSize)))
    }
}


// MARK: - Designable
public struct ScreenAdaptor {
    /// 设计稿参考尺寸 比如设计稿按iPhoneX出，就是375
    public let reference: CGFloat
    /// 实际尺寸 比如屏幕宽度
    public let standard: CGFloat
    
    public func map(_ val: CGFloat) -> CGFloat {
        (standard / reference * val)
    }
    public func mapPix(_ val: CGFloat) -> CGFloat {
        map(val).pix
    }
}
public extension ScreenAdaptor {
    static func uiwidth(reference: CGFloat) -> ScreenAdaptor {
        .init(reference: reference, standard: Screen.width)
    }
    static func uiheight(reference: CGFloat) -> ScreenAdaptor {
        .init(reference: reference, standard: Screen.height)
    }
    static func uiwithoutHeaderHeight(reference: CGFloat) -> ScreenAdaptor {
        .init(reference: reference, standard: Screen.withoutHeaderH)
    }
    static func uibodyHeight(reference: CGFloat) -> ScreenAdaptor {
        .init(reference: reference, standard: Screen.bodyH)
    }
}
public protocol BaseDesignable {
    associatedtype Adaptable: SwiftyAdaptable
    var adaptable: Adaptable { get }
    /// 按宽度适配
    static var width: ScreenAdaptor { get }
    /// 按高度适配
    static var height: ScreenAdaptor { get }
}
extension BaseDesignable {
    public var fit: Adaptable.TargetType {
        adaptable.adaptive(tramsform: Self.width.mapPix(_:))
    }
    public var fitH: Adaptable.TargetType {
        adaptable.adaptive(tramsform: Self.height.mapPix(_:))
    }
}


/// UIKit 独有
public protocol UIDesignable: BaseDesignable {
    /// 去除 status bar高度后，按高度适配
    static var withoutHeaderHeight: ScreenAdaptor { get }
    /// 去除 status bar 和 home indicator高度后，按高度适配
    static var bodyHeight: ScreenAdaptor { get }
}
extension UIDesignable {
    public var fitT: Adaptable.TargetType {
        adaptable.adaptive(tramsform: Self.withoutHeaderHeight.mapPix(_:))
    }
    public var fitC: Adaptable.TargetType {
        adaptable.adaptive(tramsform: Self.bodyHeight.mapPix(_:))
    }
    public var fitS: Adaptable.TargetType {
        adaptable.adaptive {
            if Screen.height > 570 { return $0.pix }
            return Self.height.mapPix($0)
        }
    }
}
public struct iPhoneXDesign<T: SwiftyAdaptable>: UIDesignable {
    public let adaptable: T
    public init(adaptable: T) {
        self.adaptable = adaptable
    }
    public static var width: ScreenAdaptor {
        .uiwidth(reference: 375)
    }
    
    public static var height: ScreenAdaptor {
        .uiheight(reference: 812)
    }
    public static var withoutHeaderHeight: ScreenAdaptor {
        .uiwithoutHeaderHeight(reference: 768)
    }
    public static var bodyHeight: ScreenAdaptor {
        .uibodyHeight(reference: 734)
    }
}

extension SwiftyAdaptable {
    public var ui: iPhoneXDesign<Self> {
        iPhoneXDesign(adaptable: self)
    }
    
    public var fit: TargetType {
        ui.fit
    }
    public var fitH: TargetType {
        ui.fitH
    }
    public var fitT: TargetType {
        ui.fitT
    }
    public var fitC: TargetType {
        ui.fitC
    }
    public var fitS: TargetType {
        ui.fitS
    }
}
