//
//  RatingView.swift
//  SwifterKnife
//
//  Created by liyang on 2022/8/18.
//

import UIKit

/*
fileprivate class StarView: UIView {
    var count: Int = 5
    var _starSize: CGSize?
    var margin: CGFloat = 15
    var image: UIImage?
    var starsView: [UIImageView] = []
    
    var starSize: CGSize {
        _starSize ?? image?.size ?? CGSize(width: 36, height: 36)
    }
    
}

class RatingView: UIView {
    var count: Int {
        get { backView.count }
        set {
            guard backView.count != newValue else {
                return
            }
            frontView.count = newValue
            backView.count = newValue
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }
    var margin: CGFloat {
        get { backView.margin }
        set {
            guard backView.margin != newValue else {
                return
            }
            frontView.margin = newValue
            backView.margin = newValue
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }
    var starSize: CGSize {
        frontView.starSize
    }
    func setStarSize(_ size: CGSize?) {
        if size == nil, backView._starSize == nil {
            return
        }
        if let s = size, s == backView.starSize {
            return
        }
        frontView._starSize = size
        backView._starSize = size
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }
    var panEnable = false
    
    var score: Double = 0
    
    var highlightedImage: UIImage? {
        set { frontView.image = newValue }
        get { frontView.starsView.first?.image }
    }
    var normalImage: UIImage? {
        set { backView.image = newValue }
        get { backView.starsView.first?.image }
    }
    
    private unowned var backView: StarView!
    private unowned var frontView: StarView!
}
*/

