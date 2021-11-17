//
//  Mems.swift
//  SwifterKnife
//
//  Created by liyang on 2021/11/17.
//

import Foundation

/*
 
 func show<T>(val: inout T) {
     print("-------------- \(type(of: val)) --------------")
     print("变量的地址:", Mems.ptr(ofVal: &val))
     print("变量的内存:", Mems.memStr(ofVal: &val))
     print("变量的大小:", Mems.size(ofVal: &val))
     print("")
 }

 func show<T>(ref: T) {
     print("-------------- \(type(of: ref)) --------------")
     print("对象的地址:", Mems.ptr(ofRef: ref))
     print("对象的内存:", Mems.memStr(ofRef: ref))
     print("对象的大小:", Mems.size(ofRef: ref))
     print("")
 }

 /// 整型
 func showInt() {
     var int8: Int8 = 10
     show(val: &int8)
     
     var int16: Int16 = 10
     show(val: &int16)
     
     var int32: Int32 = 10
     show(val: &int32)
     
     var int64: Int64 = 10
     show(val: &int64)
 }

 /// 枚举
 func showEnum() {
     enum TestEnum {
         case test1(Int, Int, Int)
         case test2(Int, Int)
         case test3(Int)
         case test4(Bool)
         case test5
     }
     var e = TestEnum.test1(1, 2, 3)
     show(val: &e)
     e = .test2(4, 5)
     show(val: &e)
     e = .test3(6)
     show(val: &e)
     e = .test4(true)
     show(val: &e)
     e = .test5
     show(val: &e)
 }

 /// 结构体
 func showStruct() {
     struct Date {
         var year = 10
         var test = true
         var month = 20
         var day = 30
     }
     var s = Date()
     show(val: &s)
 }

 // 类
 func showClass() {
     class Point  {
         var x = 11
         var test = true
         var y = 22
     }
     var p = Point()
     show(val: &p)
     show(ref: p)
 }

 /// 数组
 func showArray() {
     var arr = [1, 2, 3, 4]
     show(val: &arr)
     show(ref: arr)
 }

 /// 字符串
 func showString() {
     var str1 = "123456789"
     // tagPtr（tagger pointer）
     print(str1.mems.type())
     show(val: &str1)

     var str2 = "1234567812345678"
     // text（TEXT段，常量区）
     print(str2.mems.type())
     show(val: &str2)

     var str3 = "1234567812345678"
     str3.append("9")
     // heap（字符串存储在堆空间）
     print(str3.mems.type())
     show(val: &str3)
     show(ref: str3)
 }

 /// 字节格式
 func showByteFormat() {
     var int64: Int64 = 10
     print("1个字节为1组 :", Mems.memStr(ofVal: &int64, alignment: .one))
     print("2个字节为1组 :", Mems.memStr(ofVal: &int64, alignment: .two))
     print("4个字节为1组 :", Mems.memStr(ofVal: &int64, alignment: .four))
     print("8个字节为1组 :", Mems.memStr(ofVal: &int64, alignment: .eight))
 }
 
 // https://github.com/CoderMJLee/Mems
 */

public enum MemAlign : Int {
    case one = 1, two = 2, four = 4, eight = 8
}

private let _EMPTY_PTR = UnsafeRawPointer(bitPattern: 0x1)!

/// 辅助查看内存的小工具类
public struct Mems<T> {
    private static func _memStr(_ ptr: UnsafeRawPointer,
                                _ size: Int,
                                _ aligment: Int) -> String {
        if ptr == _EMPTY_PTR { return "" }
        
        var rawPtr = ptr
        var string = ""
        let fmt = "0x%0\(aligment << 1)lx"
        let count = size / aligment
        for i in 0..<count {
            if i > 0 {
                string.append(" ")
                rawPtr += aligment
            }
            let value: CVarArg
            switch aligment {
            case MemAlign.eight.rawValue:
                value = rawPtr.load(as: UInt64.self)
            case MemAlign.four.rawValue:
                value = rawPtr.load(as: UInt32.self)
            case MemAlign.two.rawValue:
                value = rawPtr.load(as: UInt16.self)
            default:
                value = rawPtr.load(as: UInt8.self)
            }
            string.append(String(format: fmt, value))
        }
        return string
    }
    
