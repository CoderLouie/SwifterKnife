//
//  Sequence+Async.swift
//  SwifterKnife
//
//  Created by liyang on 2022/03/01.
//

import Foundation

/*
 public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) throws -> ()) rethrows -> Result
 */
public enum AsyncReduceControl<Error: Swift.Error> {
    case next
    case retry
    case retryAfter(_ delay: TimeInterval)
    case stop(_ error: Error)
}
public protocol TimeoutError: Swift.Error {
    static var timeout: Self { get }
}
/// 因为Swfit不允许闭包捕获输入输出参数，所以只好包装一层
public final class AsyncReduceContext<Output, Sequence: Swift.Sequence> {
    /// 源序列
    public let sequence: Sequence
    /// 累计的结果，外界可以修改
    public var result: Output
    /// 当前迭代的索引
    public fileprivate(set) var index: Int = 0
    /// 当前迭代的元素
    public fileprivate(set) var element: Sequence.Element!
    /// 当前迭代元素重试的次数
    public fileprivate(set) var retryCount: Int = 0
    
    fileprivate init(initialResult: Output,
         sequence: Sequence) {
        self.sequence = sequence
        result = initialResult
    }
}
public extension Sequence {
    
    typealias AsyncControl<Error: Swift.Error> = (AsyncReduceControl<Error>) -> Void
    typealias AsyncContext<Output> = AsyncReduceContext<Output, Self>
    
    /// 按顺序对序列中每一个元素执行异步任务(含超时)
    /// - Parameters:
    ///   - initialResult: 初始输出结果
    ///   - errorType: 错误类型
    ///   - timeoutInterval: 总体超时时间
    ///   - background: 是否在子线程执行每一项任务
    ///   - handler: 每一个元素需要执行的异步任务，并通过control控制任务处理结果
    ///   - context: 执行上下文
    ///   - item: 此次迭代的元素
    ///   - control: 反馈此次迭代异步执行的结果
    ///   - onDone: 迭代完成后的回调
    ///   - context: 执行上下文
    ///   - result: 迭代完成后的结果
    func asyncReduce<Output, Error: TimeoutError>(
        into initialResult: Output,
        errorType: Error.Type,
        timeoutInterval: TimeInterval,
        background: Bool = true,
        handler: @escaping (_ context: AsyncContext<Output>,
                            _ item: Element,
                            _ control: @escaping AsyncControl<Error>) -> Void,
        onDone: @escaping (_ context: AsyncContext<Output>,
                           _ result: Result<Output, Error>) -> Void) {
        
        let context = AsyncContext(initialResult: initialResult,
                                   sequence: self)
        var iterator = enumerated().makeIterator()
        guard let first = iterator.next() else {
            onDone(context, .success(initialResult))
            return
        }
        var hasFinished = false
        var task: DispatchWorkItem? = nil
        let finish: (Result<Output, Error>) -> Void = { result in
            hasFinished = true
            task?.cancel()
            task = nil
            DispatchQueue.main.async {
                onDone(context, result)
            }
        }
        task = DispatchQueue.main.after(timeoutInterval) {
            finish(.failure(.timeout))
        }
        let queue = background ? DispatchQueue.global() : DispatchQueue.main
        func generator(item itemParam: (offset: Int, element: Self.Element)?) {
            guard !hasFinished else { return }
            guard let item = itemParam else {
                finish(.success(context.result))
                return
            }
            
            let closure = { (action: AsyncReduceControl<Error>) in
                switch action {
                case .next:
                    context.retryCount = 0
                    queue.async { generator(item: iterator.next()) }
                case .retry:
                    context.retryCount += 1
                    queue.async { generator(item: item) }
                case .retryAfter(let delay):
                    queue.after(delay) {
                        context.retryCount += 1
                        generator(item: item)
                    }
                case .stop(let error):
                    context.retryCount = 0
                    finish(.failure(error))
                }
            }
            context.element = item.element
            context.index = item.offset
            handler(context, item.element, closure)
        }
        queue.async { generator(item: first) }
    }
    
    /// 按顺序对序列中每一个元素执行异步任务
    /// - Parameters:
    ///   - initialResult: 初始输出结果
    ///   - errorType: 错误类型
    ///   - background: 是否在子线程执行每一项任务
    ///   - handler: 每一个元素需要执行的异步任务，并通过control控制任务处理结果
    ///   - context: 执行上下文
    ///   - item: 此次迭代的元素
    ///   - control: 反馈此次迭代异步执行的结果
    ///   - onDone: 迭代完成后的回调
    ///   - context: 执行上下文
    ///   - result: 迭代完成后的结果
    func asyncReduce<Output, Error: Swift.Error>(
        into initialResult: Output,
        errorType: Error.Type,
        background: Bool = true,
        handler: @escaping (_ context: AsyncContext<Output>,
                            _ item: Element,
                            _ control: @escaping AsyncControl<Error>) -> Void,
        onDone: @escaping (_ context: AsyncContext<Output>,
                           _ result: Result<Output, Error>) -> Void) {
        
        let context = AsyncContext(initialResult: initialResult,
                                   sequence: self)
        var iterator = enumerated().makeIterator()
        guard let first = iterator.next() else {
            onDone(context, .success(initialResult))
            return
        }
        var hasFinished = false
        let finish: (Result<Output, Error>) -> Void = { result in
            hasFinished = true
            DispatchQueue.main.async {
                onDone(context, result)
            }
        }
        let queue = background ? DispatchQueue.global() : DispatchQueue.main
        func generator(item itemParam: (offset: Int, element: Self.Element)?) {
            guard !hasFinished else { return }
            guard let item = itemParam else {
                finish(.success(context.result))
                return
            }
            
            let closure = { (action: AsyncReduceControl<Error>) in
                switch action {
                case .next:
                    context.retryCount = 0
                    queue.async { generator(item: iterator.next()) }
                case .retry:
                    context.retryCount += 1
                    queue.async { generator(item: item) }
                case .retryAfter(let delay):
                    queue.after(delay) {
                        context.retryCount += 1
                        generator(item: item)
                    }
                case .stop(let error):
                    context.retryCount = 0
                    finish(.failure(error))
                }
            }
            context.element = item.element
            context.index = item.offset
            handler(context, item.element, closure)
        }
        queue.async { generator(item: first) }
    }
    
    /// 按顺序对序列中每一个元素执行异步任务
    /// - Parameters:
    ///   - initialResult: 初始输出结果
    ///   - background: 是否在子线程执行每一项任务
    ///   - handler: 每一个元素需要执行的异步任务，并通过control控制任务处理结果
    ///   - context: 执行上下文
    ///   - item: 此次迭代的元素
    ///   - control: 反馈此次迭代异步执行的结果
    ///   - onDone: 迭代完成后的回调
    ///   - context: 执行上下文
    ///   - result: 迭代完成后的结果
    func asyncReduce<Output>(
        into initialResult: Output,
        background: Bool = true,
        handler: @escaping (_ context: AsyncContext<Output>,
                            _ item: Element,
                            _ control: @escaping AsyncControl<Swift.Error>) -> Void,
        onDone: @escaping (_ context: AsyncContext<Output>,
                           _ result: Result<Output, Swift.Error>) -> Void) {
        asyncReduce(into: initialResult,
                    errorType: Swift.Error.self,
                    handler: handler,
                    onDone: onDone)
    }
}
