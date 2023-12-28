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

fileprivate final class AirPods: NSObject, NSCopying, NSMutableCopying {
    var age = 3
    private var ptr: String = ""
    override init() {
        super.init()
        ptr = String(format: "AirPods %p", self)
    }
    func copy(with zone: NSZone? = nil) -> Any {
        Console.logFunc(whose: self)
        return self
    }
    func mutableCopy(with zone: NSZone? = nil) -> Any {
        Console.logFunc(whose: self)
        return self
    }
    override var description: String {
        ptr
    }
    // ???: - 如果在deinit这样访问会崩溃
    deinit {
        // String(format: "AirPods %p", self)
        print(ptr, "deinit")
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
//        testNormalKeyPath(\.origin)
//        testNormalKeyPath(\.size)
//        testNormalKeyPath(\.origin.x)
//        testNormalKeyPath(\.size.width)
        
        
//        testKeyPath(\.bounds)
//        testKeyPath(\.bounds.origin)
//        testKeyPath(\.bounds.origin.x)
        guard let pos = event?.touchPosition else {
            return
        }
        switch pos {
        case .topLeft:
            load_weak_table()
        case .topRight:
            print(weakTable ?? "nil")
        case .bottomLeft:
            load_strong_table()
        case .bottomRight:
            print(strongTable ?? "nil")
        }
    }
    
    
    private func load_strong_table() {
        var table1 = RefArray<AirPods>.strong
        for _ in 0...2 {
            let p = AirPods()
            print("create", p)
            table1.append(p)
        }
        self.strongTable = table1
    }
    private var strongTable: RefArray<AirPods>!
    private var weakTable: RefArray<AirPods>!
    private let pods = AirPods()
    private func load_weak_table() {
//        var nums = Array(0..<8)
        // 0 1 2 3 4 5 6 7 
        // 这样会崩溃
//        nums.replaceSubrange(8..<9, with: [98, 99])
//        print(nums)
        
        
        var table1: RefArray<AirPods> = .weak
        table1.append(pods)
        let table3 = table1
        
        table1.append(pods)
        table1.append(pods)
//        table1.count = 6
        for _ in 0...2 {
            let p = AirPods()
            print("create", p)
            table1.append(p)
        }
        for (i, p) in table1.enumerated() {
            print(i, p ?? "nil")
        }
        self.weakTable = table1
//        return ()
 // [p,p,p,nil,nil,nil]
        print(table1, table1.count)
        let p = AirPods()
        print("replacement", p)
        table1.replaceSubrange(2..<5, with: [p])
//        table1.replaceSubrange(0...3, with: [p])
        print(table1, table1.count)
//        for (i, p) in table1.enumerated() {
//            print(i, p ?? "nil")
//            if i % 2 == 0 {
//                table1.remove(at: i)
//            }
//        }
        print(table1.omitAll { idx, _ in idx % 2 == 0 }, table1)
        
        var table2 = table1
        print("table2.count1", table2.count, table1.count)
        table2.count = 10
        print("table2.count2", table2.count, table1.count)
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
//        setupTextView()
//        setupButton()
        print("pods", pods)
        weakArray.append(pods)
        let p = AirPods()
        print("create", p)
        weakArray.append(p)
        print(self.weakArray.safedesc())
        for case let o? in weakArray {
            print(o)
        }
        DispatchQueue.main.after(1) {
            print(self.weakArray.safedesc())
        }
    }
    private var weakArray: WeakArray<AirPods> = .init()
    
    private func setupButton() {
        NewButton().do { this in
            this.backgroundColor = UIColor(gray: 40)
            this.setTitle("Click Me", for: .normal)
            this.setImage(UIImage(named: "checkbox_sub_off"), for: .normal)
            this.setImage(UIImage(named: "checkbox_sub_on"), for: .selected)
            this.imagePosition = .left
            this.addBorder(color: .orange, radius: 0, width: 1)
            this.contentEdgeInsets = .inset(10)
            this.spacing = 10
            
            this.addTouchUpInsideClosure { sender, event in
                print("1")
            }
            this.addTouchUpInsideClosure { sender, event in
                print("2")
            }
            this.setTouchUpInsideClosure { sender, event in
                print("3", event.touchPosition)
                sender.isSelected.toggle()
            }
            
            view.addSubview(this)
            this.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
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
