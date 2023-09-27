//
//  IAPRequest.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2021/10/29.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

public protocol IAPRequest: AnyObject {
    func start()
    func cancel()
}
