//
//  DictationVC.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/8/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import SwifterKnife
import SnapKit

class MyTextView: UITextView {
    private var lastInputMode: String?
    private(set) var isDictationRunning = false {
        didSet {
            if isDictationRunning {
                print("开始语音输入")
            } else {
                print("停止语音输入", text ?? "nil")
            }
        }
    }
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(textInputModeDidChange), name: UITextInputMode.currentInputModeDidChangeNotification, object: nil)
    }
    @objc private func textInputModeDidChange() {
        guard let inputMode = textInputMode?.primaryLanguage else {
            return
        }
        print("textInputModeDidChange", inputMode)
        if inputMode == "dictation", lastInputMode != inputMode {
            isDictationRunning = true
        }
        lastInputMode = inputMode
    }
    override func dictationRecordingDidEnd() {
//        super.dictationRecordingDidEnd()
        Console.logFunc(whose: self)
        isDictationRunning = false
    }
    override func dictationRecognitionFailed() {
//        super.dictationRecognitionFailed()
        Console.logFunc(whose: self)
        isDictationRunning = false
    }
}

import Lottie
class DictationVC: BaseViewController {
    
    override func setupViews() {
        super.setupViews()
        title = "Dictation"
        
        MyTextView().do {
            $0.backgroundColor = .lightGray
            $0.text = "hello"
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.trailing.inset(30)
                make.top.equalTo(Screen.navbarH + 30)
                make.height.equalTo(80)
            }
        }
        
        let frog = LottieAnimationView.frog.then {
            $0.play()
            $0.frame = CGRect(x: 30, y: 300, width: 240, height: 240)
        }
        view.layer.addSublayer(frog.layer)
    }
}
