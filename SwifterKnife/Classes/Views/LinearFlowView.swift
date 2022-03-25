//
//  LinearFlowView.swift
//  SwifterKnife
//
//  Created by liyang on 2022/3/2.
//

import UIKit
 
open class LinearFlowView: UIView {
    public enum Alignment: Int {
        case left
        case center
        case right
        case leading
        case trailing
    }
    
    public var contentInset: UIEdgeInsets = .zero {
        didSet {
            guard oldValue != contentInset else { return }
            replaceArrangedViewsIfNeeded()
        }
    }
    
    public var isMultipleLines: Bool = true {
        didSet {
            guard oldValue != isMultipleLines else { return }
            replaceArrangedViewsIfNeeded()
        }
    }
    public var alignment: Alignment = .leading {
        didSet {
            guard oldValue != alignment else { return }
            replaceArrangedViewsIfNeeded()
        }
    }
    public var marginY: CGFloat = 5 {
        didSet {
            guard oldValue != marginY else { return }
            replaceArrangedViewsIfNeeded()
        }
    }
    public var marginX: CGFloat = 5 {
        didSet {
            guard oldValue != marginX else { return }
            replaceArrangedViewsIfNeeded()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setup() { }
    
    open func addArrangedView(_ view: UIView) {
        arrangedViews.append(view)
    }
    open func insertArrangedView(_ view: UIView, at index: Int) {
        arrangedViews.insert(view, at: index)
    }
    open func addArrangedViews(_ views: [UIView]) {
        for view in views {
            arrangedViews.append(view)
        }
    }
    
    @discardableResult
    open func removeArrangedView(_ view: UIView) -> Bool {
        if let index = arrangedViews.firstIndex(of: view) {
            view.removeFromSuperview()
            arrangedViews.remove(at: index)
            return true
        } else {
            return false
        }
    }
    @discardableResult
    open func removeArrangedView(at index: Int) -> Bool {
        guard arrangedViews.indices.contains(index) else {
            return false
        }
        let view = arrangedViews[index]
        view.removeFromSuperview()
        arrangedViews.remove(at: index)
        return true
    }
    open func removeAllArrangedViews() {
        (arrangedViews + rowViews).forEach {
            $0.removeFromSuperview()
        }
        arrangedViews = []
        rowViews = []
    }
    
    open override func layoutSubviews() {
        defer { replaceArrangedViews() }
        super.layoutSubviews()
    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: totalWidth, height: totalHeight)
    }
    public var arrangedViews: [UIView] = []
    public private(set) var rowViews: [UIView] = []
    public private(set) var totalHeight: CGFloat = 0
    public private(set) var totalWidth: CGFloat = 0
    private var hasLayout: Bool = false
}

public extension LinearFlowView {
    /// 如有必要，重新摆放其管理的子视图
    func replaceArrangedViewsIfNeeded() {
        guard hasLayout else { return }
        hasLayout = false
        replaceArrangedViews()
    }
}

private extension LinearFlowView {
    /// 重新摆放其管理的子视图
    func replaceArrangedViews() {
        guard !hasLayout else { return }
        
        let frameWidth = frame.width
        if isMultipleLines, frameWidth <= 0 { return }
        if isMultipleLines { totalWidth = frameWidth }
        
        let views = arrangedViews as [UIView] + rowViews
        guard !views.isEmpty else { return }
        
        hasLayout = true
        
        views.forEach { $0.removeFromSuperview() }
        rowViews.removeAll(keepingCapacity: true)

        let isRtl: Bool = effectiveUserInterfaceLayoutDirection == .rightToLeft
        let directionTransform = isRtl
            ? CGAffineTransform(scaleX: -1.0, y: 1.0)
            : CGAffineTransform.identity
        
        var rowIndex = 0
        var currentRowTagCount = 0
        
        var currentRowW: CGFloat = 0
        var currentRowH: CGFloat = 0
        
        var currentTagW: CGFloat = 0
        var currentTagH: CGFloat = 0
        
        var currentRowView: UIView = UIView()
        currentRowView.transform = directionTransform
        rowViews.append(currentRowView)
        addSubview(currentRowView)
        
        let inset = contentInset
        let placeWidth = frameWidth - inset.horizontal
        
        for tagView in arrangedViews {
            let tagViewSize = tagView.intrinsicContentSize
            currentTagH = tagViewSize.height
            currentTagW = min(tagViewSize.width, placeWidth)
            
            currentRowH = max(currentRowH, currentTagH)
            
            if isMultipleLines,
               currentRowW + currentTagW > placeWidth {
                if currentRowTagCount > 0 { currentRowW -= marginX }
                rowViews[rowIndex].frame.size = CGSize(width: currentRowW, height: currentRowH)
                
                rowIndex += 1
                currentRowW = 0
                currentRowTagCount = 0
                
                currentRowView = UIView()
                currentRowView.transform = directionTransform
                rowViews.append(currentRowView)
                addSubview(currentRowView)
            }
            tagView.frame = CGRect(x: currentRowW, y: 0, width: currentTagW, height: currentTagH)
            currentRowView.addSubview(tagView)
            
            currentRowTagCount += 1
            currentRowW += currentTagW + marginX
        }
        if currentRowTagCount > 0 { currentRowW -= marginX }
        rowViews[rowIndex].frame.size = CGSize(width: currentRowW, height: currentRowH)
        
        if !isMultipleLines {
            totalWidth = currentRowW + inset.horizontal
        }
        
        var alignment = self.alignment
        
        if alignment == .leading {
            alignment = isRtl ? .right : .left
        } else if alignment == .trailing {
            alignment = isRtl ? .left : .right
        }
        
        var rowViewX: CGFloat = inset.left
        var rowViewY: CGFloat = inset.top
        for view in rowViews {
            let size = view.frame.size
            let currentRowW = size.width
            switch alignment {
            case .leading, .left:
                rowViewX = inset.left
            case .center:
                rowViewX = (frameWidth - currentRowW) / 2
            case .trailing, .right:
                rowViewX = frameWidth - currentRowW - inset.right
            }
            view.frame.origin = CGPoint(x: rowViewX, y: rowViewY)
            rowViewY += size.height + marginY
        }
        totalHeight = rowViewY - marginY + inset.bottom
        
        invalidateIntrinsicContentSize()
    }
}
