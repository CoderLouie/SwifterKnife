//
//  KeyPath+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation


// MARK: - KeyPath
/*
 struct Article {
     var title: String
     var body: String
     var category: Category
     var isRead: Bool
 }
 extension Article {
     enum Category {
         case fullLength
         case quickReads
         case basics
     }
 }
 let articles: [Article] = []
 let readArticles = articles.filter(\.isRead)
 https://mp.weixin.qq.com/s/-xCFBCNcveNZcA_wBUhSzA
 */

/*
 let unreadArticles = articles.filter(!\.isRead)
 */
public prefix func !<T>(keyPath: KeyPath<T, Bool>) -> (T) -> Bool {
    return { !$0[keyPath: keyPath] }
}
/*
 let fullLengthArticles = articles.filter(\.category == .fullLength)
 let article = articles.last(\.category == .fullLength)
 */
public func ==<T, V: Equatable>(lhs: KeyPath<T, V>, rhs: V) -> (T) -> Bool {
    return { $0[keyPath: lhs] == rhs }
}
public func ><T, V: Comparable>(lhs: KeyPath<T, V>, rhs: V) -> (T) -> Bool {
    return { $0[keyPath: lhs] > rhs }
}
public func <<T, V: Comparable>(lhs: KeyPath<T, V>, rhs: V) -> (T) -> Bool {
    return { $0[keyPath: lhs] < rhs }
}


/*
 + 的意思是 如果 $0 > $1 则 $0 - $1 是正数
 let shortestArticle = articles.max(by: +\.title.count)
 */
public prefix func +<T, V: Comparable>(keyPath: KeyPath<T, V>) -> (T, T) -> Bool {
    return { $0[keyPath: keyPath] > $1[keyPath: keyPath] }
}

/*
 - 的意思是 如果 $0 < $1 则 $0 - $1 是负数
 let longestArticle = articles.max(by: -\.title.count)
 */
public prefix func -<T, V: Comparable>(keyPath: KeyPath<T, V>) -> (T, T) -> Bool {
    return { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
}

private func sort<R, T: Comparable>(
    r0: R, r1: R,
    using keyPath: KeyPath<R, T>,
    areInIncreasingOrder order: Bool)
-> Bool {
    return order ?
    r0[keyPath: keyPath] < r1[keyPath: keyPath]:
    r0[keyPath: keyPath] > r1[keyPath: keyPath]
}
private func sort<R, T: Comparable, U: Comparable, V: Comparable>(
    first: KeyPath<R, T>,
    second: KeyPath<R, U>,
    thrid: KeyPath<R, V>?,
    areInIncreasingOrder order: Bool
) -> (R, R) -> Bool {
    return {
        if $0[keyPath: first] != $1[keyPath: first] {
            return sort(r0: $0, r1: $1, using: first, areInIncreasingOrder: order)
        }
        guard let last = thrid else {
            return sort(r0: $0, r1: $1, using: second, areInIncreasingOrder: order)
        }
        if $0[keyPath: second] != $1[keyPath: second] {
            return sort(r0: $0, r1: $1, using: second, areInIncreasingOrder: order)
        }
        return sort(r0: $0, r1: $1, using: last, areInIncreasingOrder: order)
    }
}


public prefix func +<R, T: Comparable, U: Comparable>
(keyPaths: (KeyPath<R, T>, KeyPath<R, U>))
-> (R, R) -> Bool {
    let thrid: KeyPath<R, Int>? = nil
    return sort(first: keyPaths.0, second: keyPaths.1, thrid: thrid, areInIncreasingOrder: false)
}
public prefix func -<R, T: Comparable, U: Comparable>
(keyPaths: (KeyPath<R, T>, KeyPath<R, U>))
-> (R, R) -> Bool {
    let thrid: KeyPath<R, Int>? = nil
    return sort(first: keyPaths.0, second: keyPaths.1, thrid: thrid, areInIncreasingOrder: true)
}

public prefix func +<R, T: Comparable, U: Comparable, V: Comparable>
(keyPaths: (KeyPath<R, T>, KeyPath<R, U>, KeyPath<R, V>))
-> (R, R) -> Bool {
    return sort(first: keyPaths.0, second: keyPaths.1, thrid: keyPaths.2, areInIncreasingOrder: false)
}
public prefix func -<R, T: Comparable, U: Comparable, V: Comparable>
(keyPaths: (KeyPath<R, T>, KeyPath<R, U>, KeyPath<R, V>))
-> (R, R) -> Bool {
    return sort(first: keyPaths.0, second: keyPaths.1, thrid: keyPaths.2, areInIncreasingOrder: true)
}
