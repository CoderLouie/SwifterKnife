//
//  TypedNotification.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/3/20.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

// https://github.com/GesanTung/iOSTips
public protocol NotificationDescriptor {
    static var name: Notification.Name { get }
    var userInfo: [String: Any]? { get }
    var object: Any? { get }
}

public extension NotificationDescriptor {
    var userInfo: [String: Any]? { nil }

    var object: Any? { nil }
}

extension NotificationDescriptor {
    public func post(on center: NotificationCenter = .default) {
        center.post(name: Self.name, object: object, userInfo: userInfo)
    }
}

public protocol NotificationDecodable {
    init?(_ notification: Notification)
}

extension NotificationDecodable {
    @discardableResult
    public static func observer(on center: NotificationCenter = .default,
                                for aName: Notification.Name,
                                using block: @escaping (Self) -> Void) -> NotificationToken {
        let token = center.addObserver(forName: aName, object: nil, queue: nil) {
            guard let model = Self.init($0) else { return }
            block(model)
        }
        return NotificationToken(token, center: center)
    }
}

public typealias NotificationProtocol = NotificationDescriptor & NotificationDecodable

public protocol TypedNotification: NotificationProtocol {
    static func registerObserver(using block: @escaping (Self) -> Swift.Void) -> NotificationToken
}

extension TypedNotification {
    public static func registerObserver(using block: @escaping (Self) -> Swift.Void) -> NotificationToken {
        observer(on: NotificationCenter.default, for: Self.name, using: block)
    }
}



public final class NotificationToken {
    public let token: NSObjectProtocol
    public let center: NotificationCenter
    public init(_ token: NSObjectProtocol, center: NotificationCenter) {
        self.token = token
        self.center = center
    }

    deinit {
        center.removeObserver(token)
    }
}

/*
struct Comment {
    var user_id: Int = 0
    var content = ""
}

struct CommentChangeNotification: TypedNotification {

    static var name: Notification.Name {
        return "com.notification.comment"
    }

    let newsId: Int
    let comment: Comment

    var userInfo: [AnyHashable: Any]? {
        return ["newsId": newsId,
                "comment": comment
        ]
    }

    init(_ notification: Notification) {
        newsId = notification.userInfo?["newsId"] as! Int
        comment = notification.userInfo?["comment"] as! Comment
    }

    init( newsId: Int, comment: Comment) {
        self.newsId = newsId
        self.comment = comment
    }
}
*/
