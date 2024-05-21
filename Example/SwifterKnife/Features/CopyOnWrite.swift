//
//  CopyOnWrite.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/4/28.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation


// https://github.com/klundberg/CopyOnWrite

//private final class Box<Boxed> {
//    let unbox: Boxed
//    init(_ value: Boxed) {
//        unbox = value
//    }
//}

import Foundation
/// Describes reference types that can be copied
public protocol Cloneable: AnyObject {

    /// Makes a copy of `self` and returns it
    ///
    /// - Returns: A new instance of `self` with all relevant data copied from it.
    func clone() -> Self
}
extension Cloneable where Self: NSCopying {
    func clone() -> Self {
        copy() as! Self
    }
}
extension Cloneable where Self: NSMutableCopying {
    func clone() -> Self {
        mutableCopy() as! Self
    }
}


