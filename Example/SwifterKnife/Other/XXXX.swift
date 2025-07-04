/*
public enum Subscribers {}
extension Subscribers {
    public struct Demand {}
}
public protocol Cancellable {
    func cancel()
}
extension Subscribers {
    public enum Completion<Failure: Error> {
        case finished
        case failure(Failure)
    }
}
public protocol Subscription: Cancellable {
    func request(_ demand: Subscribers.Demand)
}
public protocol Subscriber<Input, Failure> {
    associatedtype Input
    associatedtype Failure: Error
    func receive(subscription: Subscription)
    func receive(_ input: Input) -> Subscribers.Demand
    func receive(completion: Subscribers.Completion<Failure>)
}
public protocol Publisher<Output, Failure> {
    associatedtype Output
    associatedtype Failure: Error
    func receive<Sub: Subscriber>(subscriber: Sub)
        where Failure == Sub.Failure, Output == Sub.Input
}
extension Publisher {
    public func subscribe<Sub: Subscriber>(_ subscriber: Sub)
        where Failure == Sub.Failure, Output == Sub.Input {
        receive(subscriber: subscriber)
    }
}
*/
