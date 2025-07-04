//
//  Combine.swift
//  SwifterKnife
//
//  Created by liyang on 2025/6/18.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Combine

public protocol Noticeable {
    var notifyName: Notification.Name { get }
}



public extension Noticeable {
    func post(object: AnyObject?, userInfo: [AnyHashable: Any]?) {
        NotificationCenter.default.post(name: notifyName, object: object, userInfo: userInfo)
    }
    
    var publisher: AnyPublisher<Notification, Never> {
        NotificationCenter.default
            .publisher(for: notifyName)
            .eraseToAnyPublisher()
    }
    
    func publisher(object: AnyObject?) -> AnyPublisher<Notification, Never> {
        NotificationCenter.default
            .publisher(for: notifyName, object: object)
            .eraseToAnyPublisher()
    }
}
extension Notification.Name: Noticeable {
    public var notifyName: Notification.Name { self }
}

extension Noticeable where Self: RawRepresentable, Self.RawValue == String {
    public var notifyName: Notification.Name {
        .init(rawValue: rawValue)
    }
}


