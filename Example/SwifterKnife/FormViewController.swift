//
//  FormViewController.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/3/9.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class TitleCell: FormTouchCell {
    override func setup() {
        super.setup()
        separatorMode = .automaticlly
        separatorInset = UIEdgeInsets(inset: 12)
        
        titleLabel = UILabel().then {
            addSubview($0)
            $0.font = .medium(18).fit
            $0.text = .random(ofLength: 7)
            $0.snp.makeConstraints { make in
                make.leading.inset(12)
                make.centerY.equalToSuperview()
            }
        }
    }
    override var intrinsicContentSize: CGSize {
        CGSize(width: -1, height: 44)
    }
    
    private(set) unowned var titleLabel: UILabel!
}

class MessageCell: TitleCell {
    override func setup() {
        super.setup()
        titleLabel.snp.remakeConstraints { make in
            make.leading.top.equalTo(12)
        }
        
        mssageLabel = UILabel().then {
            addSubview($0)
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = UIColor(gray: 41)
            $0.numberOfLines = 0
            $0.text = .random(minLength: 30, maxLength: 60)
            $0.snp.makeConstraints { make in
                make.leading.equalTo(titleLabel)
                make.top.equalTo(titleLabel.snp.bottom).offset(12)
                make.trailing.bottom.equalTo(-12)
            }
        }
    }
    
    private(set) unowned var mssageLabel: UILabel!
}

class SwitchCell: TitleCell {
    override func setup() {
        super.setup()
        control = UISwitch().then {
            addSubview($0)
            $0.addTarget(self, action: #selector(controlDidClick), for: .touchUpInside)
            $0.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalTo(-12)
            }
        }
    }
    @objc private func controlDidClick() {
        removeFromFormView(animated: true)
    }
    
    private unowned var control: UISwitch!
}

class FormViewController: BaseViewController {
    private unowned var label1: UILabel!
    override func setupViews() {
        super.setupViews()
        
        let age = 10
        let newAge = buildResult {
//            if age > 20 { 30 }
//            else { 10 }
            switch age {
            case 30: 20
            case 10..<30: 10
            default: 5
            }
        }
        
        let val: NSAttributedString = attributed {
            "Hello".rich.fgColor(.red).font(.bold(20)).build
            "\n"
            "word".build
        }
        
//        hStack {
//            label1 <=> UILabel()
//            SpaceView(height: 20)
//        }
        
        formView = FormView().then {
            $0.layoutMargins = UIEdgeInsets(top: 50, bottom: 50, left: 10, right: 10)
//            $0.contentInset = UIEdgeInsets(top: Screen.navbarH, bottom: Screen.safeAreaB, left: 0, right: 0)
//            $0.onSelectedCell = { cell in
////                Console.log("点击FormView", index)
//                cell.removeFromFormView(animated: true)
//            }
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        for _ in 0...5 {
            formView.addCell(TitleCell())
            formView.addCell(MessageCell())
            formView.addCell(SwitchCell())
        }
    }
    private unowned var formView: FormView!
}
