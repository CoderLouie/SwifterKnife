//
//  CarouselView.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

// MARK: - CarouselViewDelegate
@objc public protocol CarouselViewDelegate {
    @objc optional func carouselView(_ carouselView: CarouselView, didSelect cell: CarouselViewCell, at index: Int)
    @objc optional func carouselView(_ carouselView: CarouselView, didAppear cell: CarouselViewCell, at index: Int)
    @objc optional func carouselView(_ carouselView: CarouselView, didDisappear cell: CarouselViewCell, at index: Int)
    @objc optional func carouselView(_ carouselView: CarouselView, willAppear cell: CarouselViewCell, at index: Int)
    @objc optional func carouselView(_ carouselView: CarouselView, willDisappear cell: CarouselViewCell, at index: Int)
}



// MARK: - CarouselViewCell

open class CarouselViewCell: UIView {
    fileprivate unowned var carouselView: CarouselView!
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open func setup() { }
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        carouselView.didTouchCell(self)
    }
}


// MARK: - CarouselView
/// 无限循环滚动控件
open class CarouselView: UIView {
    
    open weak var delegate: CarouselViewDelegate?
    
    public private(set) lazy var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = true
        $0.delegate = self
        $0.contentInsetAdjustmentBehavior = .never
        addSubview($0)
    }
    
    public enum ScrollDirection {
        case horizontal
        case vertical
    }
    
    public let scrollDirection: ScrollDirection
    
    public init(direction: ScrollDirection, frame: CGRect) {
        self.scrollDirection = direction
        super.init(frame: frame)
    }
    public convenience init(direction: ScrollDirection) {
        self.init(direction: direction, frame: .zero)
    }
    public convenience override init(frame: CGRect) {
        self.init(direction: .horizontal, frame: frame)
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isHorizontal: Bool {
        scrollDirection == .horizontal
    }
    
    /// 当前索引, 用于currentCell
    public private(set) var currentIndex = 0
    public private(set) unowned var currentCell: CarouselViewCell!
    /// next索引, 用于nextCell
    private var nextIndex = -1
    private unowned var nextCell: CarouselViewCell!
    /// 数据源数量
    open var itemsCount: Int = 2 {
        didSet {
            if itemsCount < 2 { return }
            if itemsCount == oldValue { return }
            if isFirstLayout { return }
            
            targetParam = nil
            currentIndex = 0
            nextIndex = 1
            
            if isHorizontal {
                scrollView.contentOffset = CGPoint(x: side, y: 0)
                // cells
                currentCell.frame.origin = CGPoint(x: side, y: 0)
                nextCell.frame.origin = CGPoint(x: side * 2, y: 0)
            } else {
                scrollView.contentOffset = CGPoint(x: 0, y: side)
                
                // cells
                currentCell.frame.origin = CGPoint(x: 0, y: side)
                nextCell.frame.origin = CGPoint(x: 0, y: side * 2)
            }
            
            delegate?.carouselView?(self, willAppear: currentCell, at: currentIndex)
            delegate?.carouselView?(self, didAppear: currentCell, at: currentIndex)
        }
    }
    
    private var side: CGFloat = 0
    private var targetParam: (Int, Bool)?
    
    fileprivate func didTouchCell(_ cell: CarouselViewCell) {
        delegate?.carouselView?(self, didSelect: cell, at: currentIndex)
    }
    private enum PanDirection {
        case none
        case forward
        case fastForward
        case backward
        case fastBackward
    }
    private var direction: PanDirection = .none {
        didSet {
            guard oldValue != direction else { return }
            guard direction != .none else { return }
            print("[SetDirection] \(direction)")
            switch direction {
            case .forward:
                nextIndex = targetParam?.0 ?? (currentIndex + 1)
                if nextIndex >= itemsCount {
                    nextIndex = 0
                }
                nextCell.frame = nextCell.frame.with {
                    if isHorizontal {
                        $0.origin.x = side * 2
                    } else {
                        $0.origin.y = side * 2
                    }
                }
            case .fastForward:
                reset()
            case .backward:
                nextIndex = targetParam?.0 ?? (currentIndex - 1)
                if nextIndex < 0 {
                    nextIndex = itemsCount - 1
                }
                nextCell.frame = nextCell.frame.with {
                    if isHorizontal {
                        $0.origin.x = 0
                    } else {
                        $0.origin.y = 0
                    }
                }
            case .fastBackward:
                reset()
            case .none:  break
            }
            delegate?.carouselView?(self, willDisappear: currentCell, at: currentIndex)
            delegate?.carouselView?(self, willAppear: nextCell, at: nextIndex)
        }
    }
    
    private var cellCls: CarouselViewCell.Type!
    private var isFirstLayout = true
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        guard !bounds.isEmpty else { return }
        guard isFirstLayout else { return }
        isFirstLayout = false
        
        // scroll
        scrollView.frame = bounds
        scrollView.contentInset = .zero
        
        let curFrame: CGRect, nextFrame: CGRect
        if isHorizontal {
            let width = bounds.width
            side = width
            
            scrollView.contentSize = CGSize(width: width * 3, height: 0)
            scrollView.contentOffset = CGPoint(x: width, y: 0)
            
            // cells
            curFrame = CGRect(origin: CGPoint(x: width, y: 0), size: bounds.size)
            nextFrame = CGRect(origin: CGPoint(x: width * 2, y: 0), size: bounds.size)
        } else {
            let height = bounds.height
            side = height
            
            scrollView.contentSize = CGSize(width: 0, height: height * 3)
            scrollView.contentOffset = CGPoint(x: 0, y: height)
            
            // cells
            curFrame = CGRect(origin: CGPoint(x: 0, y: height), size: bounds.size)
            nextFrame = CGRect(origin: CGPoint(x: 0, y: height * 2), size: bounds.size)
        }
        currentCell = cellCls.init(frame: curFrame).then {
            $0.carouselView = self
            $0.clipsToBounds = true
            scrollView.addSubview($0)
        }
        nextCell = cellCls.init(frame: nextFrame).then {
            $0.carouselView = self
            $0.clipsToBounds = true
            scrollView.addSubview($0)
        }
        if let p = targetParam {
            scrollToIndex(p.0, animated: p.1)
        } else {
            delegate?.carouselView?(self, willAppear: currentCell, at: currentIndex)
            delegate?.carouselView?(self, didAppear: currentCell, at: currentIndex)
        }
    }
}

