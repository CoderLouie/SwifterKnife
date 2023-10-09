//
//  UIViewController+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/20.
//

import UIKit

// MARK: - Properties

public extension UIViewController {
    /// Check if ViewController is onscreen and not hidden.
    var isVisible: Bool {
        // http://stackoverflow.com/questions/2777438/how-to-tell-if-uiviewcontrollers-view-is-visible
        return isViewLoaded && view.window != nil
    }
}

// MARK: - Methods

public extension UIViewController {
    
    /// Helper method to embed a UIViewController as a childViewController.
    ///
    /// - Parameters:
    ///   - child: the view controller to add as a child.
    ///   - containerView: the containerView for the child viewController's root view.
    func embedViewController(_ child: UIViewController, into containerView: UIView, animated: Bool = false) {
        addChild(child)
        child.beginAppearanceTransition(true, animated: animated)
        containerView.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.didMove(toParent: self)
        if !animated {
            child.endAppearanceTransition()
        }
    }

    /// Helper method to remove a UIViewController from its parent.
    func unembed(animated: Bool = false) {
        guard parent != nil else { return }

        willMove(toParent: nil)
        let hasLoaded = isViewLoaded
        if hasLoaded {
            view.removeFromSuperview()
            beginAppearanceTransition(false, animated: animated)
        }
        removeFromParent()
        if hasLoaded, !animated {
            endAppearanceTransition()
        }
    }
    
    /// Helper method to present a UIViewController as a popover.
    ///
    /// - Parameters:
    ///   - popoverContent: the view controller to add as a popover.
    ///   - sourcePoint: the point in which to anchor the popover.
    ///   - size: the size of the popover. Default uses the popover preferredContentSize.
    ///   - delegate: the popover's presentationController delegate. Default is nil.
    ///   - animated: Pass true to animate the presentation; otherwise, pass false.
    ///   - completion: The block to execute after the presentation finishes. Default is nil.
    func presentPopover(
        _ popoverContent: UIViewController,
        sourcePoint: CGPoint,
        size: CGSize? = nil,
        delegate: UIPopoverPresentationControllerDelegate? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil) {
        popoverContent.modalPresentationStyle = .popover

        if let size = size {
            popoverContent.preferredContentSize = size
        }
 
        if let popoverPresentationVC = popoverContent.popoverPresentationController {
            popoverPresentationVC.sourceView = view
            popoverPresentationVC.sourceRect = CGRect(origin: sourcePoint, size: .zero)
            popoverPresentationVC.delegate = delegate
        }

        present(popoverContent, animated: animated, completion: completion)
    }
}

public extension UIViewController {
    /// Check if the view controller has been presented or not.
    /// - Returns: true if the controller is presented, otherwise false.
    @objc var isModal: Bool {
        presentingViewController?.presentedViewController == self ||
            navigationController?.presentingViewController?.presentedViewController == navigationController ||
            tabBarController?.presentingViewController is UITabBarController
    }
}

// MARK: - Present
public extension UIViewController { 
    
    func share(items: [Any],
               excludedTypes: [UIActivity.ActivityType]? = nil,
               completion: UIActivityViewController.CompletionWithItemsHandler? = nil) {
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        vc.excludedActivityTypes = excludedTypes
        vc.completionWithItemsHandler = { [unowned vc] type, completed, returnedItems, error in
            vc.dismiss(animated: true) {
                completion?(type, completed, returnedItems, error)
            }
        }
        present(vc, animated: true, completion: nil)
    }
    
    @discardableResult
    func present(style: UIAlertController.Style = .alert,
                 make: (UIAlertController) -> Void,
                 completion: (() -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: style)
        make(alertController)
        present(alertController, animated: true, completion: completion)
        return alertController
    }
}

public extension UIAlertController {
    
    @discardableResult
    func addAction(title: String, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        addAction(action)
        return action
    }
}
