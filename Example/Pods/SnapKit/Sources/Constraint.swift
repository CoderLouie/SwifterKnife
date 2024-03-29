//
//  SnapKit
//
//  Copyright (c) 2011-Present SnapKit Team - https://github.com/SnapKit
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#if os(iOS) || os(tvOS)
import UIKit
#else
import AppKit
#endif

public final class Constraint {
    
    internal let sourceLocation: (String, UInt)
    internal let label: String?
    
    private let from: ConstraintItem
    private let to: ConstraintItem
    private let relation: ConstraintRelation
    private let multiplier: ConstraintMultiplierTarget
    
    private var constant: ConstraintConstantTarget {
        didSet {
            self.updateConstantAndPriorityIfNeeded()
        }
    }
    
    private var priority: ConstraintPriorityTarget {
        didSet {
            self.updateConstantAndPriorityIfNeeded()
        }
    }
    public var layoutConstraints: [LayoutConstraint]
    
    public var isActive: Bool {
        set {
            if newValue {
                activate()
            } else {
                deactivate()
            }
        }
        get {
            return layoutConstraints.contains(where: \.isActive)
        }
    }
    
    // MARK: Initialization
    
    internal init(from: ConstraintItem,
                  to: ConstraintItem,
                  relation: ConstraintRelation,
                  sourceLocation: (String, UInt),
                  label: String?,
                  multiplier: ConstraintMultiplierTarget,
                  constant: ConstraintConstantTarget,
                  priority: ConstraintPriorityTarget) {
        
        self.from = from
        self.to = to
        self.relation = relation
        self.sourceLocation = sourceLocation
        self.label = label
        self.multiplier = multiplier
        self.constant = constant
        self.priority = priority
        self.layoutConstraints = []
        
        // get attributes
        let fromAttributes = from.attributes
        let toAttributes = to.attributes
        let toLayoutAttributes = toAttributes.layoutAttributes
        
        // get layout from
        let layoutFrom = from.layoutConstraintItem!
        
        // get relation
        let layoutRelation = relation.layoutRelation
        
        for layoutFromAttribute in fromAttributes.layoutAttributes {
            // get layout to attribute
            let layoutToAttribute: LayoutAttribute
#if os(iOS) || os(tvOS)
            if toLayoutAttributes.count > 0 {
                if toAttributes == .margins ||
                    toAttributes == .directionalMargins {
                    switch layoutFromAttribute {
                    case .left:
                        layoutToAttribute = .leftMargin
                    case .right:
                        layoutToAttribute = .rightMargin
                    case .leading:
                        layoutToAttribute = .leadingMargin
                    case .trailing:
                        layoutToAttribute = .trailingMargin
                    case .centerX:
                        layoutToAttribute = .centerXWithinMargins
                    case .centerY:
                        layoutToAttribute = .centerYWithinMargins
                    case .top:
                        layoutToAttribute = .topMargin
                    case .bottom:
                        layoutToAttribute = .bottomMargin
                    default: fatalError()
                    }
                } else if fromAttributes == .margins && toAttributes == .edges {
                    switch layoutFromAttribute {
                    case .leftMargin:
                        layoutToAttribute = .left
                    case .rightMargin:
                        layoutToAttribute = .right
                    case .topMargin:
                        layoutToAttribute = .top
                    case .bottomMargin:
                        layoutToAttribute = .bottom
                    default: fatalError()
                    }
                } else if fromAttributes == .directionalMargins && toAttributes == .directionalEdges {
                    switch layoutFromAttribute {
                    case .leadingMargin:
                        layoutToAttribute = .leading
                    case .trailingMargin:
                        layoutToAttribute = .trailing
                    case .topMargin:
                        layoutToAttribute = .top
                    case .bottomMargin:
                        layoutToAttribute = .bottom
                    default: fatalError()
                    }
                } else if fromAttributes == toAttributes {
                    layoutToAttribute = layoutFromAttribute
                } else {
                    layoutToAttribute = toLayoutAttributes[0]
                }
            } else {
                layoutToAttribute = layoutFromAttribute
            }
#else
            if fromAttributes == toAttributes {
                layoutToAttribute = layoutFromAttribute
            } else if layoutToAttributes.count > 0 {
                layoutToAttribute = layoutToAttributes[0]
            } else {
                layoutToAttribute = layoutFromAttribute
            }
#endif
            
            // get layout constant
            let layoutConstant = constant.constraintConstantTargetValueFor(layoutAttribute: layoutToAttribute)
            
            // get layout to
            var layoutTo = to.target
            
            // use superview if possible
            if layoutTo == nil && layoutToAttribute != .width && layoutToAttribute != .height {
                layoutTo = layoutFrom.superview
            }
            
            // create layout constraint
            let layoutConstraint = LayoutConstraint(
                item: layoutFrom,
                attribute: layoutFromAttribute,
                relatedBy: layoutRelation,
                toItem: layoutTo,
                attribute: layoutToAttribute,
                multiplier: multiplier.constraintMultiplierTargetValue,
                constant: layoutConstant
            )
            
            // set label
            layoutConstraint.label = label
            
            // set priority
            layoutConstraint.priority = LayoutPriority(rawValue: self.priority.constraintPriorityTargetValue)
            
            // set constraint
            layoutConstraint.constraint = self
            
            // append
            self.layoutConstraints.append(layoutConstraint)
        }
    }
    
