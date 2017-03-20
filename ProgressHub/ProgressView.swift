//
//  ProgressView.swift
//  ProgressHub
//
//  Created by kang huawei on 2017/3/20.
//  Copyright © 2017年 huaweikang. All rights reserved.
//

import UIKit



class ProgressView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

class BarProgressView: UIView {
    var progress: Float = 0.0 {
        didSet {
            if(oldValue != progress) {
                setNeedsDisplay()
            }
        }
    }
    var lineColor = UIColor.white
    var progressRemainingColor = UIColor.clear {
        didSet {
            if(progressRemainingColor != oldValue) {
                setNeedsDisplay()
            }
        }
    }
    var progressColor = UIColor.white {
        didSet {
            if(progressColor != oldValue) {
                setNeedsDisplay()
            }
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 120.0, height: 10.0)
    }
    
    // MARK: Drawing
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        context?.setLineWidth(2.0)
        context?.setStrokeColor(lineColor.cgColor)
        context?.setFillColor(progressRemainingColor.cgColor)
        
        // Draw background
        var radius = rect.size.height / 2 - 2.0
        context?.move(to: CGPoint(x: 2, y: rect.size.height / 2))
        context?.addArc(tangent1End: CGPoint(x: 2, y: 2), tangent2End: CGPoint(x: radius + 2.0, y: 2), radius: radius)
        context?.addLine(to: CGPoint(x: rect.size.width - radius - 2.0, y: 2))
        context?.addArc(tangent1End: CGPoint(x: rect.size.width - 2.0, y: 2), tangent2End: CGPoint(x: rect.size.width - 2, y: rect.size.height / 2), radius: radius)
        context?.addArc(tangent1End: CGPoint(x: rect.size.width - 2, y: rect.size.width - 2), tangent2End: CGPoint(x: rect.size.width - radius - 2, y: rect.size.height - 2), radius: radius)
        context?.addLine(to: CGPoint(x: radius + 2, y: rect.size.height - 2))
        context?.addArc(tangent1End: CGPoint(x: 2, y: rect.size.height - 2), tangent2End: CGPoint(x: 2, y: rect.size.height / 2), radius: radius)
        context?.fillPath()
        
        // Draw border
        context?.move(to: CGPoint(x: 2, y: rect.size.height / 2))
        context?.addArc(tangent1End: CGPoint(x: 2, y: 2), tangent2End: CGPoint(x: radius + 2.0, y: 2), radius: radius)
        context?.addLine(to: CGPoint(x: rect.size.width - radius - 2.0, y: 2))
        context?.addArc(tangent1End: CGPoint(x: rect.size.width - 2.0, y: 2), tangent2End: CGPoint(x: rect.size.width - 2, y: rect.size.height / 2), radius: radius)
        context?.addArc(tangent1End: CGPoint(x: rect.size.width - 2, y: rect.size.width - 2), tangent2End: CGPoint(x: rect.size.width - radius - 2, y: rect.size.height - 2), radius: radius)
        context?.addLine(to: CGPoint(x: radius + 2, y: rect.size.height - 2))
        context?.addArc(tangent1End: CGPoint(x: 2, y: rect.size.height - 2), tangent2End: CGPoint(x: 2, y: rect.size.height / 2), radius: radius)
        context?.strokePath()
        
        context?.setFillColor(progressColor.cgColor)
        radius = radius - 2.0
        let amount = CGFloat(progress) * rect.size.width
        // Progress in the middle area
        if (amount >= radius + 4.0 && amount <= (rect.size.width - radius - 4.0)) {
            context?.move(to: CGPoint(x: 4, y: rect.size.height / 2))
            context?.addArc(tangent1End: CGPoint(x: 4, y: 4), tangent2End: CGPoint(x: radius + 4, y: 4), radius: radius)
            context?.addLine(to: CGPoint(x: amount, y: 4.0))
            context?.addLine(to: CGPoint(x: amount, y: radius + 4))
            
            context?.move(to: CGPoint(x: 4, y: rect.size.height / 2))
            context?.addArc(tangent1End: CGPoint(x: 4, y: rect.size.height - 4), tangent2End: CGPoint(x: radius + 4, y: rect.size.height - 4), radius: radius)
            context?.addLine(to: CGPoint(x: amount, y: rect.size.width - 4))
            context?.addLine(to: CGPoint(x: amount, y: radius + 4))
            
            context?.fillPath()
        }
        // Progress in the right arc
        else if (amount > radius + 4) {
            // TODO: fill
        }
        // Progress is in the left arc
        else if (amount < radius + 4 && amount > 0) {
            // TODO: fill
        }
        
    }
}
