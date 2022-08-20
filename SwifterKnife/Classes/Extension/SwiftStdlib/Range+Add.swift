//
//  Range+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2022/8/18.
//

import Foundation

public extension ClosedRange where Bound: BinaryInteger {
    var middle: Bound {
        (upperBound + lowerBound) / Bound(2)
    }
    
    func precent(of value: Bound) -> CGFloat {
        CGFloat(value - lowerBound) / CGFloat(upperBound - lowerBound)
    }
}

public extension ClosedRange where Bound: BinaryFloatingPoint {
   var middle: Bound {
       (upperBound + lowerBound) / Bound(2)
   }
   
   func precent(of value: Bound) -> CGFloat {
       CGFloat(value - lowerBound) / CGFloat(upperBound - lowerBound)
   }
}
