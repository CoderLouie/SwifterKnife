//
//  UIView+Layout.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit
import SnapKit

public extension UIView {
    func embedInHorizontallyScrollView(
        _ contentConfig: (FlexHView) -> Void,
        _ scrollConfig: ((UIScrollView) -> Void)? = nil) -> FlexHView {
        
        let box = UIScrollView().then { s in
            s.showsVerticalScrollIndicator = false
            s.showsHorizontalScrollIndicator = false
            s.backgroundColor = .clear
            scrollConfig?(s)
            addSubview(s)
            s.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        return FlexHView().then {
            contentConfig($0)
            box.addSubview($0)
            $0.snp.makeConstraints { make in
                make.edges.equalTo(box)
                make.height.equalTo(self.snp.height)
            }
        }
    }
    func embedInverticallyScrollView() {
        
    }
}
