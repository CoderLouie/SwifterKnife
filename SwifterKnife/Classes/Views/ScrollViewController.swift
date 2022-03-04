//
//  ScrollViewController.swift
//  SwifterKnife
//
//  Created by liyang on 2022/2/8.
//

import UIKit

open class ScrollViewController: UIViewController {
    public enum ScrollDirection {
        case horizontal
        case vertical
    }
    
    open var scrollDirection: ScrollDirection {
        .vertical
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupViews()
    }
    
    open func setup() {}
    open func setupViews() {}
    
    open override func loadView() {
        let scrollView = UIScrollView().then { s in
            s.backgroundColor = .clear
            s.showsVerticalScrollIndicator = false
            s.showsHorizontalScrollIndicator = false
            s.delegate = self
        }
        contentView = UIView().then {
            scrollView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.edges.equalTo(scrollView)
                if case .vertical = scrollDirection {
                    make.width.equalToSuperview()
                } else {
                    make.height.equalToSuperview()
                }
            }
        }
        view = scrollView
    }
    public var scrollView: UIScrollView {
        view as! UIScrollView
    }
    public unowned var contentView: UIView!
}

extension ScrollViewController: UIScrollViewDelegate { }
