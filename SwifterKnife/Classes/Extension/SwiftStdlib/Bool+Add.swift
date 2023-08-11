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
}
