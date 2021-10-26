//
//  BitSet.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

//public typealias Word = UInt8
public typealias Word = UInt64
fileprivate extension Word {
    func get(_ i: Int) -> Bool {
        return (self & (1 << i)) != 0
    }
    mutating func set(_ i: Int, _ value: Bool) {
        if (value) { self |= (1 << i) } else { self &= ~(1 << i) }
    }
    
    func get(_ range: ClosedRange<Int>) -> Bool {
        return slice(range) != 0
    }
    mutating func set(_ range: ClosedRange<Int>, _ value: Bool) {
        let num = Self.build(range, value)
        if (value) { self |= num } else { self &= num }
    }
    
    func get(_ nbits: [Int]) -> Bool {
        for case let i in nbits where i >= 0 && i < Self.N {
            if ((self & (1 << i)) != 0) { return true }
        }
        return false
    }
    mutating func set(_ nbits: [Int], _ value: Bool) {
        let count = Self.N
        if (value) {
            for case let i in nbits where i >= 0 && i < count {
                self |= (1 << i)
            }
        } else {
            for case let i in nbits where i >= 0 && i < count {
                self &= ~(1 << i)
            }
        }
    }
    
    /// 翻转第i位
    mutating func flip(_ i: Int) {
        self ^= (1 << i)
    }
    mutating func flip(_ range: ClosedRange<Int>) {
        let num = Self.build(range, true)
        self ^= num
    }
    mutating func flip(_ nbits: [Int]) {
        let count = Self.N
        for case let i in nbits where i >= 0 && i < count {
            self ^= (1 << i)
        }
    }
    
    /// 2进制位中1的个数
    var cardinality: Int {
        var count = 0, n = self
//        each { count += $0 ? 1 : 0 }
        while n != 0 {
            count += 1
            n &= n - 1
        }
        return count
    }
     
    /// 最左边位为1的索引
    var msb: Int {
        var count = 0
        each { if $0 { count = $1 } }
        return count
    }
    /// 最右边位为1的索引
    var lsb: Int {
        var count = 0
        each { (b, idx, stop) in
            if b {
                count = idx
                stop.pointee = true
            }
        }
        return count
    }
    
    func slice(_ range: ClosedRange<Int>) -> Self {
        let num = Self.build(range, true)
        return (self & num)
    }
}

fileprivate extension Word {
    static let N = Self.bitWidth
    static let I = N - 1
    static let BITS = Int(log2(Double(N)))
    
    static var b_min: Self { return 0 }
    static var b_max: Self { return ~b_min }
    static func build(_ range: ClosedRange<Int>, _ value: Bool ) -> Self {
        var num = Self.fill(range.upperBound)
        num &= num << range.lowerBound
        if (value) { return num } else { return (max ^ num) }
    }
    static func fill(_ i: Int) -> Self {
        let idx = i + 1
        if (idx == N) { return b_max }
        return (1 << idx) - 1
    }
    static func hold<T>(value: T) -> [Self] where T: BinaryInteger {
        let bitWidth = MemoryLayout<T>.stride << 3
        if N > bitWidth { return [Self(value)] }
        var bits: [Self] = []
        let mask = UInt64(b_max)
        var val = value
        var w = 0
        while w < bitWidth {
            bits.append(Self(UInt64(val) & mask))
            val >>= N
            w += N
        }
        return bits
    }
}

fileprivate extension Word {
    func each(_ work: (Bool) -> Void) {
        var n = self
        while n != 0 {
            work(n & 1 != 0)
            n >>= 1
        }
    }
    func each(_ work: (Bool, Int) -> Void) {
        var n = self
        var i = 0
        while n != 0 {
            work(n & 1 != 0, i)
            i += 1
            n >>= 1
        }
    }
    func each(_ work: (Bool, Int, UnsafeMutablePointer<Bool>) -> Void) {
        var n = self
        var i = 0
        var stop = false
        while n != 0 {
            work(n & 1 != 0, i, &stop)
            if (stop) { break }
            i += 1
            n >>= 1
        }
    }
}

