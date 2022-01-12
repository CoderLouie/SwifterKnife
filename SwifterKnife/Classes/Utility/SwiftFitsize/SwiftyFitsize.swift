//
//  SwiftyFitsize.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit

// MARK:- SwiftyFitsize 

@objc public enum SwiftyFitType: Int {
    /// Original Value
    case none = 0
    /// ~
    case flexibleWidth = 1
    /// ≈
    case forceWidth = 2
    /// ∣
    case flexibleHeight = 3
    /// ∥
    case forceHeight = 4
    /// ∣=
    case flexibleSafeAreaCenterHeight = 5
    /// ∥=
    case forceSafeAreaCenterHeight = 6
    /// ∣-
    case flexibleSafeAreaWithoutTopHeight = 7
    /// ∥-
    case forceSafeAreaWithoutTopHeight = 8
    /// 小屏手机(height < 570)才会适配高度
    case flexibleHeightOnlyOnSmallDevcie = 9
}

@objc public final class SwiftyFitsize: NSObject {
    private override init() { }
    
    @objc public static let shared = SwiftyFitsize()
    
    /// 默认参照宽度
    @objc public private(set) var referenceW: CGFloat = 375
    /// 默认参照高度
    @objc public private(set) var referenceH: CGFloat = 812
    /// 是否为iPhoneX系列的参照高度，默认否
    @objc public private(set) var isIPhoneXSeriesHeight: Bool = true
    /// 默认 iPad 适配缩放倍数 (0 , 1]
    @objc public private(set) var iPadFitMultiple: CGFloat = 0.5
    /// 中间安全区域参照高度
    @objc public var referenceBodyHeight: CGFloat {
        if !isIPhoneXSeriesHeight { return referenceH }
        return referenceH - Screen.safeAreaT - Screen.safeAreaB
    }
    /// 仅去除顶部后的安全区域参照高度
    @objc public var referenceWithoutHeaderHeight: CGFloat {
        if !isIPhoneXSeriesHeight { return referenceH }
        return referenceH - Screen.safeAreaT
    }
    /// 适配倍数
    @objc public var fitMultiple: CGFloat {
        return Screen.isIPad ? iPadFitMultiple : 1
    }
     
    
    /// 设置参照的相关参数
    /// - Parameters:
    ///   - width: 参照的宽度
    ///   - height: 参照的高度
    ///   - isIPhoneXSeriesHeight: 是否为iPhoneX系列的参照高度
    ///   - iPadFitMultiple: iPad 在适配后所得值的倍数 (0 , 1]
    @objc public static func reference(
        width: CGFloat = 375,
        height: CGFloat = 812,
        isIPhoneXSeriesHeight: Bool = true,
        iPadFitMultiple: CGFloat = 0.5
    ) {
        shared.referenceW = width
        shared.referenceH = height
        shared.isIPhoneXSeriesHeight = isIPhoneXSeriesHeight
        shared.iPadFitMultiple =
            (iPadFitMultiple > 1 || iPadFitMultiple < 0) ? 1 : iPadFitMultiple
    }
    
    private func _fitNumber(
        _ value: CGFloat,
        fitType: SwiftyFitType
    ) -> CGFloat {
        switch fitType {
        case .none: return value
        case .flexibleWidth:
            return Screen.width / referenceW * value * fitMultiple
        case .forceWidth:
            return Screen.width / referenceW * value
        case .flexibleHeight:
            return Screen.height / referenceH * value * fitMultiple
        case .forceHeight:
            return Screen.height / referenceH * value
        case .flexibleSafeAreaCenterHeight:
            return Screen.bodyH / referenceBodyHeight * value * fitMultiple
        case .forceSafeAreaCenterHeight:
            return Screen.bodyH / referenceBodyHeight * value
        case .flexibleSafeAreaWithoutTopHeight:
            return Screen.withoutHeaderH / referenceWithoutHeaderHeight * value * fitMultiple
        case .forceSafeAreaWithoutTopHeight:
            return Screen.withoutHeaderH / referenceWithoutHeaderHeight * value
        case .flexibleHeightOnlyOnSmallDevcie:
            if Screen.height > 570 { return value }
            return Screen.height / referenceBodyHeight * value
        }
    }
    fileprivate func fitNumber(
        _ value: CGFloat,
        fitType: SwiftyFitType
    ) -> CGFloat {
        guard value != CGFloat.leastNormalMagnitude else { return 0 }
        let res = _fitNumber(value, fitType: fitType)
        let scale = Screen.scale
        return ceil(res * scale) / scale
    }
}

