//
//  Bool+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2023/8/11.
//

import Foundation


public extension Bool {
    var opDescription: String {
        self ? "success" : "failure"
    }
    
    /// Return 1 if true, or 0 if false.
    ///
    ///        false.int -> 0
    ///        true.int -> 1
    ///
    var int: Int {
        return self ? 1 : 0
    }

    /// Return "true" if true, or "false" if false.
    ///
    ///        false.string -> "false"
    ///        true.string -> "true"
    ///
    var string: String {
        return self ? "true" : "false"
    }
}
