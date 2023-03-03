//
//  IAPManager.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation
import StoreKit

public final class IAP {
    public static let shared = IAP()
    public static var enable: Bool {
        SKPaymentQueue.canMakePayments()
    }
    
    @discardableResult
    public static func queryProducts(_ productIds: Set<String>,
                       completion: @escaping IAPQueryCompletion) -> IAPRequest {
        return shared.queryControl.queryProducts(productIds, completion: completion)
    }
    
    
    public static
    func purchase(product: SKProduct,
                  atomically: Bool = true,
                  applicationUsername: String = "",
                  simulatesAskToBuyInSandbox sandbox: Bool = false,
                  completion: @escaping IAPPurchaseCompletion) {
        let payment = Payment(product: product, 
                              atomically: atomically,
                              applicationUsername: applicationUsername,
                              simulatesAskToBuyInSandbox: sandbox) { result in
//            completion(self.processPurchaseResult(result))
        }
        shared.paymentQueue.startPayment(payment)
    }
    
    public static
    func restorePurchases(atomically: Bool = true,
                          applicationUsername: String = "",
                          completion: @escaping IAPRestoreCompletion) {
        let rp = Restore(atomically: atomically,
                                  applicationUsername: applicationUsername) { results in
//            let results = self.processRestoreResults(results)
//            completion(results)
        }
        shared.paymentQueue.restore(rp)
    }
    
    
    public static
    func finishTransaction(_ transaction: PaymentTransaction) {
        shared.paymentQueue.finishTransaction(transaction)
    }
    
    private let queryControl = QueryControl()
    private let paymentQueue = PaymentQueueControl()
}
 
 
