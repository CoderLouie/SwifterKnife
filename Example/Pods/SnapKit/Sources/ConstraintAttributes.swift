//
//  SnapKit
//
//  Copyright (c) 2011-Present SnapKit Team - https://github.com/SnapKit
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#if os(iOS) || os(tvOS)
import UIKit
#else
import AppKit
#endif


internal struct ConstraintAttributes: OptionSet, RawRepresentable {
    
    typealias RawValue = UInt
    
    internal init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    internal init(_ rawValue: RawValue) {
        self.init(rawValue: rawValue)
    }
    
    internal private(set) var rawValue: RawValue
    
    internal var boolValue: Bool { return self.rawValue != 0 }
}

extension ConstraintAttributes: ExpressibleByNilLiteral {
    internal init(nilLiteral: ()) {
        self.rawValue = 0
    }
}

extension ConstraintAttributes: ExpressibleByIntegerLiteral {
    internal init(integerLiteral rawValue: RawValue) {
        self.init(rawValue: rawValue)
    }
}

extension ConstraintAttributes {
    // normal
    internal static let none: ConstraintAttributes = 0
    internal static let left: ConstraintAttributes = ConstraintAttributes(RawValue(1) << 0)
    internal static let top: ConstraintAttributes = ConstraintAttributes(RawValue(1) << 1)
    internal static let right: ConstraintAttributes = ConstraintAttributes(RawValue(1) << 2)
    internal static let bottom: ConstraintAttributes = ConstraintAttributes(RawValue(1) << 3)
    internal static let leading: ConstraintAttributes = ConstraintAttributes(RawValue(1) << 4)
    internal static let trailing: ConstraintAttributes = ConstraintAttributes(RawValue(1) << 5)
    internal static let width: ConstraintAttributes = ConstraintAttributes(RawValue(1) << 6)
    internal static let height: ConstraintAttributes = ConstraintAttributes(RawValue(1) << 7)
    internal static let centerX: ConstraintAttributes = ConstraintAttributes(RawValue(1) << 8)
    internal static let centerY: ConstraintAttributes = ConstraintAttributes(RawValue(1) << 9)
    internal static let lastBaseline: ConstraintAttributes = ConstraintAttributes(RawValue(1) << 10)
    
    @available(iOS 8.0, OSX 10.11, *)
    internal static let firstBaseline: ConstraintAttributes = ConstraintAttributes(RawValue(1) << 11)
    
    @available(iOS 8.0, *)
    internal static let leftMargin: ConstraintAttributes = ConstraintAttributes(RawValue(1) << 12)
    
    @available(iOS 8.0, *)
    internal static let rightMargin: ConstraintAttributes = ConstraintAttributes(RawValue(1) << 13)
    
    @available(iOS 8.0, *)
    internal static let topMargin: ConstraintAttributes = ConstraintAttributes(RawValue(1) << 14)
    
    @available(iOS 8.0, *)
    internal static let bottomMargin: ConstraintAttributes = ConstraintAttributes(RawValue(1) << 15)
    
    @available(iOS 8.0, *)
    internal static let leadingMargin: ConstraintAttributes = ConstraintAttributes(RawValue(1) << 16)
    
    @available(iOS 8.0, *)
    internal static let trailingMargin: ConstraintAttributes = ConstraintAttributes(RawValue(1) << 17)
    
    @available(iOS 8.0, *)
    internal static let centerXWithinMargins: ConstraintAttributes = ConstraintAttributes(RawValue(1) << 18)
    
    @available(iOS 8.0, *)
    internal static let centerYWithinMargins: ConstraintAttributes = ConstraintAttributes(RawValue(1) << 19)
    
    // aggregates
    
    internal static let edges: ConstraintAttributes = [.horizontalEdges, .verticalEdges]
    internal static let horizontalEdges: ConstraintAttributes = [.left, .right]
    internal static let verticalEdges: ConstraintAttributes = [.top, .bottom]
    internal static let directionalEdges: ConstraintAttributes = [.directionalHorizontalEdges, .directionalVerticalEdges]
    internal static let directionalHorizontalEdges: ConstraintAttributes = [.leading, .trailing]
    internal static let directionalVerticalEdges: ConstraintAttributes = [.top, .bottom]
    internal static let size: ConstraintAttributes = [.width, .height]
    internal static let center: ConstraintAttributes = [.centerX, .centerY]
    
    @available(iOS 8.0, *)
    internal static let margins: ConstraintAttributes = [.leftMargin, .topMargin, .rightMargin, .bottomMargin]
    
    @available(iOS 8.0, *)
    internal static let directionalMargins: ConstraintAttributes = [.leadingMargin, .topMargin, .trailingMargin, .bottomMargin]
    
    @available(iOS 8.0, *)
    internal static let centerWithinMargins: ConstraintAttributes = [.centerXWithinMargins, .centerYWithinMargins]
    
    internal var layoutAttributes: [LayoutAttribute] {
        var attrs = [LayoutAttribute]()
        if (self.contains(.left)) {
            attrs.append(.left)
        }
        if (self.contains(.top)) {
            attrs.append(.top)
        }
        if (self.contains(.right)) {
            attrs.append(.right)
        }
        if (self.contains(.bottom)) {
            attrs.append(.bottom)
        }
        if (self.contains(.leading)) {
            attrs.append(.leading)
        }
        if (self.contains(.trailing)) {
            attrs.append(.trailing)
        }
        if (self.contains(.width)) {
            attrs.append(.width)
        }
        if (self.contains(.height)) {
            attrs.append(.height)
        }
        if (self.contains(.centerX)) {
            attrs.append(.centerX)
        }
        if (self.contains(.centerY)) {
            attrs.append(.centerY)
        }
        if (self.contains(.lastBaseline)) {
            attrs.append(.lastBaseline)
        }
        
#if os(iOS) || os(tvOS)
        if (self.contains(.firstBaseline)) {
            attrs.append(.firstBaseline)
        }
        if (self.contains(.leftMargin)) {
            attrs.append(.leftMargin)
        }
        if (self.contains(.rightMargin)) {
            attrs.append(.rightMargin)
        }
        if (self.contains(.topMargin)) {
            attrs.append(.topMargin)
        }
        if (self.contains(.bottomMargin)) {
            attrs.append(.bottomMargin)
        }
        if (self.contains(.leadingMargin)) {
            attrs.append(.leadingMargin)
        }
        if (self.contains(.trailingMargin)) {
            attrs.append(.trailingMargin)
        }
        if (self.contains(.centerXWithinMargins)) {
            attrs.append(.centerXWithinMargins)
        }
        if (self.contains(.centerYWithinMargins)) {
            attrs.append(.centerYWithinMargins)
        }
#endif
        
        return attrs
    }
}

internal func + (left: ConstraintAttributes, right: ConstraintAttributes) -> ConstraintAttributes {
    return left.union(right)
}

internal func +=(left: inout ConstraintAttributes, right: ConstraintAttributes) {
    left.formUnion(right)
}

internal func -=(left: inout ConstraintAttributes, right: ConstraintAttributes) {
    left.subtract(right)
}

internal func ==(left: ConstraintAttributes, right: ConstraintAttributes) -> Bool {
    return left.rawValue == right.rawValue
}
