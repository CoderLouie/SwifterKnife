//
//  Knife.swift
//  SwifterKnife
//
//  Created by 李阳 on 2022/11/20.
//

import Foundation


public final class Lazy<T> {
    private var builder: (() -> T)!
    
    public init(_ builder: @escaping () -> T) {
        self.builder = builder
    }
//    public init(_ builder: T) {
//        self.builder = { builder }
//    }
    public private(set) var nullable: T?
    
    public var nonull: T {
        if let v = nullable { return v }
        let v = builder()
//        builder = nil
        nullable = v
        return v
    }
    public var isBuilt: Bool {
        return nullable != nil
    }
    deinit {
        print("Lazy deinit")
    }
}
public enum Knife {
    /// Get a wrapper function that executes the passed function only once
    ///
    /// - parameter function: That takes variadic arguments and return nil or some value
    /// - returns: Wrapper function that executes the passed function only once
    /// Consecutive calls will return the value returned when calling the function first time
    public static func once<T, U>(_ function: @escaping (T...) -> U) -> (T...) -> U {
        typealias Function = ([T]) -> U
        var result: U?
        let onceFunc = { (params: T...) -> U in
            if let returnVal = result {
                return returnVal
            } else {
                let f = unsafeBitCast(function, to: Function.self)
                result = f(params)
                return result!
            }
        }
        return onceFunc
    }
    
    /// Get a wrapper function that executes the passed function only once
    ///
    /// - parameter function: That takes variadic arguments and return nil or some value
    /// - returns: Wrapper function that executes the passed function only once
    /// Consecutive calls will return the value returned when calling the function first time
    public static func once<U>(_ function: @escaping () -> U) -> () -> U {
        var result: U?
        let onceFunc = { () -> U in
            if let returnVal = result {
                return returnVal
            } else {
                result = function()
                return result!
            }
        }
        return onceFunc
    }
    
    public static func lazy<T>(_ build: @escaping () -> T) -> (nullable: () -> T?, nonull: () -> T, isBuilt: () -> Bool) {
        let lazy = Lazy(build)
        return ({ lazy.nullable }, { lazy.nonull }, { lazy.isBuilt })
    }
}
