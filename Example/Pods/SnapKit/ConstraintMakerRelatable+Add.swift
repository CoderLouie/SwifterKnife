//
//  ConstraintMakerRelatable+Add.swift
//  SnapKit
//
//  Created by liyang on 11/15/2021.
//  Copyright (c) 2021 gomo. All rights reserved.
//

import Foundation
import SnapKit

/*
 
打开注释后，把此文件添加到SnapKit源码中去，方便添加宽高约束
 
没有此扩展文件，要实现宽高约束，需要
 
UILabel().do { label in
    label.backgroundColor = .darkGray
    view.addSubview(label)
    label.snp.makeConstraints { make in
        make.width.equalTo(100)
        make.height.equalTo(label.snp.width).multipliedBy(0.5)
        make.centerX.equalToSuperview()
        make.top.equalTo(100)
    }
}
 
添加此扩展文件后，只需要
UILabel().do {
    $0.backgroundColor = .darkGray
    view.addSubview($0)
    $0.snp.makeConstraints { make in
        make.width.equalTo(100)
        make.height.equalToSelf(\.width).multipliedBy(0.5)
        make.centerX.equalToSuperview()
        make.top.equalTo(100)
    }
}
 
 */

 
extension LayoutConstraintItem {
    
    internal var view: ConstraintView? {
        if let view = self as? ConstraintView {
            return view
        }
        if #available(iOS 9.0, OSX 10.11, *), let guide = self as? ConstraintLayoutGuide {
            return guide.owningView
        }
        return nil
    }
}

public extension ConstraintMakerRelatable {
    
    @discardableResult
    func equalToSelf(_ keyPath: KeyPath<ConstraintViewDSL, ConstraintItem>, _ file: String = #file, _ line: UInt = #line) -> ConstraintMakerEditable {
        guard let view = self.description.item.view else {
            fatalError("Expected view but found nil when attempting make constraint `equalToSelf`.")
        }
        return equalTo(view.snp[keyPath: keyPath], file, line)
    }
    @discardableResult
    func equalToSelfWidth(_ file: String = #file, _ line: UInt = #line) -> ConstraintMakerEditable {
        return equalToSelf(\.width, file, line)
    }
    @discardableResult
    func equalToSelfHeight(_ file: String = #file, _ line: UInt = #line) -> ConstraintMakerEditable {
        return equalToSelf(\.height, file, line)
    }
}
