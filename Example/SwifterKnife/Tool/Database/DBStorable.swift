//
//  DBStorable.swift
//  SwifterKnife
//
//  Created by 李阳 on 2024/4/3.
//

import Foundation


public protocol SimpleDB {
    func encodeToDBData() throws -> Data
    init(fromDBData data: Data)
    
    static var dbFilePath: String { get }
    static var dbTableName: String { get }
}
extension SimpleDB {
    static var dbFilePath: String {
        "SwifterKnifeDB/common.sqlite".fullFilePath(under: .document)
    }
    static var dbTableName: String {
        String(describing: self)
    }
}
