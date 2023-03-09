//
//  FormView.swift
//  SwifterKnife
//
//  Created by liyang on 2023/3/8.
//

import UIKit
import SnapKit

open class FormView: UIScrollView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    open func setup() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        backgroundColor = .clear
        
        container = UIStackView()
        container.axis = .vertical
        addSubview(container)
        
        alwaysBounceVertical = true
        alwaysBounceHorizontal = false
        
        container.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
            stackWidthCons = make.width.equalToSuperview().constraint
            stackHeightCons = make.height.equalToSuperview().constraint
        }
        stackHeightCons.deactivate()
    }
    
    public var isVertical: Bool {
        container.axis == .vertical
    }
    
    public var axis: NSLayoutConstraint.Axis {
        get { container.axis }
        set {
            guard container.axis != newValue else { return }
            let isVertical = newValue == .vertical
            alwaysBounceVertical = isVertical
            alwaysBounceHorizontal = !isVertical
            if isVertical {
                stackHeightCons.deactivate()
                stackWidthCons.activate()
            } else {
                stackHeightCons.activate()
                stackWidthCons.deactivate()
            }
            container.axis = newValue
            for subview in container.arrangedSubviews {
                if subview.isHidden { continue }
                if let cell = subview as? FormCellType {
                    cell.axisDidChange(to: newValue, dueToAxisPropertyChanged: true)
                }
            }
        }
    }
     
    public override var contentInset: UIEdgeInsets {
        didSet {
            guard contentInset != oldValue else {
                return
            }
            let inset = contentInset
            stackWidthCons.update(offset: -(inset.left + inset.right))
            stackHeightCons.update(offset: -(inset.top + inset.bottom))
        }
    }
    public var onSelectedCell: ((FormCellType, Int) -> Void)?
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var container: UIStackView!
    private var stackHeightCons: Constraint!
    private var stackWidthCons: Constraint!
}

extension FormView: FormCellType { }

public typealias FormViewCell = FormCellType & UIView

extension FormView {
    open func addCell<T: FormViewCell>(_ cell: T, animated: Bool = false) {
        insertCell(cell, at: container.arrangedSubviews.count, animated: animated)
    }
    
    open func insertCell<T: FormViewCell>(_ cell: T, at index: Int, animated: Bool = false) {
        container.insertArrangedSubview(cell, at: index)
        cell.axisDidChange(to: axis, dueToAxisPropertyChanged: false)
        cell.updateSeperatorsState(on: container)
        if animated {
            cell.alpha = 0
            container.layoutIfNeeded()
            UIView.animate(withDuration: 0.25) {
                cell.alpha = 1
            }
        }
    }
}
