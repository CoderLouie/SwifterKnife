// The MIT License (MIT)
//
// Copyright (c) 2015 Suyeol Jeon (xoul.kr)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
#if !os(Linux)
import CoreGraphics
#endif 

public protocol Then {}

extension Then where Self: Any {
    
    /// Makes it available to set properties with closures just after initializing and copying the value types.
    ///
    ///     let frame = CGRect().with {
    ///       $0.origin.x = 10
    ///       $0.size.width = 100
    ///     }
    @inlinable
    public func with(_ block: (inout Self) throws -> Void) rethrows -> Self {
        var copy = self
        try block(&copy)
        return copy
    }
    
    /// Makes it available to execute something with closures.
    ///
    ///     UserDefaults.standard.do {
    ///       $0.set("devxoul", forKey: "username")
    ///       $0.set("devxoul@gmail.com", forKey: "email")
    ///       $0.synchronize()
    ///     }
    @inlinable
    public func `do`(_ block: (Self) throws -> Void) rethrows {
        try block(self)
    }
}


extension Then where Self: AnyObject {
    
    /// Makes it available to set properties with closures just after initializing.
    ///
    ///     let label = UILabel().then {
    ///       $0.textAlignment = .center
    ///       $0.textColor = UIColor.black
    ///       $0.text = "Hello, World!"
    ///     }
    @inlinable
    public func then(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }
    
}

extension NSObject: Then {}

#if !os(Linux)
extension CGPoint: Then {}
extension CGRect: Then {}
extension CGSize: Then {}
#endif

extension Array: Then {}
extension Dictionary: Then {}
extension Set: Then {}

#if os(iOS) || os(tvOS)
extension UIEdgeInsets: Then {}
extension UIRectEdge: Then {}
#endif



@dynamicMemberLookup
/// 用于实现链式调用
public struct Chain<Object: AnyObject> {
    public let object: Object
    
    public init(_ object: Object) {
        self.object = object
    }
    
    public subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<Object, Value>) -> (Value) -> Chain<Object> {
        return {
            self.object[keyPath: keyPath] = $0
            return self
        }
    }
    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<Object, Value>) -> (Value) -> Chain<Object> {
        var object = self.object
        return {
            object[keyPath: keyPath] = $0
            return Chain(object)
        }
    }
    
    @inlinable
    public func then(_ block: (Object) throws -> Void) rethrows -> Object {
        try block(object)
        return object
    }
    
    @inlinable
    public func `do`(_ block: (Object) throws -> Void) rethrows {
        try block(object)
    }
}

extension Then where Self: AnyObject {
    public var chain: Chain<Self> {
        .init(self)
    }
}
