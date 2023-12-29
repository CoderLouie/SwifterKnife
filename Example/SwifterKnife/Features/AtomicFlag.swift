//
//  AtomicFlag.swift
//  SwifterKnife
//
//  Created by liyang on 2023/12/29.
//

import Darwin


public final class AtomicFlag {
    private  var flag = atomic_flag()
    
    public func testAndSet() -> Bool {
        atomic_flag_test_and_set(&flag)
    }
    public func clear() {
        atomic_flag_clear(&flag)
    }
}
