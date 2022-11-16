//
//  PagingSmoothView.swift
//  SwifterKnife
//
//  Created by 李阳 on 2022/11/14.
//

import UIKit

fileprivate class MainCollectionView: UICollectionView {
    var headerContainerView: UIView?
}
extension MainCollectionView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = headerContainerView else { return true }
        let point = touch.location(in: view)
        return !view.bounds.contains(point)
    }
}

public protocol PagingListViewConvertible: AnyObject {
    var hostView: UIView { get }
    var scrollView: UIScrollView { get }
    
    func hostViewDidAppear()
    func hostViewDidDisappear()
}
public extension PagingListViewConvertible {
    func hostViewDidAppear() {}
    func hostViewDidDisappear() {}
}


public protocol PagingSmoothViewDataSource: AnyObject {
    func heightForHeader(in pagingView: PagingSmoothView) -> CGFloat?
    func viewForHeader(in pagingView: PagingSmoothView) -> UIView
    
    func heightForPinHeader(in pagingView: PagingSmoothView) -> CGFloat?
    func viewForPinHeader(in pagingView: PagingSmoothView) -> UIView
    
    func numberOfLists(in pagingView: PagingSmoothView) -> Int
    
    func pagingView(_ pagingView: PagingSmoothView, initListAtIndex index: Int) -> PagingListViewConvertible
}
public extension PagingSmoothViewDataSource {
    func heightForHeader(in pagingView: PagingSmoothView) -> CGFloat? { nil }
    func heightForPinHeader(in pagingView: PagingSmoothView) -> CGFloat? { nil }
}
public protocol PagingSmoothViewDelegate: AnyObject {
    func pagingViewDidScroll(_ scrollView: UIScrollView)
}
extension PagingSmoothViewDelegate {
    func pagingViewDidScroll(_ scrollView: UIScrollView) {}
}

fileprivate let PagingCellIdentifer = "PagingCell"
fileprivate final class PagingList {
    let list: PagingListViewConvertible
    let headerView: UIView
    init(list: PagingListViewConvertible, header view: UIView) {
        self.list = list
        self.headerView = view
    }
}
extension PagingList {
    var view: UIView { list.hostView }
    var listView: UIScrollView { list.scrollView }
}
open class PagingSmoothView: UIView {
    private override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(dataSource: PagingSmoothViewDataSource) {
        self.dataSource = dataSource
        super.init(frame: .zero)
        
        let headerContainerView = UIView()
        self.headerContainerView = headerContainerView
        
        collectionView = MainCollectionView(frame: .zero, collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.scrollDirection = .horizontal
            return layout
        }()).then {
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .clear
            $0.isPagingEnabled = true
            $0.bounces = false
            $0.showsHorizontalScrollIndicator = false
            $0.scrollsToTop = false
            $0.register(UICollectionViewCell.self, forCellWithReuseIdentifier: PagingCellIdentifer)
            $0.isPrefetchingEnabled = false
            if #available(iOS 11.0, *) {
                $0.contentInsetAdjustmentBehavior = .never
            }
            $0.headerContainerView = headerContainerView
            addSubview($0)
        }
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        if headerContainerView.frame.isEmpty {
            reloadData()
        }
    }
    deinit {
        removeObserver()
    }
    public var defaultSelectedIndex: Int = 0
    public weak var delegate: PagingSmoothViewDelegate?
    
    public private(set) lazy var selectedIndex = defaultSelectedIndex
    public private(set) unowned var dataSource: PagingSmoothViewDataSource
     
    private var initialListViewOffsetY: CGFloat {
        -headerContainerViewH + min(-headerContainerViewY, headerH)
    }
    private var listMap: [Int: PagingList] = [:]
    private var needAdjusted = false
    private var headerContainerView: UIView!
    private unowned var collectionView: MainCollectionView!
    var selectedListView: UIScrollView? {
        listMap[selectedIndex]?.listView
    }
    public var listCollectionView: UICollectionView {
        collectionView
    }
    private var headerContainerViewY: CGFloat = 0
    private var headerContainerViewH: CGFloat = 0
    private var headerH: CGFloat = 0
    private var pinHeaderH: CGFloat = 0
}

extension PagingSmoothView {
    public func reloadData() {
        headerContainerViewY = 0
        removeObserver()
        for item in listMap.values {
            item.view.removeFromSuperview()
        }
        listMap.removeAll()
        let size = bounds.size
        
        let n = dataSource.numberOfLists(in: self)
        selectedIndex = min(selectedIndex, n - 1)
        headerContainerView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        dataSource.viewForHeader(in: self).do {
            headerH = dataSource.heightForHeader(in: self) ?? $0.fittingSize(withRequiredWidth: size.width).height
            $0.frame = CGRect(x: 0, y: 0, width: size.width, height: headerH)
            headerContainerView.addSubview($0)
        }
        headerContainerViewH = headerH
        if n == 0 {
            pinHeaderH = 0
        } else {
            dataSource.viewForPinHeader(in: self).do {
                pinHeaderH = dataSource.heightForPinHeader(in: self) ?? $0.fittingSize(withRequiredWidth: size.width).height
                $0.frame = CGRect(x: 0, y: headerH, width: size.width, height: pinHeaderH)
                headerContainerView.addSubview($0)
            }
        }
        headerContainerViewH += pinHeaderH
        headerContainerView.frame = CGRect(x: 0, y: 0, width: size.width, height: headerContainerViewH)
        
        collectionView.contentOffset = CGPoint(x: size.width * CGFloat(selectedIndex), y: 0)
        collectionView.reloadData()
    }
}

