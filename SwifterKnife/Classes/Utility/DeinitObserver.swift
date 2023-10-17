//
//  DeinitObserver.swift
//  SwifterKnife
//
//  Created by liyang on 2023/9/18. 
//

import Foundation

private var deinitObserveKey: UInt8 = 0

fileprivate final class DeinitObserver {
    fileprivate var onDeinit: [() -> Void] = []
    fileprivate var receipt: [UInt] = []
    deinit { onDeinit.forEach { $0() }
    }
    init() { }
}

@discardableResult
public func observeDeinit(for object: AnyObject?, once: Bool = false, onDeinit: @escaping () -> Void) -> Bool {
    guard let object = object else { return false }
    let observer = at__observer(for: object)
    if once, !observer.onDeinit.isEmpty { return false }
    observer.onDeinit.append(onDeinit)
    return true
}

/*
 在object生命周期内，receipt对象只能监听object一次
 */
@discardableResult
public func observeDeinit(for object: AnyObject?, recepit: AnyObject, onDeinit: @escaping () -> Void) -> Bool {
    guard let object = object else { return false }
    let ptr = unsafeBitCast(recepit, to: UInt.self)
    let observer = at__observer(for: object)
    if observer.receipt.contains(ptr) { return false }
    observer.receipt.append(ptr)
    observer.onDeinit.append(onDeinit)
    return true
}

private func at__observer(for object: AnyObject) -> DeinitObserver {
    objc_getAssociatedObject(object, &deinitObserveKey) as? DeinitObserver ?? {
        let observer = DeinitObserver()
        objc_setAssociatedObject(object, &deinitObserveKey, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return observer
    }()
}
