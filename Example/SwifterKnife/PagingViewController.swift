//
//  PagingViewController.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2022/11/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import SwifterKnife
import SnapKit
import JXSegmentedView

class PagingViewController: UIViewController {
    lazy var paging: PagingView = {
        return PagingView(dataSource: self)
    }()
    lazy var segmentedView: JXSegmentedView = {
        return JXSegmentedView()
    }()
    lazy var headerView: UIImageView = {
        return UIImageView(image: UIImage(named: "lufei.jpg"))
    }()
    let dataSource = JXSegmentedTitleDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false

        view.addSubview(paging)

        dataSource.titles = ["能力", "爱好", "队友"]
        dataSource.titleSelectedColor = UIColor(red: 105/255, green: 144/255, blue: 239/255, alpha: 1)
        dataSource.titleNormalColor = UIColor.black
        dataSource.isTitleColorGradientEnabled = true
        dataSource.isTitleZoomEnabled = true

        segmentedView.backgroundColor = .white
        segmentedView.isContentScrollViewClickTransitionAnimationEnabled = false
        segmentedView.delegate = self
        segmentedView.dataSource = dataSource

        let line = JXSegmentedIndicatorLineView()
        line.indicatorColor = UIColor(red: 105/255, green: 144/255, blue: 239/255, alpha: 1)
        line.indicatorWidth = 30
        segmentedView.indicators = [line]

        headerView.clipsToBounds = true
        headerView.contentMode = .scaleAspectFill

        segmentedView.contentScrollView = paging.listCollectionView

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "reload", style: .plain, target: self, action: #selector(didNaviRightItemClick))
        paging.listCollectionView.panGestureRecognizer.require(toFail: navigationController!.interactivePopGestureRecognizer!)
    }

    @objc func didNaviRightItemClick() {
        dataSource.titles = ["第一", "第二", "第三"]
        dataSource.reloadData(selectedIndex: 1)
        segmentedView.defaultSelectedIndex = 1
        paging.defaultSelectedIndex = 1
        segmentedView.reloadData()
        paging.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        paging.frame = view.bounds
    }
}

extension PagingViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = (index == 0)
    }
}

extension PagingViewController: PagingViewDataSource {
    func heightForHeader(in pagingView: PagingView) -> CGFloat? {
        return 300
    }

    func viewForHeader(in pagingView: PagingView) -> UIView {
        return headerView
    }
    func heightForPinHeader(in pagingView: PagingView) -> CGFloat? {
        return 50
    }

    func viewForPinHeader(in pagingView: PagingView) -> UIView {
        return segmentedView
    }

    func numberOfLists(in pagingView: PagingView) -> Int {
        return dataSource.titles.count
//        return 0
    }

    func pagingView(_ pagingView: PagingView, initListAtIndex index: Int) -> PagingListViewConvertible {
        let vc = SmoothListViewController()
        vc.title = dataSource.titles[index]
//        NSLog("initListAtIndex at\(index) \(vc.tableView)")
        return vc
    }
}
 


class TestTableView: UITableView {
    override var contentOffset: CGPoint {
        didSet {
            if contentOffset.y == -300 {
                print("")
            }
        }
    }
}

class SmoothListViewController: UIViewController, PagingListViewConvertible, UITableViewDataSource, UITableViewDelegate {
    
    deinit {
        print("SmoothListViewController deinit")
    }
    lazy var tableView: UITableView = {
        return TestTableView(frame: CGRect.zero, style: .plain)
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.frame = view.bounds
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(title ?? ""):\(indexPath.row)"
        return cell
    } 
    var hostView: UIView {
        return view
    }
    var scrollView: UIScrollView {
        return tableView
    }
}
