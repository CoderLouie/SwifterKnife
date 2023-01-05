//
//  ViewAddition+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2022/12/28.
//

import UIKit

public extension UIVisualEffectView {
    var bgColor: UIColor? {
        get {
            guard subviews.count > 1 else { return nil }
            return subviews[1].backgroundColor
        }
        set {
            guard subviews.count > 1 else { return }
            subviews[1].backgroundColor = newValue
        }
    }
}

extension ViewAddition where Self: UIView {
    @discardableResult
    public func blur(_ style: UIBlurEffect.Style) -> UIVisualEffectView {
        let view = _visualEffectView
        view.effect = UIBlurEffect(style: style)
        return view
    }
    
    @discardableResult
    public func vibrancy(_ style: UIBlurEffect.Style) -> UIVisualEffectView {
        let view = _visualEffectView
        let blurEffect = UIBlurEffect(style: style)
        view.effect = UIVibrancyEffect(blurEffect: blurEffect)
        return view
    }
    
    private var _visualEffectView: UIVisualEffectView {
        subviews.first {
            $0 is UIVisualEffectView
        } as? UIVisualEffectView ?? {
            let view = UIVisualEffectView()
            addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            return view
        }()
    }
}
