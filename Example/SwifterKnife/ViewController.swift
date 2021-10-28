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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Console.log("hello")
        Console.logFunc()
        Console.trace("world")
        
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

