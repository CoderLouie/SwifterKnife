//
//  Database.swift
//  SwifterKnife
//
//  Created by 李阳 on 2024/4/7.
//

import Foundation
import SQLite3
 
public final class Database {
    public enum Location {
        case inMemory
        case temporary
        case uri(String)
    }
    
    public init(_ location: Location = .inMemory, readonly: Bool = false) throws {
    
        let flags = readonly ? SQLITE_OPEN_READONLY : (SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE)
        let code = sqlite3_open_v2(location.description, &handle, flags | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_URI, nil)
        try check(code)
        
        queue.setSpecific(key: Database.queueKey, value: queueContext)
        try addUnixepoch()
    }
    public convenience init(path: String, readonly: Bool = false) throws {
        try self.init(.uri(path), readonly: readonly)
    }
    
    deinit { sqlite3_close(handle) }
    
    fileprivate static let queueKey = DispatchSpecificKey<Int>()
    fileprivate var queue = DispatchQueue(label: "SwiferKnife.Database", attributes: [])
    fileprivate lazy var queueContext: Int = unsafeBitCast(self, to: Int.self)
    
    private var handle: OpaquePointer!
    private lazy var functions: [String: [Int: Any]] = [:]
    
    fileprivate typealias Trace = @convention(block) (UnsafeRawPointer) -> Void
    fileprivate var trace: Trace?
}

extension Database {
    public enum Error: Swift.Error {
        case error(message: String, code: Int32)
        
        fileprivate static let successCodes: Set = [SQLITE_OK, SQLITE_ROW, SQLITE_DONE]
        init?(code: Int32, db: Database) {
            if Error.successCodes.contains(code) {
                return nil
            }
            self = .error(message: db.lastError, code: code)
        }
    }
    
    public var lastError: String {
        return String(cString: sqlite3_errmsg(handle))
    }
    public var lastErrorCode: Int32 {
        return sqlite3_errcode(handle)
    }
}

private extension Database {
    @discardableResult
    func sync<T>(_ block: () throws -> T) rethrows -> T {
        if DispatchQueue.getSpecific(key: Database.queueKey) == queueContext {
            return try block()
        } else {
            return try queue.sync(execute: block)
        }
    }
    
    func transaction(_ begin: String, _ block: () throws -> Void, _ commit: String, or rollback: String) throws {
        return try sync {
            try self.execute(begin)
            do {
                try block()
                try self.execute(commit)
            } catch {
                try self.execute(rollback)
                throw error
            }
        }
    }
    
    @discardableResult
    func check(_ resultCode: Int32) throws -> Int32 {
        if let error = Database.Error(code: resultCode, db: self) {
            throw error
        }
        return resultCode
    }
}


extension Database {
    public var lastInsertRowid: Int64 {
        sqlite3_last_insert_rowid(handle)
    }
 
    public var changes: Int {
        Int(sqlite3_changes(handle))
    }
    public var totalChanges: Int {
        Int(sqlite3_total_changes(handle))
    }
    
    public func vacuum() throws {
        try execute("VACUUM")
    }
    
    public func foreignKeys(enable: Bool) throws {
        let flag = enable ? "on" : "off"
        try execute("PRAGMA foreign_keys = \(flag);")
    }
    
    public func resetReq(to req: Int = 0, on table: String) throws {
        try execute("update sqlite_sequence set seq = \(req) where name = '\(table)';")
    }
    public func tableExis(_ table: String) throws -> Bool {
        let res = try scalar("select count(name) as count from sqlite_master where type = 'table' and name = '\(table)';")
        return (res?["count"] as? Int) ?? 0 > 0
    }
    
