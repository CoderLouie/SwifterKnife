//
//  CodableVC.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/9/14.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import SwifterKnife

fileprivate class ZPerson: Encodable, CodingKeyMap, DataEncodable {
    private(set) var age = 20
    private(set) var name = "xiaohua"
    static var keyMapping: [KeyMap<ZPerson>] {
        [KeyMap(ref: \.age, to: "age"),
         KeyMap(ref: \.name, to: "name")]
    }
}
fileprivate class ZStudent: ZPerson {
    private(set) var score = 80
    static var selfKeyMapping: [KeyMap<ZStudent>] {
        [KeyMap(ref: \.score, to: "score")]
    }
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        try encode(to: encoder, with: Self.selfKeyMapping)
    }
}


class CodableVC: BaseViewController {
    
    override func setupViews() {
        super.setupViews()
        
        observeDeinit(for: self) {
            print("observeDeinit1 for")
        }
        observeDeinit(for: self) {
            print("observeDeinit2 for")
        }
//        let stu = ZStudent()
//
//        let jsonStr = stu.toJSON().jsonString()
//        print(jsonStr ?? "nil")
    }
}
