//
//  CallbackHell.swift
//  BatterySwap
//
//  Created by 李阳 on 2023/3/2.
//

import Foundation

/*
 // 44
 https://github.com/vincent-pradeilles/swift-tips#transform-an-asynchronous-function-into-a-synchronous-one
 */
 
public struct AnyError: Swift.Error {
    public let error: Swift.Error
    public init(_ error: Swift.Error) {
        self.error = AnyError.rawError(of: error)
    }
    private static func rawError(of error: Swift.Error) -> Swift.Error {
        if let anyError = error as? AnyError {
            return rawError(of: anyError.error)
        }
        return error
    }
}

extension AnyError: CustomStringConvertible {
    public var description: String {
        "\(error)"
    }
}
extension AnyError: Equatable {
    public static func == (lhs: AnyError, rhs: AnyError) -> Bool {
        lhs.description == rhs.description
    }
}


enum AppError: Swift.Error {
    case big
    case small
}

