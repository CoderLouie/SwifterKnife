//
//  App.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit
 
public enum App {
    
    public var isIdleTimerEnable: Bool {
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
    
    public static func openURL(_ url: URL?, completion: ((Bool) -> Void)? = nil) {
        guard let url = url else { completion?(false); return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: completion)
        } else {
            UIApplication.shared.openURL(url)
            completion?(true)
        }
    }
     
}
