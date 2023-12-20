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
        
        fileprivate func real(with isRTL: Bool) -> Alignment {
            switch self {
            case .leading:
                return isRTL ? .right : .left
            case .trailing:
                return isRTL ? .left : .right
            default: return self
            }
        }
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
        arrangedViews = []
        removeSubviews()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        replaceArrangedViews()
    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: totalWidth, height: totalHeight)
    }
    public var cellSize: ((_ view: UIView, _ index: Int) -> CGSize)?
    
    public var arrangedViews: [UIView] = []
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
        guard !arrangedViews.isEmpty else { return }
         
        let boundsW = max(bounds.width, minPlaceWidth)
        if numberOfLines < 1, boundsW <= 0 { return }
        
        hasLayout = true
        
        removeSubviews()
        
        let inset = contentInset
        let N = arrangedViews.count
        
        let tagViewSizes = arrangedViews.enumerated().map {
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

        let isRtl: Bool = effectiveUserInterfaceLayoutDirection == .rightToLeft
        let transform = isRtl
            ? CGAffineTransform(scaleX: -1.0, y: 1.0)
            : CGAffineTransform.identity
        
        let alignment = self.alignment.real(with: isRtl)
        let placeWidth = frameWidth - inset.horizontal + marginX
        
        var rowY: CGFloat = inset.top
        var rowW: CGFloat = 0
        var rowH: CGFloat = 0
         
        var rowView = UIView()
        
        for (i, tagView) in arrangedViews.enumerated() {
            let tagViewSize = tagViewSizes[i]
            let tagH = tagViewSize.height
            let tagW = tagViewSize.width
            tagView.frame = CGRect(x: rowW, y: 0, width: tagW, height: tagH)
            rowView.addSubview(tagView)
            
            rowH = max(rowH, tagH)
            rowW += tagW + marginX
            
            let isLast = i == N - 1
            
            if (isLast ||
                rowW > placeWidth) {
                rowW -= marginX
                
                let rowViewX: CGFloat
                switch alignment {
                case .leading, .left:
                    rowViewX = inset.left
                case .center:
                    rowViewX = (frameWidth - rowW) * 0.5
                case .trailing, .right:
                    rowViewX = frameWidth - rowW - inset.right
                }
                rowView.frame = CGRect(x: rowViewX, y: rowY, width: rowW, height: rowH)
                rowView.transform = transform
                addSubview(rowView)
                rowY += rowH + marginY
                rowW = 0

                rowView = UIView()
            }
        }
        
        totalWidth = frameWidth
        totalHeight = rowY - marginY + inset.bottom
        
        invalidateIntrinsicContentSize()
    }
}