public protocol SwiftyFitsizeable {
    associatedtype TargetType
    func sf(_ type: SwiftyFitType) -> TargetType
}
public extension SwiftyFitsizeable {
    var fit: TargetType { return sf(.flexibleWidth) }
    var fitH: TargetType { return sf(.flexibleHeight) }
    var fitT: TargetType { return sf(.flexibleSafeAreaWithoutTopHeight) }
    var fitC: TargetType { return sf(.flexibleSafeAreaCenterHeight) }
    var fitS: TargetType {
        return sf(.flexibleHeightOnlyOnSmallDevcie)
    }
}

fileprivate protocol CGFloatFitsizeable: SwiftyFitsizeable {
    var cgfloatValue: CGFloat { get }
}
extension CGFloatFitsizeable {
    public func sf(_ type: SwiftyFitType) -> CGFloat {
        return SwiftyFitsize.shared.fitNumber(cgfloatValue, fitType: type)
    }
}
extension CGFloatFitsizeable where Self: BinaryInteger {
    var cgfloatValue: CGFloat { return CGFloat(self) }
}
 
extension Int: CGFloatFitsizeable {}
extension Int64: CGFloatFitsizeable {}
extension Int32: CGFloatFitsizeable {}
extension Int16: CGFloatFitsizeable {}
extension Int8: CGFloatFitsizeable {}
extension UInt: CGFloatFitsizeable {}
extension UInt64: CGFloatFitsizeable {}
extension UInt32: CGFloatFitsizeable {}
extension UInt16: CGFloatFitsizeable {}
extension UInt8: CGFloatFitsizeable {}


extension CGFloatFitsizeable where Self: BinaryFloatingPoint {
    var cgfloatValue: CGFloat { return CGFloat(self) }
}
extension Double: CGFloatFitsizeable {}
extension Float: CGFloatFitsizeable {}
#if canImport(CoreGraphics)
import CoreGraphics
extension CGFloat: CGFloatFitsizeable {
    public var cgfloatValue: CGFloat { return self }
}
#endif

extension CGPoint: SwiftyFitsizeable {
    public func sf(_ type: SwiftyFitType) -> CGPoint {
        return CGPoint(x: x.sf(type), y: y.sf(type))
    }
}
extension CGSize: SwiftyFitsizeable {
    public func sf(_ type: SwiftyFitType) -> CGSize {
        return CGSize(width: width.sf(type), height: height.sf(type))
    }
}
extension CGRect: SwiftyFitsizeable {
    public func sf(_ type: SwiftyFitType) -> CGRect {
        return CGRect(
            x: origin.x.sf(type),
            y: origin.y.sf(type),
            width: size.width.sf(type),
            height: size.height.sf(type)
        )
    }
}
extension UIEdgeInsets: SwiftyFitsizeable {
    public func sf(_ type: SwiftyFitType) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: top.sf(type),
            left: left.sf(type),
            bottom: bottom.sf(type),
            right: right.sf(type)
        )
    }
}


extension UIFont {
    @objc public var fit: UIFont {
        let newSize = SwiftyFitsize.shared.fitNumber(pointSize, fitType: .flexibleWidth)
        return withSize(round(newSize))
    }
}


@objc public final class Screen: NSObject {
    private override init() { }
    
    private static let sw: CGFloat = UIScreen.main.bounds.width
    private static let sh: CGFloat = UIScreen.main.bounds.height
    
    @objc public static var width: CGFloat { sw < sh ? sw : sh }
    @objc public static var height: CGFloat { sw < sh ? sh : sw }
    
    @objc public static let scale = UIScreen.main.scale
    
