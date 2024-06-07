//
//  App.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit
 
public enum App {
    
    public static func exit() {
        Darwin.exit(0)
    }
    public static func exitAnimated(with view: UIView? = nil, duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration) {
            (view ?? window)?.alpha = 0
        } completion: { _ in
            Darwin.exit(0)
        }
    }
    /// 打断点
    public static func makeBreakpoint() {
        raise(SIGTRAP)
    }
    
    public static var isIdleTimerEnable: Bool {
        get { !UIApplication.shared.isIdleTimerDisabled }
        set {
            UIApplication.shared.isIdleTimerDisabled = !newValue
        }
    }
    
    public static func suspend() {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
    }
    
    public static func delegate<T: UIApplicationDelegate>(as type: T.Type = T.self) -> T {
        guard let delegate = UIApplication.shared.delegate as? T else {
            fatalError("Cann't convert UIApplication.shared.delegate to \(type.self)")
        }
        return delegate
    }
    
    public static var delegate: UIApplicationDelegate? {
        UIApplication.shared.delegate
    }
    public static var window: UIWindow? {
        UIApplication.shared.delegate?.window ?? nil
    }
    

    public static var keyWindow: UIWindow? {
        if #available(iOS 13.0, tvOS 13.0, *) {
            return UIApplication.shared.connectedScenes.filter {
                $0.activationState == .foregroundActive
            }.first {
                $0 is UIWindowScene
            }.flatMap {
                $0 as? UIWindowScene
            }?.windows.first(where: \.isKeyWindow)
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    /// 是否处于debug模式
    public static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    public static var isInTestFlight: Bool {
        Bundle.main.appStoreReceiptURL?.path.contains("sandboxReceipt") == true
    }
    
    public static var schemes: [String] {
        guard let infoDictionary = Bundle.main.infoDictionary,
            let urlTypes = infoDictionary["CFBundleURLTypes"] as? [Any],
            let urlType = urlTypes.first as? [String: Any],
            let urlSchemes = urlType["CFBundleURLSchemes"] as? [String] else {
                return []
        }
        return urlSchemes
    }

    public static var mainScheme: String? {
        schemes.first
    }
    
    public static var namespace: String? {
        string(for: "CFBundleExecutable")
    }
    
    public static var version: String? {
        string(for: "CFBundleShortVersionString")
    }
    
    public static var build: String? {
        string(for: "CFBundleVersion")
    }
    public static var bundleId: String? {
        string(for: "CFBundleIdentifier")
    }
    
    public static var displayName: String? {
        string(for: "CFBundleDisplayName")
    }
    public static var appName: String? {
        string(for: kCFBundleNameKey as String)
    }
    
    /// 桌面上的应用名称，多语言
    public static var desktopName: String? {
        if let name = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
            return name
        }
        if let name = string(for: "CFBundleDisplayName") {
            return name
        }
        if let name = string(for: "CFBundleName") {
            return name
        }
        return nil
    }
    
    public static var iconPaths: [String]? {
        guard let info = Bundle.main.infoDictionary,
              let icons = info["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              !iconFiles.isEmpty else {
            return nil
        }
        return iconFiles
    }
    public static var icon: UIImage? {
        guard let path = iconPaths?.first else { return nil }
        return UIImage(named: path)
    }
    
    private static func string(for key: String) -> String? {
        guard let value = Bundle.main.infoDictionary?[key] as? String else {
                return nil
        }
        return value
    }
    
    public static func gotoSetting() {
        let url = URL(string: UIApplication.openSettingsURLString)
        openURL(url)
    }
    
    public static func openURLString(_ urlString: String?, completion: ((Bool) -> Void)? = nil) {
        openURL(urlString.flatMap(URL.init(string:)), completion: completion)
    }
    public static func openURL(_ url: URL?, completion: ((Bool) -> Void)? = nil) {
        guard let url = url else { completion?(false); return }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
     
//    public static var appID: String = ""
//    //评价应用
//    public static func writeReview(completion: ((Bool) -> Void)? = nil) {
//        guard !appID.isEmpty else {
//            completion?(false)
//            return
//        }
//
//        let url = "itms-apps://itunes.apple.com/app/id\(appID)?action=write-review"
//        App.openURL(URL(string: url), completion: completion)
//    }
}
