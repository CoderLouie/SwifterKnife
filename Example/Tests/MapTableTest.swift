//
//  MapTableTest.swift
//  SwifterKnife_Tests
//
//  Created by 李阳 on 2023/12/22.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import XCTest
import SwifterKnife
import Foundation

extension NSArray: Copyable {}

final class MapTableTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let nsarray = NSArray()
        let tmp = nsarray.copyable()
        return ()
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        let table = NSMapTable<Fish, Fish>.strongToWeakObjects()
        let array = NSPointerArray.weakObjects()
        let hash = NSHashTable<Fish>.weakObjects()
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
