//
//  Knife.swift
//  SwifterKnife
//
//  Created by 李阳 on 2022/11/20.
//

import Foundation

//@propertyWrapper
public final class Lazy<T> {
    private var builder: (() -> T)!
      
    public init(_ value: @escaping @autoclosure () -> T) {
        builder = value
    }
    public init(_ builder: @escaping () -> T) {
        self.builder = builder
    }
    public private(set) var nullable: T?
    
    public var nonull: T {
        if let v = nullable { return v }
        let v = builder()
        builder = nil
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


//public enum Knife {
//    /// Debounce a function such that the function is only invoked once no matter how many times
//    /// it is called within the delayBy interval
//    ///
//    /// - parameter delayBy: interval to delay the execution of the function by
//    /// - parameter queue: Queue to run the function on. Defaults to main queue
//    /// - parameter function: function to execute
//    /// - returns: Function that is debounced and will only invoke once within the delayBy interval
//    public static func debounce(delayBy: DispatchTimeInterval, queue: DispatchQueue = .main, _ function: @escaping () -> Void) -> () -> Void {
//        var currentWorkItem: DispatchWorkItem?
//        return {
//            currentWorkItem?.cancel()
//            currentWorkItem = DispatchWorkItem { function() }
//            queue.asyncAfter(deadline: .now() + delayBy, execute: currentWorkItem!)
//        }
//    }
//
//    /// Throttle a function such that the function is invoked immediately, and only once no matter
//    /// how many times it is called within the limitTo interval
//    ///
//    /// - parameter limitTo: interval during which subsequent calls will be ignored
//    /// - parameter queue: Queue to run the function on. Defaults to main queue
//    /// - parameter function: function to execute
//    /// - returns: Function that is throttled and will only invoke immediately and only once within the limitTo interval
//    public static func throttle(limitTo: DispatchTimeInterval, queue: DispatchQueue = .main, _ function: @escaping () -> Void) -> () -> Void {
//        var allowFunction: Bool = true
//        return {
//            guard allowFunction else { return }
//            allowFunction = false
//            function()
//            queue.asyncAfter(deadline: .now() + limitTo, qos: .background) {
//                allowFunction = true
//            }
//        }
//    }
//
//
//    public static func throttle(_ function: @escaping (_ completion: @escaping () -> Void) -> Void) -> () -> Void {
//        var allowFunction: Bool = true
//        return {
//            guard allowFunction else { return }
//            allowFunction = false
//            function {
//                allowFunction = true
//            }
//        }
//    }
//}