fileprivate class StarsView: UIView {
    private var aspectSize: CGSize = .zero
    
    public init(count: Int,
         image: UIImage?,
         margin: CGFloat,
         size: CGSize) {
        super.init(frame: .zero)
        
        isUserInteractionEnabled = false
        layer.masksToBounds = true
        backgroundColor = .clear
        
        var width: CGFloat = 0
        for _ in 0..<count {
            let imgView = UIImageView(image: image)
            imgView.contentMode = .scaleAspectFit
            addSubview(imgView)
            imgView.frame = CGRect(origin: CGPoint(x: width, y: 0), size: size)
            width += size.width + margin
        }
        width -= margin
        aspectSize = CGSize(width: width, height: size.height)
        frame.size = aspectSize
    }
    override var contentMode: UIView.ContentMode {
        set {
            for view in subviews {
                guard let imgView = view as? UIImageView else { continue }
                imgView.contentMode = newValue
            }
        }
        get {
            for view in subviews {
                guard let imgView = view as? UIImageView else { continue }
                return imgView.contentMode
            }
            return super.contentMode
        }
        
    }
    override var intrinsicContentSize: CGSize {
        aspectSize
    }
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        aspectSize
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension Double {
    func nearestMultiple(_ v: Double) -> Double {
        if v == 0 { return self }
        return v * (self / v).rounded(.up)
    }
}

public class RatingView: UIView {
    
    public init(count: Int,
         normalImage: UIImage?,
         highlightedImage: UIImage?,
         margin: CGFloat = 10,
         size: CGSize? = nil) {
        guard count > 0 else { fatalError("count must > 0") }
        self.count = count
        self.margin = margin
        let starSize = size ?? normalImage?.size ?? CGSize(width: 36, height: 36)
        self.starSize = starSize
        
        backView = StarsView(count: count, image: normalImage, margin: margin, size: starSize)
        frontView = StarsView(count: count, image: highlightedImage, margin: margin, size: starSize)

        super.init(frame: .zero)
        addSubview(backView)
        addSubview(frontView)
    }
    
    public var beginEditingGrade: ((RatingView) -> Void)?
    public var endEditingGrade: ((RatingView) -> Void)?
    public var gradeDidChange: ((RatingView) -> Void)?
    
    public override var contentMode: UIView.ContentMode {
        set {
            frontView.contentMode = newValue
            backView.contentMode = newValue
        }
        get {
            backView.contentMode
        }
    }
    /// 是否允许滑动评分
    public var isPanEnable: Bool = false
    
    /// 精度(0, 1]
    public var accuracy: Double? = 1 {
        willSet {
            guard let v = newValue else { return }
            if v <= 0 || v > 1 { fatalError("accuracy is invalid") }
        }
    }
    /// 一个完整的星星代表多少分，权重
    public var weight: Double = 1
    
    /// 最低评分值 默认一颗完整星星表示的分数
    public var minGrade: Double {
        get { _minProgress * weight }
        set {
            var progress = newValue / weight
            if progress < 0 { progress = 0 }
            if progress > _maxProgress {
                progress = _maxProgress
            }
            if let a = accuracy {
                progress = progress.nearestMultiple(a)
            }
            
            let width = widthForProgress(progress)
            if frontView.frame.width < width {
                frontView.frame.size.width = width
            }
            
            _minProgress = progress
            if _progress < _minProgress {
                _progress = _minProgress
                beginEditingGrade?(self)
                gradeDidChange?(self)
                endEditingGrade?(self)
            }
        }
    }
    /// 默认满分
    public var grade: Double {
        get { _progress * weight }
        set {
            var progress = newValue / weight
            if progress < _minProgress {
                progress = _minProgress
            } else if progress > _maxProgress {
                progress = _maxProgress
            }
            var left: Double = 0
            var right = modf(progress, &left)
            if let a = accuracy {
                right = right.nearestMultiple(a)
            }
            _progress = left + right
            let width = (starSize.width + margin) * left + right * starSize.width
            frontView.frame.size.width = width
        }
    }
    
    private lazy var _progress = _maxProgress
    private var _maxProgress: Double {
        Double(count)
    }
    private var _minProgress: Double = 1
    
    private func widthForProgress(_ progress: Double) -> CGFloat {
        var left: Double = 0
        let right = modf(progress, &left)
        return (starSize.width + margin) * left + right * starSize.width
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPanEnable {
            beginEditingGrade?(self)
        } else {
            handleTouches(touches)
            beginEditingGrade?(self)
            gradeDidChange?(self)
            endEditingGrade?(self)
        }
    }
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPanEnable else { return }
        if handleTouches(touches) {
            gradeDidChange?(self)
        } 
    }
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPanEnable else { return }
        if handleTouches(touches) {
            gradeDidChange?(self)
        }
        endEditingGrade?(self)
    }
    
    /// 返回结果表示_progress 有无发生改变
    @discardableResult
    private func handleTouches(_ touches: Set<UITouch>) -> Bool {
        guard let x = touches.randomElement()?.location(in: self).x else { return false }
        
        let step = starSize.width + margin
        var int = Int(x / step)
        let left = x - CGFloat(int) * step
        var right: Double = 0
        if left > starSize.width {
            int += 1
        } else {
            right = left / starSize.width
            if let a = accuracy {
                right = right.nearestMultiple(a)
            }
        }
        var progress = Double(int) + right
        if progress < _minProgress {
            progress = _minProgress
        } else if progress > _maxProgress {
            progress = _maxProgress
        }
        if _progress != progress {
            frontView.frame.size.width = widthForProgress(progress)
            _progress = progress
            return true
        } else {
            return false
        }
     }
    
    public override var intrinsicContentSize: CGSize {
        backView.intrinsicContentSize
    }
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        backView.sizeThatFits(size)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let size = bounds.size
        let y = (size.height - backView.frame.height) * 0.5
        backView.frame.origin = CGPoint(x: 0, y: y)
        frontView.frame.origin = CGPoint(x: 0, y: y)
    }
    
    public  let count: Int
    private let margin: CGFloat
    private let starSize: CGSize
    private let backView: StarsView
    private let frontView: StarsView
    
    private init() {
        fatalError("init() has not been implemented")
    }
    override private init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
