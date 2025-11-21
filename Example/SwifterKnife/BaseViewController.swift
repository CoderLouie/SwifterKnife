//
//  BaseViewController.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/7/28.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import SwifterKnife

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
    }
    func setupViews() {
        let s = CGRect.zero
        let f = s.sfloor
        
        var weakMap = WeakDictionary<String, UIViewController>()
        
        for (k, v) in weakMap.compacted {
            
        }
        
        weakMap["1"] = self
        
        let vc = weakMap["1"]
    }
    deinit {
        Console.logFunc(whose: self)
    }
}

import SnapKit
extension ConstraintMaker {
    func horizontalSpace(_ space: CGFloat) {
        leading.equalTo(space)
        trailing.equalTo(-space)
    }
    func verticalSpace(_ space: CGFloat) {
        top.equalTo(space)
        bottom.equalTo(-space)
    }
}