    // MARK: Public
    
    public func activate() {
        self.activateIfNeeded()
    }
    
    public func deactivate() {
        self.deactivateIfNeeded()
    }
    
    @discardableResult
    public func update(offset: ConstraintOffsetTarget) -> Constraint {
        self.constant = offset.constraintOffsetTargetValue
        return self
    }
    
    @discardableResult
    public func update(inset: ConstraintInsetTarget) -> Constraint {
        self.constant = inset.constraintInsetTargetValue
        return self
    }
    
#if os(iOS) || os(tvOS)
    @discardableResult
    @available(iOS 11.0, tvOS 11.0, *)
    public func update(inset: ConstraintDirectionalInsetTarget) -> Constraint {
        self.constant = inset.constraintDirectionalInsetTargetValue
        return self
    }
#endif
    
    @discardableResult
    public func update(priority: ConstraintPriorityTarget) -> Constraint {
        self.priority = priority.constraintPriorityTargetValue
        return self
    }
    
    @discardableResult
    public func update(priority: ConstraintPriority) -> Constraint {
        self.priority = priority.value
        return self
    }
    
    // MARK: Internal
    
    internal func updateConstantAndPriorityIfNeeded() {
        for layoutConstraint in self.layoutConstraints {
            let attribute = layoutConstraint.validAttribute
            layoutConstraint.constant = self.constant.constraintConstantTargetValueFor(layoutAttribute: attribute)
            
            let requiredPriority = ConstraintPriority.required.value
            if (layoutConstraint.priority.rawValue < requiredPriority), (self.priority.constraintPriorityTargetValue != requiredPriority) {
                layoutConstraint.priority = LayoutPriority(rawValue: self.priority.constraintPriorityTargetValue)
            }
        }
    }
    
    internal func activateIfNeeded(updatingExisting: Bool = false) {
        guard let item = from.layoutConstraintItem else {
            print("WARNING: SnapKit failed to get from item from constraint. Activate will be a no-op.")
            return
        }
        let layoutConstraints = self.layoutConstraints
        
        if updatingExisting {
            var existingLayoutConstraints: [LayoutConstraint] = []
            for constraint in item.constraints {
                existingLayoutConstraints += constraint.layoutConstraints
            }
            
            for layoutConstraint in layoutConstraints {
                let existingLayoutConstraint = existingLayoutConstraints.first { $0 == layoutConstraint }
                guard let updateLayoutConstraint = existingLayoutConstraint else {
                    fatalError("Updated constraint could not find existing matching constraint to update: \(layoutConstraint)")
                }
                
                updateLayoutConstraint.constant = self.constant.constraintConstantTargetValueFor(layoutAttribute: updateLayoutConstraint.validAttribute)
            }
        } else {
            NSLayoutConstraint.activate(layoutConstraints)
            item.add(constraints: [self])
        }
    }
    
    internal func deactivateIfNeeded() {
        guard let item = self.from.layoutConstraintItem else {
            print("WARNING: SnapKit failed to get from item from constraint. Deactivate will be a no-op.")
            return
        }
        let layoutConstraints = self.layoutConstraints
        NSLayoutConstraint.deactivate(layoutConstraints)
        item.remove(constraints: [self])
    }
}
