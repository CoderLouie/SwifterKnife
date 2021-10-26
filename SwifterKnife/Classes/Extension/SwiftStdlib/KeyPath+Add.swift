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
prefix func !<T>(keyPath: KeyPath<T, Bool>) -> (T) -> Bool {
    return { !$0[keyPath: keyPath] }
}
/*
 let fullLengthArticles = articles.filter(\.category == .fullLength)
 */
func ==<T, V: Equatable>(lhs: KeyPath<T, V>, rhs: V) -> (T) -> Bool {
    return { $0[keyPath: lhs] == rhs }
}
