//
//  Catch.swift
//  SwifterKnife
//
//  Created by 李阳 on 2021/12/6.
//

import Foundation


enum Catch {
    static func test<T>(_ work: @autoclosure () throws -> T) -> Bool {
        do {
            let _ = try work()
            return true
        } catch {
            return false
        }
    }
    static func result<T>(_ work: @autoclosure () throws -> T) -> Result<T, Error> {
        do {
            let val = try work()
            return .success(val)
        } catch {
            return .failure(error)
        }
    }
}
