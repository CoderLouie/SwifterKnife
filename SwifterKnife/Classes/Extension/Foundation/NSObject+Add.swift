//
//  NSObject+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2022/3/25.
//


/*
 https://github.com/bradhilton/AssociatedValues
 
 
 private var labelKey: UInt8 = 0
 class MyView: UIView {
    func test() {
        setAssociatedObject(10, for: &labelKey)
    }
 }
 
 */
import Foundation

private final class Associated {
    let value: Any
    init(_ value: Any) {
        self.value = value
    }
}
private final class WeakAssociated {
    weak var value: AnyObject?
    init(_ value: AnyObject) {
        self.value = value
    }
}

public protocol Associable {}

extension String {
    public var address: UnsafeRawPointer {
        return UnsafeRawPointer(bitPattern: abs(hashValue))!
    }
}

public extension Associable where Self: AnyObject {
    func loadAssociatedObject<T>(
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
    func loadWeakAssociatedObject<T: AnyObject>(
        for key: UnsafeRawPointer,
        default builder: @autoclosure () -> T
    ) -> T {
        if let v: T = associatedObject(for: key) {
            return v
        }
        let value = builder()
        setWeakAssociatedObject(value, for: key)
        return value
    }
    func associatedObject<T>(for key: UnsafeRawPointer) -> T? {
        let object = objc_getAssociatedObject(self, key)
        if let obj = object as? Associated {
            return obj.value as? T
        }
        if let obj = object as? WeakAssociated {
            return obj.value as? T
        }
        return object as? T
    }
    
    func setAssociatedObject<T>(_ value: T?, for key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, value.map { Associated($0) }, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    func setWeakAssociatedObject<T: AnyObject>(_ value: T?, for key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, value.map { WeakAssociated($0) }, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

extension NSObject: Associable {}

@discardableResult
public func synchronizd<T>(_ lock: AnyObject, closure: () -> T) -> T {
    objc_sync_enter(lock)
    let result = closure()
    objc_sync_exit(lock)
    return result
}
