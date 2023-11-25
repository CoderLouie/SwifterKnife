//
//  Int+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation
import CoreGraphics

public extension Int {
    /// Radian value of degree input.
    var degreesToRadians: Double {
        return Double.pi * Double(self) / 180.0
    }

    /// Degree value of radian input.
    var radiansToDegrees: Double {
        return Double(self) * 180 / Double.pi
    } 
}


// MARK: - Methods

public extension Int {
    /// Rounds to the closest multiple of n.
    func roundToNearest(_ number: Int) -> Int {
        return number == 0 ? self : Int(round(Double(self) / Double(number))) * number
    }
}

public extension Int {
    /// Caclulate the nearest below value for this number in comparison with a specified value.
    /// - Parameter value: The value that will be used to search the nearest up.
    /// - Returns: The nearest value to the speficied value.
    func nearest(to value: Int) -> Int {
        self / value * value + (self % value) / (value / 2) * value
    }
    
    /// Caclulate the nearest below value for this number in comparison with a specified value.
    /// - Parameter value: The value that will be used to search the nearest up.
    /// - Returns: The nearest below value to the speficied value.
    func nearestBelow(to value: Int) -> Int {
        self / value * value + 0 / (value / 2) * value
    }
    
    /// Caclulate the nearest up value for this number in comparison with a specified value.
    /// - Parameter value: The value that will be used to search the nearest up.
    /// - Returns: The nearest up value to the speficied value.
    func nearestUp(to value: Int) -> Int {
        self / value * value + (value / 2) / (value / 2) * value
    }
}


infix operator &~ : AdditionPrecedence
infix operator &? : AdditionPrecedence
public extension OptionSet where RawValue: FixedWidthInteger {
    static func & (
        lhs: Self,
        rhs: Self
    ) -> Self {
        .init(rawValue: lhs.rawValue & rhs.rawValue)
    }
    
    static func | (
        lhs: Self,
        rhs: Self
    ) -> Self {
        .init(rawValue: lhs.rawValue | rhs.rawValue)
    }
    
    static prefix func ~ (
        lhs: Self
    ) -> Self {
        .init(rawValue: ~lhs.rawValue)
    }
    
    static func &~ (
        lhs: Self,
        rhs: Self
    ) -> Self {
        .init(rawValue: lhs.rawValue & ~rhs.rawValue)
    }
    
    static func &? (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.rawValue & rhs.rawValue != 0
    }
}
