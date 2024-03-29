//
//  CGSize+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//


import CoreGraphics

// MARK: - Methods
public extension CGSize {

    /// Returns the aspect ratio.
    var whRatio: CGFloat {
        return height == 0 ? 0 : width / height
    }
    var hwRatio: CGFloat {
        return width == 0 ? 0 : height / width
    }

    /// Returns width or height, whichever is the bigger value.
    var maxDimension: CGFloat {
        return max(width, height)
    }

    /// Returns width or height, whichever is the smaller value.
    var minDimension: CGFloat {
        return min(width, height)
    }

    var standardized: CGSize {
        return CGSize(width: abs(width), height: abs(height))
    }
}


import UIKit
public extension CGSize {
    @inlinable
    init(dimension: CGFloat) {
        self = CGSize(width: dimension, height: dimension)
    }
    
    var rect: CGRect {
        CGRect(origin: .zero, size: self)
    }
    
    var isEmpty: Bool {
        width == 0 || height == 0
    }
    var isValid: Bool {
        width > 0 && height > 0
    }
    
    func inset(_ inset: UIEdgeInsets) -> CGSize {
        CGSize(width: width + inset.left + inset.right, height: height + inset.top + inset.bottom)
    }
    
    static func limitWidth(_ w: CGFloat) -> CGSize {
        CGSize(width: w, height: CGFloat.greatestFiniteMagnitude)
    }

    static func limitHeight(_ h: CGFloat) -> CGSize {
        CGSize(width: CGFloat.greatestFiniteMagnitude, height: h)
    }
    
    static var unlimit: CGSize {
        CGSize(width: CGFloat.greatestFiniteMagnitude,
               height: CGFloat.greatestFiniteMagnitude)
    }
}

// MARK: - Methods
public extension CGSize {

    /// Aspect fit CGSize.
    ///
    ///     let rect = CGSize(width: 120, height: 80)
    ///     let parentRect  = CGSize(width: 100, height: 50)
    ///     let newRect = rect.aspectFit(to: parentRect)
    ///     // newRect.width = 75 , newRect = 50
    ///
    /// - Parameter boundingSize: bounding size to fit self to.
    /// - Returns: self fitted into given bounding size
    func aspectFit(to boundingSize: CGSize) -> CGSize {
        let minRatio = min(boundingSize.width / width, boundingSize.height / height)
        return CGSize(width: width * minRatio, height: height * minRatio)
    }

    /// Aspect fill CGSize.
    ///
    ///     let rect = CGSize(width: 20, height: 120)
    ///     let parentRect  = CGSize(width: 100, height: 60)
    ///     let newRect = rect.aspectFit(to: parentRect)
    ///     // newRect.width = 100 , newRect = 60
    ///
    /// - Parameter boundingSize: bounding size to fill self to.
    /// - Returns: self filled into given bounding size
    func aspectFill(to boundingSize: CGSize) -> CGSize {
        let minRatio = max(boundingSize.width / width, boundingSize.height / height)
        let aWidth = min(width * minRatio, boundingSize.width)
        let aHeight = min(height * minRatio, boundingSize.height)
        return CGSize(width: aWidth, height: aHeight)
    }

}

// MARK: - Operators
public extension CGSize {

    /// Add two CGSize
    ///
    ///     let sizeA = CGSize(width: 5, height: 10)
    ///     let sizeB = CGSize(width: 3, height: 4)
    ///     let result = sizeA + sizeB
    ///     // result = CGSize(width: 8, height: 14)
    ///
    /// - Parameters:
    ///   - lhs: CGSize to add to.
    ///   - rhs: CGSize to add.
    /// - Returns: The result comes from the addition of the two given CGSize struct.
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    /// Add a CGSize to self.
    ///
    ///     let sizeA = CGSize(width: 5, height: 10)
    ///     let sizeB = CGSize(width: 3, height: 4)
    ///     sizeA += sizeB
    ///     // sizeA = CGPoint(width: 8, height: 14)
    ///
    /// - Parameters:
    ///   - lhs: self
    ///   - rhs: CGSize to add.
    static func += (lhs: inout CGSize, rhs: CGSize) {
        lhs.width += rhs.width
        lhs.height += rhs.height
    }

