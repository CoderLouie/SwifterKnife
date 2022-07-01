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
 
class Person {
    deinit {
        Console.logFunc(whose: self)
    }
}
class Student: Person {
    
}
class ViewController: UIViewController {
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupBody()
//        Console.log("hello world", tag: .success)
//        Console.trace("hello world", tag: .warning)
//        Console.logFunc(whose: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        label.textPosition = positions[index]
        index += 1
        if index == 1 {
            label.textInsets = UIEdgeInsets(top: 1, left: 20, bottom: 6, right: 15)
        }
        if index >= positions.count { index = 0 }
//        let s = Student()
//        Console.log("hello world", tag: .success)
//        Console.log("hello world", whose: self, tag: .success)
//        Console.trace("hello world", tag: .warning)
//        Console.trace("hello world", whose: self, tag: .warning)
//        print(s)
//        Console.logFunc(whose: self)
//        UserDefaults.standard.do {
//            print("------1", $0.dictionaryRepresentation() as NSDictionary)
//            $0.set("launched", forKey: "app_is_first_start")
//            print("------2", $0.dictionaryRepresentation() as NSDictionary)
//        }
        
//        regex2()
//        otherTest4()
//        progressLayer.strokeEnd += 0.1
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private unowned var stepView: CarouselView!
    private unowned var pageControl: UIPageControl!
    private var steps: [Step] = Step.allCases
    
    private var progressLayer: CAShapeLayer!
    private unowned var imageView: UIImageView!
    private unowned var label: PaddingLabel!
    private let positions = PaddingLabel.TextPosition.allCases
    private var index = 0
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
    func carouselView(_ carouselView: CarouselView, didAppear cell: CarouselViewCell, at index: Int) {
        pageControl.currentPage = index
    }
}
 

// MARK: - Create Views
extension ViewController {
    @objc private func buttonDidClick(_ sender: Button) {
//        UIImageView.printAllMethods()
//        imageView.perform(Selector("setDrawModel:"), with: 1)
        
        
        sender.isSelected = !sender.isSelected
//        sender.isLoading = !sender.isLoading
//        if sender.isLoading {
//            DispatchQueue.main.after(3) {
//                sender.isLoading = false
//            }
//        }
//        sender.isEnabled = !sender.isEnabled
//        if !sender.isEnabled {
//            DispatchQueue.main.after(3) {
//                sender.isEnabled = true
//            }
//        }
    }
    private func setupBody() {
        label = PaddingLabel().then {
            $0.font = .semibold(16)
            $0.textColor = .black
            $0.text = "Body"
            $0.backgroundColor = .cyan
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.width.equalTo(300)
                make.height.equalTo(50)
                make.centerX.equalToSuperview()
                make.top.equalTo(100)
            }
        }
        Button().do {
            $0.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 100)
//            $0.titleLayout = .right
            $0.titleAndImageSpace = 5
            $0.imageAndSpinnerSpace = 10
//            $0.roundedDirection = .vertical
            $0.config(forState: .normal) {
//                $0.adjustsImageWhenHighlighted = false
//                $0.adjustsImageWhenDisabled = false
                $0.titleLayout = .right
//                $0.frame.size = CGSize(width: 200, height: 80)
                $0.layer.masksToBounds = true
                $0.layer.cornerRadius = 10
            }
            $0.config(forState: .disabled) {
                $0.titleLayout = .left
            }
            
