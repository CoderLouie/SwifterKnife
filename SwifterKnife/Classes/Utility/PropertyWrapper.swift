//
//  PropertyWrapper.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/9/13.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation


// https://juejin.cn/post/7222189908429275173?searchId=2023091318390070A13A61CFD56E45E2ED

@propertyWrapper
public struct Clamping<WrappedValue: Comparable> {
    let range: ClosedRange<WrappedValue>
    var value: WrappedValue
    
    public init(wrappedValue value: WrappedValue, _ range: ClosedRange<WrappedValue>) {
        self.value = value
        self.range = range
        self.wrappedValue = value
    }
    
    public var wrappedValue: WrappedValue {
        get { value }
        set {
            value = min(max(range.lowerBound, newValue), range.upperBound)
        }
    }
}



@propertyWrapper
public struct Trimed {
    var value: String?
    
    public init(wrappedValue value: String?) {
        self.value = ""
        wrappedValue = value
    }
    
    public var wrappedValue: String? {
        get { value }
        set {
            guard let string = newValue?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !string.isEmpty else {
                value = nil
                return
            }
            value = string
        }
    }
}



@propertyWrapper
public struct StashClosure {
    public typealias Closure = () -> Void
    private var closure: Closure?
    
    public init() {}
    
    public mutating func reset() {
        closure = nil
    }
    
    public mutating func callAndReset() {
        closure?()
        closure = nil
    }
    
    public var wrappedValue: Closure? {
        get { closure }
        set {
            guard let val = newValue else { return }
            if let oldVal = closure {
                closure = {
                    oldVal()
                    val()
                }
            } else {
                closure = val
            }
        }
    }
}

@propertyWrapper
public struct Stash1Closure<T> {
    public typealias Closure = (T) -> Void
    private var closure: Closure?
     
    public init() {}
    
    public mutating func reset() {
        closure = nil
    }
    public mutating func callAndReset(_ arg: T) {
        closure?(arg)
        closure = nil
    }
    
    public var wrappedValue: Closure? {
        get { closure }
        set {
            guard let val = newValue else { return }
            if let oldVal = closure {
                closure = { arg in
                    oldVal(arg)
                    val(arg)
                }
            } else {
                closure = val
            }
        }
    }
}
@propertyWrapper
public struct Stash2Closure<T, U> {
    public typealias Closure = (T, U) -> Void
    private var closure: Closure?
    
    public init() {}
    
    public mutating func reset() {
        closure = nil
    }
    public mutating func callAndReset(_ arg1: T, _ arg2: U) {
        closure?(arg1, arg2)
        closure = nil
    }
    
    public var wrappedValue: Closure? {
        get { closure }
        set {
            guard let val = newValue else { return }
            if let oldVal = closure {
                closure = { arg1, arg2 in
                    oldVal(arg1, arg2)
                    val(arg1, arg2)
                }
            } else {
                closure = val
            }
        }
    }
}
