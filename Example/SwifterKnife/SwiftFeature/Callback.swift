//
//  Callback.swift
//  SwifterKnife
//
//  Created by liyang on 2025/6/27.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

#if canImport(Combine)
import Combine
import Foundation

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AnyPublisher {
    static func callback(_ factory: @escaping Publishers.Callback<Output, Failure>.SubscriberHandler)
        -> AnyPublisher<Output, Failure> {
        Publishers.Callback(factory: factory).eraseToAnyPublisher()
    }
}

// MARK: - Publisher
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publishers {
    
    struct Callback<Output, Failure: Swift.Error>: Combine.Publisher {
        public typealias SubscriberHandler = (@escaping (Result<Output, Failure>) -> Void) -> Cancellable?
        private let factory: SubscriberHandler
        
        init(factory: @escaping SubscriberHandler) {
            self.factory = factory
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            let subscription = Subscription(subscriber: subscriber, factory: factory)
            subscriber.receive(subscription: subscription)
        }
    }
    
}

// MARK: - Subscription
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private extension Publishers.Callback {
    class Subscription<Downstream: Combine.Subscriber>: Combine.Subscription where Downstream.Input == Output, Downstream.Failure == Failure {
        private var subscriber: Downstream?
        private var factory: SubscriberHandler?
        private var cancellable: Cancellable?
        
        init(subscriber: Downstream, factory: @escaping SubscriberHandler) {
            self.subscriber = subscriber
            self.factory = factory
        }
        
        func request(_ demand: Subscribers.Demand) {
            // 在这个简单实现中，我们忽略需求，因为我们只发送一个值
            guard demand > .none,
                let work = factory,
                let subscriber = subscriber else { return }
            factory = nil
            cancellable = work { result in
                switch result {
                case .success(let output):
                    _ = subscriber.receive(output)
                    subscriber.receive(completion: .finished)
                case .failure(let error):
                    subscriber.receive(completion: .failure(error))
                }
            }
        }
        func cancel() {
            cancellable?.cancel()
            subscriber = nil
        }
    }
}

#endif
