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
 */
public func ==<T, V: Equatable>(lhs: KeyPath<T, V>, rhs: V) -> (T) -> Bool {
    return { $0[keyPath: lhs] == rhs }
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
