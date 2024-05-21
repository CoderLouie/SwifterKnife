//
//  WaterflowVC.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/11/30.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import SwifterKnife

class GifMakeOptionCell: UICollectionViewCell, Reusable {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        label = UILabel().then {
            $0.backgroundColor = .yellow
            $0.font = UIFont.systemFont(ofSize: 25)
            $0.textAlignment = .center
            contentView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func setIndex(_ index: Int) {
        label.text = "\(index)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private unowned var label: UILabel!
}
class WaterflowVC: BaseViewController {
    private var items = (1...55).map { $0 }
    override func setupViews() {
        super.setupViews()
        let spacing = 10.fit
        let layout = WaterflowLayout()
        layout.rowSpacing = spacing
        layout.columnSpacing = spacing
        layout.columnWidthRatios = [1, 2, 1, 1]
        layout.delegate = self
        layout.edgeInset = UIEdgeInsets(top: spacing, left: spacing * 2, bottom: spacing + Screen.safeAreaB, right: spacing * 2)
        
        UICollectionView(frame: .zero, collectionViewLayout: layout).do { collectionView in
            view.addSubview(collectionView)
//            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.backgroundColor = .clear
            collectionView.contentInsetAdjustmentBehavior = .never
            
            collectionView.register(cellType: GifMakeOptionCell.self)
                
            collectionView.snp.makeConstraints { make in
//                make.edges.equalToSuperview()
                make.top.equalTo(Screen.navbarH)
                make.leading.trailing.bottom.equalToSuperview()
            }
            
            collectionView.reloadData()
        }
    }
    
}

extension WaterflowVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GifMakeOptionCell = collectionView.dequeueReusableCell(for: indexPath)
        let idx = indexPath.row
        cell.setIndex(idx)
        return cell
    }
}


extension WaterflowVC: WaterflowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout waterflowLayout: WaterflowLayout, heightForItemAt index: Int, itemWidth: CGFloat) -> CGFloat {
        itemWidth + CGFloat((-10...30).randomElement() ?? 0)
    }
}