fileprivate extension Word {
    func toString(_ barry: Int = 2, width: Int = 8, pretty: Bool = true) -> String {
        if (barry == 16) {
            let arg: CVarArg = UInt64(self)
            return String(format: "0x%02x", arg)
        }
        if (barry == 10) { return "\(self)" }
        var s = ""
        var n = self
        let count = Self.N
        if pretty {
            for i in 1..<count {
                s = ((n & 1 != 0) ? "1" : "0") + s
                if (i % width) == 0 { s = " " + s }
                n >>= 1
            }
        } else {
            for _ in 1..<count {
                s = ((n & 1 != 0) ? "1" : "0") + s
                n >>= 1
            }
        }
        s = ((n & 1 != 0) ? "1" : "0") + s
        return s;
    }
    func toArray() -> [Bool] {
        var bits: [Bool] = []
        var n = self
        for _ in 1...Self.N {
            bits.append(n & 1 != 0)
            n >>= 1
        }
        return bits
    }
}


infix operator >>> :  BitwiseShiftPrecedence
infix operator >>>= : BitwiseShiftPrecedence
public extension BinaryInteger {
    static func >>> <RHS>(lhs: Self, rhs: RHS) -> Self where RHS : BinaryInteger {
        if rhs == 0 { return lhs }
        if lhs >= 0 { return lhs >> rhs }
        let bits = lhs.bitWidth - 1
        let mask = (lhs >> 1) & (~(1 << bits))
        return mask >> (rhs - 1)
    }
    static func >>>= <RHS>(lhs: inout Self, rhs: RHS) where RHS : BinaryInteger {
        lhs = lhs >>> rhs
    }
}

public final class BitSet {
    private var bits: [Word]
    
    public init() { bits = [] }
    public init<T>(value: T, shrink: Bool = true) where T: BinaryInteger {
        bits = Word.hold(value: value)
        if shrink { self.shrink() }
    }
    public init<S>(values: S) where S: Sequence, S.Element: BinaryInteger {
        bits = []
        for val in values { bits.append(contentsOf: Word.hold(value: val)) }
    }
    
    public init(nbits: Int) {
        bits = .init(repeating: 0, count: nbits >> Word.BITS)
    }
    public init(data: Data) {
        bits = []
        var index = data.startIndex
        let byteSize = MemoryLayout<Word>.stride
        while index != data.endIndex {
            let startIdx = index
            let endIdx = data.index(startIdx, offsetBy: byteSize, limitedBy: data.endIndex) ?? data.endIndex
            var val: Word = 0
             
            data.copyBytes(to: UnsafeMutableBufferPointer(start: &val, count: 1), from: startIdx..<endIdx)
            bits.append(val)
            index = endIdx
        }
        shrink()
    }
    public init?(text: String, radix: Int = 2) {
        var s = text
        s.removeAll { !$0.isNumber && !$0.isLetter }
        
        var tmp: [Word] = []
        var index = s.startIndex
        while index != s.endIndex {
            let startIdx = index
            let endIdx = s.index(startIdx, offsetBy: Word.N, limitedBy: s.endIndex) ?? s.endIndex
            guard let val = Word(s[startIdx..<endIdx], radix: radix) else { return nil }
            tmp.append(val)
            index = endIdx
        }
        bits = tmp
    }
    
    public func get(_ i: Int) -> Bool {
        precondition(i >= 0)
        if i > endIndex { return false }
        return work(i, false) { $0.get($1) }
    }
    public func set(_ i: Int, _ value: Bool) {
        work(i) { $0.set($1, value) }
    }
    
    public func get(_ range: ClosedRange<Int>) -> Bool {
        if range.upperBound > endIndex { return false }
        var res = true
        work(range, false) { (word, range, stop) in
            if !word.get(range) { stop.pointee = true; res = false }
        }
        return res
    }
    public func set(_ range: ClosedRange<Int>, _ value: Bool) {
        work(range) { (word, range, stop) in
            word.set(range, value)
        }
    }

    public func get(_ nbits: [Int]) -> Bool {
        var res = true
        if work(nbits, false, closure: { (word, sub, stop) in
            if !word.get(sub) { stop.pointee = true; res = false }
        }) { return false }
        return res
    }
    public func set(_ nbits: [Int], _ value: Bool) {
        work(nbits) { (word, sub, stop) in
            word.set(sub, value)
        }
    }

