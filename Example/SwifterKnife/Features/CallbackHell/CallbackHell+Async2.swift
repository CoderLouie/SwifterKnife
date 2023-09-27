//
//  CallbackHell+Async2.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/3/3.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

public final class Async2<Value> {
    private enum State {
        case pending
        case fulfilled(Value)
        case rejected(Swift.Error)
    }
    public typealias Result = Swift.Result<Value, Swift.Error>
    
    private var state: State = .pending
    private var completion: ((Result) -> Void)?
    
    init(on queue: DispatchQueue = .global(qos: .userInitiated), _ trunk: @escaping (_ successed: @escaping (Value) -> Void, _ failed: @escaping (Error) -> Void) throws -> Void) {
        queue.async {
            do {
                try trunk(self.successed, self.failed)
            } catch {
                self.failed(error)
            }
        }
    }
    func then(on queue: DispatchQueue = .main,
              success: @escaping (Value) -> Void,
              fail: ((Swift.Error) -> Void)? = nil,
              before: ((Result) -> Void)? = nil,
              after: ((Result) -> Void)? = nil) {
        switch state {
        case .pending:
            completion = { result in
                queue.async {
                    switch result {
                    case .success(let value):
                        before?(result)
                        success(value)
                        after?(result)
                    case .failure(let error):
                        before?(result)
                        fail?(error)
                        after?(result)
                    }
                }
            }
        case .fulfilled(let value):
            queue.async {
                before?(.success(value))
                success(value)
                after?(.success(value))
            }
        case .rejected(let error):
            queue.async {
                before?(.failure(error))
                fail?(error)
                after?(.failure(error))
            }
        }
    }
    
    
    func successed(_ value: Value) {
        completion?(.success(value))
    }
    func failed(_ error: Swift.Error) {
        completion?(.failure(error))
    }
}
 

func async2_test() {
}
