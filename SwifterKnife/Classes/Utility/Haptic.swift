//
//  Haptic.swift
//  SwifterKnife
//
//  Created by liyang on 2022/08/15.
//

import UIKit

public enum HapticFeedbackStyle: Int {
    case light, medium, heavy
    
    @available(iOS 13.0, *)
    case soft, rigid
}

@available(iOS 10.0, *)
extension HapticFeedbackStyle {
    var value: UIImpactFeedbackGenerator.FeedbackStyle {
        return UIImpactFeedbackGenerator.FeedbackStyle(rawValue: rawValue)!
    }
}

public enum HapticFeedbackType: Int {
    case success, warning, error
}

@available(iOS 10.0, *)
extension HapticFeedbackType {
    var value: UINotificationFeedbackGenerator.FeedbackType {
        return UINotificationFeedbackGenerator.FeedbackType(rawValue: rawValue)!
    }
}

public enum Haptic {
    case impact(HapticFeedbackStyle)
    case notification(HapticFeedbackType)
    case selection
    
    // trigger
    public func generate() {
        guard #available(iOS 10, *) else { return }
        
        switch self {
        case .impact(let style):
            let generator = UIImpactFeedbackGenerator(style: style.value)
            generator.prepare()
            generator.impactOccurred()
        case .notification(let type):
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type.value)
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
}

//
//public extension Haptic {
//    static let queue: OperationQueue = {
//        let queue = OperationQueue()
//        queue.maxConcurrentOperationCount = 1
//        return queue
//    }()
//
//    static func play(_ notes: [Note],
//                     completion: (() -> Void)? = nil) {
//        guard #available(iOS 10, *), queue.operations.isEmpty else { return }
//        let n = notes.count
//
//        for (i, note) in notes.enumerated() {
//            let operation = note.operation
//            if let last = queue.operations.last {
//                operation.addDependency(last)
//            }
//            if i == n - 1, let completed = completion {
//                operation.completionBlock = completed
//            }
//            queue.addOperation(operation)
//        }
//    }
//}
//
//public enum Note {
//    case haptic(Haptic)
//    case wait(TimeInterval)
//
//    fileprivate var operation: Operation {
//        switch self {
//        case .haptic(let haptic):
//            return HapticOperation(haptic)
//        case .wait(let interval):
//            return WaitOperation(interval)
//        }
//    }
//}
//
//fileprivate class HapticOperation: Operation {
//    let haptic: Haptic
//    init(_ haptic: Haptic) {
//        self.haptic = haptic
//    }
//    override func main() {
//        DispatchQueue.main.sync {
//            self.haptic.generate()
//        }
//    }
//}
//fileprivate class WaitOperation: Operation {
//    let duration: TimeInterval
//    init(_ duration: TimeInterval) {
//        self.duration = duration
//    }
//    override func main() {
//        Thread.sleep(forTimeInterval: duration)
//    }
//}
