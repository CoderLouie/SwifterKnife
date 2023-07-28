//
//  StatementTest.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/7/28.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import SwifterKnife

func statement_test_entry() {
    
        var a = 10, b = 3
        until(a < b, a - 2 < b) {
            a -= 1
            print(a, b)
        }
//            let point = 70
//            if_(point >= 90, point < 100) {
//
//            }
//            let val: Any = 70
//            let val2 = if_some(val as? Int, and: point > 80) { v in
//                return v + 10
//            }
    //        let age = 9
    //        switch age {
    //        case { $0 > 10 }:
    //            print("greather than 10")
    //        default:
    //            break
    //        }
}
