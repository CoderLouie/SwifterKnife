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
    public override init(frame: CGRect) {
        super.init(frame: .zero)
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
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
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
    open var itemsCount: Int = 0 {
        willSet {
            guard newValue > 1 else {
                fatalError("the items count should be at least 2")
            }
        }
        didSet {
            if itemsCount == oldValue { return }
            if isFirstLayout { return }
            
            targetIndex = nil
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
    private var targetIndex: Int?
    
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
            switch direction {
            case .forward:
                nextIndex = targetIndex ?? (currentIndex + 1)
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
                nextIndex = targetIndex ?? (currentIndex - 1)
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
    
    private var isFirstLayout = true
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard isFirstLayout else { return }
        isFirstLayout = false
        
        let bounds = self.bounds
        // scroll
        scrollView.frame = bounds
        scrollView.contentInset = .zero
        
        if isHorizontal {
            let width = bounds.width
            side = width
            
            scrollView.contentSize = CGSize(width: width * 3, height: 0)
            scrollView.contentOffset = CGPoint(x: width, y: 0)
            
            // cells
            currentCell.frame = CGRect(origin: CGPoint(x: width, y: 0), size: bounds.size)
            nextCell.frame = CGRect(origin: CGPoint(x: width * 2, y: 0), size: bounds.size)
        } else {
            let height = bounds.height
            side = height
            
            scrollView.contentSize = CGSize(width: 0, height: height * 3)
            scrollView.contentOffset = CGPoint(x: 0, y: height)
            
            // cells
            currentCell.frame = CGRect(origin: CGPoint(x: 0, y: height), size: bounds.size)
            nextCell.frame = CGRect(origin: CGPoint(x: 0, y: height * 2), size: bounds.size)
        }
        
        delegate?.carouselView?(self, willAppear: currentCell, at: currentIndex)
        delegate?.carouselView?(self, didAppear: currentCell, at: currentIndex)
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
    public func scrollToIndex(_ index: Int) {
        guard index >= 0 else { return }
        let idx = index % itemsCount
        guard currentIndex != idx else { return }
        targetIndex = idx
        if idx > currentIndex {
            forward()
        } else {
            backward()
        }
    }
    
    public func forward() {
        if isHorizontal {
            scrollView.setContentOffset(CGPoint(x: side * 2, y: 0), animated: true)
        } else {
            scrollView.setContentOffset(CGPoint(x: 0, y: side * 2), animated: true)
        }
    }
    public func backward() {
        scrollView.setContentOffset(.zero, animated: true)
    }
    
    /// 注册cell
    public func register<T: CarouselViewCell>(_ cellClass: T.Type) {
        if !isFirstLayout {
            fatalError("this method can only be called onece!!!")
        }
        currentCell = T().then {
            $0.carouselView = self
            $0.clipsToBounds = true
            scrollView.addSubview($0)
        }
        nextCell = T().then {
            $0.carouselView = self
            $0.clipsToBounds = true
            scrollView.addSubview($0)
        }
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
        
        targetIndex = nil
    }
}


public protocol ATPageViewDelegate: AnyObject {
    func pageView(_ pageView: ATPageView, configCell cell: UICollectionViewCell, at index: Int)
    func pageView(_ pageView: ATPageView, didClickCell cell: UICollectionViewCell, at index: Int)
    func pageView(_ pageView: ATPageView, didSelectCell cell: UICollectionViewCell, at index: Int)
}
public extension ATPageViewDelegate {
    func pageView(_ pageView: ATPageView, didClickCell cell: UICollectionViewCell, at index: Int) {}
    func pageView(_ pageView: ATPageView, didSelectCell cell: UICollectionViewCell, at index: Int) {}
}

public final class ATPageView: UIView {
    public override init(frame: CGRect) {
        layout = UICollectionViewFlowLayout().then {
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
            $0.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        }
        super.init(frame: .zero)
        addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
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
            _selectedIndex = newValue
            scrollToIndex(newValue, animated: hasLayout)
        }
    }
    
    public func scrollToIndex(_ index: Int, animated: Bool) {
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: isHorizontalScroll ? .centeredHorizontally : .centeredVertically, animated: animated)
    }
    public func forward() {
        selectedIndex += 1
    }
    public func backward() {
        selectedIndex -= 1
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
    public let layout: UICollectionViewFlowLayout
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        delegate?.pageView(self, configCell: cell, at: indexPath.item)
        return cell
    }
}
