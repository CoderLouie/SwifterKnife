//
//  App.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit
 
public enum App {
    
    /// 是否处于debug模式
    public static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    public static var namespace: String {
        guard let namespace =  Bundle.main.infoDictionary?["CFBundleExecutable"] as? String else { return "" }
        return  namespace
    }
    
    public static var version: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    public static var build: String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
    
    public static var name: String? {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
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