    public func track(_ callback: ((String) -> Void)?) {
        guard let closure = callback else {
            // If the X callback is NULL or if the M mask is zero, then tracing is disabled.
            sqlite3_trace_v2(handle, 0 /* mask */, nil /* xCallback */, nil /* pCtx */)
            trace = nil
            return
        }

        let box: Trace = { (pointer: UnsafeRawPointer) in
            closure(String(cString: pointer.assumingMemoryBound(to: UInt8.self)))
        }
        sqlite3_trace_v2(handle, UInt32(SQLITE_TRACE_STMT), {
                 (_: UInt32, context: UnsafeMutableRawPointer?, pointer: UnsafeMutableRawPointer?, _: UnsafeMutableRawPointer?) in
                 if let pointer,
                    let expandedSQL = sqlite3_expanded_sql(OpaquePointer(pointer)) {
                     unsafeBitCast(context, to: Trace.self)(expandedSQL)
                     sqlite3_free(expandedSQL)
                 }
                 return Int32(0) // currently ignored
             },
             unsafeBitCast(box, to: UnsafeMutableRawPointer.self) /* pCtx */
        )
        trace = box
    }
}


public protocol Binding { }
extension Double: Binding { }
extension Int: Binding { }
extension String: Binding { }
extension Bool: Binding { }
extension Data: Binding { }


public enum Results {
    case value(Binding)
    case null
    case error(String)
}


public extension Database {

    func execute(_ sql: String) throws {
        try sync { try check(sqlite3_exec(handle, sql, nil, nil, nil)) }
    }
    
    /// The mode in which a transaction acquires a lock.
    enum TransactionMode: String {
        /// Defers locking the database till the first read/write executes.
        case deferred = "DEFERRED"

        /// Immediately acquires a reserved lock on the database.
        case immediate = "IMMEDIATE"

        /// Immediately acquires an exclusive lock on all databases.
        case exclusive = "EXCLUSIVE"

    }
    
    func transaction(_ mode: TransactionMode = .deferred, block: () throws -> Void) throws {
        try transaction("BEGIN \(mode.rawValue) TRANSACTION", block, "COMMIT TRANSACTION", or: "ROLLBACK TRANSACTION")
    }
    func savepoint(_ name: String = UUID().uuidString, block: () throws -> Void) throws {
        let savepoint = "SAVEPOINT \(name)"

        try transaction(savepoint, block, "RELEASE \(savepoint)", or: "ROLLBACK TO \(savepoint)")
    }
    
    func execute(_ sqls: [String], entirety: Bool = true) throws {
        if sqls.isEmpty { return }
        let work = { try sqls.forEach { try self.execute($0) } }
        if entirety {
            try savepoint(block: work)
        } else {
            try work()
        }
    }
}
public extension Database {
    
    func perform(_ sqlFunc: String) throws -> Binding? {
        guard let row = try query("select \(sqlFunc) as result").first else { return nil }
        return row["result"]
    }
    func scalar(_ sql: String) throws -> [String: Binding]? {
        try query(sql).first
    }
    func query(_ sql: String) throws -> [[String: Binding]] {
        guard !sql.isEmpty else { return [] }
        
        var stmt: OpaquePointer?
        let code = sqlite3_prepare_v2(handle, sql.cString(using: .utf8), -1, &stmt, nil)
        try check(code)
        var res: [[String: Binding]] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            let count = sqlite3_column_count(stmt)
            var row: [String: Binding] = [:]
            for i in 0..<count {
                let name = String(cString: sqlite3_column_name(stmt, i))
                
                switch sqlite3_column_type(stmt, i) {
                case SQLITE_INTEGER:
                    row[name] = Int(sqlite3_column_int64(stmt, i))
                case SQLITE_FLOAT:
                    row[name] = sqlite3_column_double(stmt, i)
                case SQLITE_BLOB:
                    if let pointer = sqlite3_column_blob(stmt, i) {
                        let length = sqlite3_column_bytes(stmt, i)
                        row[name] = Data(bytes: pointer, count: Int(length))
                    }
                case SQLITE_TEXT:
                    row[name] = String(cString: sqlite3_column_text(stmt, i))
                default: break
                }
            }
            if !row.isEmpty { res.append(row) }
        }
        sqlite3_finalize(stmt)
        return res
    }
}

