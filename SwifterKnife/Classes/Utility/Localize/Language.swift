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
    
    public static var loadDefault: ((_ code: String) -> Language)? = { code in
        if code.hasPrefix("zh-") {
            // // zh-Hant\zh-HK\zh-TW
            return code.contains("Hans") ? .zhHans : .zhHant
        }
        return Language(rawValue: code)
    }
    public static var `default`: Language {
//        guard let first = Bundle.main.preferredLocalizations.first else {
//            return .en
//        }
        guard let code = Locale.preferredLanguages.first else { return .en }
        if let config = loadDefault {
            return config(code)
        }
        
        let preferedLan = Language(rawValue: code)
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
    /// ?????? English
    static var en: Language { .init(rawValue: "en") }
    /// ???????????? Chinese, Simplified
    static var zhHans: Language { .init(rawValue: "zh-Hans") }
    
    
    // ?????????????????????????????????????????????????????????

    /// ???????????? Chinese, Traditional
    static var zhHant: Language { .init(rawValue: "zh-Hant") }
    
    /*
    /// ????????????(??????) Chinese, Hong Kong
    static var zhHK: Language { .init(rawValue: "zh-HK") }
    /// ?????? Japanese
    static var ja: Language { .init(rawValue: "ja") }
    /// ?????? Korean
    static var ko: Language { .init(rawValue: "ko") }
    /// ?????? French
    static var fr: Language { .init(rawValue: "fr") }
    /// ?????? German
    static var de: Language { .init(rawValue: "de") }
    /// ?????? Russian
    static var ru: Language { .init(rawValue: "ru") }
    /// ???????????? Spanish
    static var es: Language { .init(rawValue: "es") }
    /// ???????????? Portuguess (Portugal)
    static var ptPT: Language { .init(rawValue: "pt-PT") }
    /// ?????? Thai
    static var th: Language { .init(rawValue: "th") }
    /// ???????????? Italian
    static var it: Language { .init(rawValue: "it") }
    /// ???????????? Arabic
    static var ar: Language { .init(rawValue: "ar") }
    */
} 
