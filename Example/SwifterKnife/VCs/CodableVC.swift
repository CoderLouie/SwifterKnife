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

class CodableVC: BaseViewController {
    
    
    @SwiftyCachedDefaults(key: "iso_date_runtimeRef")
    private var age: Int?
    
    enum Gender: Int, DefaultsSerializable {
        case man, woman
    }
    
    @SwiftyDefaults(key: "at_gender")
    private var gender: Gender?
    
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
//        let stu = ZStudent()
//
//        let jsonStr = stu.toJSON().jsonString()
//        print(jsonStr ?? "nil")
    }
    private let group1 = "group1"
    override func setupViews() {
        super.setupViews()
        
        UIStackView.vertical(spacing: 15, alignment: .fill) {
            ["Apple", "Banana", "Origin", "Fruit"].map { title in
                CheckoutBox().then {
                    $0.setTitle(title, for: .normal)
                    RadioGroup.shared.addControl($0)
                }
            }
        }.do {
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(200)
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let button = RadioGroup.shared.selectedControl as? UIButton else {
            print("selected nil")
            return
        }
        print("selected", button.title(for: .normal) ?? "empty title")
    }
}
