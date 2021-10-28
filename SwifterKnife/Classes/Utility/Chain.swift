//
//  Chain.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

@dynamicMemberLookup
/// 用于实现链式调用
public struct Chain<Target> {
    public let target: Target
    
    public init(_ target: Target) {
        self.target = target
    }
    
    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<Target, Value>) -> (Value) -> Chain<Target> {
        var target = self.target
        return {
            target[keyPath: keyPath] = $0
            return Chain(target)
        }
    }
}
