//
//  Either.swift
//  SwifterKnife
//
//  Created by liyang on 2022/7/21.
//

import Foundation

public enum Either<Left, Right> {
    case left(Left)
    case right(Right)
    
    public var isLeft: Bool {
        if case .left = self { return true }
        return false
    }
    public var left: Left? {
        get {
            if case .left(let left) = self {  return left }
            return nil
        }
        set {
            guard let val = newValue else { return }
            self = .left(val)
        }
    }
    
    public var isRight: Bool {
        if case .right = self { return true }
        return false
    }
    public var right: Right? {
        get {
            if case .right(let right) = self {  return right }
            return nil
        }
        set {
            guard let val = newValue else { return }
            self = .right(val)
        }
    }
    
    public func `do`(
        ifLeft: (Left) throws -> Void,
        ifRight: (Right) throws -> Void
    ) rethrows {
        switch self {
        case let .left(left):
            try ifLeft(left)
        case let .right(right):
            try ifRight(right)
        }
    }
    
    public func reduce<Value>(
        ifLeft transformLeft: (Left) throws -> Value,
        ifRight transformRight: (Right) throws -> Value
    ) rethrows -> Value {
        switch self {
        case .left(let lhs):
            return try transformLeft(lhs)
        case .right(let rhs):
            return try transformRight(rhs)
        }
    }
    public func reduceLeft(
        _ transform: (Right) throws -> Left
    ) rethrows -> Left {
        return try reduce(ifLeft: { $0 }, ifRight: transform)
    }
    public func reduceRight(
        _ transform: (Left) throws -> Right
    ) rethrows -> Right {
        return try reduce(ifLeft: transform, ifRight: { $0 })
    }
    
    public func filter(
        ifLeft leftPredicate: (Left) throws -> Bool,
        ifRight rightPredicate: (Right) throws -> Bool
    ) rethrows -> Self? {
        switch self {
        case let .left(left):
            return try leftPredicate(left) ? self : nil
        case let .right(right):
            return try rightPredicate(right) ? self : nil
        }
    }
    
    
    public func map<NewLeft, NewRight>(
        ifLeft transformLeft: (Left) throws -> NewLeft,
        ifRight transformRight: (Right) throws -> NewRight
    ) rethrows -> Either<NewLeft, NewRight> {
        return try reduce(
            ifLeft: { .left(try transformLeft($0)) },
            ifRight: { .right(try transformRight($0)) }
        )
    }
    
    public func mapLeft<NewLeft>(
        _ transform: (Left) throws -> NewLeft
    ) rethrows -> Either<NewLeft, Right> {
        return try map(ifLeft: transform, ifRight: { $0 })
    }
    
    public func mapRight<NewRight>(
        _ transform: (Right) throws -> NewRight
    ) rethrows -> Either<Left, NewRight> {
        return try map(ifLeft: { $0 }, ifRight: transform)
    }
    
    
    public func flatMap<NewLeft, NewRight>(
        ifLeft transformLeft: ((Left) throws -> NewLeft?),
        ifRight transformRight: ((Right) throws -> NewRight?)
    ) rethrows -> Either<NewLeft, NewRight>? {
        switch self {
        case .left(let lhs):
            return try transformLeft(lhs).map(Either<NewLeft, NewRight>.left)
        case .right(let rhs):
            return try transformRight(rhs).map(Either<NewLeft, NewRight>.right)
        }
    }
    public func flatMapLeft<NewLeft>(
        _ transform: ((Left) throws -> NewLeft?)
    ) rethrows -> Either<NewLeft, Right>? {
        return try flatMap(ifLeft: transform, ifRight: { $0 })
    }
    public func flatMapRight<NewRight>(
        left transform: ((Right) throws -> NewRight?)
    ) rethrows -> Either<Left, NewRight>? {
        return try flatMap(ifLeft: { $0 }, ifRight: transform)
    }
    
    
    public func compactMapLeft<NewLeft>(
        _ transform: (Left) throws -> Either<NewLeft, Right>
    ) rethrows -> Either<NewLeft, Right> {
        return try reduce(ifLeft: transform, ifRight: { .right($0) })
    }
    public func compactMapRight<NewRight>(
        _ transform: (Right) throws -> Either<Left, NewRight>
    ) rethrows -> Either<Left, NewRight> {
        return try reduce(ifLeft: { .left($0) }, ifRight: transform)
    }
    
    public static func zipLeft<LeftLeft, RightLeft>(
        _ lhs: Either<LeftLeft, Right>,
        rhs: Either<RightLeft, Right>) -> Either
    where Left == (LeftLeft, RightLeft) {
        switch (lhs, rhs) {
        case let (.left(left), .left(otherLeft)):
            return .left((left, otherLeft))
        case let (.right(right), _):
            return .right(right)
        case let (_, .right(right)):
            return .right(right)
        }
    }
    
