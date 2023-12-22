//
//  WeakTableTest.swift
//  SwifterKnife_Tests
//
//  Created by 李阳 on 2023/12/22.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import XCTest
import SwifterKnife

fileprivate final class Fish: ExpressibleByIntegerLiteral, CustomStringConvertible {
    let age: Int
    init(_ age: Int) {
        self.age = age
    }
    init(integerLiteral value: Int) {
        self.age = value
    }
    var description: String {
        "\(age)"
    }
}

final class WeakTableTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        var array: WeakTable<Fish> = .strong
        array.append(contentsOf: fishes(3..<6))
        assert(array, [3, 4, 5])
        do {
            var ptrs = array
            ptrs.replaceSubrange(0..<0, with: fishes(0...2))
            assert(ptrs, [0, 1, 2, 3, 4, 5])
            ptrs.replaceSubrange(0..<6, with: fishes(0..<0))
            assert(ptrs, [])
        }
        assert(array, [3, 4, 5])
        do {
            var ptrs = array
            ptrs.replaceSubrange(2..<3, with: fishes(10..<13))
            assert(ptrs, [3, 4, 10, 11, 12])
        }
    }
    private func assert(_ array: WeakTable<Fish>, _ range: [Int]) {
//        print(array.description)
//        print(range.description)
        XCTAssertEqual(array.description, range.map { "\($0)" }.description)
    }
    private func fishes<S: Sequence>(_ range: S) -> [Fish] where S.Element == Int {
        range.map(Fish.init(_:))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
