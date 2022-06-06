//
//  Funcs.swift
//  SwifterKnife
//
//  Created by liyang on 2022/4/26.
//

import Foundation


public func asyncWhile(
    delay: TimeInterval = 0,
    _ cond: @escaping (_ index: Int,
                       _ exit: inout Bool,
                       _ cost: () -> TimeInterval) -> Bool,
    execute work: @escaping (_ index: Int,
                             _ cost: () -> TimeInterval) -> Void) {
    
    var index = 0
    var exit = false
    let start = CACurrentMediaTime()
    let cost = { CACurrentMediaTime() - start }
    func closure() {
        let result = cond(index, &exit, cost)
        if exit { return }
        guard result else {
            index += 1
            DispatchQueue.main.async(execute: closure)
            return
        }
        work(index, cost)
    }
    if delay > 0 {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: closure)
    } else {
        DispatchQueue.main.async(execute: closure)
    }
}


public func asyncRepeat(_ work: @escaping (
                            _ index: Int,
                            _ cond: @escaping (Bool) -> Void,
                            _ cost: () -> TimeInterval) -> Void) {
    
    let start = CACurrentMediaTime()
    let cost = { CACurrentMediaTime() - start }
    var index = 0
    var cond: ((Bool) -> Void)? = nil
    func closure() {
        work(index, cond!, cost)
        index += 1
    }
    cond = { (result: Bool) -> Void in
        guard result else { return }
        DispatchQueue.main.async(execute: closure)
    }
    DispatchQueue.main.async(execute: closure)
}
