//
//  SwiftyAdaptable.swift
//  SwifterKnife
//
//  Created by liyang on 2022/11/3.
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
//extension UIFont: SwiftyAdaptable {
//    public func adaptive(tramsform: (CGFloat) -> CGFloat) -> UIFont {
//        withSize(round(tramsform(pointSize)))
//    }
//}
extension UIFont {
    @objc public var fit: UIFont {
        let adaptor = UIDesignReference.stander.uiwidth
//        return withSize(round(adaptor.map(pointSize)))
        return withSize(adaptor.mapPix(pointSize))
    }
}

// MARK: - Designable
public struct ScreenAdaptor {
    
    public static var pixAligment: PixelAligment = .round
    
    /// 设计稿参考尺寸
    public let reference: CGFloat
    /// 实际尺寸
    public let standard: CGFloat
    
    public func map(_ val: CGFloat) -> CGFloat {
        (standard / reference * val)
    }
    public func mapPix(_ val: CGFloat) -> CGFloat {
        map(val).pixel(Self.pixAligment)
    }
    public func mapPix(_ val: CGFloat, alignment: PixelAligment?) -> CGFloat {
        map(val).pixel(alignment ?? Self.pixAligment)
    }
}

public protocol BaseDesignable {
    associatedtype Adaptable: SwiftyAdaptable
    var adaptable: Adaptable { get }
    /// 按宽度适配
    var width: ScreenAdaptor { get }
    /// 按高度适配
    var height: ScreenAdaptor { get }
}
extension BaseDesignable {
    public var fit: Adaptable.TargetType {
        adaptable.adaptive(tramsform: width.mapPix(_:))
    }
    public var fitH: Adaptable.TargetType {
        adaptable.adaptive(tramsform: height.mapPix(_:))
    }
    // Key path cannot refer to static member
    public func fit(using keyPath: KeyPath<Self, ScreenAdaptor>, alignment: PixelAligment? = nil) -> Adaptable.TargetType {
        adaptable.adaptive { val in
            self[keyPath: keyPath].mapPix(val, alignment: alignment)
        }
    }
    
    public func fit(alignment: PixelAligment) -> Adaptable.TargetType {
        adaptable.adaptive { val in
            width.mapPix(val, alignment: alignment)
        }
    }
}


/// UIKit 独有
public protocol UIDesignable: BaseDesignable {
    /// 去除 status bar高度后，按高度适配
    var withoutHeaderHeight: ScreenAdaptor { get }
    /// 去除 status bar 和 home indicator高度后，按高度适配
    var bodyHeight: ScreenAdaptor { get }
}
extension UIDesignable {
    public var fitT: Adaptable.TargetType {
        adaptable.adaptive(tramsform: withoutHeaderHeight.mapPix(_:))
    }
    public var fitC: Adaptable.TargetType {
        adaptable.adaptive(tramsform: bodyHeight.mapPix(_:))
    }
    public var fitS: Adaptable.TargetType {
        adaptable.adaptive {
            if Screen.height > 570 { return $0.pix }
            return height.mapPix($0)
        }
    }
}
public struct UIDesignReference {
    public let width: CGFloat
    public let height: CGFloat
    public let withoutHeaderHeight: CGFloat
    public let bodyHeight: CGFloat
    
    public init(width: CGFloat,
                height: CGFloat,
                withoutHeaderHeight: CGFloat,
                bodyHeight: CGFloat) {
        self.width = width
        self.height = height
        self.withoutHeaderHeight = height
        self.bodyHeight = bodyHeight
    }
    
    public static var stander: UIDesignReference = .iPhone12
}
public extension UIDesignReference {
    static var iPhoneX: UIDesignReference {
        .init(width: 375,
              height: 812,
              withoutHeaderHeight: 768,
              bodyHeight: 734)
    }
    static var iPhone12: UIDesignReference {
        .init(width: 390,
              height: 844,
              withoutHeaderHeight: 797,
              bodyHeight: 763)
    }
}
public extension UIDesignReference {
    var uiwidth: ScreenAdaptor {
        .init(reference: width, standard: Screen.width)
    }
    var uiheight: ScreenAdaptor {
        .init(reference: height, standard: Screen.height)
    }
    var uiwithoutHeaderHeight: ScreenAdaptor {
        .init(reference: withoutHeaderHeight, standard: Screen.withoutHeaderH)
    }
    var uibodyHeight: ScreenAdaptor {
        .init(reference: bodyHeight, standard: Screen.bodyH)
    }
}
extension UIDesignable {
    public var width: ScreenAdaptor {
        UIDesignReference.stander.uiwidth
    }
    
