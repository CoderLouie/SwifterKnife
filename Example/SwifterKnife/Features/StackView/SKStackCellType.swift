//
//  SKStackCellType.swift
//  SwifterKnife
//
//  Created by liyangon 2023/2/14.
//

import UIKit

public protocol SKStackCellType : AnyObject {
    var showSeparators: Bool? { get }
    var separatorInset: UIEdgeInsets? { get }
    func didSelect(by stackView: SKStackView)
}
extension SKStackCellType {
    public var showSeparators: Bool? { nil }
    public var separatorInset: UIEdgeInsets? { nil }
    public func didSelect(by stackView: SKStackView) {}
}

public protocol ManualLayoutSKStackCellType : SKStackCellType {
    func size(maxWidth: CGFloat?, maxHeight: CGFloat?) -> CGSize
}

extension SKStackCellType where Self : UIView {
    
    public var stackView: SKStackView? {
        var view = superview
        while let v = view {
            if let stackView = v as? SKStackView {
                return stackView
            }
            view = v.superview
        }
        return nil
    }
    
    public func scrollToSelf(at position: UICollectionView.ScrollPosition, animated: Bool) {
        stackView?.scroll(to: self, at: position, animated: animated)
    }
    
    public func updateLayout(animated: Bool) {
        invalidateIntrinsicContentSize()
        stackView?.updateLayout(animated: animated)
    }
    
    public func remove() {
        stackView?.remove(view: self, animated: true)
    }
}
open class SKStackCell: UIView, SKStackCellType {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    open func setup() { }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var showSeparators: Bool?
    open var shouldAnimateLayoutChanges: Bool = true
    
    open override func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
        updateLayout(animated: shouldAnimateLayoutChanges)
    }
}
