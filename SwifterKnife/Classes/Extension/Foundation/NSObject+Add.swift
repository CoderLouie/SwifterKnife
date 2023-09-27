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

/*
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
 */


public protocol Associable {}

/// Policies related to associative references.
public enum AssociationPolicy {
    /// Specifies a weak reference to the associated object.
    case assign
    /// Specifies a strong reference to the associated object.
    /// The association is not made atomically.
    case retain
    /// Specifies that the associated object is copied.
    /// The association is not made atomically.
    case copy
    /// Specifies a strong reference to the associated object.
    /// The association is made atomically.
    case retainAtomic
    /// Specifies that the associated object is copied.
    /// The association is made atomically.
    case copyAtomic
    
    fileprivate var objcPolicy: objc_AssociationPolicy {
        switch self {
        case .assign: return .OBJC_ASSOCIATION_ASSIGN
        case .retain: return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        case .copy: return .OBJC_ASSOCIATION_COPY_NONATOMIC
        case .retainAtomic: return .OBJC_ASSOCIATION_RETAIN
        case .copyAtomic: return .OBJC_ASSOCIATION_COPY
        }
    }
}

public struct AssociationKey: CustomDebugStringConvertible {
    let address: UnsafeRawPointer
    
    public static func current(_ function: StaticString = #function) -> AssociationKey {
        .init(function)
    }
    /// Create an ObjC association key.
    ///
    /// - warning: The key must be uniqued.
    public init() {
        self.address = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
    }
    
    /// Create an ObjC association key from a `StaticString`.
    ///
    ///     let key1 = AssociationKey("SomeString" as StaticString)
    ///     let key2 = AssociationKey(#function as StaticString)
    ///
    /// - precondition: `key` has a pointer representation.
    public init(_ key: StaticString) {
        assert(key.hasPointerRepresentation)
        self.address = UnsafeRawPointer(key.utf8Start)
    }
    
    /// Create an ObjC association key from a `Selector`.
    ///
    ///     @objc var foo: String {
    ///         get {
    ///             re.associatedValue(forKey: AssociationKey(#selector(getter: self.foo)), default: "23")
    ///         }
    ///     }
    ///
    /// - Parameter key: An @objc function or computed property selector.
    public init(_ key: Selector) {
        self.address = UnsafeRawPointer(unsafeBitCast(key, to: UnsafePointer<Int8>.self))
    }
    
    public var debugDescription: String {
        address.debugDescription
    }
}


extension Associable where Self: AnyObject {
    func setAssociatedValue(
        _ value: Any?,
        forKey key: AssociationKey,
        withPolicy policy: AssociationPolicy = .retain
    ) {
        objc_setAssociatedObject(self, key.address, value, policy.objcPolicy)
    }
    func associatedValue<Value>(forKey key: AssociationKey) -> Value? {
        return (objc_getAssociatedObject(self, key.address) as? Value?) ?? nil
    }
    
    func setAssociatedWeakObject<Object: AnyObject>(_ object: Object, forKey key: AssociationKey) {
        let closure = { [weak object] in
            return object
        }
        objc_setAssociatedObject(self, key.address, closure, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    func associatedWeakObject<Object: AnyObject>(forKey key: AssociationKey) -> Object? {
        guard let closure = objc_getAssociatedObject(self, key.address) as? (() -> Object?) else { return nil }
        return closure()
    }
}

@discardableResult
public func synchronizd<T>(_ lock: AnyObject, closure: () -> T) -> T {
    objc_sync_enter(lock)
    let result = closure()
    objc_sync_exit(lock)
    return result
}


//extension NSObject {
//    @discardableResult
//    public static func at_swizzleInstanceMethod(_ originalSelector: Selector, with swizzledSelector: Selector) -> Bool {
//        guard let originalMethod = class_getInstanceMethod(self, originalSelector),
//              let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else { return false }
//        // swizzledMethod (用来替换原始方法)，有可能没在本类中实现，而是在其父类中实现，此时，就需要将其加入到本类中。
//        let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
//        // 添加 originalSelector 对应的方法
//        // 注意代码实现的效果是：originalSelector -> swizzledMethod
//        // 若是方法已经存在，则 didAddMethod 为 NO
//        if didAddMethod {
//            // originalMethod 在上面添加成功了
//            // 下面代码实现： swizzledSelector -> originalMethod
//           class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
//        } else {
//           method_exchangeImplementations(originalMethod, swizzledMethod)
//        }
//        return true
//    }
//}
