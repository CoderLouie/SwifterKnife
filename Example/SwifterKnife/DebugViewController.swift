//
//  DebugViewController.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2022/11/20.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import SwifterKnife

fileprivate class TestCaseCell: UITableViewCell, Reusable {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
    }
}

enum Gender: String, Codable {
    case man, woman
}
struct Tag: RawRepresentable, Codable {
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    init(_ rawValue: Int) {
        self.rawValue = rawValue
    }
    let rawValue: Int
}
fileprivate extension DefaultsKeys {
    var reviewed: DefaultsKey<Bool?> {
        .init("reviewed")
    }
    var pCount: DefaultsKey<Int?> {
        .init("pCount")
    }
    var reviewCount: DefaultsKey<Int> {
        .init("reviewCount", defaultValue: 100)
    }
    var gender: DefaultsKey<Gender?> {
        .init("gender")
    }
    var niltag: DefaultsKey<Tag?> {
        .init("niltag")
    }
    var tag: DefaultsKey<Tag> {
        .init("tag", defaultValue: Tag(10))
    }
    var genders: DefaultsKey<[Gender]> {
        .init("genders", defaultValue: [])
    }
    var nilgenders: DefaultsKey<[Gender]?> {
        .init("nilgenders")
    }
}

fileprivate enum TestCase: String, CaseIterable {
    case promise1 = "Promise1"
    case promise2 = "Promise2"
    case promise3 = "Promise Retry"
    case lazy2 = "Lazy2"
    case throttle = "throttle"
    case defaults = "UserDefaults"
    
    case statement = "Statement"
    
    private func peekus() {
        let r = Defaults[\.reviewed]
        let n = Defaults[\.reviewCount]
        let g = Defaults[\.gender]
        let t = Defaults[\.tag]
        let nilt = Defaults[\.niltag]
        let gs = Defaults[\.genders]
        let nilgs = Defaults[\.nilgenders]
        print(r, n, g, t, nilt, gs, nilgs)
    }
    func perform(from vc: DebugViewController) {
        switch self {
        case .statement:
            var a = 10, b = 3
            until(a < b, a - 2 < b) {
                a -= 1
                print(a, b)
            }
//            let point = 70
//            if_(point >= 90, point < 100) {
//                
//            }
//            let val: Any = 70
//            let val2 = if_some(val as? Int, and: point > 80) { v in
//                return v + 10
//            }
        case .defaults:
            peekus()
            Defaults[\.reviewed] = true
            Defaults[\.reviewCount] = 5
            Defaults[\.gender] = .man
            Defaults[\.tag] = Tag(20)
            Defaults[\.niltag] = Tag(8)
            Defaults[\.genders] = [.woman, .man]
            Defaults[\.nilgenders] = [.man]
            
            peekus()
            break
        case .throttle:
//            vc.mapPresentAd()
            break
        case .lazy2:
//            let nums: [Int]? = [1, 2]
//            if !nums.map(\.isEmpty, or: true) {
//
//            }
//            break
            print(vc._res?.age)
            print(vc.res.age)
            print(vc._res?.age)
            print(vc.res.age)
            
//            print(vc.res.nullable ??? "nil")
//            print(vc.res.isBuilt)
//            vc.res.nonull(or: Resource(age:  110))
//            print(vc.res.nonull.age)
//            print(vc.res.isBuilt)
        case .promise3:
            Console.trace("bengin retry")
            Promises.retry(delay: 2) { n, error -> Promise<Int>? in
                if n > 4 { return nil }
                Console.trace("第 \(n) 次生成 promise, \(error) \(Thread.current)")
                return Promise<Int>.create { fulfill, reject in
                    DispatchQueue.main.after(1) {
                        reject(StepError(step: n))
                    }
                }
            }.then { val in
                Console.trace("reolve", val)
            } onRejected: { err in
                Console.trace("reject", err)
            }

        case .promise1:
            vc.promise.then { val in
                print("reolve", val)
            } onRejected: { err in
                print("reject", err)
            }.catchs { err in
                print("catch", err)
            }
        case .promise2:
            Promise<Int>.create { fulfill, reject in
                DispatchQueue.main.after(1) {
//                    fulfill(100)
//                    reject(PromiseError.missed)
                    reject(StepError(step: 10, error: StepError(step: 9, error: PromiseError.missed)))
                }
            }.step(1).flatMap { val in
                return Promise<String>.create { fulfill, reject in
                    DispatchQueue.main.after(1) {
                        fulfill("\(val + 10)")
//                        reject(PromiseError.missed)
                    }
                }.step(2)
            }.step(5).then { val in
                print("reolve", val)
            } onRejected: { err in
                print("reject", err)
            }.catchs(as: StepError.self) { err in
                print("catch", err)
            }
        }
    }
}

