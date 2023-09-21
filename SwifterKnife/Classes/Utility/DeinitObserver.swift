//
//  DeinitObserver.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/9/18.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

private var deinitObserveKey: UInt8 = 0

fileprivate final class DeinitObserver {
    private var onDeinit: [() -> Void] = []
    fileprivate func onObjectDeinit(_ closure: @escaping () -> Void) {
        onDeinit.append(closure)
    }
    deinit {
        onDeinit.forEach { $0() }
    }
    init() { }
}
public func observeDeinit(for object: AnyObject?, onDeinit: @escaping () -> Void) {
    guard let object = object else { return }
    let observer = objc_getAssociatedObject(object, &deinitObserveKey) as? DeinitObserver ?? {
        let observer = DeinitObserver()
        objc_setAssociatedObject(object, &deinitObserveKey, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return observer
    }()
    observer.onObjectDeinit(onDeinit)
}
