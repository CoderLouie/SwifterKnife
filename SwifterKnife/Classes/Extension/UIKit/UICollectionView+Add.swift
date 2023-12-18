//
//  UICollectionView+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2022/8/8.
//

import UIKit


open class CollectionHeaderView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open func setup() { }
    
    private var isFirstLayout = true
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard isFirstLayout else { return }
        guard let view = superview else { return }
        guard let collectionView = view as? UICollectionView else {
            fatalError("the superview \(view) must be an UICollectionView")
        }
        isFirstLayout = false
        
        let direction: UICollectionView.ScrollDirection
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            direction = layout.scrollDirection
        } else { direction = .vertical }
        
        var inset = collectionView.contentInset
        let collectionViewSize = collectionView.bounds.size
        var size = bounds.size
        if direction == .vertical {
            if size.height == 0 {
                size = fittingSize(withRequiredWidth: collectionViewSize.width)
            }
            inset.top += size.height
            frame = CGRect(x: -inset.left, y: -size.height, width: collectionViewSize.width, height: size.height)
        } else {
            if size.width == 0 {
                size = fittingSize(withRequiredHeight: collectionViewSize.height)
            }
            inset.left += size.width
            frame = CGRect(x: -size.width, y: -inset.top, width: size.width, height: collectionViewSize.height)
        }
        collectionView.contentInset = inset
        collectionView.contentOffset = CGPoint(x: -inset.left, y: -inset.top)
    }
}


public extension UICollectionView {
    convenience init(layout: (UICollectionViewFlowLayout) -> Void) {
        let flowLayout = UICollectionViewFlowLayout()
        layout(flowLayout)
        self.init(frame: .zero, collectionViewLayout: flowLayout)
    }
    var theFlowLayout: UICollectionViewFlowLayout? {
        collectionViewLayout as? UICollectionViewFlowLayout
    }
    /// VisibleCells in the order they are displayed on screen.
    var orderedVisibleCells: [UICollectionViewCell] {
        return indexPathsForVisibleItems.sorted().compactMap { cellForItem(at: $0) }
    }

    /// Gets the currently visibleCells of a section.
    ///
    /// - Parameter section: The section to filter the cells.
    /// - Returns: Array of visible UICollectionViewCells in the argument section.
    func visibleCells(in section: Int) -> [UICollectionViewCell] {
        return visibleCells.filter { indexPath(for: $0)?.section == section }
    }
    
    var headerView: CollectionHeaderView? {
        get { subviews.first as? CollectionHeaderView }
        set {
            guard let view = newValue else { 
                headerView?.removeFromSuperview()
                return
            }
            insertSubview(view, at: 0)
        }
    }
}
