//
//  Lazy.swift
//  SwifterKnife
//
//  Created by 李阳 on 2021/12/8.
//

import Foundation
 

public final class Lazy<T> {
    private var builder: (() -> T)!
    
    public init(_ builder: @escaping () -> T) {
        self.builder = builder
    } 
    public private(set) var rawValue: T?
    
    public var wrapped: T {
        if let v = rawValue { return v }
        let v = builder()
        builder = nil
        rawValue = v
        return v
    }
    public var isInitialized: Bool {
        return rawValue != nil
    }
}