    public static func zipRight<LeftRight, RightRight>(
        _ lhs: Either<Left, LeftRight>,
        rhs: Either<Left, RightRight>) -> Either
    where Right == (LeftRight, RightRight) {
        switch (lhs, rhs) {
        case let (.right(right), .right(otherRight)):
            return .right((right, otherRight))
        case let (.left(left), _):
            return .left(left)
        case let (_, .left(left)):
            return .left(left)
        }
    }
}

extension Either: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        reduce(
            ifLeft: { "Either.left(\(String(describing: $0)))" },
            ifRight: { "Either.right(\(String(describing: $0)))" }
        )
    }
    public var debugDescription: String {
        reduce(
            ifLeft: { "Either.left(\(String(reflecting: $0)))" },
            ifRight: { "Either.right(\(String(reflecting: $0)))" }
        )
    }
}

extension Either: Equatable where Left: Equatable, Right: Equatable {
    public static func == (lhs: Either, rhs: Either) -> Bool {
        switch (lhs, rhs) {
        case let (.left(lhs), .left(rhs)):
            return lhs == rhs
        case let (.right(lhs), .right(rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension Either: Comparable where Left: Comparable, Right: Comparable {
    public static func < (lhs: Either, rhs: Either) -> Bool {
        switch (lhs, rhs) {
        case let (.left(lhs), .left(rhs)):
            return lhs < rhs
        case let (.right(lhs), .right(rhs)):
            return lhs < rhs
        case (.left, .right):
            return true
        case (.right, .left):
            return false
        }
    }
}

private enum HashableTag: Hashable { case left, right }

extension Either: Hashable where Left: Hashable, Right: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .left(left):
            hasher.combine(HashableTag.left)
            hasher.combine(left)
        case let .right(right):
            hasher.combine(HashableTag.right)
            hasher.combine(right)
        }
    }
}


extension Either: Decodable where Left: Decodable, Right: Decodable {
    public struct DecodeError: Error {
        public let errors: [Error]
    }
    public init(from decoder: Decoder) throws {
        do {
            self = try .left(Left(from: decoder))
        } catch let leftError {
            do {
                self = try .right(Right(from: decoder))
            } catch let rightError {
                throw DecodingError.typeMismatch(
                    Either.self,
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Could not decode \(Left.self) or \(Right.self)",
                        underlyingError: DecodeError(errors: [leftError, rightError])
                    )
                )
            }
        }
    }
}

extension Either: Encodable where Left: Encodable, Right: Encodable {
    public func encode(to encoder: Encoder) throws {
        return try reduce(
            ifLeft: { try $0.encode(to: encoder) },
            ifRight: { try $0.encode(to: encoder) }
        )
    }
}

extension Either where Left: Error {
    public var asRightResult: Result<Right, Left> {
        return reduce(ifLeft: Result.failure, ifRight: Result.success)
    }
}

extension Either where Right: Error {
    public var asLeftResult: Result<Left, Right> {
        return reduce(ifLeft: Result.success, ifRight: Result.failure)
    } 
}

extension Optional {
    public func selectLeft<Left, Right>(
        _ perform: (Right) -> Left? = {_ in nil }) -> Left?
    where Wrapped == Either<Left, Right> {
        return flatMap { e in
            e.reduce(
                ifLeft: { a in .some(a) },
                ifRight: { b in perform(b) }
            )
        }
    }
    public func selectRight<Left, Right>(
        _ perform: (Left) -> Right? = {_ in nil }) -> Right?
    where Wrapped == Either<Left, Right> {
        return flatMap { e in
            e.reduce(
                ifLeft: { a in perform(a) },
                ifRight: { b in .some(b) }
            )
        }
    }
}

extension Sequence {
    public func lefts<Left, Right>() -> [Left] where Element == Either<Left, Right> {
        return compactMap { $0.left }
    }
    
    public func rights<Left, Right>() -> [Right] where Element == Either<Left, Right> {
        return compactMap { $0.right }
    }
    
    public func partitionMap<Left, Right>(_ transform: (Element) -> Either<Left, Right>)
    -> ([Left], [Right]) {
        return reduce(into: ([], [])) { result, element in
            transform(element).do {
                result.0.append($0)
            } ifRight: {
                result.1.append($0)
            }
        }
    }
    
    public func partitioned<Left, Right>() -> ([Left], [Right])
    where Element == Either<Left, Right> {
        return partitionMap { $0 }
    }
}
