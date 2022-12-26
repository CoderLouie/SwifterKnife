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
    private var builder: (() -> T)!
    private var config: ((T) -> Void)?
    
    public init(_ value: @escaping @autoclosure () -> T) {
        builder = value
    }
    
    public func then(_ block: @escaping (T) -> Void) -> Self {
        config = block
        return self
    }
//    public init(_ builder: @escaping () -> T) {
//        self.builder = builder
//    }
    public private(set) var nullable: T?
    
    public var nonull: T {
        if let v = nullable { return v }
        let v = builder()
        builder = nil
        config?(v)
        config = nil
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


