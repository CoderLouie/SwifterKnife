//
//  DeinitObserver.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/9/18.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

private var deinitObserveKey: UInt8 = 0

fileprivate final class DeinitObserver<Object: AnyObject> {
    private weak var object: Object?
    private var onDeinit: [(Object) -> Void] = []
    fileprivate func onObjectDeinit(_ closure: @escaping (Object) -> Void) {
        onDeinit.append(closure)
    }
    deinit {
        guard let object = object else { return }
        for c in onDeinit {
            c(object)
        }
    }
    init(object: Object) {
        self.object = object
    }
}
public func observeDeinit<Object: AnyObject>(for object: Object?, onDeinit: @escaping (Object) -> Void) {
    guard let object = object else { return }
    let observer = objc_getAssociatedObject(object, &deinitObserveKey) as? DeinitObserver<Object> ?? {
        let observer = DeinitObserver(object: object)
        objc_setAssociatedObject(object, &deinitObserveKey, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return observer
    }()
    observer.onObjectDeinit(onDeinit)
}