// MARK: - Public Method
extension CarouselView {
    public var isTracking: Bool { scrollView.isTracking }
    public var isDragging: Bool { scrollView.isDragging }
    public var isDecelerating: Bool { scrollView.isDecelerating }
    
    public var isSilent: Bool {
        if scrollView.isTracking ||
            scrollView.isDragging ||
            scrollView.isDecelerating ||
            scrollView.isZooming { return false }
        return true
    }
    
    public var isScrollEnabled: Bool {
        get { scrollView.isScrollEnabled }
        set { scrollView.isScrollEnabled = newValue }
    }
    
    /// 滚动到指定位置
    public func scrollToIndex(_ index: Int, animated: Bool = true) {
        guard index >= 0 else { return }
        let idx = index % itemsCount
        guard currentIndex != idx else { return }
        targetParam = (idx, animated)
        if isFirstLayout { return }
        if idx > currentIndex {
            forward(animated: animated)
        } else {
            backward(animated: animated)
        }
        guard !animated else { return }
        let offset = isHorizontal ?
            scrollView.contentOffset.x :
            scrollView.contentOffset.y
         
        if offset > side {
            direction = .forward
        } else if offset < side {
            direction = .backward
        }
        scrollingDidEnd()
    }
    
    public func forward(animated: Bool) {
        if isHorizontal {
            scrollView.setContentOffset(CGPoint(x: side * 2, y: 0), animated: animated)
        } else {
            scrollView.setContentOffset(CGPoint(x: 0, y: side * 2), animated: animated)
        }
    }
    
    public func backward(animated: Bool) {
        scrollView.setContentOffset(.zero, animated: animated)
    }
    /// 注册cell
    public func register<T: CarouselViewCell>(_ cellClass: T.Type) {
        if !isFirstLayout {
            fatalError("this method can only be called onece!!!")
        }
        cellCls = cellClass
    }
}

