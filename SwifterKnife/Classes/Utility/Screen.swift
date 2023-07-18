//
//  Screen.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit


@objc public final class Screen: NSObject {
    private override init() { }
    
    private static let sw: CGFloat = UIScreen.main.bounds.width
    private static let sh: CGFloat = UIScreen.main.bounds.height
    
    @objc public static var width: CGFloat { sw < sh ? sw : sh }
    @objc public static var height: CGFloat { sw < sh ? sh : sw }
    @objc public static var size: CGSize {
        CGSize(width: width, height: height)
    }
    @objc public static var bounds: CGRect {
        CGRect(origin: .zero, size: size)
    }
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
        let inset = safeAreaInsets
        return height - inset.top - inset.bottom
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
                if let mainWindow = windowScene.value(forKeyPath: "delegate.window") as? UIWindow {
                    return mainWindow
                }
                return UIApplication.shared.windows.last
            }
        }
        return UIApplication.shared.keyWindow
    }
    @objc public static var keyWindow: UIWindow? {
        return UIApplication.shared.keyWindow
    }
//    @objc public static var fontWindow: UIWindow? {
//        for window in UIApplication.shared.windows.reversed() {
//            if window.isKeyWindow,
//               window.screen === UIScreen.main,
//               (!window.isHidden && window.alpha > 0),
//               window.windowLevel >= .normal {
//                return window
//            }
//        }
//        return nil
//    }

    
    @objc public static var safeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            guard let window = currentWindow else { return .zero }
            if let inset = window.rootViewController?.view.safeAreaInsets,
               inset.top > 0 { return inset }
            return window.safeAreaInsets
        }
        let height = UIApplication.shared.statusBarFrame.height
        return UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
    }
    
    @objc public static var frontViewController: UIViewController? {
        guard let window = currentWindow,
              let rootVC = window.rootViewController else {
            return nil
        }
        return rootVC.front()
    }
}


// MARK:- OC
public extension Screen {
    /// 像素化对齐
    @objc static func pix(_ value: CGFloat) -> CGFloat {
        value.pix
    }
    @objc static func pixFloor(_ value: CGFloat) -> CGFloat {
        value.pixFloor
    }
    @objc static func pixRound(_ value: CGFloat) -> CGFloat {
        value.pixRound
    }
    @objc static func pixCeil(_ value: CGFloat) -> CGFloat {
        value.pixCeil
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
