//
//  RestoreControl.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2021/10/29.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import StoreKit
 
public struct RestoreDetail {
    public let productId: String
    public let quantity: Int
    public let transaction: PaymentTransaction
    public let originalTransaction: PaymentTransaction?
    public let needsFinishTransaction: Bool
    
    public init(productId: String,
                quantity: Int,
                transaction: PaymentTransaction,
                originalTransaction: PaymentTransaction?,
                needsFinishTransaction: Bool) {
        self.productId = productId
        self.quantity = quantity
        self.transaction = transaction
        self.originalTransaction = originalTransaction
        self.needsFinishTransaction = needsFinishTransaction
    }
}

public typealias IAPRestoreResult = Result<[RestoreDetail], Error>
public typealias IAPRestoreCompletion = (IAPRestoreResult) -> Void

struct Restore {
    let atomically: Bool
    let applicationUsername: String?
    let completion: IAPRestoreCompletion

    init(atomically: Bool,
         applicationUsername: String? = nil,
         callback: @escaping IAPRestoreCompletion) {
        self.atomically = atomically
        self.applicationUsername = applicationUsername
        self.completion = callback
    }
}

final class RestoreControl {
    public var param: Restore?
    private var details: [RestoreDetail] = []
    
    private func processTransaction(
        _ transaction: SKPaymentTransaction,
        atomically: Bool,
        on paymentQueue: PaymentQueue) -> RestoreDetail? {

        let transactionState = transaction.transactionState

        if transactionState == .restored {

            let transactionId = transaction.payment.productIdentifier
            
            let detail = RestoreDetail(
                productId: transactionId,
                quantity: transaction.payment.quantity,
                transaction: transaction,
                originalTransaction: transaction.original,
                needsFinishTransaction: !atomically)
            if atomically {
                paymentQueue.finishTransaction(transaction)
            }
            return detail
        }
        return nil
    }
    
    func restoreFailed(withError error: Error) {

        guard let restore = param else {
            print("Callback already called. Returning")
            return
        }
        restore.completion(.failure(error))
        details = []
        param = nil
    }
    
    
    func restoreCompleted() {

        guard let restore = param else {
            print("Callback already called. Returning")
            return
        }
        restore.completion(.success(details))

        // Reset state after error transactions finished
        details = []
        param = nil
    }
}

extension RestoreControl: TransactionHandle {
    
    func processTransactions(_ transactions: [SKPaymentTransaction],
                             on paymentQueue: PaymentQueue) -> [SKPaymentTransaction] {

        guard let restore = param else {
            return transactions
        }

        var unhandledTransactions: [SKPaymentTransaction] = []
        for transaction in transactions {
            if let detail = processTransaction(
                transaction,
                atomically: restore.atomically,
                on: paymentQueue) {
                details.append(detail)
            } else {
                unhandledTransactions.append(transaction)
            }
        }

        return unhandledTransactions
    }
}
