//
//  Localize.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation
/*
 //从userDefault中获取到的，返回的是一个数组,表示在当前APP下使用过的。["zh-Hans-CN","en"]
 let userLanguage = UserDefaults.standard.object(forKey: "AppleLanguages")
 
 //用户在手机系统设置里设置的首选语言列表。可以通过设置-通用-语言与地区-首选语言顺序看到，不是程序正在显示的语言。["zh-Hans-CN","en"]
 let preferredLanguages = Locale.preferredLanguages
 
 //当前系统语言，不带地区码，"zh","en"
 let currentLanguage = Locale.current.languageCode
 
 //返回数组 ["Base"]?
 let bundleLanguages = Bundle.main.preferredLocalizations
 */
public struct Language: RawRepresentable, Equatable, Hashable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public static var didChangeNotification: Notification.Name {
        .init("LanguageDidChangeNotification")
    }
    
    public static func available(for bundle: Bundle = .main, excludeBase: Bool = true) -> [Language] {
        var languages = bundle.localizations
        if excludeBase {
            languages.removeAll { $0 == "Base" }
        }
        return languages.map(Language.init(rawValue:))
    }
    
    public static func availableCodes(for bundle: Bundle = .main) -> Set<String> {
        Set(bundle.localizations)
    }
    
    public static var customized: ((_ code: String) -> String?)?
    
    public static var `default`: Language = .en
    
    public static func reset() {
        current = `default`
    }
    
    private static let CurrentLanguageCodeKey = "CurrentLanguageCodeKey"
    
    private static func loadCurrent() -> Language? {
        if let code = UserDefaults.standard.object(forKey: CurrentLanguageCodeKey) as? String {
            return Language(rawValue: code)
        }
        guard var code = Locale.current.languageCode else {
            return nil
        }
        if let closure = customized,
           let res = closure(code) {
            code = res
        }
        guard Set(Bundle.main.localizations).contains(code) else {
            return nil
        }
        return Language(rawValue: code)
    }
    private static var _current: Language? {
        didSet {
            guard let lan = _current else { return }
            UIView.appearance().semanticContentAttribute = lan.direction == .rightToLeft ? .forceRightToLeft : .forceLeftToRight
        }
    }
    public static var current: Language {
        get {
            if let tmp = _current { return tmp }
            let lan = loadCurrent() ?? `default`
            _current = lan
            return lan
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
