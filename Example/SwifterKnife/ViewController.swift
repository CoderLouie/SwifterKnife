//
//  ViewController.swift
//  SwifterKnife
//
//  Created by liyang on 10/25/2021.
//  Copyright (c) 2021 liyang. All rights reserved.
//

import UIKit
import SwifterKnife

class ViewController: UIViewController {
 
    private lazy var subView = Lazy {
        UIView().then {
            self.view.addSubview($0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Console.log("hello")
        Console.logFunc()
        Console.trace("world")
        
        print(subView.isInitialized)
        print(subView.wrapped)
        print(subView.isInitialized)
        
        let stack: Queue<Int> = [1, 2, 3, 4]
        for val in stack {
            print(val)
            if val == 2 {
//                stack.push(10)
                stack.pollFirst()
            }
        }
 
//        let val = 5.fit
        print(5.fit, 5.fitH)
        
        let res = stack.map { $0 + 2 }
        print(res)
        
        print(Device.current)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