    /// Subtract two CGSize
    ///
    ///     let sizeA = CGSize(width: 5, height: 10)
    ///     let sizeB = CGSize(width: 3, height: 4)
    ///     let result = sizeA - sizeB
    ///     // result = CGSize(width: 2, height: 6)
    ///
    /// - Parameters:
    ///   - lhs: CGSize to subtract from.
    ///   - rhs: CGSize to subtract.
    /// - Returns: The result comes from the subtract of the two given CGSize struct.
    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    /// Subtract a CGSize from self.
    ///
    ///     let sizeA = CGSize(width: 5, height: 10)
    ///     let sizeB = CGSize(width: 3, height: 4)
    ///     sizeA -= sizeB
    ///     // sizeA = CGPoint(width: 2, height: 6)
    ///
    /// - Parameters:
    ///   - lhs: self
    ///   - rhs: CGSize to subtract.
    static func -= (lhs: inout CGSize, rhs: CGSize) {
        lhs.width -= rhs.width
        lhs.height -= rhs.height
    }

    /// Multiply two CGSize
    ///
    ///     let sizeA = CGSize(width: 5, height: 10)
    ///     let sizeB = CGSize(width: 3, height: 4)
    ///     let result = sizeA * sizeB
    ///     // result = CGSize(width: 15, height: 40)
    ///
    /// - Parameters:
    ///   - lhs: CGSize to multiply.
    ///   - rhs: CGSize to multiply with.
    /// - Returns: The result comes from the multiplication of the two given CGSize structs.
    static func * (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }

    /// Multiply a CGSize with a scalar.
    ///
    ///     let sizeA = CGSize(width: 5, height: 10)
    ///     let result = sizeA * 5
    ///     // result = CGSize(width: 25, height: 50)
    ///
    /// - Parameters:
    ///   - lhs: CGSize to multiply.
    ///   - scalar: scalar value.
    /// - Returns: The result comes from the multiplication of the given CGSize and scalar.
    static func * (lhs: CGSize, scalar: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * scalar, height: lhs.height * scalar)
    }

    /// Multiply a CGSize with a scalar.
    ///
    ///     let sizeA = CGSize(width: 5, height: 10)
    ///     let result = 5 * sizeA
    ///     // result = CGSize(width: 25, height: 50)
    ///
    /// - Parameters:
    ///   - scalar: scalar value.
    ///   - rhs: CGSize to multiply.
    /// - Returns: The result comes from the multiplication of the given scalar and CGSize.
    static func * (scalar: CGFloat, rhs: CGSize) -> CGSize {
        return CGSize(width: scalar * rhs.width, height: scalar * rhs.height)
    }

    /// Multiply self with a CGSize.
    ///
    ///     let sizeA = CGSize(width: 5, height: 10)
    ///     let sizeB = CGSize(width: 3, height: 4)
    ///     sizeA *= sizeB
    ///     // result = CGSize(width: 15, height: 40)
    ///
    /// - Parameters:
    ///   - lhs: self.
    ///   - rhs: CGSize to multiply.
    static func *= (lhs: inout CGSize, rhs: CGSize) {
        lhs.width *= rhs.width
        lhs.height *= rhs.height
    }

    /// Multiply self with a scalar.
    ///
    ///     let sizeA = CGSize(width: 5, height: 10)
    ///     sizeA *= 3
    ///     // result = CGSize(width: 15, height: 30)
    ///
    /// - Parameters:
    ///   - lhs: self.
    ///   - scalar: scalar value.
    static func *= (lhs: inout CGSize, scalar: CGFloat) {
        lhs.width *= scalar
        lhs.height *= scalar
    }

}

