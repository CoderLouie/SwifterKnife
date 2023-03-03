//
//  Func.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/3/3.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

// MARK: - Transform an asynchronous function into a synchronous one
// 将异步函数转换为同步函数
public func makeSynchrone<A, B>(_ asyncFunction: @escaping (A, (B) -> Void) -> Void) -> (A) -> B {
    return { arg in
        let lock = NSRecursiveLock()
        
        var result: B? = nil
        
        asyncFunction(arg) {
            result = $0
            lock.unlock()
        }
        
        lock.lock()
        
        return result!
    }
}
/*
func myAsyncFunction(arg: Int, completionHandler: (String) -> Void) {
    completionHandler("🎉 \(arg)")
}
let syncFunction = makeSynchrone(myAsyncFunction)
print(syncFunction(42)) // prints 🎉 42
*/
