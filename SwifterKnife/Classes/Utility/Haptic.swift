//
//  Haptic.swift
//  SwifterKnife
//
//  Created by liyang on 2022/08/15.
//

import UIKit

public enum Haptic {
    public enum ImpactStyle: Int {
        case light, medium, heavy
        
        @available(iOS 13.0, *)
        case soft, rigid
        
        var value: UIImpactFeedbackGenerator.FeedbackStyle {
            return .init(rawValue: rawValue)!
        }
    }

    public enum NotifyType: Int {
        case success, warning, error
        
        var value: UINotificationFeedbackGenerator.FeedbackType {
            return .init(rawValue: rawValue)!
        }
    }
    
    case impact(ImpactStyle)
    case notification(NotifyType)
    case selection
    
    // trigger
    public func generate() {
        switch self {
        case .impact(let style):
            let generator = UIImpactFeedbackGenerator(style: style.value)
            generator.prepare()
            generator.impactOccurred()
        case .notification(let type):
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type.value)
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
}

import AudioToolbox
extension Haptic {
    public static func vibrate() {
        AudioServicesPlaySystemSound(1519)
//        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
