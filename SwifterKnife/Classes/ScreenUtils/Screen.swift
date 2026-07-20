//
//  Screen.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit


public enum Screen {
    
    private static let sw: CGFloat = UIScreen.main.bounds.width
    private static let sh: CGFloat = UIScreen.main.bounds.height
    
    public static var width: CGFloat { sw < sh ? sw : sh }
    public static var height: CGFloat { sw < sh ? sh : sw }
    public static var size: CGSize {
        CGSize(width: width, height: height)
    }
    public static var bounds: CGRect {
        CGRect(origin: .zero, size: size)
    }
    public static let scale = UIScreen.main.scale
    
    public static var isIPad: Bool {
//        UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad
        UIDevice.current.userInterfaceIdiom == .pad
    }
    public static let isIPhoneXSeries: Bool = {
        let screenHeight = UIScreen.main.bounds.height
        return screenHeight > 800
    }()
    
    /// 当前是否是竖屏
    public static var isPortrait: Bool {
        interfaceOrientation.isPortrait
    }
    
    /// 安全区域刘海一侧的间距 (20/44/50) 也即状态栏高度
    public static var safeAreaT: CGFloat {
        let inset = safeAreaInsets
        switch interfaceOrientation {
        case .landscapeLeft: return inset.right
        case .landscapeRight: return inset.left
        default: return inset.top
        }
    }
    
    /// 安全区域刘海对侧的间距 也即 HomeIndicator 高度
    public static var safeAreaB: CGFloat {
        let inset = safeAreaInsets
        switch interfaceOrientation {
        case .landscapeLeft: return inset.left
        case .landscapeRight: return inset.right
        default: return inset.bottom
        }
    }
    
    public static var bodyRect: CGRect {
        let inset = safeAreaInsets
        let y = inset.top
        return CGRect(x: 0, y: y, width: width, height: height - y - inset.bottom)
    }
    public static var bodyH: CGFloat {
        let inset = safeAreaInsets
        return height - inset.top - inset.bottom
    }
    public static var withoutHeaderH: CGFloat {
        return height - safeAreaT
    }
    public static var withoutFooterH: CGFloat {
        return height - safeAreaB
    }
    // 44 + 20 ---- (44/50) + 44
    public static var navbarH: CGFloat {
        safeAreaT + _navbarH
    }
    public static var navbarCenterY: CGFloat {
        Screen.safeAreaT + (_navbarH * 0.5)
    }
    // 49 --- 49 + 34
    public static var tabbarH: CGFloat {
        safeAreaB + _tabbarH
    }
    
    public static var _tabbarH: CGFloat = 49
    public static var _navbarH: CGFloat = 44
    
    public static var delegateWindow: UIWindow? {
        UIApplication.shared.delegate?.window ?? nil
    }
    
    public static var currentWindow: UIWindow? {
        delegateWindow ?? keyWindow
    }

    private static var interfaceOrientation: UIInterfaceOrientation {
        if #available(iOS 13.0, *) {
            return currentWindow?.windowScene?.interfaceOrientation ?? .unknown
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }
    
    @available(iOS 13.0, *)
    public static var activeWindowScene: UIWindowScene? {
        return UIApplication.shared.connectedScenes.first {
            $0.activationState == .foregroundActive &&
            ($0 as? UIWindowScene) != nil
        } as? UIWindowScene
    }
    public static var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return activeWindowScene?.windows.first {
                $0.isKeyWindow
            }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
//    public static func fontWindow(maxLevel: CGFloat? = nil) -> UIWindow? {
//        for window in UIApplication.shared.windows.reversed() {
//            if window.isKeyWindow,
//               window.screen === UIScreen.main,
//               (!window.isHidden && window.alpha > 0),
//               window.windowLevel >= .normal {
//                if let level = maxLevel,
//                   window.windowLevel.rawValue > level {
//                    return nil
//                }
//                return window
//            }
//        }
//        return nil
//    }

    
    public static var safeAreaInsets: UIEdgeInsets {
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
    
    public static var frontViewController: UIViewController? {
        guard let window = currentWindow,
              let rootVC = window.rootViewController else {
            return nil
        }
        return rootVC.front()
    }
    
    public static var isRTL: Bool {
        guard let window = currentWindow else {
            return false
        }
        return UIView.userInterfaceLayoutDirection(for: window.semanticContentAttribute) == .rightToLeft
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

