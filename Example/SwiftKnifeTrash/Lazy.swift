//
//  Lazy.swift
//  SwifterKnife
//
//  Created by liyang on 2021/12/8.
//

import Foundation
 
/*
 class HomeViewController: UIViewController {
    var model = Lazy(Model())
 }
 如果没有调用过model.nonull，会发生内存泄漏
 */
//@propertyWrapper
public final class Lazy<T> {
    public init() {}
    public private(set) var nullable: T?
    
    public var nonull: T {
        nullable!
    }
    
    public func buildIfNeeded(_ defaultValue: @autoclosure () -> T) {
        if let _ = nullable { return }
        nullable = defaultValue()
    }
    
    @discardableResult
    public func nonull(or defaultValue: @autoclosure () -> T) -> T {
        if let v = nullable { return v }
        let v = defaultValue()
        nullable = v
        return v
    }
    
    public var isBuilt: Bool {
        return nullable != nil
    }
/*
 propertyWrapper修饰的属性不能使用lazy，
 */
//    public var projectedValue: Lazy<T> { self }
//    public var wrappedValue: T {
//       return nonull
//    }
    deinit {
        print("Lazy deinit")
    }
}


