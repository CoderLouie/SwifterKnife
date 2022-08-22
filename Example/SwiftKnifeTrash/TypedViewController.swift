//
//  TypedViewController.swift
//  SwifterKnife
//
//  Created by liyang on 2022/4/13.
//

import UIKit


open class TypedViewController<T: UIView>: UIViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupViews()
    }
    
    open func setup() {}
    open func setupViews() {}
    
    open override func loadView() {
        view = T()
    }
    
    deinit {
        Console.log("\(type(of: self)) deinit")
    }
    public var rootView: T {
        view as! T
    }
}