    public var height: ScreenAdaptor {
        UIDesignReference.stander.uiheight
    }
    public var withoutHeaderHeight: ScreenAdaptor {
        UIDesignReference.stander.uiwithoutHeaderHeight
    }
    public var bodyHeight: ScreenAdaptor {
        UIDesignReference.stander.uibodyHeight
    }
}
public struct UIDesigner<T: SwiftyAdaptable>: UIDesignable {
    public let adaptable: T
    public let reference: UIDesignReference
    public init(adaptable: T) {
        self.adaptable = adaptable
        reference = .stander
    }
    public init(adaptable: T, reference: UIDesignReference) {
        self.adaptable = adaptable
        self.reference = reference
    }
    
    public var width: ScreenAdaptor {
        reference.uiwidth
    }
    
    public var height: ScreenAdaptor {
        reference.uiheight
    }
    public var withoutHeaderHeight: ScreenAdaptor {
        reference.uiwithoutHeaderHeight
    }
    public var bodyHeight: ScreenAdaptor {
        reference.uibodyHeight
    }
}

extension SwiftyAdaptable {
    public var ui: UIDesigner<Self> {
        UIDesigner(adaptable: self)
    }
    public func ui(ref: UIDesignReference) -> UIDesigner<Self> {
        UIDesigner(adaptable: self, reference: ref)
    }
    
    public func fit(alignment: PixelAligment) -> TargetType {
        ui.fit(alignment: alignment)
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



/*
 extension UIDesignReference {
     public func adaptor(_ keyPath: KeyPath<UIDesignReference, CGFloat>) -> ScreenAdaptor {
         let stander: CGFloat
         switch keyPath {
         case \UIDesignReference.width:
             stander = Screen.width
         case \UIDesignReference.height:
             stander = Screen.height
         case \UIDesignReference.withoutHeaderHeight:
             stander = Screen.withoutHeaderH
         case \UIDesignReference.bodyHeight:
             stander = Screen.bodyH
         default:
             stander = Screen.width
         }
         return .init(reference: self[keyPath: keyPath], standard: stander)
     }
 }
 extension UIDesignable {
     public static var width: ScreenAdaptor {
         UIDesignReference.stander.adaptor(\.width)
     }
     
     public static var height: ScreenAdaptor {
         UIDesignReference.stander.adaptor(\.height)
     }
     public static var withoutHeaderHeight: ScreenAdaptor {
         UIDesignReference.stander.adaptor(\.withoutHeaderHeight)
     }
     public static var bodyHeight: ScreenAdaptor {
         UIDesignReference.stander.adaptor(\.bodyHeight)
     }
 }
 */


public extension String {
    func aspectFitSize(for font: UIFont, limitSize: CGSize, model: NSLineBreakMode = .byWordWrapping) -> CGSize {
        var attr: [NSAttributedString.Key: Any] = [.font: font]
        if model != .byWordWrapping {
            let style = NSMutableParagraphStyle()
            style.lineBreakMode = model
            attr[.paragraphStyle] = style
        }
        let rect = (self as NSString).boundingRect(with: limitSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attr, context: nil)
        let res = rect.size.adaptive(tramsform: \.pixCeil)
        return res
    }
    func aspectFitSize(for font: UIFont, maxWidth: CGFloat, model: NSLineBreakMode = .byWordWrapping) -> CGSize {
        aspectFitSize(for: font, limitSize: CGSize(width: maxWidth, height: .greatestFiniteMagnitude), model: model)
    }
    func aspectFitHeight(for font: UIFont, maxWidth: CGFloat, model: NSLineBreakMode = .byWordWrapping) -> CGFloat {
        aspectFitSize(for: font, limitSize: CGSize(width: maxWidth, height: .greatestFiniteMagnitude), model: model).height
    }
    func aspectFitWidth(for font: UIFont, model: NSLineBreakMode = .byWordWrapping) -> CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude,
                          height: CGFloat.greatestFiniteMagnitude)
        return aspectFitSize(for: font, limitSize: size, model: model).width
    }
}
extension UIFont {
    public var singleLineHeight: CGFloat {
        "Hello".aspectFitHeight(for: self,
                                maxWidth: .greatestFiniteMagnitude)
    }
}
