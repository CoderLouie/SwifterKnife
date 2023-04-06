//
//  HomeViewController.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2022/11/20.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit


fileprivate class BottomBar: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setup() {
        backgroundColor = .cyan
        layoutMargins = UIEdgeInsets(top: 8, bottom: 8, left: 20, right: 55)
        
        let redView = UIView().then {
            addSubview($0)
            $0.backgroundColor = .red
            $0.snp.makeConstraints { make in
//                make.centerX.equalTo(0)
//                make.trailing.equalTo(snp.trailingMargin)
//                make.top.equalTo(snp.topMargin)
//                make.bottom.equalTo(snp.bottomMargin)
//                make.trailing.top.bottom.equalTo(snp.directionalMargins)
                make.centerX.top.bottom.equalToSuperviewMargin()
//                make.horizontal.inset(30)
//                make.left.top.bottom.equalTo(snp.margins)
                make.width.equalTo(100)
//                make.centerX.equalTo(snp.centerXWithinMargins)
//                make.centerX.equalTo(10)
//                make.centerX.inset(10)
//                make.centerX.offset(10)
                make.height.equalTo(30)
            }
        }
    }
}

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

extension UIView {
    static var canvasView: UIView? {
        let field = UITextField()
        field.isSecureTextEntry = true
        let target: UIView? = field.searchInLevelOrder { view, _ in
            let typename = String(describing: type(of: view)) 
            return typename.contains("CanvasView")
        }
        target?.removeSubviews()
        target?.isUserInteractionEnabled = true
        return target
    }
}

class HomeViewController: BaseViewController {
    
    override func setupViews() {
        super.setupViews()
        title = "Home"
        view.keyboardKeepSpaceClosure = { CGFloat($0.tag) }
//        view.keyboardKeepSpace = 20
        UITextField().do {
            $0.backgroundColor = .lightGray
            $0.isSecureTextEntry = true
            $0.placeholder = "请输入密码1"
            $0.tag = 40
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.trailing.inset(30)
                make.bottom.equalTo(-100)
            }
        }
        UITextField().do {
            $0.backgroundColor = .lightGray
            $0.isSecureTextEntry = true
            $0.placeholder = "请输入密码1"
            $0.tag = 10
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.trailing.inset(30)
                make.bottom.equalTo(-160)
            }
        }
        
        BottomBar().do {
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.trailing.equalTo(0)
//                make.top.equalTo(view.snp.topMargin)
//                make.top.equalTo(0)
                make.bottom.equalTo(0)
            }
        }
          
        
//        let cell = FormCell().then {
//            $0.backgroundColor = .groupTableViewBackground
//            view.addSubview($0)
//            $0.snp.makeConstraints { make in
//                make.center.equalToSuperview()
//                make.width.height.equalTo(100)
//            }
//        }
//        cell.setHidden(true, animatied: true)
        
//        label = UILabel().then {
//            $0.text = "touchesBegantouchesBegantouchesBegantouchesBegantouchesBegantouchesBegan"
//            $0.numberOfLines = 0
//            view.addSubview($0)
//            $0.snp.makeConstraints { make in
//                make.leading.trailing.inset(50)
//                make.centerY.equalToSuperview()
//            }
//        }
        
        greenView = UIView().then {
            $0.backgroundColor = .green
            $0.frame = CGRect(x: 20, y: 100, width: 50, height: 50)
            view.addSubview($0)
        }
        redView = UIView().then {
            $0.backgroundColor = .red
            $0.frame = CGRect(x: 70, y: 150, width: 250, height: 250)
            view.addSubview($0)
        }
        blueView = UIView().then {
            $0.backgroundColor = .cyan
            $0.frame = CGRect(x: 50, y: 50, width: 100, height: 100)
            redView.addSubview($0)
        }
    }
//    private unowned var label: UILabel!
    private unowned var redView: UIView!
    private unowned var greenView: UIView!
    private unowned var blueView: UIView!
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        return ()
        
        print(view.convert(blueView.frame, from: redView))
        print(redView.convert(blueView.frame, to: view))
        print(blueView.convert(blueView.bounds, to: view))
        
        
        print(blueView.convert(CGRect(x: 50, y: 50, width: 100, height: 100), to: greenView))
        print(blueView.convert(blueView.frame, to: greenView))
//        let width = view.bounds.width - 60
//        print(label.frame, label.fittingSize(withRequiredWidth: width), label.compressedSize)
        
        
        
//        view.resignFirstResponder()
//        view.endEditing(true)
//        let vc = DebugViewController()
//        let vc = FormViewController()
////        let vc = TimerViewController()
//        navigationController?.pushViewController(vc, animated: true)
    }
}
