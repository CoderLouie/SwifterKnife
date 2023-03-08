//
//  SKStackView.swift
//  SwifterKnife
//
//  Created by liyang on 2023/2/14.
//

import UIKit

public final class SKStackView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private enum LayoutKeys {
        static let top = "me.muukii.StackScrollView.top"
        static let right = "me.muukii.StackScrollView.right"
        static let left = "me.muukii.StackScrollView.left"
        static let bottom = "me.muukii.StackScrollView.bottom"
        static let width = "me.muukii.StackScrollView.width"
        static let height = "me.muukii.StackScrollView.height"
        
        static let separatorTag = -123124
    }
    
    private static func defaultLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        return layout
    }
    
    @available(*, unavailable)
    public override var dataSource: UICollectionViewDataSource? {
        didSet { }
    }
    
    @available(*, unavailable)
    public override var delegate: UICollectionViewDelegate? {
        didSet { }
    }
    
    private var direction: UICollectionView.ScrollDirection {
        flowLayout.scrollDirection
    }
    
    public var separatorInset: UIEdgeInsets = .zero
    public var showSeparators = false
    
    public var flowLayout: UICollectionViewFlowLayout {
        (collectionViewLayout as! UICollectionViewFlowLayout)
    }
    
    // MARK: - Initializers
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    public convenience init(frame: CGRect) {
        self.init(frame: frame, collectionViewLayout: SKStackView.defaultLayout())
        setup()
    }
    public convenience init(flowLayout: (UICollectionViewFlowLayout) -> Void) {
        let layout = SKStackView.defaultLayout()
        flowLayout(layout)
        self.init(frame: .zero, collectionViewLayout: layout)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate final class ViewItem {
        let view: UIView
        var size: CGSize?
        
        init(_ view: UIView) {
            self.view = view
        }
    }
    private var items: [ViewItem] = []
    private func indexOf(_ view: UIView) -> Int? {
        items.firstIndex { $0.view === view }
    }
    public var views: [UIView] {
        items.map(\.view)
    }
    
    public subscript<V: UIView>(safe index: Int) -> V? {
        guard items.indices.contains(index) else { return nil }
        return items[index].view as? V
    }
    public subscript<V: UIView>(index: Int) -> V {
        return items[index].view as! V
    }
    
    private func identifier(_ v: UIView) -> String {
        return v.hashValue.description
    }
    
    private func setup() {
         
        contentInsetAdjustmentBehavior = .never
        
        switch direction {
        case .vertical:
            alwaysBounceVertical = true
        case .horizontal:
            alwaysBounceHorizontal = true
        @unknown default:
            fatalError()
        }
        
        delaysContentTouches = false
        keyboardDismissMode = .onDrag
        backgroundColor = .clear
        
        super.delegate = self
        super.dataSource = self
    }
    
    public override func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }
    
    public func append(view: UIView) {
        items.append(.init(view))
        register(Cell.self, forCellWithReuseIdentifier: identifier(view))
    }
    
    public func append(views _views: [UIView]) {
        items += _views.map(ViewItem.init(_:))
        _views.forEach { view in
            register(Cell.self, forCellWithReuseIdentifier: identifier(view))
        }
    }
    
    public func insert(views _views: [UIView], at index: Int, animated: Bool, completion: @escaping () -> Void) {
        
        layoutIfNeeded()
        
        var _views = _views
        _views.removeAll(where: views.contains(_:))
        items.insert(contentsOf: _views.map(ViewItem.init(_:)), at: index)
        _views.forEach { view in
            register(Cell.self, forCellWithReuseIdentifier: identifier(view))
        }
        execute(animated: animated) {
            self.performBatchUpdates {
                self.insertItems(at: (index ..< index.advanced(by: _views.count)).map({ IndexPath(item: $0, section: 0) }))
            } completion: { _ in completion() }
        }
    }
    
    public func insert(views _views: [UIView], before view: UIView, animated: Bool, completion: @escaping () -> Void = {}) {
        
        guard let index = views.firstIndex(of: view) else {
            completion()
            return
        }
        insert(views: _views, at: index, animated: animated, completion: completion)
    }
    
    public func insert(views _views: [UIView], after view: UIView, animated: Bool, completion: @escaping () -> Void = {}) {
        guard let index = indexOf(view)?.advanced(by: 1) else {
            completion()
            return
        }
        insert(views: _views, at: index, animated: animated, completion: completion)
    }
    
    public func remove(view: UIView, animated: Bool, completion: @escaping () -> Void = {}) {
        remove(views: [view], animated: animated, completion: completion)
    }
    
    public func remove(views: [UIView], animated: Bool, completion: @escaping () -> Void = {}) {
        handle(views: views, animated: animated) { indices in
            indices.forEach {
                self.items.remove(at: $0)
            }
        } work: {
            self.deleteItems(at: $0)
        } completion: {
            completion()
        }
    }
    
    
    public func reload(view: UIView, animated: Bool, completion: @escaping () -> Void = {}) {
        reload(views: [view], animated: animated, completion: completion)
    }
    public func reload(views: [UIView], animated: Bool, completion: @escaping () -> Void = {}) {
        handle(views: views, animated: animated) { indices in
            indices.forEach {
                self.items[$0].size = nil
            }
        } work: {
            self.reloadItems(at: $0)
        } completion: {
            completion()
        }
    }
    
    private func handle(views: [UIView],
                        animated: Bool,
                        indicesPrepared: (([Int]) -> Void)? = nil,
                        work: @escaping ([IndexPath]) -> Void,
                        completion: @escaping () -> Void = {}) {
        
        layoutIfNeeded()
        
        // It seems that the layout is not updated properly unless the order is aligned.
        let indicesForRemove = views.compactMap(indexOf(_:)).sorted(by: >)
        
        indicesPrepared?(indicesForRemove)
        
        execute(animated: animated) {
            self.performBatchUpdates {
                work(indicesForRemove.map { IndexPath.init(item: $0, section: 0) })
            } completion: { _ in completion() }
        }
    }
    
    public func scroll(to view: UIView, at position: UICollectionView.ScrollPosition, animated: Bool) {
        if let index = indexOf(view) {
            scrollToItem(at: IndexPath(item: index, section: 0), at: position, animated: animated)
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = items[indexPath.item]
        let view = item.view
        let _identifier = identifier(view)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: _identifier, for: indexPath)
        
        let contentView = cell.contentView
        
        if view.superview === contentView { return cell }
        
        precondition(contentView.subviews.isEmpty)
        
        if view is ManualLayoutSKStackCellType {
            
            contentView.addSubview(view)
            
        } else {
            
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            contentView.addSubview(view)
            
            let top = view.topAnchor.constraint(equalTo: contentView.topAnchor)
            let right = view.rightAnchor.constraint(equalTo: contentView.rightAnchor)
            let bottom = view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            let left = view.leftAnchor.constraint(equalTo: contentView.leftAnchor)
            
            top.identifier = LayoutKeys.top
            right.identifier = LayoutKeys.right
            bottom.identifier = LayoutKeys.bottom
            left.identifier = LayoutKeys.left
            
            NSLayoutConstraint.activate(
                [top, right, bottom, left])
        }
        var showSeparators = (view as? SKStackCellType)?.showSeparators ?? showSeparators
        if indexPath.item == items.count - 1 {
            showSeparators = false
        }
        let existLineView: UIView?
        if let v = contentView.subviews.last, v.tag == LayoutKeys.separatorTag {
            existLineView = v
        } else { existLineView = nil }
        
        if showSeparators, let size = item.size {
            
            let lineView: UIView
            if let v = existLineView {
                lineView = v
            } else {
                lineView = UIView()
                lineView.tag = LayoutKeys.separatorTag
                lineView.backgroundColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.29)
                contentView.addSubview(lineView)
            }
            let lineH = 1 / UIScreen.main.scale
            let inset = (view as? SKStackCellType)?.separatorInset ?? separatorInset
            switch direction {
            case .horizontal:
                let w = lineH
                lineView.frame = CGRect(x: size.width - w - inset.right, y: inset.top, width: w, height: size.height - inset.top - inset.bottom)
            case .vertical:
                let h = lineH
                lineView.frame = CGRect(x: inset.left, y: size.height - h - inset.bottom, width: size.width - inset.left - inset.right, height: h)
            @unknown default: fatalError()
            }
        } else {
            existLineView?.isHidden = true
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let item = items[indexPath.item]
        if let size = item.size {
            return size
        }
        let size: CGSize
        let view = item.view
        let direction = direction
        let csize = collectionView.bounds.size
        
        if let view = view as? ManualLayoutSKStackCellType {
            
            switch direction {
            case .vertical:
                size = view.size(maxWidth: csize.width, maxHeight: nil)
            case .horizontal:
                size = view.size(maxWidth: nil, maxHeight: csize.height)
            @unknown default:
                fatalError()
            }
        } else {
            switch direction {
            case .vertical:
                let width: NSLayoutConstraint = {
                    
                    guard let c = view.constraints.first(where: { $0.identifier == LayoutKeys.width }) else {
                        let width = view.widthAnchor.constraint(equalToConstant: csize.width)
                        width.identifier = LayoutKeys.width
                        width.isActive = true
                        return width
                    }
                    
                    return c
                }()
                
                width.constant = csize.width
                
                size = view.superview?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                
            case .horizontal:
                
                let heightConstraint: NSLayoutConstraint = {
                    
                    guard let c = view.constraints.first(where: { $0.identifier == LayoutKeys.height }) else {
                        let heightConstraint = view.heightAnchor.constraint(equalToConstant: csize.height)
                        heightConstraint.identifier = LayoutKeys.height
                        heightConstraint.isActive = true
                        return heightConstraint
                    }
                    
                    return c
                }()
                
                heightConstraint.constant = csize.height
                
                size = view.superview?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                
            @unknown default:
                fatalError()
            }
        }
        item.size = size
        return size
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let view = items[indexPath.item].view
        if let skcell = view as? SKStackCellType {
            skcell.didSelect(by: self)
        }
    }
    
    public func updateLayout(animated: Bool) {
        execute(animated: animated) {
            self.items.forEach { $0.size = nil }
            self.performBatchUpdates(nil, completion: nil)
            self.layoutIfNeeded()
        }
    }
    
    private func execute(animated: Bool,
                         closure: @escaping () -> Void,
                         completion: ((Bool) -> Void)? = nil) {
        
        if animated {
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: [
                    .beginFromCurrentState,
                    .allowUserInteraction,
                    .overrideInheritedCurve,
                    .overrideInheritedOptions,
                    .overrideInheritedDuration
                ],
                animations: closure, completion: completion)
        } else {
            UIView.performWithoutAnimation(closure)
        }
    }
    
    final class Cell: UICollectionViewCell {
        override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            return layoutAttributes
        }
    }
}
