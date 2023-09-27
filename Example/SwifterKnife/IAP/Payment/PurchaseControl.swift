//
//  PurchaseControl.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2021/10/29.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import StoreKit


/// Purchased product
public struct PurchaseDetail {
    public let productId: String
    public let quantity: Int
    public let product: SKProduct
    public let transaction: PaymentTransaction
    public let originalTransaction: PaymentTransaction?
    public let needsFinishTransaction: Bool
    
    public init(productId: String,
                quantity: Int,
                product: SKProduct,
                transaction: PaymentTransaction,
                originalTransaction: PaymentTransaction?,
                needsFinishTransaction: Bool) {
        self.productId = productId
        self.quantity = quantity
        self.product = product
        self.transaction = transaction
        self.originalTransaction = originalTransaction
        self.needsFinishTransaction = needsFinishTransaction
    }
}

public typealias IAPPurchaseResult = Result<PurchaseDetail, SKError>

public typealias IAPPurchaseCompletion = (IAPPurchaseResult) -> Void

struct Payment: Hashable {
    let product: SKProduct
      
    let atomically: Bool
    let applicationUsername: String
    let simulatesAskToBuyInSandbox: Bool
    let completion: IAPPurchaseCompletion

    func hash(into hasher: inout Hasher) {
        hasher.combine(product) 
        hasher.combine(atomically)
        hasher.combine(applicationUsername)
        hasher.combine(simulatesAskToBuyInSandbox)
    }
    
    static func == (lhs: Payment, rhs: Payment) -> Bool {
        return lhs.product.productIdentifier == rhs.product.productIdentifier
    }
}




fileprivate extension SKPaymentTransaction {
    var skError: SKError {
        if let skerr = error as? SKError { return skerr }
        let nsError = (error as NSError?) ?? NSError(domain: SKErrorDomain, code: SKError.unknown.rawValue, userInfo: [ NSLocalizedDescriptionKey: "Unknown error" ])
        return SKError(_nsError: nsError)
    }
}

final class PurchaseControl {
    
    private var payments: [Payment] = []

    func append(_ payment: Payment) {
        payments.append(payment)
    }

    func processTransaction(_ transaction: SKPaymentTransaction,
                            on paymentQueue: PaymentQueue) -> Bool {

        let transactionId = transaction.payment.productIdentifier

        guard let paymentIndex = payments.firstIndex(where: {
            $0.product.productIdentifier == transactionId
        }) else {
            return false
        }
        let payment = payments[paymentIndex]

        let transactionState = transaction.transactionState

        if transactionState == .purchased ||
            transactionState == .restored {
            
            if transactionState == .restored {
                print("Unexpected restored transaction for payment \(transactionId)")
            }
            let detail = PurchaseDetail(
                productId: transactionId,
                quantity: transaction.payment.quantity,
                product: payment.product,
                transaction: transaction,
                originalTransaction: transaction.original,
                needsFinishTransaction: !payment.atomically)
            
            payment.completion(.success(detail))

            if payment.atomically {
                paymentQueue.finishTransaction(transaction)
            }
            payments.remove(at: paymentIndex)
            return true
        }

        if transactionState == .failed {
             
            payment.completion(.failure(transaction.skError))
            paymentQueue.finishTransaction(transaction)
            payments.remove(at: paymentIndex)
            return true
        }

        return false
    }
}

extension PurchaseControl: TransactionHandle {
    
    func processTransactions(_ transactions: [SKPaymentTransaction],
                             on paymentQueue: PaymentQueue) -> [SKPaymentTransaction] {

        return transactions.filter { !processTransaction($0, on: paymentQueue) }
    }
}