class Resource: CustomStringConvertible {
    let age: Int
    init(age: Int) {
        print("create res with \(age)")
        self.age = age
    }
    var description: String {
        return "an res with \(age)"
    }
    deinit {
        print("res with \(age) deinit")
    }
}
extension Resource: Then {}

enum AppError: Swift.Error {
    case missed
}
enum NetError: Swift.Error {}
class DebugViewController: BaseViewController {
//    lazy var mapPresentAd = Knife.throttle(presentAd(_:))
    func presentAd(_ completion: @escaping () -> Void) {
        print("enter presentAd")
        DispatchQueue.main.after(2) {
            completion()
            print("exit presentAd")
        }
    }
     
    func service1(_ param: Int, _ completion: @escaping ResultCompletion<Int, AppError>) {
        completion(.success(42))
    }
    func service2(_ param: Int, arg: String, _ completion: @escaping ResultCompletion<String, NetError>) {
        completion(.success("🎉 \(arg)"))
    }
    func isValidate(_ param: Int, arg: String, _ completion: @escaping (AppError?) -> Void) {
        completion(nil)
    }
    func testChainFunc1() {
        let chainedServices = service1
        >>> { String($1 / 2) }// or throw some error
        >>? isValidate
        >>> service2
        chainedServices(10) { result in
            switch result {
            case .success(let val):
                print(val)// Prints: 🎉 21
            case .failure(let anyError):
                let error = anyError.error
                print(error)
            }
        }
    }
    
    
   func service11(_ completion: @escaping ResultCompletion<Int, AppError>) {
       completion(.success(42))
   }
   func service12(arg: String, _ completion: @escaping ResultCompletion<String, NetError>) {
       completion(.success("🎉 \(arg)"))
   }
   func isValidate11(arg: String, _ completion: @escaping (AppError?) -> Void) {
       completion(nil)
   }
   func testChainFunc2() {
       let chainedServices = service11
       >>> { String($0 / 2) }// or throw some error
       >>? isValidate11
       >>> service12
       chainedServices { result in
           switch result {
           case .success(let val):
               print(val)// Prints: 🎉 21
           case .failure(let anyError):
               let error = anyError.error
               print(error)
           }
       }
   }
    
    override func setupViews() {
        super.setupViews()
        title = "Debug"
        setupBody()
    }
//    lazy var res = Lazy(Resource(age:  110).then { [unowned self] _ in
//        print("execute lazy", self.n)
////        print("execute lazy")
//    })
//    lazy var res = Lazy {
//        Resource(age:  110).then { _ in
//            print("execute lazy", self.n)
//        }
//    }
//    lazy var res = Lazy { [unowned self] in
//        Resource(age:  110).then { _ in
//            print("execute lazy", self.n)
//        }
//    }
//    lazy var res = Lazy<Resource>()
    
    var _res: Resource?
    var res: Resource {
        _res ?<< Resource(age: 10).then {
            print("execute lazy", self.n, $0.age)
        }
    }
    
//    lazy var res = Lazy(Resource(age: 10)).then { [unowned self] r in
//        print("execute lazy", self.n, r.age)
//    }
    // 不会循环引用，但是会等promise完成后，self才会释放
    private let n = 100
    lazy var promise = Promise<Int>.create { fulfill, reject in
        DispatchQueue.main.after(3) {
            fulfill(self.n)
        }
    }.then { val in
        print("reolve0000", val, self.n)
    }
    private unowned var tableView: UITableView!
    private lazy var items: [TestCase] = TestCase.allCases
}
 
// MARK: - Delegate
extension DebugViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TestCaseCell = tableView.dequeueReusableCell(for: indexPath)
        let index = indexPath.row
        let text = String(format: "%02d. ", index) + items[index].rawValue
        cell.textLabel?.text = text
        return cell
    }
}
extension DebugViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        items[indexPath.row].perform(from: self)
    }
}

// MARK: - Create Views
extension DebugViewController {
    
    private func setupBody() {
        tableView = UITableView().then {
            $0.backgroundColor = .clear
            $0.tableFooterView = UIView()
            $0.contentInsetAdjustmentBehavior = .never
            $0.separatorStyle = .none
            $0.delegate = self
            $0.dataSource = self
            $0.rowHeight = 45.fit
            $0.register(cellType: TestCaseCell.self)
            view.addSubview($0)
            $0.contentInset = UIEdgeInsets(top: Screen.navbarH, left: 0, bottom: Screen.safeAreaB, right: 0)
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}