fileprivate typealias Context = OpaquePointer?
fileprivate typealias Argv = UnsafeMutablePointer<OpaquePointer?>?
fileprivate extension Argv {
    func getParameter(argc: Int32) -> [Binding] {
        (0..<Int(argc)).map { idx in
            let value = self![idx]
            switch sqlite3_value_type(value) {
            case SQLITE_BLOB:
                return Data(bytes: sqlite3_value_blob(value), count: Int(sqlite3_value_bytes(value)))
            case SQLITE_FLOAT:
                return sqlite3_value_double(value)
            case SQLITE_INTEGER:
                return Int(sqlite3_value_int64(value))
            
            case SQLITE_TEXT:
                return String(cString: UnsafePointer(sqlite3_value_text(value)))
            case let type:
                fatalError("unsupported value type: \(type)")
            }
        }
    }
}
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
fileprivate extension Context {
    func set(result: Results) {
        switch result {
        case let .value(value):
            switch value {
            case let data as Data:
                let bytes = [UInt8](data)
                sqlite3_result_blob(self, bytes, Int32(bytes.count), nil)
            case let double as Double:
                sqlite3_result_double(self, double)
            case let int as Int:
                sqlite3_result_int64(self, Int64(int))
            case let string as String:
                sqlite3_result_text(self, string, Int32(string.lengthOfBytes(using: .utf8)), SQLITE_TRANSIENT)
            case let bool as Bool:
                sqlite3_result_int64(self, Int64(bool ? 1 : 0))
            default:
                fatalError("unsupported result type: \(String(describing: result))")
            }
        case .null:
            sqlite3_result_null(self)
        case let .error(string):
            sqlite3_result_error(self, string, -1)
        }
    }
}
extension Database {
    fileprivate typealias Function = @convention(block) (Context, Int32, Argv) -> Void
    
    public func addFunction(_ name: String,
                            argumentCount: UInt? = nil,
                            deterministic: Bool = false,
                            _ block: @escaping (_ db: Database, _ args: [Binding]) -> Results) throws {
        let argc = argumentCount.map { Int($0) } ?? -1
        let box: Function = { (context: Context, argc, argv: Argv) in
            context.set(result: block(self, argv.getParameter(argc: argc)))
        }
        func xFunc(context: Context, argc: Int32, value: Argv) {
            unsafeBitCast(sqlite3_user_data(context), to: Function.self)(context, argc, value)
        }
        let flags = SQLITE_UTF8 | (deterministic ? SQLITE_DETERMINISTIC : 0)
        let code = sqlite3_create_function_v2(
            handle,
            name,
            Int32(argc),
            flags,
            /* pApp */ unsafeBitCast(box, to: UnsafeMutableRawPointer.self),
            xFunc, /*xStep*/ nil, /*xFinal*/ nil, /*xDestroy*/ nil
        )
        try check(code)
        
        if functions[name] == nil {
            functions[name] = [:]
        }
        functions[name]?[argc] = box
    }
}
 

extension Database {
    
