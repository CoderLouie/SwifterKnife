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
//        UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad
        UIDevice.current.userInterfaceIdiom == .pad
    }
    @objc public static let isIPhoneXSeries: Bool = {
        let bottomSafeInset = currentWindow?.safeAreaInsets.bottom ?? 0
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
    
    @objc public static var delegateWindow: UIWindow? {
        UIApplication.shared.delegate?.window ?? nil
    }
    
    @objc public static var currentWindow: UIWindow? {
        delegateWindow ?? keyWindow
    }
    
    @available(iOS 13.0, *)
    public static var activeWindowScene: UIWindowScene? {
        return UIApplication.shared.connectedScenes.firstMap {
            guard $0.activationState == .foregroundActive,
                  let scene = $0 as? UIWindowScene else {
                return nil
            }
            return scene
        }
    }
    @objc public static var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes.firstMap {
                guard $0.activationState == .foregroundActive,
                      let scene = $0 as? UIWindowScene else {
                    return nil
                }
                return scene.windows.first(where: \.isKeyWindow)
            }
        } else {
            return UIApplication.shared.keyWindow
        }
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
        } else {
            let height = UIApplication.shared.statusBarFrame.height
            return UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
        }
    }
    
    @objc public static var frontViewController: UIViewController? {
        guard let window = currentWindow,
              let rootVC = window.rootViewController else {
            return nil
        }
        return rootVC.front()
    }
}


weak var _curFirstResponder: UIResponder? = nil
private extension UIResponder {
    @objc func at_findFirstResponder(_ sender: UIResponder) {
        _curFirstResponder = self
    }
}

extension Screen {
    public static var firstResponder: UIView? {
        _curFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIView.at_findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _curFirstResponder as? UIView
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
        } else if let page = self as? UIPageViewController,
                  let vcs = page.viewControllers,
                  vcs.count == 1 {
            return vcs[0].front()
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
