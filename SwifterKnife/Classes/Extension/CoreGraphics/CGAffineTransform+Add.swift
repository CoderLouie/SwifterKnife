//
//  CGAffineTransform+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import CoreGraphics
import QuartzCore

// MARK: - Methods
public extension CGAffineTransform {

    /// Returns a transform with the same effect as the receiver.
    @inlinable
    func transform3D() -> CATransform3D { CATransform3DMakeAffineTransform(self) }

}
