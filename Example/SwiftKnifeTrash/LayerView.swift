//
//  LayerView.swift
//  SwifterKnife
//
//  Created by liyang on 2022/4/13. 
//

import UIKit

open class LayerView<T: CALayer>: UIView {
    open override class var layerClass: AnyClass {
        return T.self
    }
    public var rootLayer: T {
        layer as! T
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    public convenience init(_ config: (T) -> Void) {
        self.init(frame: .zero)
        config(rootLayer)
    }
    
    open func setup() { }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
