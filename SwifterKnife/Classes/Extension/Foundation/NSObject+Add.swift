//
//  NSObject+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2022/3/25.
//

import Foundation

public enum AssociationPolicy: RawRepresentable {
    case assign
    case retain
    case copy
    case nonatomic_retain
    case nonatomic_copy
    
    public init?(rawValue: objc_AssociationPolicy) {
        switch rawValue {
        case .OBJC_ASSOCIATION_ASSIGN:
            self = .assign
        case .OBJC_ASSOCIATION_RETAIN:
            self = .retain
        case .OBJC_ASSOCIATION_COPY:
            self = .copy
        case .OBJC_ASSOCIATION_RETAIN_NONATOMIC:
            self = .nonatomic_retain
        case .OBJC_ASSOCIATION_COPY_NONATOMIC:
            self = .nonatomic_copy
        @unknown default:
            return nil
        }
    }
    
    public var rawValue: objc_AssociationPolicy {
        switch self {
        case .assign:
            return .OBJC_ASSOCIATION_ASSIGN
        case .retain:
            return .OBJC_ASSOCIATION_RETAIN
        case .copy:
        return .OBJC_ASSOCIATION_COPY
        case .nonatomic_retain:
            return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        case .nonatomic_copy:
            return .OBJC_ASSOCIATION_COPY_NONATOMIC
        }
    }
}

public extension NSObject {
    func associatedValue<T>(
        for key: UnsafeRawPointer,
        policy: AssociationPolicy,
        default builder: @autoclosure () -> T) -> T {
        if let target = objc_getAssociatedObject(self, key) as? T {
            return target
        }
        let value = builder()
        objc_setAssociatedObject(self, key, value, policy.rawValue)
        return value
    }
}
