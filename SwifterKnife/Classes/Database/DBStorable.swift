//
//  DBStorable.swift
//  SwifterKnife
//
//  Created by 李阳 on 2024/4/3.
//

import Foundation


public protocol DBStorable {
    func encodeToDBData() throws -> Data
    init(fromDBData data: Data)
    
    static var dbFilePath: String { get }
    static var dbTableName: String { get }
}
extension DBStorable {
    static var dbFilePath: String {
        "SwifterKnifeDB/common.sqlite".fullFilePath(under: .document)
    }
    static var dbTableName: String {
        String(describing: self)
    }
}