            $0.configGradientLayer(forState: .normal) {
                $0.colors = [UIColor(hexString: "#FFCA70"),
                             UIColor(hexString: "#FFAF28")].map { $0.cgColor }
                $0.locations = [0, 1]
                $0.startPoint = CGPoint(x: 0, y: 0.5)
                $0.endPoint = CGPoint(x: 1, y: 0.5)
            }
            $0.configGradientLayer(forState: .disabled) {
                $0.colors = [UIColor.lightGray,
                             UIColor.darkGray].map { $0.cgColor }
            }
//            $0.config(forState: .loading) {
//                $0.backgroundColor = .darkGray
//            }
            $0.configLabel(forState: .normal) {
//                $0.numberOfLines = 0
//                $0.textAlignment = .center
                $0.preferredMaxLayoutWidth = 150
                $0.adjustsFontSizeToFitWidth = true
                $0.text = "backgroundColorbackgroundColor"
            }
            $0.configLabel(forState: .highlighted) {
                $0.text = "highlighted"
            }
            $0.configLabel(forState: .disabled) {
                $0.text = "disabled"
            }
            $0.configLabel(forState: .selected) {
                $0.frame.size = CGSize(width: 100, height: 25)
                $0.textAlignment = .center
                $0.text = "selected"
            }
            $0.configImageView(forState: .normal) {
                $0.image = UIImage(named: "ic_edit_contrast")
            }
//            $0.configImageView(forState: .loading) {
//                $0.image = UIImage(named: "ic_edit_filter")
////                $0.image = nil
//            }
            $0.configLabel(forState: .loading) {
                $0.text = "Loading,Disabled"
            }
            $0.configSpinnerView(forState: .loading) {
                $0.color = .red
            }
            $0.addTarget(self, action: #selector(buttonDidClick), for: .touchUpInside)
            view.addSubview($0)
//            $0.frame = CGRect(x: 100, y: 100, width: 120, height: 40)
            $0.snp.makeConstraints { make in
                make.center.equalToSuperview()
//                make.width.equalTo(200)
//                make.height.equalTo(56)
            }
        }
    }
    @objc private func atbuttonDidClick(_ sender: ATButton) { 
//        imageView.drawMode += 1
//        if imageView.drawMode > 4 {
//            imageView.drawMode = 0
//        }
//        print(imageView.drawMode)
//        let sel = NSSelectorFromString("setDrawMode:")
//        let res = imageView.perform(sel, with: NSNumber(1))
//        print(res)
//        let sel = #selector(setter: UIImageView.image)
//        let res = imageView.perform(sel, with: UIImage(named: "ic_edit_sharpen"))
//        let sel = #selector(setter: UIImageView.drawMode)
//        let str = NSStringFromSelector(sel)
//        print(str)
//        let res = imageView.perform(sel, with: NSNumber(2))
//        print(res)
        imageView.grayLevel = .dark
        
//        sender.isEnabled = !sender.isEnabled
//        if !sender.isEnabled {
//            DispatchQueue.main.after(3) {
//                sender.isEnabled = true
//            }
//        }
        
//        UIImageView.printAllMethods()
//        NSLog("------------------")
//        UIButton.printAllMethods()
//        sender.isSelected = !sender.isSelected
//        sender.isLoading = !sender.isLoading;
    }
    private func setupBody8() {
        imageView = UIImageView().then {
            $0.backgroundColor = .cyan
            $0.image = UIImage(named: "ic_edit_contrast")
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-100)
            }
        }
        
        ATButton().do { 
            $0.backgroundColor = .cyan
            $0.setTitle("normal", for: .normal)
            $0.setTitle("disabled", for: .disabled)
            $0.setTitle("highlighted", for: .highlighted)
            $0.setTitleColor(.black, for: .normal)
            $0.setImage(UIImage(named: "ic_edit_contrast"), for: .normal)
            $0.addTarget(self, action: #selector(atbuttonDidClick), for: .touchUpInside)
            view.addSubview($0)
            
//            $0.frame = CGRect(x: 100, y: 100, width: 120, height: 40)
//            $0.sizeToFit()
//            $0.center = view.bounds.center
            $0.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
    }
    private func setupBody7() {
        let frame = view.frame.resizing(to: CGSize(width: 100, height: 150))
        let path = UIBezierPath(roundedRect: frame, cornerRadius: 10)
        let trackLayer = CAShapeLayer().then {
            $0.path = path.cgPath
            $0.fillColor = UIColor.clear.cgColor
            $0.strokeColor = UIColor.gray.cgColor
            $0.lineWidth = 5
            $0.lineCap = .round
            view.layer.addSublayer($0)
        }
        progressLayer = CAShapeLayer().then {
            $0.path = path.cgPath
            $0.fillColor = UIColor.clear.cgColor
            $0.strokeColor = UIColor.red.cgColor
            $0.lineWidth = 5
            $0.lineCap = .round
            $0.strokeEnd = 0
            view.layer.addSublayer($0)
        }
    }
    private func setupBody6() {
        let frame = view.frame.resizing(to: CGSize(width: 100, height: 10))
        let path = UIBezierPath().then {
            $0.move(to: CGPoint(x: frame.minX, y: frame.midY))
            $0.addLine(to: CGPoint(x: frame.maxX, y: frame.midY))
        }
        let trackLayer = CAShapeLayer().then {
            $0.path = path.cgPath
            $0.strokeColor = UIColor.gray.cgColor
            $0.lineWidth = 10
            $0.lineCap = .round
            view.layer.addSublayer($0)
        }
        progressLayer = CAShapeLayer().then {
            $0.path = path.cgPath
            $0.strokeColor = UIColor.red.cgColor
            $0.lineWidth = 10
            $0.lineCap = .round
            $0.strokeEnd = 0
            view.layer.addSublayer($0)
        }
    }
    private func setupBody5() {
        let guide = VLayoutGuide(owningView: view, aligment: .end).then {
            $0.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
        let label = UILabel().then {
            $0.text = "UILable"
            guide.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.equalTo(guide)
            }
        }
        let testView = UIView().then {
            $0.backgroundColor = .cyan
            guide.addSubview($0)
            
            $0.snp.makeConstraints { make in
                make.top.equalTo(label.snp.bottom).offset(20)
                make.height.equalTo(40)
//                make.width.equalTo(120)
                make.width.equalToSelfHeight().multipliedBy(3)
            }
        }
//        guide.makeSizeToFit()
        guide.makeHorizontalSizeToFit()
        guide.snp.makeConstraints { make in
            make.height.equalToSelfWidth().multipliedBy(2)
//            make.height.equalTo(guide.snp.width).multipliedBy(2)
        }
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
