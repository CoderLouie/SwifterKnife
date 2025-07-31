//
//  OdinTest.swift
//  SwifterKnife
//
//  Created by liyang on 2025/7/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//  https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if !os(watchOS)

private protocol Test: AnyObject {
}

private protocol TestDependency {
    var test: Test! { get set }
}

private class TestObject: Test {
}

private class TestDependencyObject: TestDependency {
    var test: Test!
}

class OdinTests {
    func testTypes() {
        let container = Odin()
        let testObject = TestObject()
        container.register { () -> Test in testObject }

        let resolvedTestObject: Test? = container.resolve()
        precondition(resolvedTestObject === testObject)
    }

    func testTypesParent() {
        let parentContainer = Odin()
        let parentTestObject = TestObject()
        parentContainer.register { () -> Test in parentTestObject }

        let container = Odin(parentContainer: parentContainer)

        let resolvedParentTestObject: Test? = container.resolve()
        precondition(resolvedParentTestObject === parentTestObject)
    }

    func testTypesParentOverride() {
        let parentContainer = Odin()
        let parentTestObject = TestObject()
        parentContainer.register { () -> Test in parentTestObject }

        let container = Odin(parentContainer: parentContainer)
        let testObject = TestObject()
        container.register { () -> Test in testObject }

        let resolvedTestObject: Test? = container.resolve()
        precondition(resolvedTestObject === testObject)
    }

    func testProtocols() {
        let container = Odin()
        let testObject = TestObject()
        container.register { (object: inout TestDependency) in object.test = testObject }

        let testDependencyObject = TestDependencyObject()

        container.resolve(testDependencyObject)
        let resolvedTestObject = testDependencyObject.test
        precondition(resolvedTestObject === testObject)
    }

    func testProtocolsParent() {
        let parentContainer = Odin()
        let parentTestObject = TestObject()
        parentContainer.register { (object: inout TestDependency) in object.test = parentTestObject }

        let container = Odin(parentContainer: parentContainer)

        let testDependencyObject = TestDependencyObject()

        container.resolve(testDependencyObject)
        let resolvedTestObject = testDependencyObject.test
        precondition(resolvedTestObject === parentTestObject)
    }

    func testProtocolsParentOverride() {
        let parentContainer = Odin()
        let parentTestObject = TestObject()
        parentContainer.register { (object: inout TestDependency) in object.test = parentTestObject }

        let container = Odin(parentContainer: parentContainer)
        let testObject = TestObject()
        container.register { (object: inout TestDependency) in object.test = testObject }

        let testDependencyObject = TestDependencyObject()
        container.resolve(testDependencyObject)
        let resolvedTestObject = testDependencyObject.test
        precondition(resolvedTestObject === testObject)
    }
}

#endif