    private static func _memBytes(_ ptr: UnsafeRawPointer,
                                  _ size: Int) -> [UInt8] {
        var arr: [UInt8] = []
        if ptr == _EMPTY_PTR { return arr }
        for i in 0..<size {
            arr.append((ptr + i).load(as: UInt8.self))
        }
        return arr
    }
    
    /// 获得变量的内存数据（字节数组格式）
    public static func memBytes(ofVal v: inout T) -> [UInt8] {
        return _memBytes(ptr(ofVal: &v), MemoryLayout.stride(ofValue: v))
    }
    
    /// 获得引用所指向的内存数据（字节数组格式）
    public static func memBytes(ofRef v: T) -> [UInt8] {
        let p = ptr(ofRef: v)
        return _memBytes(p, malloc_size(p))
    }
    
    /// 获得变量的内存数据（字符串格式）
    ///
    /// - Parameter alignment: 决定了多少个字节为一组
    public static func memStr(ofVal v: inout T, alignment: MemAlign? = nil) -> String {
        let p = ptr(ofVal: &v)
        return _memStr(p, MemoryLayout.stride(ofValue: v),
                       alignment != nil ? alignment!.rawValue : MemoryLayout.alignment(ofValue: v))
    }
    
    /// 获得引用所指向的内存数据（字符串格式）
    ///
    /// - Parameter alignment: 决定了多少个字节为一组
    public static func memStr(ofRef v: T, alignment: MemAlign? = nil) -> String {
        let p = ptr(ofRef: v)
        return _memStr(p, malloc_size(p),
                       alignment != nil ? alignment!.rawValue : MemoryLayout.alignment(ofValue: v))
    }
    
    /// 获得变量的内存地址
    public static func ptr(ofVal v: inout T) -> UnsafeRawPointer {
        return MemoryLayout.size(ofValue: v) == 0 ? _EMPTY_PTR : withUnsafePointer(to: &v) {
            UnsafeRawPointer($0)
        }
    }
    
    /// 获得引用所指向内存的地址
    public static func ptr(ofRef v: T) -> UnsafeRawPointer {
        if v is Array<Any>
            || Swift.type(of: v) is AnyClass
            || v is AnyClass {
            return UnsafeRawPointer(bitPattern: unsafeBitCast(v, to: UInt.self))!
        } else if v is String {
            var mstr = v as! String
            if mstr.mems.type() != .heap {
                return _EMPTY_PTR
            }
            return UnsafeRawPointer(bitPattern: unsafeBitCast(v, to: (UInt, UInt).self).1)!
        } else {
            return _EMPTY_PTR
        }
    }
    
    /// 获得变量所占用的内存大小
    public static func size(ofVal v: inout T) -> Int {
        return MemoryLayout.size(ofValue: v) > 0 ? MemoryLayout.stride(ofValue: v) : 0
    }
    
    /// 获得引用所指向内存的大小
    public static func size(ofRef v: T) -> Int {
        return malloc_size(ptr(ofRef: v))
    }
}


public enum StringMemType : UInt8 {
    /// TEXT段（常量区）
    case text = 0xd0
    /// taggerPointer
    case tagPtr = 0xe0
    /// 堆空间
    case heap = 0xf0
    /// 未知
    case unknow = 0xff
}

public struct MemsWrapper<Base> {
    public private(set) var base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol MemsCompatible {}
public extension MemsCompatible {
    static var mems: MemsWrapper<Self>.Type {
        get { return MemsWrapper<Self>.self }
        set {}
    }
    var mems: MemsWrapper<Self> {
        get { return MemsWrapper(self) }
        set {}
    }
}

extension String: MemsCompatible {}
public extension MemsWrapper where Base == String {
    mutating func type() -> StringMemType {
        let ptr = Mems.ptr(ofVal: &base)
        return StringMemType(rawValue: (ptr + 15).load(as: UInt8.self) & 0xf0)
            ?? StringMemType(rawValue: (ptr + 7).load(as: UInt8.self) & 0xf0)
            ?? .unknow
    }
}
