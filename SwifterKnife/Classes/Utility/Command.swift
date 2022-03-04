//
//  Checkman.swift
//  SwifterKnife
//
//  Created by liyang on 2022/02/26.
//

import Foundation

final class Command<Success, Error: Swift.Error> {
    deinit {
        Console.log("Command deinit")
    }
    
    private(set) var isValid: Bool = true
    
    var onSuccess: (Success) -> Void
    var onFailure: (Error) -> Void
    var onTimeout: (() -> Void)?
    
    init(onSuccess: @escaping (Success) -> Void,
         onFailure: @escaping (Error) -> Void,
         onTimeout: (() -> Void)? = nil) {
        (self.onSuccess, self.onFailure) = (onSuccess, onFailure)
        self.onTimeout = onTimeout
    }
    
    func makeInvalid(after interval: TimeInterval) {
        timer?.cancel()
        timer = nil
        timer = DispatchQueue.main.after(interval) { [weak self] in
            guard let this = self else { return }
            this.isValid = false
            this.onTimeout?()
            this.timer?.cancel()
            this.timer = nil
        }
    }
     
    @discardableResult
    func send(_ event: Result<Success, Error>) -> Bool {
        guard isValid else { return false }
        isValid = false
        switch event {
        case .success(let value):
            DispatchQueue.main.async { self.onSuccess(value) }
        case .failure(let error):
            DispatchQueue.main.async { self.onFailure(error) }
        }
        timer?.cancel()
        timer = nil
        return true
    }
    
    private var timer: DispatchWorkItem?
}
