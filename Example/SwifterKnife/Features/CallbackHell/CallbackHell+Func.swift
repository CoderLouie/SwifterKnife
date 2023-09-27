//
//  CallbackHell+Func.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/3/3.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

public typealias ResultCompletion<Success, Failure: Swift.Error> = (Result<Success, Failure>) -> Void
public typealias GeneralResultCompletion<Success> = ResultCompletion<Success, AnyError>

// MARK: - Solving callback hell with function composition
// 用函数组合解决回调地狱
infix operator >>>: MultiplicationPrecedence
infix operator >>?: MultiplicationPrecedence

// MARK: Contains Param
public func >>> <P, T, U, E1: Swift.Error, E2: Swift.Error>(
    _ first: @escaping (P, @escaping ResultCompletion<T, E1>) -> Void,
    _ second: @escaping (P, T, @escaping ResultCompletion<U, E2>) -> Void) -> (P, @escaping GeneralResultCompletion<U>) -> Void {
    return { p, completion in
        first(p) { firstResult  in
            switch firstResult {
            case .success(let value):
                second(p, value) { secondResult in
                    completion(secondResult.mapError(AnyError.init(_:)))
                }
            case .failure(let error):
                completion(.failure(AnyError(error)))
            }
        }
    }
}
public func >>? <P, T, E1: Swift.Error>(
    _ first: @escaping (P, @escaping ResultCompletion<T, E1>) -> Void,
    _ second: @escaping (P, T, @escaping (Swift.Error?) -> Void) -> Void) -> (P, @escaping GeneralResultCompletion<T>) -> Void {
    return { p, completion in
        first(p) { firstResult  in
            switch firstResult {
            case .success(let value):
                second(p, value) { error in
                    if let error = error {
                        completion(.failure(AnyError(error)))
                    } else {
                        completion(.success(value))
                    }
                }
            case .failure(let error):
                completion(.failure(AnyError(error)))
            }
        }
    }
}

public func >>> <P, T, U, E: Swift.Error>(
    _ first: @escaping (P, @escaping ResultCompletion<T, E>) -> Void,
    _ transform: @escaping (P, T) throws -> U) -> (P, @escaping GeneralResultCompletion<U>) -> Void {
    return { p, completion in
        first(p) { result in
            switch result {
            case .failure(let error):
                completion(.failure(AnyError(error)))
            case .success(let value):
                do {
                    completion(.success(try transform(p, value)))
                } catch {
                    completion(.failure(AnyError(error)))
                }
            }
        }
    }
}


// MARK: NO Param
public func >>> <T, U, E1: Swift.Error, E2: Swift.Error>(
    _ first: @escaping (@escaping ResultCompletion<T, E1>) -> Void,
    _ second: @escaping (T, @escaping ResultCompletion<U, E2>) -> Void) -> (@escaping GeneralResultCompletion<U>) -> Void {
    return { completion in
        first { firstResult  in
            switch firstResult {
            case .success(let value):
                second(value) { secondResult in
                    completion(secondResult.mapError(AnyError.init(_:)))
                }
            case .failure(let error):
                completion(.failure(AnyError(error)))
            }
        }
    }
}
public func >>? <T, E1: Swift.Error>(
    _ first: @escaping (@escaping ResultCompletion<T, E1>) -> Void,
    _ second: @escaping (T, @escaping (Swift.Error?) -> Void) -> Void) -> (@escaping GeneralResultCompletion<T>) -> Void {
    return { completion in
        first { firstResult  in
            switch firstResult {
            case .success(let value):
                second(value) { error in
                    if let error = error {
                        completion(.failure(AnyError(error)))
                    } else {
                        completion(.success(value))
                    }
                }
            case .failure(let error):
                completion(.failure(AnyError(error)))
            }
        }
    }
}

public func >>> <T, U, E: Swift.Error>(
    _ first: @escaping (@escaping ResultCompletion<T, E>) -> Void,
    _ transform: @escaping (T) throws -> U) -> (@escaping GeneralResultCompletion<U>) -> Void {
    return { completion in
        first { result in
            switch result {
            case .failure(let error):
                completion(.failure(AnyError(error)))
            case .success(let value):
                do {
                    completion(.success(try transform(value)))
                } catch {
                    completion(.failure(AnyError(error)))
                }
            }
        }
    }
}

/*
func service1(_ param: Int, _ completionHandler: ResultCompletion<Int, AppError>) {
    completionHandler(.success(42))
}
func service2(_ param: Int, arg: String, _ completionHandler: ResultCompletion<String, NetError>) {
    completionHandler(.success("🎉 \(arg)"))
}
func isValidate(_ param: Int, arg: String, _ completion: (AppError?) -> Void) {
    completion(nil)
}
func testChainFunc() {
    let chainedServices = service1
    >>> { String($1 / 2) }// or throw some error
    >>? isValidate
    >>> service2
    chainedServices(10) { result in
        switch result {
        case .success(let val):
            print(val)// Prints: 🎉 21
        case .failure(let anyError):
            let error = anyError.error
            print(error)
        }
    }
}
*/



fileprivate func service1(_ param: Int, _ completion: @escaping ResultCompletion<Int, AppError>) {
    completion(.success(42))
}
fileprivate func service2(_ param: Int, arg: String, _ completion: @escaping ResultCompletion<String, NetError>) {
    completion(.success("🎉 \(arg)"))
}
fileprivate func isValidate(_ param: Int, arg: String, _ completion: @escaping (AppError?) -> Void) {
    completion(nil)
}
func testChainFunc1() {
    let chainedServices = service1
    >>> { String($1 / 2) }// or throw some error
    >>? isValidate
    >>> service2
    chainedServices(10) { result in
        switch result {
        case .success(let val):
            print(val)// Prints: 🎉 21
        case .failure(let anyError):
            let error = anyError.error
            print(error)
        }
    }
}


fileprivate func service11(_ completion: @escaping ResultCompletion<Int, AppError>) {
   completion(.success(42))
}
fileprivate func service12(arg: String, _ completion: @escaping ResultCompletion<String, NetError>) {
   completion(.success("🎉 \(arg)"))
}
fileprivate func isValidate11(arg: String, _ completion: @escaping (AppError?) -> Void) {
   completion(nil)
}
func testChainFunc2() {
   let chainedServices = service11
   >>> { String($0 / 2) }// or throw some error
   >>? isValidate11
   >>> service12
   chainedServices { result in
       switch result {
       case .success(let val):
           print(val)// Prints: 🎉 21
       case .failure(let anyError):
           let error = anyError.error
           print(error)
       }
   }
}
