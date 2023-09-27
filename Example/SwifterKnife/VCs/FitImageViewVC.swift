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
            newBtn.setTitle("free trial", for: .normal)
            pairView.view1.image = .fileNamed("banner_home_1aging@2x")
        } else {
            newBtn.setTitle("3 day free trial then 28/year, cancel anytime", for: .normal)
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
        
        
        let bgView = UIView().then {
            $0.backgroundColor = UIColor(gray: 40, alpha: 0.5)
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
                make.top.equalTo(pairView.snp.bottom).offset(10)
            }
        }
        newBtn = NewButton().then {
//            $0.setTitle("3 day free trial then 28/year, cancel anytime", for: .normal)
            $0.setTitle("3 day", for: .normal)
            $0.titleLabel?.font = .semibold(17).fit
            $0.titleLabel?.addBorder(color: .orange, radius: 0, width: 1)
//            $0.titleLabel?.numberOfLines = 0
            
            $0.setImage(UIImage(named: "checkbox_sub_off"), for: .normal)
            $0.setImage(UIImage(named: "checkbox_sub_on"), for: .selected)
//            $0.centerTextAndImage(imageAboveText: true, spacing: 10)

            $0.imageView?.addBorder(color: .orange, radius: 0, width: 1)
            $0.imagePosition = .top
            
            $0.addBorder(color: .orange, radius: 0, width: 1)
            $0.spacing = 10
            $0.contentVerticalAlignment = .fill
            $0.contentHorizontalAlignment = .fill
            $0.contentEdgeInsets = .inset(10)
            bgView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(10)
                make.width.equalTo(200)
//                make.height.equalTo(40)
//                make.width.equalTo(100)
                make.height.equalTo(100)
            }
        }
    }
    private unowned var newBtn: NewButton!
    private unowned var pairView: PairView<FitVImageView, UILabel>!
}
