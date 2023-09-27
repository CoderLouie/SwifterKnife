//
//  Query.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2021/10/29.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import StoreKit

public struct QueryResult {
    public let products: Set<SKProduct>
    public let invalidProductIDs: Set<String>
    
    public init(products: Set<SKProduct>,
                invalidProductIDs: Set<String> ) {
        self.products = products
        self.invalidProductIDs = invalidProductIDs
    }
}
public typealias IAPQueryResult = Result<QueryResult, Error>

public typealias IAPQueryCompletion = (IAPQueryResult) -> Void

final class QueryRequest: NSObject {
    
    private let completion: IAPQueryCompletion
    private let request: SKProductsRequest

    deinit { request.delegate = nil }
    
    init(productIds: Set<String>,
         completion: @escaping IAPQueryCompletion) {

        self.completion = completion
        request = SKProductsRequest(productIdentifiers: productIds)
        super.init()
        request.delegate = self
    }
    
    private func performCallback(_ results: IAPQueryResult) {
        DispatchQueue.main.async {
            self.completion(results)
        }
    }
    
}

extension QueryRequest: IAPRequest {
    
    func start() {
        request.start()
    }
    func cancel() {
        request.cancel()
    }
}

// MARK: SKProductsRequestDelegate
extension QueryRequest: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {

        let products = Set<SKProduct>(response.products)
        let invalidProductIDs = Set<String>(response.invalidProductIdentifiers)
        
        let result = QueryResult(
            products: products,
            invalidProductIDs: invalidProductIDs)
        performCallback(.success(result))
    }

    func requestDidFinish(_ request: SKRequest) {

    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        performCallback(.failure(error))
    }
}



final class QueryControl {
    struct Record {
        let request: QueryRequest
        var completions: [IAPQueryCompletion]
    }
    private var records: [Set<String>: Record] = [:]
    
    func queryProducts(_ productIds: Set<String>,
                       completion: @escaping IAPQueryCompletion) -> QueryRequest {
        if records[productIds] == nil {
            let request = QueryRequest(productIds: productIds) { result in
                if let record = self.records[productIds] {
                    for closure in record.completions {
                        closure(result)
                    }
                    self.records[productIds] = nil
                } else {
                    completion(result)
                }
            }
            records[productIds] = Record(
                request: request,
                completions: [completion])
            request.start()
            return request
        } else {
            records[productIds]!.completions.append(completion)
            return records[productIds]!.request
        }
    }
}
