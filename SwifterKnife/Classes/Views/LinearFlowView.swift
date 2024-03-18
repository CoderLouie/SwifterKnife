//
//  LinearFlowView.swift
//  SwifterKnife
//
//  Created by liyang on 2022/3/2.
//

import UIKit

open class LinearFlowView: UIView {
    
    public var contentInset: UIEdgeInsets = .zero
    
    public var marginY: CGFloat = 5
    public var marginX: CGFloat = 5
    public var minPlaceWidth: CGFloat = 0
    
    public var cellSize: ((_ view: UIView, _ index: Int) -> CGSize?)?
    
    // 高度根据布局属性及子视图自动计算
    /// 布局行为
    public enum LayoutBehavior {
        /// 宽度自动，不会小于minPlaceWidth，
        /// 根据子视图数量布局成numberOfLines行，但需要 > 0
        case autoSelfWidth(_ numberOfLines: Int)
        
        /// 固定宽度(max(bounds.width, minPlaceWidth))
        case fixedWidth
        
        /// 固定宽度(max(bounds.width, minPlaceWidth))
        /// 支持动态添加子视图
        case fixedWidth1(_ createView: (_ times: Int) -> UIView?, _ onDidLayout: (_ pos: SudokuView.Position, _ enoughSpace: Bool) -> Bool)
    }
    public var layoutBehavior: LayoutBehavior = .fixedWidth
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setup() { }
    
    open func addArrangedView(_ view: UIView) {
        addSubview(view)
    }
    open func addArrangedViews(_ views: [UIView]) {
        for view in views {
            addSubview(view)
        }
    }
     
    open func removeAllArrangedViews() {
        removeSubviews()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        replaceArrangedViews()
    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: totalWidth, height: totalHeight)
    }
     
    public private(set) var linesCount = 0
    public private(set) var totalHeight = UIView.noIntrinsicMetric
    public private(set) var totalWidth = UIView.noIntrinsicMetric
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
    private func getCellSize(_ cell: UIView, at index: Int) -> CGSize {
        let size: CGSize
        if let s = cellSize?(cell, index), !s.isEmpty {
            size = s
        } else {
            let s = cell.intrinsicContentSize
            if !s.isEmpty {
                size = s
            } else { size = cell.frame.size }
        }
        return size.adaptive { Darwin.ceil($0) }
    }
    /// 重新摆放其管理的子视图
    func replaceArrangedViews() {
        guard !hasLayout else { return }
         
        let boundsW = max(bounds.width, minPlaceWidth)
        
        let inset = contentInset
        let subviews = self.subviews
        
        var numberOfLines = 0
        switch layoutBehavior {
        case let .fixedWidth1(create, layout):
            
            hasLayout = true
            removeSubviews()
            
            let placeWidth = boundsW - inset.right
            let contentW = placeWidth - inset.left
            var index = 0
            var times = 0
            
            var rowY: CGFloat = inset.top
            var rowW: CGFloat = inset.left - marginX
            var rowH: CGFloat = 0
            var rows = 0
            var columns = 0
            
            var hasIn = false
            while let view = create(times) {
                hasIn = true
                times += 1
                let tagViewSize = getCellSize(view, at: index)
                let tagH = tagViewSize.height
                let tagW = min(tagViewSize.width, contentW)
                 
                let nextRowW = rowW + marginX
                let enough = nextRowW + tagW <= placeWidth
                
                guard layout(.init(rows, columns), enough) else {
                    continue
                }
                index += 1
                if enough {
                    rowW = nextRowW
                    columns += 1
                } else {
                    rows += 1
                    rowY += rowH + marginY
                    rowW = inset.left
                    rowH = 0
                    columns = 0
                }
                
                view.frame = CGRect(x: rowW, y: rowY, width: tagW, height: tagH)
                addSubview(view)
                rowH = max(rowH, tagH)
                rowW += tagW
            }
            
            totalWidth = boundsW
            guard hasIn else { return }
            self.linesCount = rows + 1
            totalHeight = rowY + rowH + inset.bottom
            invalidateIntrinsicContentSize()
            return
        case .fixedWidth:
            break
        case let .autoSelfWidth(linesN):
            guard linesN > 0, !subviews.isEmpty else { return }
            numberOfLines = linesN
        }
        let tagViewSizes = subviews.enumerated().map {
            return getCellSize($0.1, at: $0.0)
        }
        
        let N = subviews.count
        let frameWidth: CGFloat
        if numberOfLines == 0 {
            frameWidth = boundsW
            if boundsW <= 0 { return }
        } else if numberOfLines == 1 {
            let totalW = tagViewSizes.map(\.width).reduce(into: 0, +=) + CGFloat(N - 1) * marginX + inset.horizontal
            frameWidth = max(totalW, boundsW)
        } else {
            let widths = tagViewSizes.map(\.width)
            let pair = splitArray(widths, numberOfLines)
            let totalW = Darwin.ceil(pair.0) + CGFloat((pair.1 - 1)) * marginX + inset.horizontal
            frameWidth = max(totalW, boundsW)
        }
        
        hasLayout = true
        
        let placeWidth = frameWidth - inset.right
        let contentW = placeWidth - inset.left
        
        var rowY: CGFloat = inset.top
        var rowW: CGFloat = inset.left - marginX
        var rowH: CGFloat = 0
        var lines = 1
        for (i, tagView) in subviews.enumerated() {
            let tagViewSize = tagViewSizes[i]
            let tagH = tagViewSize.height
            let tagW = min(tagViewSize.width, contentW)
             
            let nextRowW = rowW + marginX
            if nextRowW + tagW > placeWidth {
                lines += 1
                rowY += rowH + marginY
                rowW = inset.left
                rowH = 0
            } else {
                rowW = nextRowW
            }
            tagView.frame = CGRect(x: rowW, y: rowY, width: tagW, height: tagH)
            rowH = max(rowH, tagH)
            rowW += tagW
        }
        self.linesCount = lines
        totalWidth = frameWidth
        totalHeight = rowY + rowH + inset.bottom
        invalidateIntrinsicContentSize()
    }
    
    func splitArray(_ nums: [CGFloat], _ m: Int) -> (CGFloat, Int) {
        let len = nums.count
        if m == 1 {
            return (nums.reduce(into: 0, +=), len)
        }
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
}


