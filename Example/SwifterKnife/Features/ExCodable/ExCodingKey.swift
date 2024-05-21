//
//  ExCodingKey.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/10/16.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

public struct ExCodingKey: CodingKey {
    public let stringValue: String
    public let intValue: Int?
    
    public init(_ stringValue: String) {
        (self.stringValue, self.intValue) = (stringValue, nil)
    }
    public init(_ stringValue: Substring) {
        self.init(String(stringValue))
    }
    public init?(stringValue: String) {
        self.init(stringValue)
    }
    public init(_ intValue: Int) {
        (self.intValue, self.stringValue) = (intValue, String(intValue))
    }
    public init?(intValue: Int) {
        self.init(intValue)
    }
    public init(index: Int) {
        self.init(index)
    }
    static let `super` = ExCodingKey("super")
}
extension ExCodingKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}
extension ExCodingKey: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}
