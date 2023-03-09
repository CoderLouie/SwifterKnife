//
//  FormViewCell.swift
//  SwifterKnife
//
//  Created by liyang on 2023/3/8.
//

import UIKit
import SwifterKnife

public extension UIColor {
    static var systemFeedback: UIColor {
        UIColor(gray: 217)
    }
}

public protocol FormCellType: AnyObject {
    func axisDidChange(to axis: NSLayoutConstraint.Axis, dueToAxisPropertyChanged dueto: Bool)
}
extension FormCellType {
    public func axisDidChange(to axis: NSLayoutConstraint.Axis, dueToAxisPropertyChanged dueto: Bool) {}
}

public enum FormSeparatorVisibleMode {
    case never, always, automaticlly
}
public protocol FormSeperatorCellType: FormCellType {
    var separatorMode: FormSeparatorVisibleMode { get }
    var separatorView: SeparatorView! { get }
}


extension FormCellType where Self: UIView {
    
    fileprivate var stackView: UIStackView? {
        if let stackView = superview as? UIStackView,
           let _ = stackView.superview as? FormView {
            return stackView
        }
        return nil
    }
    fileprivate func aboveCell(on stackView: UIStackView) -> FormCellType? {
        let subviews = stackView.arrangedSubviews
        guard let index = subviews.firstIndex(of: self), index > 0 else { return nil }
        return subviews[index - 1] as? FormCellType
    }
    internal func updateSeperatorsState(on stackView: UIStackView) {
        /// 只有操作最后一个cell时，才需要更新操作
        guard self === stackView.arrangedSubviews.last else {
            return
        }
        let aboveCell = aboveCell(on: stackView) as? FormSeperatorCellType
        if isHidden {
            // 隐藏最后一个cell时，隐藏上面一个cell的分割线
            aboveCell?.setSeperatorShow(false)
        } else {
            // 显示最后一个cell时，隐藏当前cell的分割线， 显示上面一个cell的分割线，
            (self as? FormSeperatorCellType)?.setSeperatorShow(false)
            aboveCell?.setSeperatorShow(true)
        }
    }
     
    public func updateSeperatorVisibleState() {
        guard let stackView = stackView else {
            return
        }
        updateSeperatorsState(on: stackView)
    }
    public func setHidden(_ isHidden: Bool,
                          animatied: Bool = false,
                          completion: (() -> Void)? = nil) {
        guard self.isHidden != isHidden else { return }

        guard let stackView = stackView else {
            return
        }
        if animatied {
            UIView.animate(withDuration: 0.25) {
                self.isHidden = isHidden
                stackView.layoutIfNeeded()
            } completion: { _ in
                self.updateSeperatorsState(on: stackView)
                completion?()
            }
        } else {
            self.isHidden = isHidden
            updateSeperatorsState(on: stackView)
            completion?()
        }
    }
    
    public func removeFromFormView(animated: Bool = false) {
        setHidden(true, animatied: animated) {
            self.removeFromSuperview()
        }
    }
    
    public func scrollToVisible(animated: Bool = true) {
        guard let formView = stackView?.superview as? FormView else { return }
        formView.scrollRectToVisible(frame, animated: animated)
    }
}

extension FormSeperatorCellType {
    fileprivate func setSeperatorShow(_ isShow: Bool) {
        guard let view = separatorView else { return }
        guard separatorMode == .automaticlly else { return }
        view.isHidden = !isShow
    }
}

fileprivate extension NSLayoutConstraint.Axis {
    var crossed: NSLayoutConstraint.Axis {
        self == .vertical ? .horizontal : .vertical
    }
}

open class FormCell: UIView, FormCellType {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        didSetup()
    }
    public private(set) var axis: NSLayoutConstraint.Axis = .vertical
    
    public func axisDidChange(to axis: NSLayoutConstraint.Axis, dueToAxisPropertyChanged dueto: Bool) {
        self.axis = axis
    }
    
    open func setup() { }
    fileprivate func didSetup() {}
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

open class FormSeperatorCell: FormCell, FormSeperatorCellType {
    
    open var separatorMode: FormSeparatorVisibleMode = .never {
        didSet {
            switch separatorMode {
            case .never: separatorView.isHidden = true
            case .always: separatorView.isHidden = false
            default: break
            }
        }
    }
     
    open override func setup() {
        super.setup()
        separatorView = SeparatorView().then {
            addSubview($0)
            $0.isHidden = true
        }
    }
    override func didSetup() {
        bringSubviewToFront(separatorView)
    }
    
    public private(set) var separatorView: SeparatorView!
    
    public var separatorInset: UIEdgeInsets? {
        didSet {
            updateSeperatorViewIfNeeded()
        }
    }
    
    public override func axisDidChange(to axis: NSLayoutConstraint.Axis, dueToAxisPropertyChanged dueto: Bool) {
        super.axisDidChange(to: axis, dueToAxisPropertyChanged: dueto)
        updateSeperatorViewIfNeeded()
    }
    
    private func updateSeperatorViewIfNeeded() {
        guard let inset = separatorInset else { return }
        let axis = self.axis.crossed
        separatorView.axis = axis
        separatorView.snp.remakeConstraints { make in
            if axis == .horizontal {
                make.leading.trailing.equalToSuperview().inset(inset)
                make.bottom.equalToSuperview()
            } else {
                make.top.bottom.equalToSuperview().inset(inset)
                make.trailing.equalToSuperview()
            }
        }
    }
}

open class FormFeedbackCell: FormSeperatorCell {
    
    public var highlightColor: UIColor? = .systemFeedback
    
    public var isHighlightable: Bool = true
    
    public var isHighlighted = false {
        didSet {
            guard isHighlighted != oldValue else { return }
            guard let color = highlightColor else { return }
            
            highlightColor = backgroundColor
            backgroundColor = color
        }
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if isHighlightable {
            isHighlighted = true
        }
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard isHighlightable, let touch = touches.randomElement() else { return }
        
        let locationInSelf = touch.location(in: self)
        isHighlighted = point(inside: locationInSelf, with: event)
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        if isHighlightable {
            isHighlighted = false
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if isHighlightable {
            isHighlighted = false
        }
    }
}
