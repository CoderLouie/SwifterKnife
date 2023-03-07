//
//  HomeViewController.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2022/11/20.
//  Copyright © 2022 CocoaPods. All rights reserved.
//


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
        
        BottomBar().do {
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.trailing.equalTo(0)
//                make.top.equalTo(view.snp.topMargin)
//                make.top.equalTo(0)
                make.bottom.equalTo(0)
            }
        }
    }
    deinit {
        Console.logFunc(whose: self)
    }
}


class HomeViewController: BaseViewController {
    override func setupViews() {
        super.setupViews()
        title = "Home"
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let a = 10
        
//        if a > 5, a < 10 {
//
//        }
        
//        let vc = DebugViewController()
////        let vc = TimerViewController()
//        navigationController?.pushViewController(vc, animated: true)
    }
}
