//
//  InputSemaphore.swift
//  Toonpics
//
//  Created by 李阳 on 2023/3/14.
//

import Foundation


enum InputSemaphore {
    static var onEnableChanged: ((Bool) -> Void)?
    
    static func reset() {
        onEnableChanged = nil
        _totalCount = 1
        _currentCount = 0
    }
    private static var _totalCount: Int = 1
    
    static func observer(_ totalCount: Int, closure: @escaping (Bool) -> Void) {
        reset()
        _totalCount = totalCount
        onEnableChanged = closure
    }
    
    static var totalCount: Int {
        get { _totalCount }
        set {
            guard _totalCount != newValue else { return }
            _totalCount = newValue
            onEnableChanged?(_currentCount >= _totalCount)
        }
    }
    
    static func increase() {
        totalCount += 1
    }
    static func decrease() {
        totalCount -= 1
    }
    
    private static var _currentCount: Int = 0
    private static var currentCount: Int {
        get { _currentCount }
        set {
            let oldValue = _currentCount
            guard oldValue != newValue else { return }
            _currentCount = newValue
            if oldValue >= totalCount,
               newValue < totalCount {
                onEnableChanged?(false)
            }
            if oldValue < totalCount,
               currentCount >= totalCount {
                onEnableChanged?(true)
            }
        }
    }
    
    static func finishOne(_ flag: Bool) {
        if flag {
            currentCount += 1
        } else {
            currentCount -= 1
        }
    }
}
