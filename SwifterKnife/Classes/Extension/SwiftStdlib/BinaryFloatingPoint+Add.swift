//
//  BinaryFloatingPoint+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation
import CoreGraphics

// MARK: - Methods

public extension BinaryFloatingPoint { 
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
    
    /// Int.
    var int: Int {
        return Int(self)
    }
    
    /// Float.
    var float: Float {
        return Float(self)
    }
 
    /// CGFloat.
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
}
