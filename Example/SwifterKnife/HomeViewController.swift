//
//  HomeViewController.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2022/11/20.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

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


class HomeViewController: BaseViewController {
    override func setupViews() {
        super.setupViews()
        title = "Home"
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let a = 10
        
//        if a > 5, a < 10 {
//
//        }
        
        let vc = DebugViewController()
//        let vc = TimerViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
