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


public extension PartialKeyPath {
    /// The name of the key path.
    var stringValue: String {
        if let string = self._kvcKeyPathString {
            return string
        }
        let mirr = Mirror(reflecting: self)
        let me = String(describing: self)
        let rootName = String(describing: Root.self)
        let removingRootName = me.components(separatedBy: rootName)
        var keyPathValue = removingRootName.last ?? ""
        if keyPathValue.first == "." { keyPathValue.removeFirst() }
        return keyPathValue
    }
}

class TestUIVC: BaseViewController {
    
    private func testKeyPath<T>(_ keyPath: KeyPath<CALayer, T>) {
//        print(#keyPath(keyPath))
//        print(keyPath._kvcKeyPathString ??? "nil") 
        print(keyPath.animKeyPath ??? "exten nil")
//        print(keyPath.keyPath)
//        let expression = NSExpression(forKeyPath: keyPath)
//        print(expression.keyPath)
//        print("")
    }
    private func testNormalKeyPath<T>(_ keyPath: KeyPath<CGRect, T>) {
        print(keyPath.stringValue)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print(#keyPath(CALayer.bounds.origin.x))
        testNormalKeyPath(\.origin)
        testNormalKeyPath(\.size)
        testNormalKeyPath(\.origin.x)
        testNormalKeyPath(\.size.width)
//        testKeyPath(\.bounds)
//        testKeyPath(\.bounds.origin)
//        testKeyPath(\.bounds.origin.x)
    }
    
    private func testOfView(_ view: UIView) {
        let v1 = view.contentHuggingPriority(for: .vertical).rawValue
        let h1 = view.contentHuggingPriority(for: .horizontal).rawValue
        let v2 = view.contentCompressionResistancePriority(for: .vertical).rawValue
        let h2 = view.contentCompressionResistancePriority(for: .horizontal).rawValue
        
        print("\(type(of: view))", v1, h1, v2, h2)
    }
    override func setupViews() {
        super.setupViews()
//        let views: [UIView] = [UILabel(), UIView(), UIImageView(), UIButton()]
//        views.forEach { testOfView($0) }
//        setupImageLabel()
        setupTextView()
    }
    private func setupTextView() {
        PlaceholderTextView().do {
            $0.maxLength = 3
            $0.onTextDidChange = { 
                print($0.text ?? "nil")
            }
            view.addSubview($0)
            $0.addBorder(color: .orange, radius: 0, width: 1)
            $0.snp.makeConstraints { make in
                make.horizontalSpace(30)
                make.height.equalTo(100)
                make.centerY.equalToSuperview()
            }
        }
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
//            this.axis = .horizontal
//            this.distribution = .fill
//            this.horizontalAlignment = .left
//            this.verticalAlignment = .bottom
            this.addBorder(color: .orange, radius: 0, width: 1)
//            this.edgeInsets = .inset(10)
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