// MARK: - UIScrollViewDelegate
extension CarouselView: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingDidEnd()
    }
    private func scrollingDidEnd() {
        direction = .none
        let offset = isHorizontal ?
            scrollView.contentOffset.x :
            scrollView.contentOffset.y
        let index = offset / side
        if index == 1 { return }
        
        delegate?.carouselView?(self, didDisappear: currentCell, at: currentIndex)
        delegate?.carouselView?(self, didAppear: nextCell, at: nextIndex)
        
        reset()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let p = targetParam, !p.1 { return }
        
        guard scrollView.contentSize != .zero else {
            return
        }
        let offset = isHorizontal ?
            scrollView.contentOffset.x :
            scrollView.contentOffset.y
         
        if offset > side {
            direction = .forward
            if offset > side * 2.05 {
                direction = .fastForward
            }
        } else if offset < side {
            direction = .backward
            if offset < -side * 0.05 {
                direction = .fastBackward
            }
        } else {
            direction = .none
        }
    }
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollingDidEnd()
    }
     
    private func reset() {
        (currentIndex, nextIndex) = (nextIndex, currentIndex)
         
        (currentCell.frame, nextCell.frame) = (nextCell.frame, currentCell.frame)
         
        (currentCell, nextCell) = (nextCell, currentCell)
        if isHorizontal {
            scrollView.contentOffset = CGPoint(x: side, y: 0)
        } else {
            scrollView.contentOffset = CGPoint(x: 0, y: side)
        }
        
        targetParam = nil
    }
}


public protocol ATPageViewDelegate: AnyObject {
    func pageView(_ pageView: ATPageView, cellAtIndex index: Int) -> ATPageView.Cell
    
    func pageView(_ pageView: ATPageView, didClickCell cell: UICollectionViewCell, at index: Int)
    func pageView(_ pageView: ATPageView, didSelectCell cell: UICollectionViewCell, at index: Int)
}
public extension ATPageViewDelegate {
    func pageView(_ pageView: ATPageView, didClickCell cell: UICollectionViewCell, at index: Int) {}
    func pageView(_ pageView: ATPageView, didSelectCell cell: UICollectionViewCell, at index: Int) {}
}

public final class ATPageView: UIView {
    public override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout().then {
            $0.scrollDirection = .horizontal
            $0.minimumLineSpacing = 0
            $0.minimumInteritemSpacing = 0
        }
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.contentInsetAdjustmentBehavior = .never
            $0.backgroundColor = .clear
            $0.isPagingEnabled = true
            $0.decelerationRate = .fast
            $0.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "DefaultCollectionViewCell")
        }
        super.init(frame: .zero)
        addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    public typealias Cell = UICollectionViewCell & Reusable
    public func registerCellType(_ cellType: Cell.Type) {
        collectionView.register(cellType: cellType)
    }
    public func dequeueReusableCell<T: Cell>(for index: Int) -> T {
        collectionView.dequeueReusableCell(for: IndexPath(item: index, section: 0), cellType: T.self)
    }
    
    public var isHorizontalScroll: Bool {
        layout.scrollDirection == .horizontal
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public weak var delegate: ATPageViewDelegate?
    public var itemsCount = 0
    
    private var _selectedIndex: Int = 0
    public var selectedIndex: Int {
        get { _selectedIndex }
        set {
            guard newValue != _selectedIndex else { return }
            scrollToIndex(newValue, animated: hasLayout)
        }
    }
    
    public func scrollToIndex(_ index: Int, animated: Bool) {
        if !animated { _selectedIndex = index }
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: isHorizontalScroll ? .centeredHorizontally : .centeredVertically, animated: animated)
    }
    public func forward() {
        selectedIndex += 1
    }
    public func backward() {
        selectedIndex -= 1
    }
    
    var isScrollEnabled: Bool {
        get { collectionView.isScrollEnabled }
        set { collectionView.isScrollEnabled = newValue }
    }
    
    private var hasLayout = false
    public override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = bounds
        guard !bounds.isEmpty, !hasLayout else { return }
        hasLayout = true
        collectionView.frame = bounds
        layout.itemSize = bounds.size
    }
    
    private let collectionView: UICollectionView
    public var layout: UICollectionViewFlowLayout {
        collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
}
extension ATPageView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        delegate?.pageView(self, didClickCell: cell, at: indexPath.item)
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingDidEnd()
    }
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollingDidEnd()
    }
    private func scrollingDidEnd() {
        let index = collectionView.pageIndex()
        guard index != _selectedIndex else { return }
        _selectedIndex = index
        guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) else { return }
        delegate?.pageView(self, didSelectCell: cell, at: index)
    }
}
extension ATPageView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        itemsCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        delegate?.pageView(self, cellAtIndex: indexPath.item) ??
        collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultCollectionViewCell", for: indexPath)
    }
}

