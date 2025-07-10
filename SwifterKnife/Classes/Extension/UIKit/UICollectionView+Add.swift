//
//  UICollectionView+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2022/8/8.
//

import UIKit


//open class CollectionHeaderView: UIView {
//    public override init(frame: CGRect) {
//        super.init(frame: frame)
//        setup()
//    }
//    required public init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    open func setup() { }
//    
//    private var isFirstLayout = true
//    
//    open override func layoutSubviews() {
//        super.layoutSubviews()
//        guard isFirstLayout else { return }
//        guard let view = superview else { return }
//        guard let collectionView = view as? UICollectionView else {
//            fatalError("the superview \(view) must be an UICollectionView")
//        }
//        isFirstLayout = false
//        
//        let direction: UICollectionView.ScrollDirection
//        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            direction = layout.scrollDirection
//        } else { direction = .vertical }
//        
//        var inset = collectionView.contentInset
//        let collectionViewSize = collectionView.bounds.size
//        var size = bounds.size
//        if direction == .vertical {
//            if size.height == 0 {
//                size = fittingSize(withRequiredWidth: collectionViewSize.width)
//            }
//            inset.top += size.height
//            frame = CGRect(x: -inset.left, y: -size.height, width: collectionViewSize.width, height: size.height)
//        } else {
//            if size.width == 0 {
//                size = fittingSize(withRequiredHeight: collectionViewSize.height)
//            }
//            inset.left += size.width
//            frame = CGRect(x: -size.width, y: -inset.top, width: size.width, height: collectionViewSize.height)
//        }
//        collectionView.contentInset = inset
//        collectionView.contentOffset = CGPoint(x: -inset.left, y: -inset.top)
//    }
//}

public extension UICollectionViewFlowLayout {
    /*
     https://www.jianshu.com/p/ffafb589539e
     与滚动方向相同的间距是minimumLineSpacing
     垂直的是minimumInteritemSpacing
     
     水平滚动时：cell从上倒下，从左到右排列
     垂直滚动时：cell从左到右，从上倒下排列
     */
    public func makeItemSize(_ maxDimension: CGFloat, count: Int) {
        let inset = sectionInset
        let n = CGFloat(count)
        let contentD: CGFloat
        if scrollDirection == .vertical {
            contentD = maxDimension - inset.left - inset.right
        } else {
            contentD = maxDimension - inset.top - inset.bottom
        }
        let wh = Darwin.floor(((contentD - (n - 1) * minimumInteritemSpacing) / n))
        itemSize = CGSize(width: wh, height: wh)
    }
}
public extension UICollectionView {
    public func commonConfig() {
        backgroundColor = .clear
        contentInsetAdjustmentBehavior = .never
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }
    
    static func create(layout: (UICollectionViewFlowLayout) -> Void) -> Self {
        let flowLayout = UICollectionViewFlowLayout()
        layout(flowLayout)
        let view = Self(frame: .zero, collectionViewLayout: flowLayout)
        view.commonConfig()
        return view
    }
    var theFlowLayout: UICollectionViewFlowLayout? {
        collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    var displayingCells: [UICollectionViewCell] {
        let visibleCells = visibleCells
        let visibleRect = frame.intersection(superview?.bounds ?? frame)
        return visibleCells.filter { $0.frame.intersects(visibleRect) }
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
    func deselectAll(animated: Bool = true) {
        guard let paths = indexPathsForSelectedItems, !paths.isEmpty else { return }
        for path in paths {
            deselectItem(at: path, animated: animated)
        }
    }
    func deleteSelectedItems() {
        guard let paths = indexPathsForSelectedItems, !paths.isEmpty else { return }
        deleteItems(at: paths)
    }
    /// 刷新后，仍然选中原来的indexpath，最好保证刷新前后，数据源数量不变
    func situReloadData() {
        guard let paths = indexPathsForSelectedItems, !paths.isEmpty else { reloadData(); return }
        reloadData()
        var map: [Int: Int] = [:]
        for s in (0..<numberOfSections) {
            map[s] = numberOfItems(inSection: s)
        }
        for path in paths {
            guard let max = map[path.section], path.item < max else { continue }
            selectItem(at: path, animated: false, scrollPosition: .centeredHorizontally)
        }
    }
    
    
//    var headerView: CollectionHeaderView? {
//        get { subviews.first as? CollectionHeaderView }
//        set {
//            guard let view = newValue else { 
//                headerView?.removeFromSuperview()
//                return
//            }
//            insertSubview(view, at: 0)
//        }
//    }
}
