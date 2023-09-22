//
//  RatioGroup.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/9/20.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

//extension UIControl.Event {
//    static var selectedChanged: UIControl.Event {
//
//    }
//}

public final class RadioGroup {
    public struct Name: RawRepresentable, Hashable {
        public let rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    private static var groups: [Name: RadioGroup] = [:]
    private static func remove(_ group: RadioGroup) {
        groups.removeValue(forKey: group.name)
    }
    public static let shared = RadioGroup(name: .init(rawValue: "AnonymousRatioGroup"))
  
    public static subscript(_ name: Name) -> RadioGroup {
        groups[name] ?? {
            let m = RadioGroup(name: name)
            groups[name] = m
            return m
        }()
    }
    @discardableResult
    public static func compact() -> Bool {
        let keys = groups.filter {
            $0.value.refCount == 0
        }.keys
        guard !keys.isEmpty else { return false }
        keys.forEach { groups.removeValue(forKey: $0) }
        return true
    }
    @discardableResult
    public static func remove(for name: Name) -> Bool {
        guard let val = groups[name],
              val.refCount == 0 else { return false }
        groups.removeValue(forKey: val.name)
        return true
    }
    
    public var autoSetControlsTag = true
    public var allowCancelChoice = false
    public private(set) weak var selectedControl: UIControl?
    
    private var refCount = 0
    private let name: Name
    private init(name: Name) { self.name = name }
    
    var isNewed: Bool {
        get { selectedControl == nil && refCount == 0 }
        set {
            guard newValue else { return }
            selectedControl = nil
            refCount = 0
        }
    }
    
    @discardableResult
    public func addControl(_ control: UIControl) -> Bool {
        let success = observeDeinit(for: control, recepit: self) { [weak self] in
            guard let this = self else { return }
            this.refCount -= 1
            if this.refCount == 0 {
                RadioGroup.remove(this)
            }
        }
        /// 防止对同一个control多次调用
        if !success { return false }
        if autoSetControlsTag {
            control.tag = refCount
        }
        refCount += 1
        if control.isSelected {
            selectedControl?.isSelected = false
            if let control = selectedControl {
                control.sendActions(for: .valueChanged)
            }
            selectedControl = control
        }
        DispatchQueue.main.async {
            control.addTarget(self, action: #selector(self.onControlTouchUpInside(_:)), for: .touchUpInside)
        }
        return true
    }
    @objc private func onControlTouchUpInside(_ sender: UIControl) {
        guard let control = selectedControl else {
            selectControl(sender)
            return
        }
        if control === sender {
            if !allowCancelChoice { return }
            sender.isSelected = false
            selectedControl = nil
            sender.sendActions(for: .valueChanged)
            return
        }
        control.isSelected = false
        control.sendActions(for: .valueChanged)
        selectControl(sender)
    }
    private func selectControl(_ sender: UIControl) {
        sender.isSelected = true
        selectedControl = sender
        sender.sendActions(for: .valueChanged)
    }
    deinit {
        print("RadioGroup with \(name.rawValue) deinit")
    }
}
//enum RadioGroup {
//    private static var anonymousKey: String {
//        "AnonymousRatioGroup"
//    }
//    private static var groups: [String: ControlGroup] = [:]
//    private static func group(for key: String) -> ControlGroup {
//        groups[key] ?? {
//            let m = ControlGroup(key: key)
//            groups[key] = m
//            return m
//        }()
//    }
//    static func setAllowCancelChoice(_ allow: Bool, for key: String) {
//        group(for: key).allowCancelChoice = allow
//    }
//    static func allowCancelChoice(for key: String) -> Bool {
//        group(for: key).allowCancelChoice
//    }
//    static func addControl(_ control: UIControl, for key: String) {
//        group(for: key).addControl(control)
//    }
//    static func selectedControl(for key: String) -> UIControl? {
//        groups[key]?.selControl
//    }
//
//    static func addControl(_ control: UIControl) {
//        addControl(control, for: anonymousKey)
//    }
//    static var selectedControl: UIControl? {
//        selectedControl(for: anonymousKey)
//    }
//    static var allowCancelChoice: Bool {
//        get { allowCancelChoice(for: anonymousKey) }
//        set { setAllowCancelChoice(newValue, for: anonymousKey) }
//    }
//
//    fileprivate static func remove(_ group: ControlGroup) {
//        groups.removeValue(forKey: group.key)
//    }
//}
