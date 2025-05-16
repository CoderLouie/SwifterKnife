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
//        return Foundation.ceil(self)
        return rounded(.up)
    }
    
    /// Floor of number.
    var floor: Self {
//        return Foundation.floor(self)
        return rounded(.down)
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
    
    static func * <I: BinaryInteger>(lhs: I, rhs: Self) -> Self {
        return Self(lhs) * rhs
    }
    static func * <I: BinaryInteger>(lhs: Self, rhs: I) -> Self {
        return lhs * Self(rhs)
    }
    static func / <I: BinaryInteger>(lhs: Self, rhs: I) -> Self {
        return lhs / Self(rhs)
    }
}

infix operator ~= : ComparisonPrecedence
infix operator !~= : ComparisonPrecedence


extension CFTimeInterval {
    public var coseTime: CFTimeInterval {
        CACurrentMediaTime() - self
    }
    public var coseTimeDesc: String {
        String(format: "%.02f", CACurrentMediaTime() - self)
    }
}


public extension FloatingPoint where Self: CVarArg {
    
    /** Formatted representation
     
     @code
     
     let someDouble = 3.14159265359, someDoubleFormat = ".3"
     print("The floating point number \(someDouble) formatted with \"\(someDoubleFormat)\"
     looks like \(someDouble(someDoubleFormat))")
     // The floating point number 3.14159265359 formatted with ".3" looks like 3.142
     
     @endcode
     */
    func formatted(_ format: String) -> String {
        return String(format: "%\(format)f", self)
    }
    func stringAsFixed(_ fractionDigits: Int = 2) -> String {
        return String(format: "%.\(fractionDigits)f", self)
    }
}


/*
 .toNearestOrAwayFromZero (默认)
 四舍五入（学校常用的舍入方式）
 当小数部分正好为 0.5 时，向远离零的方向舍入
 示例：3.5 → 4.0, -3.5 → -4.0
 
 .toNearestOrEven (银行家舍入法)
 向最近的整数舍入
 当小数部分正好为 0.5 时，向最近的偶数舍入
 示例：3.5 → 4.0, 4.5 → 4.0, -2.5 → -2.0
 
 .up
 向正无穷方向舍入（向上取整）
 示例：3.2 → 4.0, -3.2 → -3.0
 
 .down
 向负无穷方向舍入（向下取整）
 示例：3.8 → 3.0, -3.8 → -4.0
 
 .towardZero
 向零方向舍入（截断小数部分）
 示例：3.8 → 3.0, -3.8 → -3.0
 
 .awayFromZero
 远离零方向舍入
 示例：3.2 → 4.0, -3.2 → -4.0
 */
public extension BinaryFloatingPoint {
    var isInteger: Bool {
        return Darwin.floor(self) == self
    }
    /// Returns a rounded value with the specified number of decimal places and rounding rule. If `numberOfDecimalPlaces` is negative, `0` will be used.
    ///
    ///     let num = 3.1415927
    ///     num.rounded(numberOfDecimalPlaces: 3, rule: .up) -> 3.142
    ///     num.rounded(numberOfDecimalPlaces: 3, rule: .down) -> 3.141
    ///     num.rounded(numberOfDecimalPlaces: 2, rule: .awayFromZero) -> 3.15
    ///     num.rounded(numberOfDecimalPlaces: 4, rule: .towardZero) -> 3.1415
    ///     num.rounded(numberOfDecimalPlaces: -1, rule: .toNearestOrEven) -> 3
    ///
    /// - Parameters:
    ///   - numberOfDecimalPlaces: The expected number of decimal places.
    ///   - rule: The rounding rule to use.
    /// - Returns: The rounded value.
    func rounded(numberOfDecimalPlaces: Int, rule: FloatingPointRoundingRule) -> Self {
        let factor = Self(pow(10.0, Double(max(0, numberOfDecimalPlaces))))
        return (self * factor).rounded(rule) / factor
    }
    func rounded(countBehindDot count: Int) -> Self {
        let factor = Self(pow(10.0, Double(max(0, count))))
        return Darwin.round(self * factor) / factor
    }
    
}

public extension CGFloat {
    static var pixel: CGFloat { return 1.0 / UIScreen.main.scale }

    var sign: CGFloat { return self < 0.0 ? -1.0 : 1.0 }
}


//public protocol ApproximatelyEquatable {
//    func approximatelyEqualTo(_ rhs: Self) -> Bool
//}
