//
//  TimerViewController.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/1/31.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class TimerViewController: BaseViewController {
    var timer: Timer?
    var intervals: [TimeInterval] = []
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }
//    deinit {
//        print("TimerViewController deinit")
//    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { _ in
            self.intervals.append(ProcessInfo.processInfo.systemUptime)
            if self.intervals.count == 5 {
                print(self.intervals)
            }
            print("tick", self.timer as Any)
        })
    }
}
