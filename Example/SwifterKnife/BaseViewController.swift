//
//  BaseViewController.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/7/28.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
    }
    func setupViews() {
    }
    deinit {
        Console.logFunc(whose: self)
    }
}
