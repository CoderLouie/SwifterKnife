//
//  PagingView.swift
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
extension PagingListViewConvertible {
    func hostViewDidAppear() {}
    func hostViewDidDisappear() {}
}


public protocol PagingViewDataSource: AnyObject {
    func heightForHeader(in pagingView: PagingView) -> CGFloat
    func viewForHeader(in pagingView: PagingView) -> UIView
    
    func heightForPinHeader(in pagingView: PagingView) -> CGFloat
    func viewForPinHeader(in pagingView: PagingView) -> UIView
    
    func numberOfLists(in pagingView: PagingView) -> Int
    
    func pagingView(_ pagingView: PagingView, initListAtIndex index: Int) -> PagingListViewConvertible
}
public protocol PagingViewDelegate: AnyObject {
    func pagingViewDidScroll(_ scrollView: UIScrollView)
}
extension PagingViewDelegate {
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
open class PagingView: UIView {
    private override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(dataSource: PagingViewDataSource) {
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
    public weak var delegate: PagingViewDelegate?
    
    public private(set) lazy var selectedIndex = defaultSelectedIndex
    public private(set) unowned var dataSource: PagingViewDataSource
    
    private var selectedListView: UIScrollView? {
        listMap[selectedIndex]?.listView
    }
    private var initialListViewOffsetY: CGFloat {
//        selectedListView?.contentOffset.y ?? -headerContainerViewH
        -headerContainerViewH + min(-headerContainerViewY, headerH)
    }
    private var listMap: [Int: PagingList] = [:]
    private var canSeenHeader = false
    private var headerContainerView: UIView!
    private unowned var collectionView: MainCollectionView!
    public var listCollectionView: UICollectionView {
        collectionView
    }
    private var headerContainerViewY: CGFloat = 0
    private var headerContainerViewH: CGFloat = 0
    private var headerH: CGFloat = 0
    private var pinHeaderH: CGFloat = 0
}

extension PagingView {
    public func reloadData() {
        canSeenHeader = false
        headerContainerViewY = 0
        removeObserver()
        listMap.forEach {
            $0.value.list.hostView.removeFromSuperview()
        }
        listMap.removeAll()
        headerH = dataSource.heightForHeader(in: self)
        pinHeaderH = dataSource.heightForPinHeader(in: self)
        
        headerContainerViewH = headerH + pinHeaderH
        let size = bounds.size
        headerContainerView.frame = CGRect(x: 0, y: 0, width: size.width, height: headerContainerViewH)
        
        dataSource.viewForHeader(in: self).do {
            $0.frame = CGRect(x: 0, y: 0, width: size.width, height: headerH)
            headerContainerView.addSubview($0)
        }
        dataSource.viewForPinHeader(in: self).do {
            $0.frame = CGRect(x: 0, y: headerH, width: size.width, height: pinHeaderH)
            headerContainerView.addSubview($0)
        }
        
        collectionView.contentOffset = CGPoint(x: size.width * CGFloat(selectedIndex), y: 0)
        collectionView.reloadData()
    }
}

private extension PagingView {
    func removeObserver() {
        listMap.forEach {
            let listView = $0.value.listView
            listView.removeObserver(self, forKeyPath: "contentOffset")
            listView.removeObserver(self, forKeyPath: "contentSize")
        }
    }
    func collectionViewDidEndScroll(at index: Int) {
        guard index != selectedIndex else { return }
        guard let item = listMap[index],
            let oldItem = listMap[selectedIndex] else { return }
        selectedIndex = index
        oldItem.listView.scrollsToTop = false
        let listView = item.listView
        listView.scrollsToTop = true
        if listView.contentOffset.y <= -pinHeaderH {
            headerContainerView.frame.origin.y = 0
            item.headerView.addSubview(headerContainerView)
        }
    }
    func index(of listView: UIScrollView) -> Int? {
        listMap.first { $0.value.listView === listView }?.key
    }
}

extension PagingView {
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let scrollView = object as? UIScrollView else { return }
        if keyPath == "contentOffset" {
            listViewDidScroll(scrollView)
        } else if keyPath == "contentSize" {
            let minContentSizeH = bounds.height - pinHeaderH
            let contentSize = scrollView.contentSize
            if contentSize.height < minContentSizeH {
                scrollView.contentSize = CGSize(width: contentSize.width, height: minContentSizeH)
                if let selectedListView = selectedListView, scrollView !== selectedListView {
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
        
        let offset = listView.contentOffset
        let scrollY = offset.y + listView.contentInset.top
        if scrollY < headerH {
            canSeenHeader = true
            headerContainerViewY = -scrollY
            for (index, item) in listMap {
                if index == selectedIndex { continue }
                item.listView.contentOffset = offset
            }
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
            if canSeenHeader {
                canSeenHeader = false
                headerContainerViewY = -headerH
                for (index, item) in listMap {
                    if index == selectedIndex { continue }
                    item.listView.contentOffset = CGPoint(x: 0, y: headerContainerViewY)
                }
            }
        }
    }
}

extension PagingView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfLists(in: self)
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PagingCellIdentifer, for: indexPath)
        let row = indexPath.item
        let item = listMap[indexPath.item] ?? {
            let convertable = dataSource.pagingView(self, initListAtIndex: row)
            let hostView = convertable.hostView
            hostView.setNeedsLayout()
            hostView.layoutIfNeeded()
            
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
            listView.contentOffset = CGPoint(x: 0, y: initialListViewOffsetY)
            let header = UIView(frame: CGRect(x: 0, y: -headerContainerViewH, width: bounds.width, height: headerContainerViewH))
            listView.addSubview(header)
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
extension PagingView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.pagingViewDidScroll(scrollView)
        let percent = scrollView.contentOffset.x/scrollView.bounds.size.width
        let index = Int(percent)

        if index != selectedIndex,
           percent - CGFloat(index) == 0,
           !scrollView.isDragging,
           !scrollView.isDecelerating,
           listMap[index]?.listView.contentOffset.y ?? 0 < -pinHeaderH {
            collectionViewDidEndScroll(at: index)
        } else {
            if headerContainerView.superview != self {
                headerContainerView.frame.origin.y = headerContainerViewY
                addSubview(headerContainerView)
            }
            if index != selectedIndex {
                selectedListView?.scrollsToTop = false
                selectedIndex = index
                selectedListView?.scrollsToTop = true
            }
        }
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let index = Int(scrollView.contentOffset.x/scrollView.bounds.size.width)
            collectionViewDidEndScroll(at: index)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x/scrollView.bounds.size.width)
        collectionViewDidEndScroll(at: index)
    }
}
extension PagingView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        listMap[indexPath.row]?.list.hostViewDidAppear()
    }
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        listMap[indexPath.row]?.list.hostViewDidDisappear()
    }
}
extension PagingView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return bounds.size
    }
}
