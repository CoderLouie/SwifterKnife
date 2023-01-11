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
    let age: Int = 10
    let score: Int = 80
    let name: String = "xiaoming"
    deinit {
        Console.logFunc(whose: self)
    }
}
class Student: Person {
    
}

//extension DefaultsKey {
//    static let cached = Key<Int>("nihao")
//    static let saved = DefaultKey<Bool>("nihao", defaultValue: true)
//}

enum SomeError: Swift.Error {
    case timeout
}
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupBody5()
//        setupButton1()
//        setupRatingView()
//        setupImageView()
//        setupGradientControl()
//        let stus: [Student] = []
//        let newStus = stus.sorted(by: +[+\.age, +\.score, +\.name])
        
//        print("home".i18n)
//        Console.log("hello world", tag: .success)
//        Console.trace("hello world", tag: .warning)
//        Console.logFunc(whose: self)
    }
    private func setupGradientControl() {
        control = GradientControl().then {
            $0.gradientComponent = .border(4)
            $0.backgroundColor = .lightGray
            $0.gradientColors = [UIColor(hexString: "#FFCA70"),
                                 UIColor(hexString: "#FFAF28")]
            $0.roundedWay = .dynamic(.horizontal)
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(200)
                make.height.equalTo(50)
            }
        }
    }
    private unowned var control: GradientControl!
    private func testControl() {
        if control.gradientComponent.isBorder {
            control.gradientComponent = .background
        } else {
            control.gradientComponent = .border(8)
        }
    }
    private func testPromise() {
        
        let promise = Promise<Int>.create { fulfill, reject in
            DispatchQueue.main.after(2) {
                fulfill(100)
            }
        }
        promise.then { val in
            print("reolve", val)
        } onRejected: { err in
            print("reject", err)
        }.catchs { err in
            print("catch", err)
        }
    }
    private func testPromise1() {
        let size1 = CGSize.zero
        let new1 = size1.fit
        
        let font = UIFont.semibold(12)
        let font1 = font.fit
        
        let nums = [1, 2, 3]
        
        let promise = Promise<Int>.reject(SomeError.timeout)
        promise.then { val in
            print("reolve", val)
        } onRejected: { err in
            print("reject", err)
        }.catchs { err in
            print("catch", err)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        promise_test_entry()
//        let key = Key<Int>("hahahha")
//        Defaults.set(99, for: key)
//        let val = Defaults.get(for: key)
////        Defaults.shared.get(for: .cached)
////        let f = Defaults.shared.get(for: .saved)
//        let f = Defaults[.saved]
//        print(val ?? "nil")
//         testPromise()
//        kviewTest()
        
        
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
         
        regexTestEntry()
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
    
    private unowned var label1: GradientLabel!
    private unowned var kview: KView!
    private unowned var kButton: UIButton!
    private let positions: [Position] = [
        .leftTop, .leftCenter, .leftBottom,
        .topCenter, .center, .bottomCenter,
        .rightTop, .rightCenter, .rightBottom]
    private var index = 0
}

private func voidwork(completion: @escaping (Result<String, PromiseError>) -> Void) {
    DispatchQueue.global().after(2) {
        completion(.success("voidwork"))
    }
}
private func intwork(num: Int, completion: @escaping (Result<String, PromiseError>) -> Void) {
    DispatchQueue.global().after(2) {
        completion(.success("\(num)"))
    }
}
private func int2work(num1: Int, num2: Int, completion: @escaping (Result<String, PromiseError>) -> Void) {
    DispatchQueue.global().after(2) {
//        completion(.success("\(num1 + num2)"))
        completion(.failure(.missed))
    }
}
func promise_test_entry() {
    10.ui.fit(using: \.width, alignment: .floor)
    
//    10.ui.fit(using: { $0.width }, alignment: .floor)
//    let c1 = voidwork(completion:)
//    Promises.wrap(c1).trace("1")
//    
//    let c2 = intwork(num:completion:)
//    Promises.wrap(param: 10, c2).trace("2")
//    
//    let c3 = int2work(num1:num2:completion:)
//    Promises.wrap(param1: 10, param2: 20, c3).trace("3")
}
fileprivate extension Promise {
    func trace(_ tag: String) {
        then { val in
            print(tag, "reolve", val)
        } onRejected: { err in
            print(tag, "reject", err)
        }.catchs { err in
            print(tag, "catch", err)
        }
    }
}

// MARK: - Async
private extension ViewController {
    func otherTest4() {
        UIColor.blue.alpha
        let icon = UIImage(fileNamed: "h2000")
//        ManagedBufferPointer
        var num = 3
        num <>= 5...7
        print(num)
    }
    func otherTest3() {
//        let num: Int? = nil
//        let res: Result<String, Error> = .success("3")
//        let res1 = res.flatMap { _ in res }
//        asyncRepeat { index, cond, cost in
//            print("asyncRepeat work", index, cost())
//            DispatchQueue.main.after(0.5) {
//                cond(index < 3)
//            }
//        }
        
    }
    func otherTest2() {
        let val: Int? = 5
        var age = 3
        age ??= val
        print("age is \(age)")
        
//        var step: Step? = nil
//        step?.speak() !? "step is nil"
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
            
        
//        var key1: UInt8 = 0
//        let val = associatedValue(for: &key1, policy: .nonatomic_retain, default: UIView())
        
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
}

// MARK: - Regex
private extension ViewController {
    func regexa1() {
        let limiter = DebouncedLimiter(limit: 3) { _ in
            print("")
        }
        let attr = "nihaoya hello world".at.build {
            $0.foreground(color: .red)
        }.modified(with: .one.foreground(color: .red), for: "hello")
        
        UIButton().do {
            $0.addTarget(limiter, action: #selector(DebouncedLimiter.execute(param:)), for: .touchUpInside)
        }
        let regex: Regex = #".(at)g"#
        let str = "The fat cat sat on the mat."
        print(regex.firstMatch(in: str)?.value ?? "nil")
        
//        let random: Double = Random.one(3, 10)
    }
    func regrxaaaa() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let size = CGSize(width: 60, height: 80)
        print(rect.resizing(to: size, model: .scaleAspectFit))
        print(rect.resizing(to: size, model: .scaleAspectFill))
        print(rect.resizing(to: size, model: .scaleToFill))
    }
    func regexTestEntry() {
//        regexa1()
        regrxaaaa()
    }
    /// 提取重叠的字母数字
    func regex1() {
        let regex: Regex = #"([a-z])\1(\d)\2"#
        let str = "aa11+bb23-mj33*dd44/5566%ff77"
        let result = regex.matches(in: str)
        for (i, r) in result.enumerated() {
            print(i, r, r.groupValues)
        }
    }
    func regex11() {
        let regex: Regex = #"[a-z]{2}\d(\d)"#
        let str = "aa12+bb34-mj56*dd78/9900"
        let result = regex.matches(in: str)
        for (i, r) in result.enumerated() {
            print(i, r, r.groupValues)
        }
    }
    func regex2() {
        let str = "_123_456_789"
        let pattern = #"\d{3}"#
//        print((try? str.matchesAll(pattern: pattern)) ?? "error")
    }
    /// 正则分割字符串
    func regex3() {
        let regex: Regex = #"\d+"#
//        let regex: Regex = "\\d+"
        let str = "ab12c3d456efg7h89i1011jk12lmn"
        let result = regex.split(str)
        for (i, r) in result.enumerated() {
            print(i, r.value)
        }
    }
    /// 替换字符串中的数字
    func regex4() {
        let regex: Regex = #"\d+"#
        let str = "ab12c3d456efg7h89i1011jk12lmn"
//      let st1 = "ab**c*d***efg*h**i****jk**lmn"
        let result1 = regex.replacingMatches(in: str, count: .max) {
            String(repeating: "*", count: $0.intRange.count)
        }
        let result2 = regex.replacingAllMatches(in: str, with: "**")
        print(result1)
        print(result2)
        print(result1 == result2)
    }
    func regex41() {
        let regex: Regex = #"(Phil|John), ([\d]{4})"#
        let str = "Phil, 1991 and John, 1985"
        let with = "$1 was born in $2"
        let result1 = regex.replacingMatches(in: str, count: 1) { _ in with }
        let result2 = regex.replacingAllMatches(in: str, with: with)
        let result3 = regex.replacingFirstMatch(in: str, with: with)
        print(result1)
        print(result2)
        print(result3)
        print(result1 == result2, result1 == result3)
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
 
class KView: UIView {
    
    var textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10) {
        didSet {
            guard textInsets != oldValue else { return }
            setNeedsLayout()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var text: String? {
        set {
            label.text = newValue
            Console.log("setText", newValue ?? "nil")
//            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
        get { label.text }
    }
    private func setup() {
        backgroundColor = .groupTableViewBackground
        label = UILabel().then {
            $0.backgroundColor = .cyan
            $0.textColor = .black
            $0.font = .medium(14)
            $0.text = "Slideratobseecthedchanges"
            addSubview($0)
        }
    }
    override var intrinsicContentSize: CGSize {
        let size = label.intrinsicContentSize
        let inset = textInsets
        let res = CGSize(width: size.width + inset.left + inset.right, height: size.height + inset.top + inset.bottom)
        Console.log("intrinsicContentSize", res, size)
        return res
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = bounds
        let insetBounds = bounds.inset(by: textInsets)
        var textSize = label.intrinsicContentSize
        Console.log("layoutSubviews", bounds, insetBounds, textSize)
        if textSize.width > insetBounds.width {
            if label.numberOfLines != 1 {
                label.preferredMaxLayoutWidth = insetBounds.width
                textSize = label.intrinsicContentSize
                invalidateIntrinsicContentSize()
                Console.log("layoutSubviews 1", textSize)
            }
        }
        textSize.width = min(textSize.width, insetBounds.width)
        textSize.height = min(textSize.height, insetBounds.height)
        label.frame.size = textSize
        label.center = insetBounds.center
    }
    private(set) unowned var label: UILabel!
}

extension UIView {
    var info: [Float] {
        [contentCompressionResistancePriority(for: .vertical).rawValue,
         contentCompressionResistancePriority(for: .horizontal).rawValue,
         contentHuggingPriority(for: .vertical).rawValue,
         contentHuggingPriority(for: .horizontal).rawValue
        ]
    }
}

// MARK: - Button
extension ViewController {
    private func setupImageView() {
        
        
        
        let view = UIView()
        let label = UILabel()
        let imgView = UIImageView()
        let button = UIButton()
        print([view, label, imgView, button].map(\.info))
        
        let img1View = UIImageView().then { this in
            this.contentMode = .scaleAspectFill
            this.image = UIImage(fileNamed: "banner_home_1aging")
            view.addSubview(this)
            this.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(40)
                make.centerY.equalToSuperview()
//                make.center.equalToSuperview()
            }
        }
        print(img1View.info)
    }
    private func setupRatingView() {
        view.backgroundColor = UIColor(gray: 43)
        
        let label = UILabel().then { this in
            this.textColor = .white
            this.font = .semibold(17)
            view.addSubview(this)
            this.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-50)
            }
        }
        let ratingView = RatingView(
            count: 5,
            normalImage: UIImage(named: "img_star_inactive"),
            highlightedImage: UIImage(named: "img_star_active"),
            margin: 22).then {
//                $0.isPanEnable = true
                $0.weight = 20
                $0.accuracy = 0.5
                view.addSubview($0)
                $0.snp.makeConstraints { make in
                    make.center.equalToSuperview()
                }
            }
        label.text = "\(ratingView.grade)"
        ratingView.gradeDidChange = {
            label.text = "\($0.grade)"
        }
//        ratingView.endEditingGrade = {
//            label.text = "\($0.grade)"
//        }
    }
    private func setupButton1() {
        
        let e1: Either<Int, String>? = .left(3)
        let right = e1.selectRight()
        
        let color1: UIColor = .create(10,20,30)
    }
}

// MARK: - Create Views
extension ViewController {
    private func kviewTest() {
        kview.text = "q2bEHYRGVIBX6E1zwVLox6DOVS7bRhq2bEHYRGVIBX6E1zwVLox6DOVS7bRh"
    }
    private func setupBody() {
//        kview = KView(frame: CGRect(x: 100, y: 100, width: 175, height: 44)).then {
//            $0.label.numberOfLines = 0
//            view.addSubview($0)
//        }
        kview = KView().then {
            $0.label.numberOfLines = 0
            view.addSubview($0)
            $0.snp.makeConstraints { make in
//                make.centerX.equalToSuperview()
                make.leading.equalTo(100)
                make.trailing.equalTo(-100)
//                make.height.equalTo(44)
                make.centerY.equalToSuperview()

            }
        }
    }
    
    @objc private func kbuttonDidClick(_ sender: UIButton) {
        Console.log("1", sender.intrinsicContentSize, sender.sizeThatFits(.zero), sender.titleLabel?.sizeThatFits(.zero) ??? "nil")
        sender.isSelected = !sender.isSelected
//        sender.invalidateIntrinsicContentSize()
        sender.setNeedsLayout()
        DispatchQueue.main.async {
            Console.log("2", sender.intrinsicContentSize, sender.sizeThatFits(.zero), sender.titleLabel?.intrinsicContentSize ??? "nil")
        }
    }
    private func setupKButton() {
        kButton = UIButton().then {
            $0.backgroundColor = .cyan
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.numberOfLines = 0
            $0.titleLabel?.preferredMaxLayoutWidth = 100
            $0.setTitle("normal numberOfLines numberOfLines numberOfLines numberOfLines", for: .normal)
            $0.setTitle("selected numberOfLines numberOfLines", for: .selected)
            $0.addTarget(self, action: #selector(kbuttonDidClick(_:)), for: .touchUpInside)
            view.addSubview($0)
            $0.snp.makeConstraints { make in
//                make.leading.equalTo(100)
//                make.trailing.equalTo(-100)
                make.center.equalToSuperview()
            }
        }
    }
    
    private func labelTest() {
        label1.textPosition = positions[index]
        index += 1
        if index == 1 {
            label1.textInsets = UIEdgeInsets(top: 1, left: 20, bottom: 6, right: 15)
        }
        label1.gradientComponent = index == 2 ? .text : .background
        label1.text = index == 3 ? "一旦把label层设置为mask层，label层就不能显示了,会直接从父层中移除，然后作为渐变层的mask层，且label层的父层会指向渐变层, 父层改了，坐标系也就改了，需要重新设置label的位置，才能正确的设置裁剪区域" : "Copyright (c) 2021 Copyright (c) 2021Copyright (c) 2021"
        if index == 3 || index == 4 {
//            label1.setNeedsLayout()
            label1.invalidateIntrinsicContentSize()
        }
        if index >= positions.count { index = 0 }
    }
    private func setupBody9() {
//        label = PaddingLabel().then {
//            $0.font = .semibold(16)
//            $0.textColor = .black
//            $0.text = "Body"
//            $0.backgroundColor = .cyan
//            view.addSubview($0)
//            $0.snp.makeConstraints { make in
//                make.width.equalTo(300)
//                make.height.equalTo(50)
//                make.centerX.equalToSuperview()
//                make.top.equalTo(100)
//            }
//        }

        label1 = GradientLabel().then {
            $0.textInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
            $0.font = .semibold(16)
            $0.text = "Copyright (c) 2021 Copyright (c) 2021Copyright (c) 2021"
            $0.numberOfLines = 0
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.equalTo(100)
                make.trailing.equalTo(-100)
                make.top.equalTo(100)
//                make.height.equalTo(100)
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
//        guide.makeHorizontalSizeToFit()
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
//        guide.makeHorizontalSizeToFit()
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
