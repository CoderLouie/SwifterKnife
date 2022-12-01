//
//  ConstraintArrayDSL.swift
//  SwifterKnife
//
//  Created by liyang on 2022/01/26.
//

import SnapKit

public enum ConstraintAxis : Int {
    case horizontal
    case vertical
}

#if os(iOS) || os(tvOS)
import UIKit
public typealias ConstraintEdgeInsets = UIEdgeInsets
#else
import AppKit
extension NSEdgeInsets {
    public static let zero = NSEdgeInsetsZero
}
public typealias ConstraintEdgeInsets = NSEdgeInsets


#endif

public struct ConstraintArrayDSL {
    @discardableResult
    public func prepareConstraints(_ closure: (_ make: ConstraintMaker) -> Void) -> [Constraint] {
        var constraints = Array<Constraint>()
        for view in self.array {
            constraints.append(contentsOf: view.snp.prepareConstraints(closure))
        }
        return constraints
    }
    
    public func makeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        for view in self.array {
            view.snp.makeConstraints(closure)
        }
    }
    
    public func remakeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        for view in self.array {
            view.snp.remakeConstraints(closure)
        }
    }
    
    public func updateConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        for view in self.array {
            view.snp.updateConstraints(closure)
        }
    }
    
    public func removeConstraints() {
        for view in self.array {
            view.snp.removeConstraints()
        }
    }
    
    /// distribute with fixed spacing
    ///
    /// - Parameters:
    ///   - axisType: which axis to distribute items along
    ///   - fixedSpacing: the spacing between each item
    ///   - leadSpacing: the spacing before the first item and the container
    ///   - tailSpacing: the spacing after the last item and the container
    public func distributeViewsAlong(
        axisType: ConstraintAxis,
        fixedSpacing: CGFloat = 0,
        leadSpacing: CGFloat = 0,
        tailSpacing: CGFloat = 0) {
        
        guard self.array.count > 1,
              let tempSuperView = commonSuperviewOfViews() else {
            return
        }
        
        if axisType == .horizontal {
            var prev: ConstraintView?
            for view in self.array {
                view.snp.makeConstraints { make in
                    guard let prev = prev else {//first one
                        make.leading.equalTo(tempSuperView).offset(leadSpacing)
                        return
                    }
                    make.width.equalTo(prev)
                    make.leading.equalTo(prev.snp.trailing).offset(fixedSpacing)
                }
                prev = view
            }
            if let last = prev {
                last.snp.makeConstraints { make in
                    make.trailing.equalTo(tempSuperView).offset(-tailSpacing)
                }
            }
        }else {
            var prev: ConstraintView?
            for view in self.array {
                view.snp.makeConstraints { make in
                    guard let prev = prev else {//first one
                        make.top.equalTo(tempSuperView).offset(leadSpacing)
                        return
                    }
                    make.height.equalTo(prev)
                    make.top.equalTo(prev.snp.bottom).offset(fixedSpacing)
                }
                prev = view
            }
            if let last = prev {
                last.snp.makeConstraints { make in
                    make.bottom.equalTo(tempSuperView).offset(-tailSpacing)
                }
            }
        }
    }
    
    /// distribute with fixed item size
    ///
    /// - Parameters:
    ///   - axisType: which axis to distribute items along
    ///   - fixedItemLength: the fixed length of each item
    ///   - leadSpacing: the spacing before the first item and the container
    ///   - tailSpacing: the spacing after the last item and the container
    public func distributeViewsAlong(
        axisType: ConstraintAxis,
        fixedItemLength: CGFloat,
        leadSpacing: CGFloat = 0,
        tailSpacing: CGFloat = 0) {
        
        guard self.array.count > 1,
              let tempSuperView = commonSuperviewOfViews() else {
            return
        }
        let n = CGFloat(self.array.count - 1)
        
        if axisType == .horizontal {
            var prev: ConstraintView?
            for (i, v) in self.array.enumerated() {
                v.snp.makeConstraints { make in
                    make.width.equalTo(fixedItemLength)
                    if prev != nil {
                        let offset = (CGFloat(1) - (CGFloat(i) / n)) *
                            (fixedItemLength + leadSpacing) -
                            CGFloat(i) * tailSpacing / n
                        make.trailing.equalTo(tempSuperView).multipliedBy(CGFloat(i) / n).offset(offset)
                    }else {//first one
                        make.leading.equalTo(tempSuperView).offset(leadSpacing)
                    }
                }
                prev = v
            }
            if let last = prev {
                last.snp.makeConstraints { make in
                    make.trailing.equalTo(tempSuperView).offset(-tailSpacing)
                }
            }
        } else {
            var prev: ConstraintView?
            for (i, v) in self.array.enumerated() {
                v.snp.makeConstraints { make in
                    make.height.equalTo(fixedItemLength)
                    if prev != nil {
                        let offset = (CGFloat(1) - (CGFloat(i) / n)) *
                            (fixedItemLength + leadSpacing) -
                            CGFloat(i) * tailSpacing / n
                        make.bottom.equalTo(tempSuperView).multipliedBy(CGFloat(i) / n).offset(offset)
                    }else {//first one
                        make.top.equalTo(tempSuperView).offset(leadSpacing)
                    }
                }
                prev = v
            }
            if let last = prev {
                last.snp.makeConstraints { make in
                    make.bottom.equalTo(tempSuperView).offset(-tailSpacing)
                }
            }
        }
    }
    
    /// distribute Sudoku with fixed item size
    ///
    /// - Parameters:
    ///   - fixedItemWidth: the fixed width of each item
    ///   - fixedItemLength: the fixed length of each item
    ///   - warpCount: the warp count in the super container
    ///   - edgeInset: the padding in the super container
    public func distributeSudokuViews(
        fixedItemWidth: CGFloat,
        fixedItemHeight: CGFloat,
        warpCount: Int,
        edgeInset: ConstraintEdgeInsets = .zero) {
        let n = self.array.count
        guard n > 1,
              warpCount >= 1,
              let tempSuperView = commonSuperviewOfViews() else {
            return
        }
        
        let remainder = n % warpCount
        let quotient = n / warpCount
        
        let rowCount = (remainder == 0) ? quotient : (quotient + 1)
        let columnCount = rowCount == 1 ? n : warpCount
        
        for (i,v) in self.array.enumerated() {
            
            let currentRow = i / warpCount
            let currentColumn = i % warpCount
            
            v.snp.makeConstraints { make in
                make.width.equalTo(fixedItemWidth)
                make.height.equalTo(fixedItemHeight)
                if currentRow == 0 {//fisrt row
                    make.top.equalTo(tempSuperView).offset(edgeInset.top)
                }
                if currentRow == rowCount - 1 {//last row
                    make.bottom.equalTo(tempSuperView).offset(-edgeInset.bottom)
                }
                
                if currentRow != 0,
                   currentRow != rowCount - 1 {//other row
                    let offset = (CGFloat(1) - CGFloat(currentRow) / CGFloat(rowCount - 1)) *
                        (fixedItemHeight + edgeInset.top) -
                        CGFloat(currentRow) * edgeInset.bottom / CGFloat(rowCount - 1)
                    make.bottom.equalTo(tempSuperView).multipliedBy(CGFloat(currentRow) / CGFloat(rowCount - 1)).offset(offset)
                }
                
                if currentColumn == 0 {//first col
                    make.leading.equalTo(tempSuperView).offset(edgeInset.left)
                }
                if currentColumn == columnCount - 1 {//last col
                    make.trailing.equalTo(tempSuperView).offset(-edgeInset.right)
                }
                
                if currentColumn != 0,
                   currentColumn != columnCount - 1 {//other col
                    let offset = (CGFloat(1) - CGFloat(currentColumn) / CGFloat(columnCount - 1)) *
                        (fixedItemWidth + edgeInset.left) -
                        CGFloat(currentColumn) * edgeInset.right / CGFloat(columnCount - 1)
                    make.trailing.equalTo(tempSuperView).multipliedBy(CGFloat(currentColumn) / CGFloat(columnCount - 1)).offset(offset)
                }
            }
        }
    }
    
    /// distribute Sudoku with fixed item spacing
    ///
    /// - Parameters:
    ///   - fixedLineSpacing: the line spacing between each item
    ///   - fixedInteritemSpacing: the Interitem spacing between each item
    ///   - warpCount: the warp count in the super container
    ///   - edgeInset: the padding in the super container
    public func distributeSudokuViews(
        fixedLineSpacing: CGFloat,
        fixedInteritemSpacing: CGFloat,
        warpCount: Int,
        edgeInset: ConstraintEdgeInsets = .zero) {
        let n = array.count
        guard n > 1,
              warpCount >= 1,
              let tempSuperView = commonSuperviewOfViews() else {
            return
        }
        
        let remainder = n % warpCount
        let quotient = n / warpCount
        
        let rowCount = (remainder == 0) ? quotient : (quotient + 1)
        let columnCount = rowCount == 1 ? n : warpCount
        
        var prev: ConstraintView!
        
        for (i, v) in array.enumerated() {
            
            let currentRow = i / warpCount
            let currentColumn = i % warpCount
            
            v.snp.makeConstraints { make in
                if i > 0 { make.width.height.equalTo(array[0]) }
                
                if currentRow == 0 {
                    make.top.equalTo(tempSuperView).offset(edgeInset.top)
                } else {
                    make.top.equalTo(array[i-columnCount].snp.bottom).offset(fixedLineSpacing)
                }
                if currentRow == rowCount - 1 {
                    make.bottom.equalTo(tempSuperView).offset(-edgeInset.bottom)
                }
                
                if currentColumn == 0 {
                    make.leading.equalTo(tempSuperView).offset(edgeInset.left)
                } else {
                    make.leading.equalTo(prev.snp.trailing).offset(fixedInteritemSpacing)
                }
                if currentColumn == columnCount - 1 {
                    make.trailing.equalTo(tempSuperView).offset(-edgeInset.right)
                }
            }
            prev = v
        }
    }
    
    internal let array: Array<ConstraintView>
    
    internal init(array: Array<ConstraintView>) {
        self.array = array
    }
    
}

public extension Array {
    var snp: ConstraintArrayDSL {
        return ConstraintArrayDSL(array: self as! Array<ConstraintView>)
    }
}

private extension ConstraintArrayDSL {
    func commonSuperviewOfViews() -> ConstraintView? {
        var commonSuperview : ConstraintView?
        var previousView : ConstraintView?
        
        for view in self.array {
            if previousView != nil {
                commonSuperview = view.closestCommonSuperview(commonSuperview)
            }else {
                commonSuperview = view
            }
            previousView = view
        }
        
        return commonSuperview
    }
}

private extension ConstraintView {
    func closestCommonSuperview(_ view : ConstraintView?) -> ConstraintView? {
        var closestCommonSuperview: ConstraintView?
        var secondViewSuperview: ConstraintView? = view
        while closestCommonSuperview == nil && secondViewSuperview != nil {
            var firstViewSuperview: ConstraintView? = self
            while closestCommonSuperview == nil && firstViewSuperview != nil {
                if secondViewSuperview == firstViewSuperview {
                    closestCommonSuperview = secondViewSuperview
                }
                firstViewSuperview = firstViewSuperview?.superview
            }
            secondViewSuperview = secondViewSuperview?.superview
        }
        return closestCommonSuperview
    }
}
