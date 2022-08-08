//
//  Localize.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

public struct Language: RawRepresentable, Equatable, Hashable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public static var didChangeNotification: Notification.Name {
        .init("LanguageDidChangeNotification")
    }
    
    public static func available() -> [Language] {
        let languages = Bundle.main.localizations
        return languages.map(Language.init(rawValue:))
    }
    
    public static var customized: ((_ code: String) -> Language)?
//        = { code in
//        if code.hasPrefix("zh-") {
//            // zh-Hant\zh-HK\zh-TW
//            return code.contains("Hans") ? .zhHans : .zhHant
//        }
//        return Language(rawValue: code)
//    }
    public static var `default`: Language = .en
    
    public static func reset() {
        current = `default`
    }
    
    private static let CurrentLanguageCodeKey = "CurrentLanguageCodeKey"
    
    private static func loadCurrent() -> Language? {
        if let code = UserDefaults.standard.object(forKey: CurrentLanguageCodeKey) as? String {
            if let transform = customized {
                return transform(code)
            }
            return Language(rawValue: code)
        }
        guard let code = Locale.preferredLanguages.first else { return nil }
        if let transform = customized {
            return transform(code)
        }
        
        let preferedLan = Language(rawValue: code)
        return preferedLan
    }
    private static var _current: Language?
    public static var current: Language {
        get {
            if let tmp = _current { return tmp }
            _current = loadCurrent() ?? `default`
            return _current!
        }
        set {
            if newValue == current { return }
            _current = newValue
            UserDefaults.standard.set(newValue.rawValue, forKey: CurrentLanguageCodeKey)
            UserDefaults.standard.synchronize()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Self.didChangeNotification, object: nil, userInfo: nil)
            }
        }
    }
    
    public func displayName(localized: Bool = false) -> String? {
        let locale = NSLocale(localeIdentifier: localized ? Self.current.rawValue : rawValue)
        return locale.displayName(forKey: .identifier, value: rawValue)
    }
    
    public var direction: Locale.LanguageDirection {
        Locale.characterDirection(forLanguage: rawValue)
    }
}


public extension Language {
    
    // static var base: Language { .init(rawValue: "Base") }
    
    /// 英语 English
    static var en: Language { .init(rawValue: "en") }
    /// 简体中文 Chinese, Simplified
    static var zhHans: Language { .init(rawValue: "zh-Hans") } 
    /// 繁体中文 Chinese, Traditional
    static var zhHant: Language { .init(rawValue: "zh-Hant") }
    
    // 请在你的项目中自行扩展添加支持的多语言
    /*
    /// 繁体中文(香港) Chinese, Hong Kong
    static var zhHK: Language { .init(rawValue: "zh-HK") }
    /// 日语 Japanese
    static var ja: Language { .init(rawValue: "ja") }
    /// 韩语 Korean
    static var ko: Language { .init(rawValue: "ko") }
    /// 法语 French
    static var fr: Language { .init(rawValue: "fr") }
    /// 德语 German
    static var de: Language { .init(rawValue: "de") }
    /// 俄语 Russian
    static var ru: Language { .init(rawValue: "ru") }
    /// 西班牙语 Spanish
    static var es: Language { .init(rawValue: "es") }
    /// 葡萄牙语 Portuguess (Portugal)
    static var ptPT: Language { .init(rawValue: "pt-PT") }
    /// 泰语 Thai
    static var th: Language { .init(rawValue: "th") }
    /// 意大利语 Italian
    static var it: Language { .init(rawValue: "it") }
    /// 阿拉伯语 Arabic
    static var ar: Language { .init(rawValue: "ar") }
    */
} 