    @objc public static var isIPad: Bool {
        UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad
    }
    @objc public static let isIPhoneXSeries: Bool = {
        var bottomSafeInset: CGFloat = 0
        if #available(iOS 11.0, *) {
            bottomSafeInset = currentWindow?.safeAreaInsets.bottom ?? 0
        }
        return bottomSafeInset > 0
    }()
    
    /// 当前是否是竖屏
    @objc public static var isPortrait: Bool {
        return UIApplication.shared.statusBarOrientation.isPortrait
    }
    
    /// 安全区域刘海一侧的间距 (20/44/50) 也即状态栏高度
    @objc public static var safeAreaT: CGFloat {
        let inset = safeAreaInsets
        switch UIApplication.shared.statusBarOrientation {
        case .portrait, .portraitUpsideDown: return inset.top
        case .landscapeLeft: return inset.right
        case .landscapeRight: return inset.left
        default: return 0
        }
    }
    
    /// 安全区域刘海对侧的间距 也即 HomeIndicator 高度
    @objc public static var safeAreaB: CGFloat {
        let inset = safeAreaInsets
        switch UIApplication.shared.statusBarOrientation {
        case .portrait, .portraitUpsideDown: return inset.bottom
        case .landscapeLeft: return inset.left
        case .landscapeRight: return inset.right
        default: return 0
        }
    }
    
    @objc public static var bodyH: CGFloat {
        return height - safeAreaT - safeAreaB
    }
    @objc public static var withoutHeaderH: CGFloat {
        return height - safeAreaT
    }
    @objc public static var withoutFooterH: CGFloat {
        return height - safeAreaB
    }
    // 44 + 20 ---- (44/50) + 44
    @objc public static var navbarH: CGFloat {
        safeAreaT + 44
    }
    // 49 --- 49 + 34
    @objc public static var tabbarH: CGFloat {
        safeAreaB + 49
    }
    
    @objc public static var currentWindow: UIWindow? {
        if let window = UIApplication.shared.delegate?.window {
            return window
        }
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first {
                if let mainWindow = windowScene.value(forKey: "delegate.window") as? UIWindow {
                    return mainWindow
                }
                return UIApplication.shared.windows.last
            }
        }
        return UIApplication.shared.keyWindow
    }
    
    @objc public static var safeAreaInsets: UIEdgeInsets {
        guard global.top > 0 else { return global }
        global = _safeAreaInsets
        return global
    }
    private static var global: UIEdgeInsets = .zero
    private static var _safeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            guard let window = currentWindow else { return .zero }
            if let inset = window.rootViewController?.view.safeAreaInsets,
               inset.top > 0 { return inset }
            return window.safeAreaInsets
        }
        let height = UIApplication.shared.statusBarFrame.height
        return UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
    }
    
    @objc public static var frontViewController: UIViewController {
        guard let window = currentWindow,
              let rootVC = window.rootViewController else {
            fatalError()
        }
        return rootVC.front()
    }
}


// MARK:- OC
public extension Screen {
    /// 向下像素化对其
    @objc static func pix(_ value: CGFloat) -> CGFloat {
        value.pix
    }
    @objc static func fit(_ value: CGFloat) -> CGFloat {
        value.fit
    }
    @objc static func fitH(_ value: CGFloat) -> CGFloat {
        value.fitH
    }
    @objc static func fitT(_ value: CGFloat) -> CGFloat {
        value.fitT
    }
    @objc static func fitC(_ value: CGFloat) -> CGFloat {
        value.fitC
    }
    /// 只有小屏幕手机才会是配高度 small
    @objc static func fitS(_ value: CGFloat) -> CGFloat {
        value.fitS
    }
}
 
extension UIViewController {
    public func front() -> UIViewController {
        if let presented = presentedViewController {
            return presented.front()
        } else if let nav = self as? UINavigationController,
                  let visible = nav.visibleViewController {
            return visible.front()
        } else if let tab = self as? UITabBarController,
                  let selected = tab.selectedViewController {
            return selected.front()
        } else {
            for vc in children.reversed() {
                if vc.view.window != nil {
                    return vc.front()
                }
            }
            return self
        }
    }
}

public extension CGFloat {
    /// 向下像素化对齐
    var pix: CGFloat {
        let scale = Screen.scale
        return Darwin.floor(self * scale) / scale
    }
}