    /// 翻转第i位
    public func flip(_ i: Int) {
        work(i) { $0.flip($1) }
    }
    public func flip(_ range: ClosedRange<Int>) {
        work(range) { (word, sub, _) in word.flip(sub) }
    }
    public func flip(_ nbits: [Int]) {
        work(nbits) { (word, sub, _) in word.flip(sub) }
    }
    
    public func slice(_ range: ClosedRange<Int>) -> BitSet {
        let res = BitSet()
        work(range) { (word, sub, _) in res.bits.append(word.slice(sub)) }
        return res
    }
    
    /// 2进制位中1的个数
    public var cardinality: Int {
        return bits.reduce(0) { $0 + $1.cardinality }
    }
    
    /// 最左边位为1的索引(最高有效位 Most Significant Bit)
    public var msb: Int {
        guard let idx = (bits.lastIndex { $0 != 0 }) else { return 0 }
        return bits[idx].msb + idx * Word.N
    }
    /// 最右边位为1的位置(最低有效位 Least Significant Bit)
    public var lsb: Int {
        guard let idx = (bits.firstIndex { $0 != 0 }) else { return 0 }
        return bits[idx].lsb + idx * Word.N
    }
    
    public var endIndex: Int { return bits.count * Word.N - 1 }
    public var isEmpty: Bool {
        return bits.first { $0 != 0 } == nil
    }
    public var copy: BitSet {
        let bs = BitSet()
        for val in bits {
            bs.bits.append(val)
        }
        return bs
    }
}

public extension BitSet {
    static func &=<T>(lhs: BitSet, rhs: T) where T: BinaryInteger  {
        lhs &= BitSet(value: rhs, shrink: false)
    }
    static func &=(lhs: BitSet, rhs: BitSet)  {
        if rhs.bits.isEmpty { return }
        for i in 0..<Swift.min(lhs.bits.count, rhs.bits.count) {
            lhs.bits[i] &= rhs.bits[i]
        }
        lhs.shrink()
    }
    static func |=<T>(lhs: BitSet, rhs: T) where T: BinaryInteger  {
        lhs |= BitSet(value: rhs)
    }
    static func |=(lhs: BitSet, rhs: BitSet)  {
        if rhs.bits.isEmpty { return }
        for i in 0..<rhs.bits.count {
            if i >= lhs.bits.count { lhs.bits.append(rhs.bits[i]) }
            else { lhs.bits[i] |= rhs.bits[i] }
        }
        lhs.shrink()
    }
    static func ^=<T>(lhs: BitSet, rhs: T) where T: BinaryInteger  {
        lhs ^= BitSet(value: rhs)
    }
    static func ^=(lhs: BitSet, rhs: BitSet)  {
        if rhs.bits.isEmpty { return }
        for i in 0..<rhs.bits.count {
            if i >= lhs.bits.count { lhs.bits.append(rhs.bits[i]) }
            else { lhs.bits[i] ^= rhs.bits[i] }
        }
        lhs.shrink()
    }
    static prefix func ~(lhs: BitSet) {
        for i in 0..<lhs.bits.count {
            lhs.bits[i] = ~lhs.bits[i]
        }
    }
    static func <<=(lhs: BitSet, shift: Int) {
        var remain: Word = 0
        let mask = Word.build(Word.I-shift...Word.I, true)
        for i in 0..<lhs.bits.count {
            let last = remain
            remain = mask
            remain &= lhs.bits[i]
            remain >>= Word.N - shift
            lhs.bits[i] <<= shift
            lhs.bits[i] |= last
        }
    }
    static func >>=(lhs: BitSet, shift: Int) {
        var i = lhs.bits.count - 1
        var remain: Word = 0
        while i >= 0 {
            let last = remain
            remain = .fill(shift)
            remain &= lhs.bits[i]
            remain <<= Word.N - shift
            lhs.bits[i] >>= shift
            lhs.bits[i] |= last
            i -= 1
        }
    }
}