open class LinearFlowView1: UIView {
    
    public var contentInset: UIEdgeInsets = .zero
    public var numberOfLines: Int = 0
      
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
        addSubview(view)
    }
    open func addArrangedViews(_ views: [UIView]) {
        for view in views {
            addSubview(view)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        replaceArrangedViews()
    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: totalWidth, height: totalHeight)
    }
    public var cellSize: ((_ view: UIView, _ index: Int) -> CGSize?)?
     
    public private(set) var totalHeight: CGFloat = 0
    public private(set) var totalWidth: CGFloat = 0
    private var hasLayout: Bool = false
}

public extension LinearFlowView1 {
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
private extension LinearFlowView1 {
    func splitArray(_ nums: [CGFloat], _ m: Int) -> (CGFloat, Int) {
        let len = nums.count
        if m == 1 {
            return (nums.reduce(into: 0, +=), len)
        }
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
        let subviews = self.subviews
        guard !subviews.isEmpty else { return }
         
        let boundsW = max(bounds.width, minPlaceWidth)
        if numberOfLines < 1, boundsW <= 0 { return }
        
        hasLayout = true
        
        removeSubviews()
        
        let inset = contentInset
        let N = subviews.count
        
        let tagViewSizes = subviews.enumerated().map {
            let size: CGSize
            if let s = cellSize?($0.1, $0.0), !s.isEmpty {
                size = s
            } else {
                let s = $0.1.intrinsicContentSize
                if !s.isEmpty {
                    size = s
                } else { size = $0.1.frame.size }
            }
            return size.adaptive { $0.pixCeil }
        }
        let frameWidth: CGFloat
        if numberOfLines == 0 {
            frameWidth = boundsW
        } else if numberOfLines == 1 {
            let contentW = tagViewSizes.map(\.width).reduce(into: 0, +=)
            let totalW = contentW + CGFloat(N - 1) * marginX + inset.horizontal
            frameWidth = max(totalW, boundsW)
        } else {
            let widths = tagViewSizes.map(\.width)
            let pair = splitArray(widths, numberOfLines)
            let totalW = Darwin.ceil(pair.0) + CGFloat((pair.1 - 1)) * marginX + contentInset.horizontal
            frameWidth = max(totalW, boundsW)
        }
 
        let placeWidth = frameWidth - inset.horizontal + marginX
        
        var rowY: CGFloat = inset.top
        var rowW: CGFloat = 0
        var rowH: CGFloat = 0
         
        var rowView = UIView()
        
        for (i, tagView) in subviews.enumerated() {
            let tagViewSize = tagViewSizes[i]
            let tagH = tagViewSize.height
            let tagW = tagViewSize.width
            
            rowH = max(rowH, tagH)
            let isLast = i == N - 1
            let nextRowW = rowW + tagW + marginX
            let noSpace = nextRowW > placeWidth
            if (noSpace || isLast) {
                if !noSpace {
                    rowW = nextRowW
                }
                rowW -= marginX
                 
                rowView.frame = CGRect(x: inset.left, y: rowY, width: rowW, height: rowH)
                addSubview(rowView)
                rowY += rowH + marginY
                if noSpace {
                    rowW = 0
                    rowView = UIView()
                } else {
                    rowW -= tagW
                }
            }
            
            tagView.frame = CGRect(x: rowW, y: 0, width: tagW, height: tagH)
            rowView.addSubview(tagView)
            
            if !isLast { rowW += tagW + marginX }
        }
        
        totalWidth = frameWidth
        totalHeight = rowY - marginY + inset.bottom
        
        invalidateIntrinsicContentSize()
    }
}

