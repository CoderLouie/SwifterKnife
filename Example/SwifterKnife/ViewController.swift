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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        regex2()
        let nums = [1, 2, 3, 4]
        let nums1 = nums[...]
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private unowned var stepView: CarouselView!
    private unowned var pageControl: UIPageControl!
    private var steps: [Step] = Step.allCases
}


// MARK: - Async
private extension ViewController {
    func tagViewTest() {
        let imag = UIImage(named: "")
        imag?.withAlignmentRectInsets(.zero)
    }
    func async1() {
        enum TestError: TimeoutError {
            case timeout
        }
        [30, 40, 50].asyncReduce(into: [Int](),
                                 errorType: TestError.self,
                                 timeoutInterval: 5) { context, item, control in
            print("开始请求 \(item)")
            DispatchQueue.main.after(TimeInterval((1...3).randomElement()!)) {
                print("\(item) 请求结束")
                if item == 40, context.retryCount < 2 {
                    control(.retry)
                } else {
                    context.result.append(item + 10)
                    control(.next)
                }
            }
        } onDone: { context, result in
            result.unwrap { value in
                print(value)
            } onFailure: { err in
                print(err)
            }
            print("")
        }
    }
}

// MARK: - Regex
private extension ViewController {
    func regex2() {
        let str = "aa11+bb23-mj33*dd44/5566%ff77"
        let pattern = #"([a-z])\1(\d)\2"#
        print((try? str.matchesAll(pattern: pattern)) ?? "error")
    }
    func regex1() {
        let str = "_123_456_789"
        let pattern = #"\d{3}"#
        print((try? str.matchesAll(pattern: pattern)) ?? "error")
    }
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
//            this.behaviour = .itemLength(50, 130)
            view.addSubview(this)
            this.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.7)
            }
            this.warpCount = 4
            
            for i in 1...5 {
                let label = UILabel().then {
                    $0.backgroundColor = .yellow
                    $0.text = "\(i)"
                    $0.font = UIFont.systemFont(ofSize: 25)
                    $0.textAlignment = .center
                }
                this.addArrangedView(label)
            }
            this.placeArrangedViews()
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
