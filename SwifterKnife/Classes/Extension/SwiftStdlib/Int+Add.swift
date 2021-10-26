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
    
    /// Double.
    var double: Double {
        return Double(self)
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


// MARK: - Methods

public extension Int {
    /// Rounds to the closest multiple of n.
    func roundToNearest(_ number: Int) -> Int {
        return number == 0 ? self : Int(round(Double(self) / Double(number))) * number
    }
}
