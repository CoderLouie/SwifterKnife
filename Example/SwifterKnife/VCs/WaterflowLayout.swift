//
//  WaterflowLayout.swift
//  Toonpics
//
//  Created by 李阳 on 2022/4/28.
//

import UIKit

public protocol WaterflowLayoutDelegate: NSObjectProtocol {
    func collectionView(_ collectionView: UICollectionView, layout waterflowLayout: WaterflowLayout, heightForItemAt index: Int, itemWidth: CGFloat) -> CGFloat
}
public class WaterflowLayout: UICollectionViewLayout {
    public var edgeInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    public var rowSpacing: CGFloat = 10
    public var columnSpacing: CGFloat = 10
    public var columnWidthRatios: [CGFloat] = [1, 1]
    public var headerReferenceSize: CGSize?
    public var footerReferenceSize: CGSize?
    
    public unowned var delegate: WaterflowLayoutDelegate!
     
    private var contentHeight: CGFloat = 0
    private var columnHeights: [CGFloat] = []
    private var layoutAttrs: [UICollectionViewLayoutAttributes] = []
    private var itemWs: [CGFloat] = []
    private var itemLefts: [CGFloat] = []
     
    public override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        let count = collectionView.numberOfItems(inSection: 0)
        guard count > 0 else { return }
        
        let sum = columnWidthRatios.reduce(0, +)
        
        let collectionWidth = collectionView.bounds.size.width
        let columnCount = columnWidthRatios.count
        let totoalW = (collectionWidth - edgeInset.left - edgeInset.right - CGFloat(columnCount - 1) * columnSpacing)
        itemWs = columnWidthRatios.map { totoalW * ($0 / sum) }
        var i = 0
        itemLefts = sequence(first: edgeInset.left, next: {
            let v = $0 + self.itemWs[i] + self.columnSpacing
            i += 1
            return i < columnCount ? v : nil
        }).compactMap { $0 }
        
        contentHeight = edgeInset.top
        columnHeights = .init(repeating: contentHeight, count: columnCount)
        layoutAttrs.removeAll()
        
        if let size = headerReferenceSize,
           size.height > 0 {
            let attr = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: 0))
            attr.frame = CGRect(origin: .zero, size: CGSize(width: collectionWidth, height: size.height))
            layoutAttrs.append(attr)
            contentHeight += size.height
            columnHeights = columnHeights.map { _ in contentHeight }
        }
        
        for i in 0..<count {
            let indexPath = IndexPath(item: i, section: 0)
            if let attr = layoutAttributesForItem(at: indexPath) {
                layoutAttrs.append(attr)
            }
        }
        
        if let size = footerReferenceSize,
           size.height > 0 {
            let attr = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: IndexPath(item: 0, section: 0))
            contentHeight += edgeInset.bottom
            attr.frame = CGRect(x: 0, y: contentHeight, width: collectionWidth, height: size.height)
            layoutAttrs.append(attr)
            contentHeight += size.height
            columnHeights = columnHeights.map { _ in contentHeight }
        }
    }
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        layoutAttrs
    }
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        
        guard let (i, height) = columnHeights.enumerated().min(by: { $0.element < $1.element
        }) else { return nil }
        let w = itemWs[i]
        let h = delegate.collectionView(collectionView!, layout: self, heightForItemAt: indexPath.item, itemWidth: w)
        let x = itemLefts[i]
        let y = height == edgeInset.top ? height : (height + rowSpacing)
        
        let rect = CGRect(x: x, y: y, width: w, height: h)
        attr.frame = rect
        
        columnHeights[i] = rect.maxY
        contentHeight = max(columnHeights[i], contentHeight)
        
        return attr
    }
    
    public override var collectionViewContentSize: CGSize {
        CGSize(width: 0, height: contentHeight)
    }
}
