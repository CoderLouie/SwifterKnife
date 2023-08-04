//
//  FitImageViewVC.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/7/28.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import SwifterKnife

fileprivate extension NSNotification.Name {
    static var didFitImage: NSNotification.Name {
        .init(rawValue: "didFitImage")
    }
}

class FitImageViewVC: BaseViewController {
    private var flag = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        flag.toggle()
        if flag {
            pairView.view1.image = .fileNamed("banner_home_1aging@2x")
        } else {
            pairView.view1.image = .fileNamed("h2000")
        }
        Notify.post(name: .didFitImage, userInfo: ["flag": flag])
        UIView.animate(withDuration: 0.25) {
            self.pairView.layoutIfNeeded()
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        Notify.addObserver(self, name: .didFitImage) { obj, no in
            print("didFitImage", (no.userInfo?["flag"] as? Bool) ??? "nil")
        }
        
        pairView = .init().then {
            $0.spacing = 10
            $0.alignment = .fill
            
            $0.view1.image = .fileNamed("h2000")
            $0.view2.do {
                $0.numberOfLines = 0
                $0.font = .regular(18)
                $0.textColor = .black
                $0.textAlignment = .center
                $0.text = "RAW photo, a 22-year-old-girl, upper body, selfie in a car, blue hoodie, (raecmbr-2650:0.9), (r4ec4mbr4:0.95), (1girl)"
            }
            
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.equalTo(30)
                make.trailing.equalTo(-30)
                make.centerY.equalToSuperview()
            }
        }
    }
    private unowned var pairView: PairView<FitVImageView, UILabel>!
}
