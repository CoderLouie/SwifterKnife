//
//  FloatingPoint+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

// MARK: - Properties

public extension FloatingPoint {

    /// Ceil of number.
    var ceil: Self {
        return Foundation.ceil(self)
    }
    
    /// Floor of number.
    var floor: Self {
        return Foundation.floor(self)
    }
    /// Radian value of degree input.
    var degreesToRadians: Self {
        return Self.pi * self / Self(180)
    }

    /// Degree value of radian input.
    var radiansToDegrees: Self {
        return self * Self(180) / Self.pi
    }
}


public extension FloatingPoint {
    /// 浮点数比较是否相等
    static func ~=(lhs: Self, rhs: Self) -> Bool {
        return lhs == rhs || lhs.nextDown == rhs || lhs.nextUp == rhs
    }
    
    /// 浮点数比较是否不相等
    static func !~=(lhs: Self, rhs: Self) -> Bool {
        return !(lhs ~= rhs)
    }
}

infix operator ~= : ComparisonPrecedence
infix operator !~= : ComparisonPrecedence
