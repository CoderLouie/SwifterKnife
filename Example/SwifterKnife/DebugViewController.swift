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
    case lazy1 = "Lazy1"
    case lazy2 = "Lazy2"
    func perform(from vc: DebugViewController) {
        switch self {
        case .lazy2:
            print(vc.res1.nullable ??? "nil")
            print(vc.res1.isBuilt)
            print(vc.res1.nonull.age)
            print(vc.res1.isBuilt)
        case .lazy1:
            print(vc.res.nullable() ??? "nil")
            print(vc.res.isBuilt())
            print(vc.res.nonull().age)
            print(vc.res.isBuilt())
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
                    reject(StepError(step: 3, error: StepError(step: 2, error: PromiseError.missed)))
                }
            }.step(1).flatMap { val in
                return Promise<String>.create { fulfill, reject in
                    DispatchQueue.main.after(1) {
                        fulfill("\(val + 10)")
//                        reject(PromiseError.missed)
                    }
                }.step(2)
            }.then { val in
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

class DebugViewController: BaseViewController {
    override func setupViews() {
        super.setupViews()
        title = "Debug"
        setupBody()
    }
    var res1 = Lazy { () -> Resource in
//        print("execute laze closure1", self.n)
        return Resource(age:  110)
    }
    lazy var res = Knife.lazy { () -> Resource in
        print("execute laze closure", self.n)
        return Resource(age: 10)
    }
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
