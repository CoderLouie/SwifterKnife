//
//  UITableView+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit
import SnapKit

public extension UITableView {
    func buildTableHeaderView(_ builder: (FlexHView) -> Void) {
        let header = FlexHView()
        builder(header)
        tableHeaderView = header
        header.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
        header.layoutIfNeeded()
    }
}
