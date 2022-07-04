//
//  Position.swift
//  SwifterKnife
//
//  Created by 李阳 on 2022/7/4.
//

import UIKit

public typealias Position = CGPoint

public extension Position {
    static var leftTop: Position {
        return Position(x: 0, y: 0)
    }
    static var leftCenter: Position {
        return Position(x: 0, y: 0.5)
    }
    static var leftBottom: Position {
        return Position(x: 0, y: 1)
    }
    static var topCenter: Position {
        return Position(x: 0.5, y: 0)
    }
    static var center: Position {
        return Position(x: 0.5, y: 0.5)
    }
    static var bottomCenter: Position {
        return Position(x: 0.5, y: 1)
    }
    static var rightTop: Position {
        return Position(x: 1, y: 0)
    }
    static var rightCenter: Position {
        return Position(x: 1, y: 0.5)
    }
    static var rightBottom: Position {
        return Position(x: 1, y: 1)
    }
}