public extension BitSet {
    subscript(_ i: Int) -> Bool {
        get { get(i) }
        set { set(i, newValue) }
    }
    subscript(_ range: ClosedRange<Int>) -> Bool {
        get { get(range) }
        set { set(range, newValue) }
    }
    subscript(_ nbits: Int...) -> Bool {
        get { get(nbits) }
        set { set(nbits, newValue) }
    }
}

public extension BitSet {
    func toString(width: Int = 4, separator: String = ", ") -> String {
        bits.reversed().map { $0.toString(width: width) }.joined(separator: separator)
    }
    func toArray() -> [Bool] {
        bits.map { $0.toArray() }.flatMap { $0 }
    }
    func toBinary<T>() -> T? where T: BinaryInteger {
        if bits.count * Word.N > MemoryLayout<T>.stride << 3 { return nil }
        var res: T = 0
        for (i, val) in bits.enumerated() {
            res |= T(val) << (i * Word.N)
        }
        return res
    }
    var intValue: Int? {
        return toBinary()
    }
    func toData(batchSize: Int) -> Data {
        return bits.reduce(into: Data()) { (data, val) in
            var tmp: Word = val
            data.append(Data(bytes: &tmp, count: batchSize))
        }
    }
}

extension BitSet: CustomStringConvertible {
    public var description: String {
        toString(width: 4)
    }
}



extension BitSet: Sequence {
    public struct Iterator: IteratorProtocol {
        var bits: [Bool]
        public mutating func next() -> Bool? {
            if bits.isEmpty { return nil }
            return bits.removeLast()
        }
    }
    public func makeIterator() -> BitSet.Iterator {
        let str = bits.reversed().map { $0.toString(pretty: false) }.joined()
        return Iterator(bits: Array(str).map { $0 == "1" } )
    }
}

private extension BitSet {
    private func expand(to nbits: Int) {
        var delta = (nbits >> Word.BITS + 1) - bits.count
        while delta > 0 {
            bits.append(0)
            delta -= 1
        }
    }
    private func shrink() {
        while let last = bits.last, last == 0 {
            bits.removeLast()
        }
    }
    @discardableResult
    private func work<T>(_ i: Int,
                         _ expand: Bool = true,
                         closure: (inout Word, Int) -> T) -> T {
        precondition(i >= 0)
        if expand { self.expand(to: i) }
        defer { if expand { shrink() } }
        return closure(&bits[i >> Word.BITS], i & Word.I)
    }
    private func work(_ range: ClosedRange<Int>,
                      _ expand: Bool = true,
                      closure: (inout Word, ClosedRange<Int>, UnsafeMutablePointer<Bool>) -> Void) {
        let lower = range.lowerBound
        precondition(lower >= 0)
        let upper = range.upperBound
        if expand { self.expand(to: upper) }
        var stop: Bool = false
        var i = lower >> Word.BITS
        var ri = (i + 1) * Word.N - 1
        if ri >= upper {
            closure(&bits[i], lower&Word.I...upper&Word.I, &stop)
            return
        } else {
            closure(&bits[i], lower&Word.I...Word.I, &stop)
            i += 1
        }
        while i < bits.count {
            ri = (i + 1) * Word.N - 1
            closure(&bits[i], 0...Swift.min(upper, ri)&Word.I, &stop)
            if ri >= upper { break }
            if stop { break }
            i += 1
        }
        if expand { shrink() }
    }
    @discardableResult
    private func work(_ nbits: [Int],
                      _ expand: Bool = true,
                      closure: (inout Word, [Int], UnsafeMutablePointer<Bool>) -> Void) -> Bool {
        if nbits.isEmpty { return false }
        let copy = nbits.sorted()
        if expand { self.expand(to: copy.last!) }
        else if copy.last! > endIndex { return false }
        var pos: [[Int]] = .init(repeating: [], count: bits.count)
        for idx in copy {
            let i = idx >> Word.BITS
            pos[i].append(idx & Word.I)
        }
        var stop = false
        for (i, sub) in pos.enumerated() {
            if sub.isEmpty { continue }
            closure(&bits[i], sub, &stop)
            if stop { break }
        }
        if expand { shrink() }
        return true
    }
}
