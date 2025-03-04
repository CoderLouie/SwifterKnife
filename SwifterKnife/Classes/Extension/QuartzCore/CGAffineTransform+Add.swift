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
    
//    var scale: CGPoint {
//        return CGPoint(x: a, y: d)
//    }
    
    var scaleX: CGFloat {
        sqrt(a * a + c * c)
    }
    var scaleY: CGFloat {
        sqrt(b * b + d * d)
    }
    
    static func from(_ fromRect: CGRect, to toRect: CGRect) -> CGAffineTransform {
//        let moveTrans = CGAffineTransform(translationX: toRect.midX - fromRect.midX, y: toRect.midY - fromRect.midY)
//        let scaleTrans = CGAffineTransform(scaleX: toRect.width / fromRect.width, y: toRect.height / fromRect.height)
//        return moveTrans.concatenating(scaleTrans)
        return .init(toRect.width / fromRect.width, 0, 0, toRect.height / fromRect.height, toRect.midX - fromRect.midX, toRect.midY - fromRect.midY)
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
