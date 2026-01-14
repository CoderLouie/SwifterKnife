//
//  UIFont+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2022/3/10.
//

import Foundation


public extension UIFont {
    static func regular(_ size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .regular)
    }
    static func semibold(_ size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .semibold)
    }
    static func medium(_ size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .medium)
    }
    static func bold(_ size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
    @discardableResult
    static func regist(from url: URL) -> String? {
        guard let fontData = CGDataProvider(url: url as CFURL),
            let fontRef = CGFont(fontData) else { return nil }
        CTFontManagerRegisterGraphicsFont(fontRef, nil)
//        guard let name = fontRef.fullName as? String, !name.isEmpty else { return nil }
//        return UIFont(name: name, size: 20)?.familyName
        return fontRef.postScriptName as? String
    }
}
