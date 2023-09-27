//
//  PaymentQueueControl.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2021/10/29.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import StoreKit


public protocol PaymentQueue: AnyObject {
    
    func add(_ observer: SKPaymentTransactionObserver)
    func remove(_ observer: SKPaymentTransactionObserver)
    
    func add(_ payment: SKPayment)
    
    func restoreCompletedTransactions(withApplicationUsername username: String?)
    
    func finishTransaction(_ transaction: SKPaymentTransaction)
}
extension SKPaymentQueue: PaymentQueue {}

protocol TransactionHandle {
    
    /// Process the supplied transactions on a given queue.
    /// - parameter transactions: transactions to process
    /// - parameter paymentQueue: payment queue for finishing transactions
    /// - returns: array of unhandled transactions
    func processTransactions(
        _ transactions: [SKPaymentTransaction],
        on paymentQueue: PaymentQueue) -> [SKPaymentTransaction]
}

final class PaymentQueueControl: NSObject {
    
    deinit {
        queue.remove(self)
    }
    override init() {
        super.init()
        queue.add(self)
    }
    
    func startPayment(_ payment: Payment) {
        let skPayment = SKMutablePayment(product: payment.product)
        skPayment.applicationUsername = payment.applicationUsername
         
        if #available(iOS 8.3, watchOS 6.2, *) {
            skPayment.simulatesAskToBuyInSandbox = payment.simulatesAskToBuyInSandbox
        }
        
        queue.add(skPayment)
        purchase.append(payment)
    }
    
    func restore(_ param: Restore) {
        guard restore.param == nil else { return }
        
        queue.restoreCompletedTransactions(withApplicationUsername: param.applicationUsername)
        restore.param = param
    }
    
    func finishTransaction(_ transaction: PaymentTransaction) {
        guard let skTransaction = transaction as? SKPaymentTransaction else {
            print("Object is not a SKPaymentTransaction: \(transaction)")
            return
        }
        queue.finishTransaction(skTransaction)
    }
    
    unowned let queue: PaymentQueue = SKPaymentQueue.default()
    private let purchase = PurchaseControl()
    private let restore = RestoreControl()
}
extension PaymentQueueControl: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        var unhandledTransactions = transactions.filter { $0.transactionState != .purchasing }
        
        if unhandledTransactions.count > 0 {
            
            unhandledTransactions = purchase.processTransactions(transactions, on: queue)
            
            unhandledTransactions = restore.processTransactions(unhandledTransactions, on: queue)
             
            for transaction in unhandledTransactions {
                self.queue.finishTransaction(transaction)
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue,
                      removedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue,
                      restoreCompletedTransactionsFailedWithError error: Error) {
        
        restore.restoreFailed(withError: error)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {

        restore.restoreCompleted()
    }
}
