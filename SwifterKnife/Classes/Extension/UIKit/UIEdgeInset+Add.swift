//
//  UIEdgeInset+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit

/// EdgeInsets
public typealias SFEdgeInsets = UIEdgeInsets

// MARK: - Properties

public extension SFEdgeInsets {
    /// Return the vertical insets. The vertical insets is composed by top + bottom.
    ///
    var vertical: CGFloat {
        // Source: https://github.com/MessageKit/MessageKit/blob/master/Sources/SwifterSwift/EdgeInsets%2BExtensions.swift
        return top + bottom
    }

    /// Return the horizontal insets. The horizontal insets is composed by  left + right.
    ///
    var horizontal: CGFloat {
        // Source: https://github.com/MessageKit/MessageKit/blob/master/Sources/SwifterSwift/EdgeInsets%2BExtensions.swift
        return left + right
    }
}

// MARK: - Methods

public extension SFEdgeInsets {
    static func inset(_ side: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: side, left: side, bottom: side, right: side)
    }
    init(top: CGFloat = 0,
         bottom: CGFloat = 0,
         left: CGFloat = 0,
         right: CGFloat = 0) {
        self.init(top: top, left: left, bottom: bottom, right: right)
    }
    /// Creates an `EdgeInsets` with the inset value applied to all (top, bottom, right, left).
    ///
    /// - Parameter inset: Inset to be applied in all the edges.
    init(inset: CGFloat) {
        self.init(top: inset, left: inset, bottom: inset, right: inset)
    }

    /// Creates an `EdgeInsets` with the horizontal value equally divided and applied to right and left.
    ///               And the vertical value equally divided and applied to top and bottom.
    ///
    ///
    /// - Parameter horizontal: Inset to be applied to right and left.
    /// - Parameter vertical: Inset to be applied to top and bottom.
    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical / 2, left: horizontal / 2, bottom: vertical / 2, right: horizontal / 2)
    }

    /// Creates an `EdgeInsets` based on current value and top offset.
    ///
    /// - Parameters:
    ///   - top: Offset to be applied in to the top edge.
    /// - Returns: EdgeInsets offset with given offset.
    func insetBy(top: CGFloat) -> SFEdgeInsets {
        return SFEdgeInsets(top: self.top + top, left: left, bottom: bottom, right: right)
    }

    /// Creates an `EdgeInsets` based on current value and left offset.
    ///
    /// - Parameters:
    ///   - left: Offset to be applied in to the left edge.
    /// - Returns: EdgeInsets offset with given offset.
    func insetBy(left: CGFloat) -> SFEdgeInsets {
        return SFEdgeInsets(top: top, left: self.left + left, bottom: bottom, right: right)
    }

    /// Creates an `EdgeInsets` based on current value and bottom offset.
    ///
    /// - Parameters:
    ///   - bottom: Offset to be applied in to the bottom edge.
    /// - Returns: EdgeInsets offset with given offset.
    func insetBy(bottom: CGFloat) -> SFEdgeInsets {
        return SFEdgeInsets(top: top, left: left, bottom: self.bottom + bottom, right: right)
    }

    /// Creates an `EdgeInsets` based on current value and right offset.
    ///
    /// - Parameters:
    ///   - right: Offset to be applied in to the right edge.
    /// - Returns: EdgeInsets offset with given offset.
    func insetBy(right: CGFloat) -> SFEdgeInsets {
        return SFEdgeInsets(top: top, left: left, bottom: bottom, right: self.right + right)
    }

    /// Creates an `EdgeInsets` based on current value and horizontal value equally divided and applied to right offset and left offset.
    ///
    /// - Parameters:
    ///   - horizontal: Offset to be applied to right and left.
    /// - Returns: EdgeInsets offset with given offset.
    func insetBy(horizontal: CGFloat) -> SFEdgeInsets {
        return SFEdgeInsets(top: top, left: left + horizontal / 2, bottom: bottom, right: right + horizontal / 2)
    }

    /// Creates an `EdgeInsets` based on current value and vertical value equally divided and applied to top and bottom.
    ///
    /// - Parameters:
    ///   - vertical: Offset to be applied to top and bottom.
    /// - Returns: EdgeInsets offset with given offset.
    func insetBy(vertical: CGFloat) -> SFEdgeInsets {
        return SFEdgeInsets(top: top + vertical / 2, left: left, bottom: bottom + vertical / 2, right: right)
    }
}

// MARK: - Operators

public extension SFEdgeInsets {
    /// Add all the properties of two `EdgeInsets` to create their addition.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand expression
    ///   - rhs: The right-hand expression
    /// - Returns: A new `EdgeInsets` instance where the values of `lhs` and `rhs` are added together.
    static func + (_ lhs: SFEdgeInsets, _ rhs: SFEdgeInsets) -> SFEdgeInsets {
        return SFEdgeInsets(top: lhs.top + rhs.top,
                          left: lhs.left + rhs.left,
                          bottom: lhs.bottom + rhs.bottom,
                          right: lhs.right + rhs.right)
    }

    /// Add all the properties of two `EdgeInsets` to the left-hand instance.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand expression to be mutated
    ///   - rhs: The right-hand expression
    static func += (_ lhs: inout SFEdgeInsets, _ rhs: SFEdgeInsets) {
        lhs.top += rhs.top
        lhs.left += rhs.left
        lhs.bottom += rhs.bottom
        lhs.right += rhs.right
    }
}
