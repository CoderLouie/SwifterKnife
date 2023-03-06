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

import Foundation

#if os(iOS) || os(tvOS)
import UIKit
#if swift(>=4.2)
typealias LayoutRelation = NSLayoutConstraint.Relation
typealias LayoutAttribute = NSLayoutConstraint.Attribute
#else
typealias LayoutRelation = NSLayoutRelation
typealias LayoutAttribute = NSLayoutAttribute
#endif
typealias LayoutPriority = UILayoutPriority

public typealias ConstraintInsets = UIEdgeInsets

@available(iOS 11.0, tvOS 11.0, *)
public typealias ConstraintDirectionalInsets = NSDirectionalEdgeInsets

public typealias ConstraintView = UIView

@available(iOS 9.0, *)
public typealias ConstraintLayoutGuide = UILayoutGuide

@available(iOS 8.0, *)
public typealias ConstraintLayoutSupport = UILayoutSupport
#else
import AppKit
typealias LayoutRelation = NSLayoutConstraint.Relation
typealias LayoutAttribute = NSLayoutConstraint.Attribute
typealias LayoutPriority = NSLayoutConstraint.Priority

public typealias ConstraintInsets = NSEdgeInsets

public typealias ConstraintView = NSView

@available(OSX 10.11, *)
public typealias ConstraintLayoutGuide = NSLayoutGuide

public final class ConstraintLayoutSupport {}
#endif

