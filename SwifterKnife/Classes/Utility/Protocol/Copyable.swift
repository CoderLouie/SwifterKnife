//
//  Copyable.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

public protocol Copyable: AnyObject {
    func copyable() -> Self
}

public extension Copyable where Self: NSCopying {
    func copyable() -> Self {
        let obj = copy()
        guard let ins = obj as? Self else {
            fatalError("when copy \(self) but got type \(type(of: obj))")
        }
        return ins
    }
}
public extension Copyable where Self: NSMutableCopying {
    func mutableCopyable() -> Self {
        let obj = mutableCopy()
        guard let ins = obj as? Self else {
            fatalError("when mutable copy \(self) but got type \(type(of: obj))")
        }
        return ins
    }
}

public extension Copyable where Self: DataCodable {
    func copyable() -> Self {
        do {
            let data = try encode()
            let copied = try Self.decode(with: data)
            return copied
        } catch {
            fatalError("can not copy \(self) due \(error)")
        }
    }
}

public extension Copyable where Self: Codable {
    func copyable() -> Self {
        do {
            let data = try JSONEncoder().encode(self)
            let instance = try JSONDecoder().decode(Self.self, from: data)
            return instance
        } catch {
            fatalError("can not copy \(self) due \(error)")
        }
    }
}

/// Encapsulates behavior surrounding value semantics and copy-on-write behavior
public struct CopyOnWrite<Reference: Copyable> {

    private var _reference: Reference

    /// Constructs the copy-on-write wrapper around the given reference and copy function
    ///
    /// - Parameters:
    ///   - reference: The object that is to be given value semantics
    ///   - copier: The function that is responsible for copying the reference if the consumer of this API needs it to be copied. This function should create a new instance of the referenced type; it should not return the original reference given to it.
    public init(_ reference: Reference) {
        self._reference = reference
    }

    /// Returns the reference meant for read-only operations.
    public var ref: Reference {
        return _reference
    }

    /// Returns the reference meant for mutable operations. If necessary, the reference is copied using the `copier` function or closure provided to the initializer before returning, in order to preserve value semantics.
    public var mutatingRef: Reference {
        mutating get {
            // copy the reference only if necessary
            if !isKnownUniquelyReferenced(&_reference) {
                _reference = _reference.copyable()
            } 
            return _reference
        }
    }
}
 
