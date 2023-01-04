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
    
    public var contentInset: UIEdgeInsets = .zero
    public var numberOfLines: Int = 0
     
    public var alignment: Alignment = .leading
    public var marginY: CGFloat = 5
    public var marginX: CGFloat = 5
    public var minPlaceWidth: CGFloat = 0
    
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
        super.layoutSubviews()
        replaceArrangedViews()
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
    func setNeedsReplace() {
        hasLayout = false
    }
    /// 如有必要，重新摆放其管理的子视图
    func replaceArrangedViewsIfNeeded() {
        if hasLayout { return }
        replaceArrangedViews()
    }
}

/*
 https://leetcode.cn/problems/split-array-largest-sum/solution/er-fen-cha-zhao-by-liweiwei1419-4/
 */
private extension LinearFlowView {
    func splitArray(_ nums: [CGFloat], _ m: Int) -> (CGFloat, Int) {
        let len = nums.count
        var preSum: [CGFloat] = .init(repeating: 0, count: len + 1)
        preSum[0] = 0
        for i in 0..<len {
            preSum[i + 1] = preSum[i] + nums[i]
        }
        var dp: [[CGFloat]] = .init(repeating: .init(repeating: .greatestFiniteMagnitude, count: m + 1), count: len)
        for i in 0..<len {
            dp[i][1] = preSum[i + 1]
        }
        if m < 2 {
            return (dp[len - 1][m], len)
        }
        for k in 2...m {// 2...5
            for i in k-1..<len {//1..<5
                for j in k-2..<i {//0..<1
                    dp[i][k] = Swift.min(
                        dp[i][k],
                        Swift.max(dp[j][k - 1], preSum[i + 1] - preSum[j + 1]))
                }
            }
        }
        let res = dp[len - 1][m]
        var n = 0
        var sum: CGFloat = 0
        for (i, num) in nums.enumerated() {
            sum = num
            n = 1
            for num1 in nums[(i+1)...] {
                sum += num1
                n += 1
                if abs(sum - res) < 0.01 { return (res, n) }
                else if sum > res { break }
            }
        }
        return (dp[len - 1][m], len)
    }
    /// 重新摆放其管理的子视图
    func replaceArrangedViews() {
        guard !hasLayout else { return }
        
        let boundsW = frame.width
        
        let views = arrangedViews as [UIView] + rowViews
        guard !views.isEmpty else { return }
        
        views.forEach { $0.removeFromSuperview() }
        rowViews.removeAll(keepingCapacity: true)
        
        var tagViewSizes: [CGSize] = []
        for tagView in arrangedViews {
            tagViewSizes.append(tagView.intrinsicContentSize)
        }
        let isMultipleLines = numberOfLines != 1
        let frameWidth: CGFloat
        if numberOfLines < 2 {
            frameWidth = boundsW
            if boundsW <= 0 { return }
        } else {
            let widths = tagViewSizes.map(\.width)
            let sumw = widths.reduce(into: 0, +=) + CGFloat(widths.count - 1) * marginX
            let estimedW = sumw / CGFloat(numberOfLines)
            if estimedW <= boundsW {
                frameWidth = boundsW
            } else {
                let pair = splitArray(widths, numberOfLines)
                let tmpWidth = pair.0 + CGFloat((pair.1 - 1)) * marginX + contentInset.horizontal
                let targetW = Swift.max(minPlaceWidth, boundsW)
                frameWidth = tmpWidth < targetW ? targetW : tmpWidth
            }
        }
        hasLayout = true

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
        
        for (i, tagView) in arrangedViews.enumerated() {
            let tagViewSize = tagViewSizes[i]
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
         
        totalWidth = frameWidth
        
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