    private func addUnixepoch() throws {
        try addFunction("unixepoch") { (_ db: Database, _ param: [Binding]) -> Results in
            let n = param.count
            guard n > 1 else { return .error("need at least two arguments") }
            
            guard let ts = param[0] as? NSNumber else {
                return .error("first argument must be integer or float")
            }
            guard let modifier = (param[1] as? String)?.lowercased() else {
                return .error("second argument must be text")
            }
            let unsupportError: Results = .error("unsupport '\(modifier)' modifier")
            var sql = ""
            if modifier == "start of year" {
                sql = "select strftime('%s', \(ts), 'unixepoch', 'localtime', 'start of year', 'utc') as result"
            } else if modifier == "end of year" {
                sql = "select strftime('%s', \(ts), 'unixepoch', 'localtime', 'start of year', '+1 year', '-1 second', 'utc') as result"
            } else if modifier == "start of month" {
                sql = "select strftime('%s', \(ts), 'unixepoch', 'localtime', 'start of month', 'utc') as result"
            } else if modifier == "end of month" {
                sql = "select strftime('%s', \(ts), 'unixepoch', 'localtime', 'start of month', '+1 month', '-1 second', 'utc') as result"
            } else if modifier == "start of day" {
                sql = "select strftime('%s', \(ts), 'unixepoch', 'localtime', 'start of day', 'utc') as result"
            } else if modifier == "end of day" {
                sql = "select strftime('%s', \(ts), 'unixepoch', 'localtime', 'start of day', '+1 day', '-1 second', 'utc') as result"
            } else if modifier.contains("week") {
                var delta = ""
                if n > 2 {
                    if let val2 = param[2] as? Int {
                        let temp = abs(val2)
                        delta = val2 > 0 ? " '+\(temp) day'," : " '-\(temp) day',"
                    } else {
                        return .error("thrid argument must be integer")
                    }
                }
                if modifier == "start of week" {
                    sql = "select strftime('%s', \(ts), 'unixepoch', 'localtime', strftime('-%w day', \(ts), 'unixepoch'), 'start of day',\(delta) 'utc') as result"
                } else if modifier == "end of week" {
                    sql = "select strftime('%s', \(ts), 'unixepoch', 'localtime', strftime('-%w day', \(ts), 'unixepoch'), 'start of day',\(delta) '+7 day', '-1 second', 'utc') as result"
                } else {
                    return unsupportError
                }
            } else if modifier.contains("hour") {
                guard let row = try? db.scalar("select strftime('%H', \(ts), 'unixepoch', 'localtime') as result") else {
                    return .null
                }
                guard var hour = row["result"] as? Int else { return .null }
                var step = 1
                if n > 2 {
                    if let val2 = param[2] as? Int {
                        guard (0..<24).contains(val2) else {
                            return .error("thrid argument out of bounds")
                        }
                        step = val2
                    } else {
                        return .error("thrid argument must be integer")
                    }
                }
                var delta = ""
                if modifier == "start of hour" {
                    hour = hour / step * step;
                    delta = "'+\(hour) hour'"
                } else if modifier == "end of hour" {
                    hour = (hour / step + 1) * step;
                    delta = "'+\(hour) hour'"
                } else if modifier == "middle of hour"  {
                    hour = (hour / step) * step;
                    delta = "'+\(hour) hour', '+\(step * 30) minute'"
                } else {
                    return unsupportError
                }
                sql = "select strftime('%s', \(ts), 'unixepoch', 'localtime', 'start of day', \(delta), 'utc') as result"
            } else if modifier.contains("minute") {
                guard n > 2 else {
                    return .error("need at least three arguments")
                }
                guard let step = param[2] as? Int else {
                    return .error("thrid argument must be integer")
                }
                if step <= 0 {
                    return .error("thrid argument should be > 0")
                }
                guard let row = try? db.scalar("select strftime('%H:%M', \(ts), 'unixepoch', 'localtime') as result") else {
                    return .null
                }
                guard let cmps = (row["result"] as? String)?.components(separatedBy: ":").compactMap(Int.init),
                      cmps.count > 1 else { return .null }
                var min = cmps[0] * 60 + cmps[1]
                var delta = ""
                if modifier == "start of minute" {
                    min = min / step * step;
                    delta = "'+\(min) minute'"
                } else if modifier == "end of minute" {
                    min = (min / step + 1) * step;
                    delta = "'+\(min) minute'"
                } else {
                    return unsupportError
                }
                sql = "select strftime('%s', \(ts), 'unixepoch', 'localtime', 'start of day', \(delta), 'utc') as result"
            } else {
                return unsupportError
            }
            guard let v = try? db.scalar(sql)?["result"] else {
                return .null
            }
            return .value(v)
        }
    }
}



extension Database.Location: CustomStringConvertible {
    public var description: String {
        switch self {
        case .inMemory:
            return ":memory:"
        case .temporary:
            return ""
        case .uri(let URI):
            return URI
        }
    }
}

