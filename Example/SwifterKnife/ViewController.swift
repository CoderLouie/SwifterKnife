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
    func speak() {
        print(title, "speak")
    }
}
 

class ViewController: UIViewController {
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupBody()
         
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        regex2()
        otherTest4()
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
    func otherTest4() {
        let icon = UIImage(fileNamed: "h2000")
//        ManagedBufferPointer
        var num = 3
        num <>= 5...7
        print(num)
    }
    func otherTest3() {
//        let num: Int? = nil
        let res: Result<String, Error> = .success("3")
        let res1 = res.flatMap { _ in res }
        asyncRepeat { index, cond, cost in
            print("asyncRepeat work", index, cost())
            DispatchQueue.main.after(0.5) {
                cond(index < 3)
            }
        }

        
    }
    func otherTest2() {
        let val: Int? = 5
        var age = 3
        age ??= val
        print("age is \(age)")
        
        var step: Step? = nil
        step?.speak() !? "step is nil"
    }
    func otherTest1() {
        
        let nums = [1, 2, 3, 4]
        var i1 = nums.makeIterator()
        print(i1.next() ?? "nil")
        print(i1.next() ?? "nil")
        var i2 = AnyIterator(i1)
        print(i1.next() ?? "nil")
        print(i2.next() ?? "nil")
//        print(i2.next() ?? "nil")
            
        
        var key1: UInt8 = 0
        let val = associatedValue(for: &key1, policy: .nonatomic_retain, default: UIView())
        
        do {
            let val: Double? = nil
            let str = "the num is \(val ??? "nil")"
            print(str)
        }
    }
    
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
        let guide = VLayoutGuide(owningView: view, aligment: .end).then {
            $0.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
        let label = UILabel().then {
            $0.text = "UILable"
            guide.addSubview($0)
        }
        let testView = UIView().then {
            $0.backgroundColor = .cyan
            guide.addSubview($0)
            
            $0.snp.makeConstraints { make in
                make.top.equalTo(label.snp.bottom).offset(20)
                make.height.equalTo(40)
                make.width.equalTo(120)
            }
        }
        guide.makeSizeToFit()
//        guide.makeHorizontalSizeToFit()
        DispatchQueue.main.after(1) {
            print(guide.layoutFrame)
            print("")
        }
        let label2 = UILabel().then {
            $0.text = "UILable2"
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.centerY.equalTo(guide)
//                make.bottom.equalTo(guide.snp.top).offset(-30)
                make.leading.equalTo(guide.snp.trailing).offset(10)
            }
        }
    }
    private func setupBody4() {
        let guide = HLayoutGuide(owningView: view, aligment: .start).then {
            $0.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
        let label = UILabel().then {
            $0.text = "UILable"
            guide.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.equalTo(guide)
            }
        }
        let testView = UIView().then {
            $0.backgroundColor = .cyan
            guide.addSubview($0)
            
            $0.snp.makeConstraints { make in
                make.leading.equalTo(label.snp.trailing).offset(20)
                make.trailing.equalTo(guide)
                make.height.equalTo(40)
                make.width.equalTo(120)
            }
        }
//        guide.makeSizeToFit()
        guide.makeHorizontalSizeToFit()
        DispatchQueue.main.after(1) {
            print(guide.layoutFrame)
            print("")
        }
        let label2 = UILabel().then {
            $0.text = "UILable2"
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.centerX.equalTo(guide)
//                make.bottom.equalTo(guide.snp.top).offset(-30)
                make.top.equalTo(guide.snp.bottom).offset(30)
            }
        }
    }
    private func setupBody3() {
        let container = UILayoutGuide().then {
            view.addLayoutGuide($0)
            $0.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
        
        let label = UILabel().then {
            $0.text = "UILable"
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.centerY.equalTo(container)
                make.top.greaterThanOrEqualTo(container)
                make.bottom.lessThanOrEqualTo(container)
            }
        }
        let testView = UIView().then {
            $0.backgroundColor = .cyan
            view.addSubview($0)
            
            $0.snp.makeConstraints { make in
                make.leading.equalTo(label.snp.trailing).offset(20)
                make.height.equalTo(40)
                make.width.equalTo(120)
                make.trailing.centerY.equalTo(container)
                make.top.greaterThanOrEqualTo(container)
                make.bottom.lessThanOrEqualTo(container)
            }
        }
        let label2 = UILabel().then {
            $0.text = "UILable2"
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.centerX.equalTo(container)
                make.top.equalTo(container.snp.bottom).offset(10)
//                make.trailing.equalTo(container.snp.leading).offset(-10)
            }
        }
        DispatchQueue.main.after(1) {
            print(container.layoutFrame)
            print("")
        }
    }
    private func setupBody2() {
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
