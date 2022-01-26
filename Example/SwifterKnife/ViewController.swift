//
//  ViewController.swift
//  SwifterKnife
//
//  Created by liyang on 10/25/2021.
//  Copyright (c) 2021 liyang. All rights reserved.
//

import UIKit
import SwifterKnife
import SnapKit

enum Step: Int, CaseIterable {
    case step1 = 1
    case step2
    case step3
    case step4
    case step5
    var title: String {
        return "step_\(rawValue)"
    }
    var image: UIImage? {
        return UIImage(named: "img_tutorial_0\(rawValue)")
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBody()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private unowned var stepView: CarouselView!
    private unowned var pageControl: UIPageControl!
    private var steps: [Step] = Step.allCases
}


// MARK: - Delegate
extension ViewController: CarouselViewDelegate {
    func carouselView(_ carouselView: CarouselView, willAppear cell: CarouselViewCell, at index: Int) {
        guard let stepCell = cell as? StepCell else {
            return
        }
        stepCell.reload(step: steps[index])
    }
    func carouselView(_ carouselView: CarouselView, didSelect cell: CarouselViewCell, at index: Int) {
        pageControl.currentPage = index
    }
}

// MARK: - Create Views
extension ViewController {
    private func setupBody() {
        SudokuView().do { this in
            this.contentInsets = UIEdgeInsets(top: 68, left: 50, bottom: 15, right: 30)
            this.behaviour = .spacing(10, 15)
            view.addSubview(this)
            this.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.7)
            }
            this.warpCount = 4
            
            this.addArrangedViews((1...5).map { idx in
                UILabel().then {
                    $0.backgroundColor = .yellow
                    $0.text = "\(idx)"
                    $0.font = UIFont.systemFont(ofSize: 25)
                    $0.textAlignment = .center
                }
            })
        }
    }
    private func setupBody1() {
        let direction: CarouselView.ScrollDirection = .vertical
        stepView = CarouselView(direction: direction).then {
//            $0.isInfinitely = false
            $0.backgroundColor = .groupTableViewBackground
            $0.register(StepCell.self)
            $0.delegate = self
            $0.itemsCount = steps.count
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.trailing.equalTo(0)
                make.height.equalToSelfWidth().multipliedBy(96.0/78.0)
                make.centerY.equalToSuperview()
            }
        }
        pageControl = UIPageControl().then {
            $0.numberOfPages = steps.count
            stepView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(-10)
            }
        }
    }
}


fileprivate class StepCell: CarouselViewCell {
    override func setup() {
        label = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 20)
            $0.numberOfLines = 0
            $0.textAlignment = .center
            $0.textColor = .black
            addSubview($0)
            $0.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(0)
            }
        }
        imageView = UIImageView().then {
            $0.contentMode = .scaleAspectFit
            addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.equalTo(label.snp.bottom)
                make.leading.trailing.bottom.equalTo(0)
            }
        }
    }
    
    func reload(step: Step) {
        label.text = step.title
        imageView.image = step.image
    }
    
    private unowned var label: UILabel!
    private unowned var imageView: UIImageView!
}
