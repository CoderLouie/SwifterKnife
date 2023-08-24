//
//  TestUIVC.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/8/24.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import SwifterKnife

class TestUIVC: BaseViewController {
    
    override func setupViews() {
        super.setupViews()
        ATLabels().do { this in
            this.view1.do {
                $0.textColor = .black
                $0.font = .regular(16)
//                $0.text = "3 day free trial then 28/year, cancel anytime"
                
                $0.text = "3 day free"
                $0.addBorder(color: .orange, radius: 0, width: 1)
//                $0.numberOfLines = 0
            }
            this.view2.do {
                $0.textColor = .black
                $0.font = .bold(18)
//                $0.numberOfLines = 0
//                $0.text = "free trial"
                $0.text = "$0.titleLabel?.addBorder(color: .orange, radius: 0, width: 1)"
                $0.addBorder(color: .orange, radius: 0, width: 1)
            }
            this.horizontalAlignment = .left
            this.addBorder(color: .orange, radius: 0, width: 1)
            this.edgeInsets = .inset(10)
//            this.view1Position = .top
            this.spacing = 10
            view.addSubview(this)
            this.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(150)
            }
        }
    }
}
