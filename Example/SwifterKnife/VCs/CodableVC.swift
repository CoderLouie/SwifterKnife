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



class CheckoutBox: NewButton {
    override func setup() {
        super.setup()
        setImage(UIImage(named: "checkbox_sub_off"), for: .normal)
        setImage(UIImage(named: "checkbox_sub_on"), for: .selected)
        backgroundColor = .orange
        imagePosition = .right
        spacing = 4
        contentHorizontalAlignment = .fill
        setTitleColor(.black, for: .normal)
        contentEdgeInsets = UIEdgeInsets(horizontal: 18, vertical: 10)
//        addTarget(self, action: #selector(onClick), for: .touchUpInside)
    }
//    @objc private func onClick() {
//        isSelected.toggle()
//    }
    deinit {
        print("checkbox with", title(for: .normal) ?? "empty title", "deinit")
    }
}

//private var designSizeKey: Int8 = 0
//extension UIView {
//    open override class func load() {
//        DispatchQueue.once {
//            self.at_swizzleInstanceMethod(#selector(getter: intrinsicContentSize), with: <#T##Selector#>)
//        }
//    }
//    var designSize: CGSize {
//        get {
//           objc_getAssociatedObject(self, &designSizeKey) as? CGSize ?? CGSize(width: -1, height: -1)
//        }
//        set {
//            objc_setAssociatedObject(self, &designSizeKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
//        }
//    }
//    
////    @_dynamicReplacement(for: intrinsicContentSize)
//    var at_intrinsicContentSize: CGSize {
//        var size = self.intrinsicContentSize
//        let insSize = designSize
//        if insSize.width > 0 {
//            size.width = insSize.width
//        }
//        if insSize.height > 0 {
//            size.height = insSize.height
//        }
//        return size
//    }
//}

fileprivate extension RadioCross.Name {
    static var codable: Self {
        .init(rawValue: "codable")
    }
}

class CodableVC: BaseViewController {
    
    
    @SwiftyCachedDefaults(key: "iso_date_runtimeRef")
    private var age: Int?
    
    enum Gender: Int, DefaultsSerializable {
        case man, woman
    }
    
    @SwiftyDefaults(key: "at_gender")
    private var gender: Gender?
    
    @StashClosure
    private var closure: (() -> Void)?
    private func test_codable() {
        
        let a = self.gender
//        self.age = nil
//        print(self.age ??? "nil")
//        self.age = 10
//        print(self.age ??? "nil")
        
        print("gender", gender ??? "nil")
//        self.gender = .man
//        print("gender", gender ??? "nil")
        
//        observeDeinit(for: self) {
//            print("observeDeinit1 for")
//        }
//        observeDeinit(for: self) {
//            print("observeDeinit2 for")
//        }

    }
//    private var radioGroup: RadioGroup {
//        RadioGroup[.codable]
//    }
    
    private var stu_index = 0
    private var score: Int {
        get { Defaults["stu_score_\(stu_index)"] ?? 0 }
        set { Defaults["stu_score_\(stu_index)"] = newValue }
    }
    private func test_codable1() {
        print(score) // 0
        score = 90
        print(score)// 90
        
        stu_index = 1
        print(score) // 0
        score = 70
        print(score)// 70
        
        stu_index = 0
        print(score)// 90
    }
    
    private var radioGroup = RadioGroup()
    private let group1 = "group1"
    override func setupViews() {
        super.setupViews()
        
//        setupColorView()
//        setRadioGroupView()
        
    }
    @objc private func tapBlueView() {
//        let pair = (1, "")
//        print(type(of: pair))
        closure?()
//        $closure.reset()
        _closure.reset()
        guard let v = blueView else { return }
        DispatchQueue.main.async(execute: weakify {
            print($0)
        })
        v.bounds.origin.assign {
            if $0.x == 50 { $0.x = 0; $0.y = 0 }
            else { $0.x = 50; $0.y = 50 }
        }
        /*
         https://juejin.cn/post/7285290243297689652
         https://www.jianshu.com/p/7e3ed50b39a1
         更改蓝色视图的bounds对自身没有影响，只是改变了蓝色视图的坐标系
         (50, 50)则是以前原点的坐上50距离处，所以黄色视图变成在以前原点处
         */
//        v.bounds.origin.assign {
//            if $0.x == 50 { return .zero }
//            return CGPoint(x: 50, y: 50)
//        }
//        v.isHidden.toggle()
    }
    private var blueView: UIView?
    private func setupColorView() {
        closure = {
            print("callback 1")
        }
        closure = {
            print("callback 2")
        }
        closure = {
            print("callback 3")
        }
        
        blueView = UIView().then {
            $0.frame = CGRect(x: 100, y: 100, width: 200, height: 200)
            $0.backgroundColor = .blue
            view.addSubview($0)
            $0.addTap(target: self, action: #selector(tapBlueView))
        }
        UIView().do {
            $0.backgroundColor = .yellow
            $0.frame = CGRect(x: 50, y: 50, width: 100, height: 100)
            blueView?.addSubview($0)
        }
    }
    private func setRadioGroupView() {
        let stackView = UIStackView.vertical(spacing: 15, alignment: .fill) {
            ["Apple", "Banana", "Origin", "Fruit"].map { title in
                CheckoutBox().then {
                    $0.setTitle(title, for: .normal)
                    let suc1 = radioGroup.addControl($0)
                    let suc2 = radioGroup.addControl($0)
                    print("addcontrol \(title)", suc1, suc2)
                }
            }
        }.then {
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(200)
            }
        }
//        stackView.customSpacing(10, at: 0)
//        stackView.customSpacing(20, at: 1)
//        stackView.customSpacing(30, at: 2)
//        stackView.arrangedSubviews[1].isHidden = true
//        // 10.0 20.0 30.0 3.4028234663852886e+38 3.4028234663852886e+38 1.1754943508222875e-38
//        print(stackView[spacingIndex: 0], stackView[spacingIndex: 1],
//              stackView[spacingIndex: 2], stackView[spacingIndex: 3], UIStackView.spacingUseDefault, UIStackView.spacingUseSystem)
        
        UIView().do {
            $0.backgroundColor = .cyan
            $0.desginSize = CGSize(width: 100, height: 50)
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(stackView.snp.top).offset(-30)
            }
        }
    }
    
    private func peekSelectedControl() {
        guard let button = radioGroup.selectedControl as? UIButton else {
            print("selected nil")
            return
        }
        print("selected", button.title(for: .normal) ?? "empty title", button.tag)
    }
//    dynamic func run(a: String) {
//        print("run", a)
//    }
//    dynamic var a = 1
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        run_new(a: "param")
//        run(a: "param")
        test_codable1()
    }
}
//extension CodableVC {
//    @_dynamicReplacement(for: run(a:))
//    func run_new(a: String) {
//        print("run_new", a)
//        print(self.a)
//        run(a: a)
//    }
//
//    @_dynamicReplacement(for: a)
//    var b: Int {
//        a = a * 10
//        return a
//    }
//}
