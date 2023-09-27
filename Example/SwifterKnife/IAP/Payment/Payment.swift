//
//  Payment.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2021/10/29.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import StoreKit

/// Payment transaction
public protocol PaymentTransaction {
    var transactionDate: Date? { get }
    var transactionState: SKPaymentTransactionState { get }
    var transactionIdentifier: String? { get }
    var downloads: [SKDownload] { get }
}
extension SKPaymentTransaction: PaymentTransaction { }

