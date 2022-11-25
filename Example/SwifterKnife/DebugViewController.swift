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


fileprivate enum TestCase: String, CaseIterable {
    case promise1 = "Promise1"
    case promise2 = "Promise2"
    case promise3 = "Promise Retry"
    case lazy2 = "Lazy2"
    case throttle = "throttle"
    func perform(from vc: DebugViewController) {
        switch self {
        case .throttle:
//            vc.mapPresentAd()
            break
        case .lazy2:
            break
//            print(vc.res.nullable ??? "nil")
//            print(vc.res.isBuilt)
//            print(vc.res.nonull.age)
//            print(vc.res.isBuilt)
        case .promise3:
            Console.trace("bengin retry")
            Promises.retry(attempts: 4, delay: 2) { n, error in
                Console.trace("第 \(n) 次重试 \(error)")
//                if n > 2 { return false }
                return true
            } generate: { n -> Promise<Int> in
                Console.trace("第 \(n) 次生成 promise")
                return Promise<Int>.create { fulfill, reject in
                    DispatchQueue.main.after(1) {
                        reject(StepError(step: n))
                    }
                }
            }.then { val in
                print("reolve", val)
            } onRejected: { err in
                print("reject", err)
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

class DebugViewController: BaseViewController {
//    lazy var mapPresentAd = Knife.throttle(presentAd(_:))
    func presentAd(_ completion: @escaping () -> Void) {
        print("enter presentAd")
        DispatchQueue.main.after(2) {
            completion()
            print("exit presentAd")
        }
    }
    
    override func setupViews() {
        super.setupViews()
        title = "Debug"
        setupBody()
    }
//    lazy var res = Lazy(Resource(age:  110).then { _ in
//        print("execute lazy", self.n)
//    })
//    lazy var res = Lazy {
//        Resource(age:  110).then { _ in
//            print("execute lazy", self.n)
//        }
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
