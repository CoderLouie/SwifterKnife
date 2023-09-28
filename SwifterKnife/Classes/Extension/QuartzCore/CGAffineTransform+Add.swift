//
//  CGAffineTransform+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import CoreGraphics

// MARK: - Properties
public extension CGAffineTransform {
    var radians: CGFloat {
        atan2(b, a)
    }
    
    var translation: CGPoint {
        return CGPoint(x: tx, y: ty)
    }
    
    var scale: CGPoint {
        return CGPoint(x: a, y: d)
    }
}

// MARK: - Methods
public extension CGAffineTransform {
    
    /// Returns a transform with the same effect as the receiver.
    @inlinable
    func transform3D() -> CATransform3D {
        CATransform3DMakeAffineTransform(self)
    }
    
    static func += (left: inout CGAffineTransform, right: CGAffineTransform) {
        left = left.concatenating(right)
    }
}

public func + (left: CGAffineTransform, right: CGAffineTransform) -> CGAffineTransform {
    return left.concatenating(right)
}

public prefix func ! (transform: CGAffineTransform) -> CGAffineTransform {
    return transform.inverted()
}
