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

fileprivate final class ControlGroup {
    func addControl(_ control: UIControl) {
        if control.isSelected {
            selControl?.isSelected = false
            if let control = selControl {
                control.sendActions(for: .valueChanged)
            }
            selControl = control
        }
        DispatchQueue.main.async {
            control.addTarget(self, action: #selector(self.onControlTouchUpInside(_:)), for: .touchUpInside)
        }
        refCount += 1
        observeDeinit(for: control) { [weak self] in
            guard let this = self else { return }
            this.refCount -= 1
            if this.refCount == 0 {
                RadioGroup.remove(this)
            }
        }
    }
    @objc private func onControlTouchUpInside(_ sender: UIControl) {
        guard let control = selControl else {
            selectControl(sender)
            return
        }
        if control === sender {
            if !allowCancelChoice { return }
            sender.isSelected = false
            selControl = nil
            sender.sendActions(for: .valueChanged)
            return
        }
        control.isSelected = false
        control.sendActions(for: .valueChanged)
        selectControl(sender)
    }
    private func selectControl(_ sender: UIControl) {
        sender.isSelected = true
        selControl = sender
        sender.sendActions(for: .valueChanged)
    }
    private(set) weak var selControl: UIControl?
    private var refCount = 0
    fileprivate let key: String
    fileprivate var allowCancelChoice = false
    init(key: String) { self.key = key }
    deinit {
        print("ControlGroup deinit")
    }
}
enum RadioGroup {
    private static var anonymousKey: String {
        "AnonymousRatioGroup"
    }
    private static var groups: [String: ControlGroup] = [:]
    private static func group(for key: String) -> ControlGroup {
        groups[key] ?? {
            let m = ControlGroup(key: key)
            groups[key] = m
            return m
        }()
    }
    static func setAllowCancelChoice(_ allow: Bool, for key: String) {
        group(for: key).allowCancelChoice = allow
    }
    static func allowCancelChoice(for key: String) -> Bool {
        group(for: key).allowCancelChoice
    }
    static func addControl(_ control: UIControl, for key: String) {
        group(for: key).addControl(control)
    }
    static func selectedControl(for key: String) -> UIControl? {
        groups[key]?.selControl
    }
    
    static func addControl(_ control: UIControl) {
        addControl(control, for: anonymousKey)
    }
    static var selectedControl: UIControl? {
        selectedControl(for: anonymousKey)
    }
    static var allowCancelChoice: Bool {
        get { allowCancelChoice(for: anonymousKey) }
        set { setAllowCancelChoice(newValue, for: anonymousKey) }
    }
    
    fileprivate static func remove(_ group: ControlGroup) {
        groups.removeValue(forKey: group.key)
    }
}
