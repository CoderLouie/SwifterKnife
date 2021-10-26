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
    
    public static func available(excludeBase: Bool = false) -> [Language] {
        var availableLanguages = Bundle.main.localizations
        // If excludeBase = true, don't include "Base" in available languages
        if excludeBase == true,
           let indexOfBase = availableLanguages.firstIndex(of: "Base") {
            availableLanguages.remove(at: indexOfBase)
        }
        return availableLanguages.map(Language.init(rawValue:))
    }
    
    public static var `default`: Language {
//        guard let first = Bundle.main.preferredLocalizations.first else {
//            return .en
//        }
        guard let first = Locale.preferredLanguages.first else { return .en }
        
        let preferedLan = Language(rawValue: first)
        return preferedLan
//        if (available().contains(preferedLan)) {
//            return preferedLan
//        }
//        return .en
    }
    
    public static func reset() {
        current = `default`
    }
    
    private static var _current: Language?
    
    private static let CurrentLanguageKey = "CurrentLanguageKey"
    public static var current: Language {
        get {
            if let tmp = _current { return tmp }
            if let current = UserDefaults.standard.object(forKey: CurrentLanguageKey) as? String {
                let lan = Language(rawValue: current)
                _current = lan
                return lan
            }
            _current = `default`
            return _current!
        }
        set {
            if newValue == current { return }
//            guard available().contains(newValue) else {
//                return
//            }
            _current = newValue
            UserDefaults.standard.set(newValue, forKey: CurrentLanguageKey)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Self.didChangeNotification, object: nil, userInfo: nil)
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
    
    static var base: Language { .init(rawValue: "Base") }
    /// 英语 English
    static var en: Language { .init(rawValue: "en") }
    /// 简体中文 Chinese, Simplified
    static var zhHans: Language { .init(rawValue: "zh-Hans") }
    
    
    // 请在你的项目中自行扩展添加支持的多语言
    /*
    /// 繁体中文 Chinese, Traditional
    static var zhHant: Language { .init(rawValue: "zh-Hant") }
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

extension Language {
    
    public struct Table: RawRepresentable, Equatable, Hashable {
        public let rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}
