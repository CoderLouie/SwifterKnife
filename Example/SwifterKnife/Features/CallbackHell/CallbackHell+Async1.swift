//
//  CallbackHell+Async1.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/3/3.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation 

public typealias GeneralAsync<V> = Async<V, AnyError>

public struct Async<Value, Error: Swift.Error> {
    public typealias Result = Swift.Result<Value, Error>
    public typealias ResultCompletion = (Result) -> Void
    public typealias Trunk = (@escaping ResultCompletion) -> Void
    
    let trunk: Trunk
    init(_ trunk: @escaping Trunk) {
        self.trunk = trunk
    }
    
    func execute(completion: @escaping ResultCompletion) {
        trunk(completion)
    }
    
    func map<U>(_ transform: @escaping (Value) throws -> U) -> GeneralAsync<U> {
        .init { completion in
            execute { result in
                switch result {
                case .success(let v):
                    do {
                        completion(.success(try transform(v)))
                    } catch {
                        completion(.failure(AnyError(error)))
                    }
                case .failure(let error):
                    completion(.failure(AnyError(error)))
                }
            }
        }
    }
    
    func flatMap<U, E: Swift.Error>(_ transform: @escaping (Value) throws -> Async<U, E>) -> GeneralAsync<U> {
        .init { completion in
            execute { result in
                switch result {
                case .success(let v):
                    do {
                        try transform(v).execute {
                            completion($0.mapError(AnyError.init(_:)))
                        }
                    } catch {
                        completion(.failure(AnyError(error)))
                    }
                case .failure(let error):
                    completion(.failure(AnyError(error)))
                }
            }
        }
    }
    func flatMap<U, E: Swift.Error>(_ transform: @escaping (Value, @escaping Async<U, E>.ResultCompletion) -> Void) -> GeneralAsync<U> {
        .init { completion in
            execute { result in
                switch result {
                case .success(let v):
                    transform(v) {
                        completion($0.mapError(AnyError.init(_:)))
                    }
                case .failure(let error):
                    completion(.failure(AnyError(error)))
                }
            }
        }
    }
    
    func validate(_ work: @escaping (Value, @escaping (Swift.Error?) -> Void) -> Void) -> GeneralAsync<Value> {
        .init { completion in
            execute { result in
                switch result {
                case .success(let v):
                    work(v) { error in
                        if let error = error {
                            completion(.failure(AnyError(error)))
                        } else {
                            completion(.success(v))
                        }
                    }
                case .failure(let error):
                    completion(.failure(AnyError(error)))
                }
            }
        }
    }
}

extension Async {
    static func success(_ value: Value) -> Async {
        Async { $0(.success(value)) }
    }
    static func failed(_ error: Error) -> Async {
        Async { $0(.failure(error)) }
    }
}

extension Async where Error == AnyError {
    static func failed(_ error: Swift.Error) -> Async {
        Async { $0(.failure(AnyError(error))) }
    }
}

fileprivate func service1(_ completion: @escaping Async<Int, AppError>.ResultCompletion) {
    DispatchQueue.main.after(1) {
        completion(.success(52))
    }
}
fileprivate func isValidate(arg: Int, _ completion: @escaping (AppError?) -> Void) {
    if arg > 50 {
        completion(.big)
    } else if arg < 20 {
        completion(.small)
    } else {
        completion(nil)
    }
}

fileprivate func service2(arg: String, _ completion: @escaping Async<String, AppError>.ResultCompletion) {
    DispatchQueue.main.after(2) {
        completion(.success("🎉 \(arg)"))
    }
}
fileprivate func service3(arg: String) -> Async<String, AppError> {
    .init { completion in
        DispatchQueue.main.after(2) {
            completion(.success("🎉 \(arg)"))
        }
    }
}

func async1_test() {
    Async(service1)
        .validate(isValidate)
        .map { String($0 / 2) }
        .flatMap(service2)
//        .flatMap(service3(arg:))
        .execute { result in
            print(result)
        }
}
