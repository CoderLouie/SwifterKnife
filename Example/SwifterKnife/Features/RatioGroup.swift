//
//  RatioGroup.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/9/20.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation


fileprivate final class Weak<T: AnyObject> {
    fileprivate weak var object: T?
    
    init(object: T?) {
        self.object = object
    }
}

fileprivate final class ControlGroup {
//    private var controls: [Weak<UIControl>] = []
    func addControl(_ control: UIControl) {
//        let wrap = Weak(object: control)
        if control.isSelected {
            selControl?.isSelected = false
            selControl = control
        }
        DispatchQueue.main.async {
            control.addTarget(self, action: #selector(self.onControlTouchUpInside(_:)), for: .touchUpInside)
        }
//        controls.append(wrap)
//        observeDeinit(for: control) { [weak self] in
//            guard let this = self else { return }
//            this.controls.removeAll { $0 === wrap }
//            if this.controls.isEmpty {
//                RatioGroup.remove(this)
//            }
//        }
    }
    @objc private func onControlTouchUpInside(_ sender: UIControl) {
        selControl?.isSelected = false
        sender.isSelected = true
        selControl = sender
    }
    private(set) weak var selControl: UIControl?
    init() { }
    deinit {
        print("ControlGroup deinit")
    }
}
enum RatioGroup {
    private static var groups: [String: ControlGroup] = [:]
    static func addControl(_ control: UIControl, for key: String) {
        let group = groups[key] ?? {
            let m = ControlGroup()
            groups[key] = m
            return m
        }()
        group.addControl(control)
    }
    static func selectedControl(for key: String) -> UIControl? {
        groups[key]?.selControl
    }
    fileprivate static func remove(_ group: ControlGroup) {
        var keys: [String] = []
        for (k, v) in groups {
            if v === group {
                keys.append(k)
            }
        }
        groups.removeAll(keys: keys)
    }
}
