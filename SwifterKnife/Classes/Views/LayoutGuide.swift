//  LayoutGuide.swift
//  SwifterKnife
//
//  Created by liyang on 2022/5/24.
//

import UIKit
import SnapKit

public class LayoutGuide: UILayoutGuide {
    public enum Alignment {
        /// 左/上
        case start
        /// 中
        case center
        /// 右/下
        case end
    }
    
    public let aligment: Alignment
    fileprivate var arrangedViews: [UIView] = []
    
    private override init() {
        fatalError("please use init(owningView:aligment:) initialize method")
    }
    
    public init(owningView view: UIView,
                aligment: Alignment = .center) {
        self.aligment = aligment
        super.init()
        view.addLayoutGuide(self)
        self.snp.makeConstraints { make in
            make.width.height.equalTo(1).priority(2)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addSubview(_ view: UIView) {
        owningView!.addSubview(view)
        arrangedViews.append(view)
        makeConstraints(for: view)
    }
    public func makeHorizontalSizeToFit() { }
    public func makeVerticalSizeToFit() { }
    public func makeSizeToFit() {
        makeHorizontalSizeToFit()
        makeVerticalSizeToFit()
    }
    fileprivate func makeConstraints(for subview: UIView) { }
}

public final class HLayoutGuide: LayoutGuide {
    fileprivate override func makeConstraints(for subview: UIView) {
        subview.snp.makeConstraints { make in
            switch aligment {
            case .start:
                make.top.equalTo(self)
            case .center:
                make.centerY.equalTo(self)
            case .end:
                make.bottom.equalTo(self)
            }
        }
    }
    public override func makeHorizontalSizeToFit() {
        if let view = arrangedViews.first {
            view.snp.makeConstraints { make in
                make.leading.equalTo(self)
            }
        }
        if let view = arrangedViews.last {
            view.snp.makeConstraints { make in
                make.trailing.equalTo(self)
            }
        }
    }
    public override func makeVerticalSizeToFit() {
        var height: CGFloat = 0
        for view in arrangedViews {
            let h = view.intrinsicContentSize.height
            if h > height { height = h }
        }
        guard height > 0 else { return }
        self.snp.updateConstraints { make in
            make.height.equalTo(ceil(height))
        } 
    }
}

public final class VLayoutGuide: LayoutGuide {
    fileprivate override func makeConstraints(for subview: UIView) {
        subview.snp.makeConstraints { make in
            switch aligment {
            case .start:
                make.leading.equalTo(self)
            case .center:
                make.centerX.equalTo(self)
            case .end:
                make.trailing.equalTo(self)
            }
        }
    }
    
    public override func makeHorizontalSizeToFit() {
        var width: CGFloat = 0
        for view in arrangedViews {
            let w = view.intrinsicContentSize.width
            if w > width { width = w }
        }
        guard width > 0 else { return }
        self.snp.updateConstraints { make in
            make.width.equalTo(ceil(width))
        }
    }
    public override func makeVerticalSizeToFit() {
        if let view = arrangedViews.first {
            view.snp.makeConstraints { make in
                make.top.equalTo(self)
            }
        }
        if let view = arrangedViews.last {
            view.snp.makeConstraints { make in
                make.bottom.equalTo(self)
            }
        }
    }
}


public extension UIScrollView {
    @available(iOS 11.0, *)
    func setScrollDirection(_ direction: UIScrollView.ScrollDirection) {
        contentLayoutGuide.snp.makeConstraints { make in 
            switch direction {
            case .horizontal:
                make.height.equalTo(self)
            case .vertical:
                make.width.equalTo(self)
            }
        }
    }
}
