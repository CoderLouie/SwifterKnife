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

fileprivate extension UILabel {
    var config1: Void {
        textColor = .black
        font = .regular(16)
        text = "3 day free"
        addBorder(color: .orange, radius: 0, width: 1)
        return ()
    }
}

class TestUIVC: BaseViewController {
    
    private func testOfView(_ view: UIView) {
        let v1 = view.contentHuggingPriority(for: .vertical).rawValue
        let h1 = view.contentHuggingPriority(for: .horizontal).rawValue
        let v2 = view.contentCompressionResistancePriority(for: .vertical).rawValue
        let h2 = view.contentCompressionResistancePriority(for: .horizontal).rawValue
        
        print("\(type(of: view))", v1, h1, v2, h2)
    }
    override func setupViews() {
        super.setupViews()
        let views: [UIView] = [UILabel(), UIView(), UIImageView(), UIButton()]
        views.forEach { testOfView($0) }
        setupImageLabel()
    }
    private func setupImageLabel() {
        view.backgroundColor = UIColor(gray: 40)
        ATLabelImage().do { this in
            this.view1.do {
                $0.textColor = .white
                $0.font = .regular(16)
                $0.text = "3 day free trial then 28/year, cancel anytime"
                $0.addBorder(color: .orange, radius: 0, width: 1)
                $0.snp.contentCompressionResistanceHorizontalPriority = 800
            }
            this.view2.do {
                $0.image = UIImage(named: "checkbox_sub_off")
                $0.addBorder(color: .orange, radius: 0, width: 1)
            }
            this.view1Position = .left
//            this.horizontalAlignment = .left
//            this.verticalAlignment = .bottom
            this.addBorder(color: .orange, radius: 0, width: 1)
            this.edgeInsets = .inset(10)
//            this.view1Position = .top
            this.spacing = 10
            view.addSubview(this)
            this.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(150)
//                make.height.equalTo(300)
            }
        }
    }
    
    private func setupLabels() {
        
        ATLabels().do { this in
//            this.view1.do(\.config1)
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
