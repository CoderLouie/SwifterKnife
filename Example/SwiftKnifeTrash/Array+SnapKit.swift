//
//  Array+SnapKit.swift
//  SwifterKnife
//
//  Created by 李阳 on 2022/8/12.
//

import UIKit
import SnapKit

extension Array {
    func makeConstraints(
        to superView: UIView,
        tramsform: (_ index: Int,
                    _ item: Element) -> UIView?,
        first: (_ make: ConstraintMaker,
                _ superView: UIView) -> Void,
        succeed: (_ make: ConstraintMaker,
                  _ prevView: UIView) -> Void,
        last: (_ make: ConstraintMaker,
                _ superView: UIView) -> Void) {
        guard !isEmpty else { return }
        var prevView: UIView?
        for (i, item) in enumerated() {
            guard let view = tramsform(i, item) else { continue }
            superView.addSubview(view)
            view.snp.makeConstraints { make in
                if let prev = prevView {
                    succeed(make, prev)
                } else {
                    first(make, superView)
                }
            }
            prevView = view
        }
        prevView?.snp.makeConstraints { make in
            last(make, superView)
        }
    }
}
