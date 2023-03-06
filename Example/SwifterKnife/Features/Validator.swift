//
//  Validator.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/3/3.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

/*
 [在 Swift 中使用 errors 作为控制流](https://juejin.cn/post/6844903800017256462)
 */
struct Validator<Value> {
    let closure: (Value) throws -> Void
}

struct MessageError: Swift.Error, LocalizedError {
    let message: String
    
    var errorDescription: String? { message }
}

func validate(_ condition: Bool, errorDesc message: @autoclosure () -> String) throws {
    guard condition else {
        throw MessageError(message: message())
    }
}
func validate<T>(_ value: T, using validator: Validator<T>) throws {
    try validator.closure(value)
}

extension Validator where Value == String {
    static var password: Validator {
        .init { pwd in
            try validate(
                pwd.count >= 7,
                errorDesc: "Password must contain min 7 characters"
            )
            
            try validate(
                pwd.lowercased() != pwd,
                errorDesc: "Password must contain an uppercased character"
            )
            
            try validate(
                pwd.uppercased() != pwd,
                errorDesc: "Password must contain a lowercased character"
            )
        }
    }
}


func onLogin() {
    let password = "some text"
    do {
        try validate(password, using: .password)
    } catch {
        print(error.localizedDescription)
    }
}
