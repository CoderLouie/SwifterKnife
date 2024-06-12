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
    
    public var displayName: String? {
        let locale = NSLocale(localeIdentifier: rawValue)
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

public final class Lan {
    public static let main = Lan(bundle: .main)
    
    public let bundle: Bundle
    public var `default`: Language
    public init(bundle: Bundle, defaultLanguage: Language = .en) {
        self.bundle = bundle
        self.default = defaultLanguage
    }
    
    public static var didChangeNotification: Notification.Name {
        .init("LanguageDidChangeNotification")
    }
    
    public func available(excludeBase: Bool = true) -> [Language] {
        var languages = bundle.localizations
        if excludeBase {
            languages.removeAll { $0 == "Base" }
        }
        return languages.map(Language.init(rawValue:))
    }
    
    public func reset() {
        current = `default`
    }
    
    private var cachedLanguage: Language? {
        get {
            if let code = UserDefaults.standard.object(forKey: "CurrentLanguageCodeKey") as? String {
                return Language(rawValue: code)
            }
            return nil
        }
        set {
            UserDefaults.standard.set(newValue?.rawValue, forKey: "CurrentLanguageCodeKey")
        }
    }
    private var preferredLanguage: Language? {
        guard let code = bundle.preferredLocalizations.first,
                !code.isEmpty else {
            return nil
        }
        return Language(rawValue: code)
    }
     
    private var _current: Language?
    public var current: Language {
        get {
            if let tmp = _current { return tmp }
            let lan = cachedLanguage ?? preferredLanguage ?? `default`
            _current = lan
            return lan
        }
        set {
            if newValue == current { return }
            _current = newValue
            UIView.appearance().semanticContentAttribute = newValue.direction == .rightToLeft ? .forceRightToLeft : .forceLeftToRight
            cachedLanguage = newValue
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Self.didChangeNotification, object: nil, userInfo: nil)
            }
        }
    }
} 
