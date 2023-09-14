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
struct Clamping<WrappedValue: Comparable> {
    let range: ClosedRange<WrappedValue>
    var value: WrappedValue
    
    init(wrappedValue value: WrappedValue, _ range: ClosedRange<WrappedValue>) {
        self.value = value
        self.range = range
        self.wrappedValue = value
    }
    
    var wrappedValue: WrappedValue {
        get { value }
        set {
            value = min(max(range.lowerBound, newValue), range.upperBound)
        }
    }
}



@propertyWrapper
struct Trimed {
    var value: String?
    
    init(wrappedValue value: String?) {
        self.value = ""
        wrappedValue = value
    }
    
    var wrappedValue: String? {
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