private extension PagingSmoothView {
    func removeObserver() {
        listMap.forEach {
            let listView = $0.value.listView
            listView.removeObserver(self, forKeyPath: "contentOffset")
            listView.removeObserver(self, forKeyPath: "contentSize")
        }
    }
    func collectionViewDidEndScroll(at index: Int) {
        if index != selectedIndex {
            selectedListView?.scrollsToTop = false
            selectedIndex = index
            selectedListView?.scrollsToTop = true
        }
        guard let item = listMap[index] else { return }
        let listView = item.listView
        if listView.contentOffset.y <= -pinHeaderH {
            headerContainerView.frame.origin.y = 0
            item.headerView.addSubview(headerContainerView)
        }
    }
    func index(of listView: UIScrollView) -> Int? {
        listMap.first { $0.value.listView === listView }?.key
    }
}

extension PagingSmoothView {
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let scrollView = object as? UIScrollView else { return }
        if keyPath == "contentOffset" {
            listViewDidScroll(scrollView)
        } else if keyPath == "contentSize" {
            let minContentSizeH = bounds.height - pinHeaderH
            let contentSize = scrollView.contentSize
            if contentSize.height < minContentSizeH {
                scrollView.contentSize = CGSize(width: contentSize.width, height: minContentSizeH)
                if let current = selectedListView,
                    scrollView !== current {
                    scrollView.contentOffset = CGPoint(x: 0, y: initialListViewOffsetY)
                }
            }
        }
    }
    private func listViewDidScroll(_ listView: UIScrollView) {
        if collectionView.isDragging ||
            collectionView.isDecelerating { return }
        guard let index = index(of: listView),
        index == selectedIndex else { return }
        needAdjusted = true
        
        let offset = listView.contentOffset
        let scrollY = offset.y + listView.contentInset.top
        if scrollY < headerH {
            headerContainerViewY = -scrollY
            guard let headerView = listMap[index]?.headerView else {
                return
            }
            if headerContainerView.superview != headerView {
                headerContainerView.frame.origin.y = 0
                headerView.addSubview(headerContainerView)
            }
        } else {
            if headerContainerView.superview != self {
                headerContainerView.frame.origin.y = -headerH
                addSubview(headerContainerView)
            }
            headerContainerViewY = -headerH
        }
    }
}

extension PagingSmoothView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfLists(in: self)
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PagingCellIdentifer, for: indexPath)
        let row = indexPath.item
        let item = listMap[indexPath.item] ?? {
            let convertable = dataSource.pagingView(self, initListAtIndex: row)
            let view = convertable.hostView
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            view.frame = cell.contentView.bounds
            cell.contentView.addSubview(view)
            view.setNeedsLayout()
            view.layoutIfNeeded()
            
            let listView = convertable.scrollView
            listView.scrollsToTop = row == selectedIndex
            if let tableView = listView as? UITableView {
                tableView.estimatedRowHeight = 0
                tableView.estimatedSectionHeaderHeight = 0
                tableView.estimatedSectionFooterHeight = 0
            }
            if #available(iOS 11.0, *) {
                listView.contentInsetAdjustmentBehavior = .never
            }
            listView.contentInset = UIEdgeInsets(top: headerContainerViewH, left: 0, bottom: 0, right: 0)
            let header = UIView(frame: CGRect(x: 0, y: -headerContainerViewH, width: bounds.width, height: headerContainerViewH))
            listView.addSubview(header)
            
            listView.contentOffset = CGPoint(x: 0, y: initialListViewOffsetY)
            if headerContainerView.superview == nil {
                header.addSubview(headerContainerView)
            }
            listView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
            listView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
             
            let item = PagingList(list: convertable, header: header)
            listMap[row] = item
            return item
        }()
        let hostView = item.view
        if hostView.superview != cell.contentView {
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            hostView.frame = cell.contentView.bounds
            cell.contentView.addSubview(hostView)
        }
        return cell
    }
}
extension PagingSmoothView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if needAdjusted, let current = selectedListView {
            if -headerContainerViewY < headerH {
                let offset = current.contentOffset
                for (index, item) in listMap {
                    if index == selectedIndex { continue }
                    item.listView.contentOffset = offset
                }
            } else {
                for (index, item) in listMap {
                    if index == selectedIndex { continue }
                    let listView = item.listView
                    if listView.contentOffset.y >= -pinHeaderH { continue }
                    item.listView.contentOffset = CGPoint(x: 0, y: -pinHeaderH)
                }
            }
            needAdjusted = false
        }
        delegate?.pagingViewDidScroll(scrollView)
        let percent = scrollView.contentOffset.x / scrollView.bounds.size.width
        let index = Int(percent)

        if index != selectedIndex,
           percent - CGFloat(index) == 0,
           !scrollView.isDragging,
           !scrollView.isDecelerating {
            collectionViewDidEndScroll(at: index)
        } else {
            if headerContainerView.superview != self {
                headerContainerView.frame.origin.y = headerContainerViewY
                addSubview(headerContainerView)
            }
        }
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let index = Int(scrollView.contentOffset.x/scrollView.bounds.size.width)
            collectionViewDidEndScroll(at: index)
        }
    }
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x/scrollView.bounds.size.width)
        collectionViewDidEndScroll(at: index)
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x/scrollView.bounds.size.width)
        collectionViewDidEndScroll(at: index)
    }
}
extension PagingSmoothView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        listMap[indexPath.row]?.list.hostViewDidAppear()
    }
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        listMap[indexPath.row]?.list.hostViewDidDisappear()
    }
}
extension PagingSmoothView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return bounds.size
    }
}
