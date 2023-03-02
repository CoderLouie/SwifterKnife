//
//  CallbackHell.swift
//  BatterySwap
//
//  Created by 李阳 on 2023/3/2.
//

import Foundation

public struct AnyError: Swift.Error {
    let error: Swift.Error
    init(_ error: Swift.Error) {
        self.error = AnyError.rawError(of: error)
    }
    
    private static func rawError(of error: Swift.Error) -> Swift.Error {
        if let anyError = error as? AnyError {
            return rawError(of: anyError.error)
        }
        return error
    }
}

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
