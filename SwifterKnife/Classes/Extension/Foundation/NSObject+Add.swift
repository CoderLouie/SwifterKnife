//
//  NSObject+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2022/3/25.
//

import Foundation

private final class Associated<T> {
    let value: T
    init(_ value: T) {
        self.value = value
    }
}

public protocol Associable {}

extension Associable where Self: AnyObject {
    func lazyAssociatedObject<T>(
        for key: UnsafeRawPointer,
        default builder: @autoclosure () -> T
    ) -> T {
        if let v: T = associatedObject(for: key) {
            return v
        }
        let value = builder()
        setAssociatedObject(value, for: key)
        return value
    }
    func associatedObject<T>(for key: UnsafeRawPointer) -> T? {
        return (objc_getAssociatedObject(self, key) as? Associated<T>).map { $0.value }
    }
    
    func setAssociatedObject<T>(_ value: T?, for key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, value.map { Associated<T>($0) }, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

extension NSObject: Associable {}
