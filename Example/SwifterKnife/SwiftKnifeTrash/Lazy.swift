//
//  Lazy.swift
//  SwifterKnife
//
//  Created by liyang on 2021/12/8.
//

import Foundation
 

public final class Lazy<T> {
    private var builder: (() -> T)!
    
    public init(_ builder: @escaping () -> T) {
        self.builder = builder
    } 
    public private(set) var wrapped: T?
    
    public var wrappedValue: T {
        if let v = wrapped { return v }
        let v = builder()
        builder = nil
        wrapped = v
        return v
    }
    public var hasBuilt: Bool {
        return wrapped != nil
    }
}


