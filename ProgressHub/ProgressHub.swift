//
//  ProgressHub.swift
//  ProgressHub
//
//  Created by kang huawei on 2017/3/20.
//  Copyright © 2017年 huaweikang. All rights reserved.
//

import UIKit
import Foundation
import CoreGraphics

public class ProgressHub: UIView {
    
    public enum HudMode {
        case indeterminate, determinate, determinateHorizontalBar, annularDeterminate, customView, text
    }
    
    public enum HubAnimation {
        case fade, zoom, zoomOut, zoomIn
    }
    
    // public
    public var progress: Float = 0.0
    public var progressObject: Progress?
    public var bezelView: ProgressHubBackgroundView?
    public var backgroundView: ProgressHubBackgroundView?
    public var customView: UIView?
    public var label: UILabel?
    public var detailsLabel: UILabel?
    public var button: UIButton?
    public var removeFromSuperViewOnHide: Bool = false
    public var mode: HudMode = .indeterminate
    public var animationType: HubAnimation = .fade
    public var minShowTime: TimeInterval = 0.0
    public var graceTime: TimeInterval = 0.0
    
    var activityIndicatorColor: UIColor?
    
    var isUseAnimation: Bool?
    var isFinished: Bool?
    var indicator: UIView?
    var showStarted: Date?
    var graceTimer: Timer?
    var minShowTimer: Timer?
    var hideDelayTimer: Timer?
    var progressObjectDisplayLink: CADisplayLink?

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    public func show(addedToView view: UIView, animated: Bool) -> ProgressHub {
        let hub = ProgressHub(withView: view)
        hub.removeFromSuperViewOnHide = true
        view.addSubview(hub)
        
        return hub;
    }
    
    public class func hubForView(_ view: UIView) -> ProgressHub? {
        let subviews = view.subviews.reversed()
        for subview in subviews {
            if (subview is ProgressHub) {
                return subview as? ProgressHub
            }
        }
        
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(withView view: UIView) {
        //assert(view != nil, "View must not be nil.")
        super.init(frame: view.bounds)
    }
    
    // MARK: Show & Hide
    func show(animated: Bool) {
        assert(Thread.isMainThread, "ProgressHub needs to be accessed on the main thread.")
        minShowTimer?.invalidate()
        isUseAnimation = animated
        isFinished = false
        // If the grace time is set, postpone the HUD display
        if ( graceTime > 0.0) {
            let timer = Timer(timeInterval: graceTime, target: self, selector: #selector(handleGraceTimer(_:)), userInfo: nil, repeats: false)
            RunLoop.current.add(timer, forMode: .commonModes)
            graceTimer = timer
        } else {
            
        }
    }
    
    func hide(animated: Bool) {
        assert(Thread.isMainThread, "ProgressHub needs to be accessed on the main thread.")
        graceTimer?.invalidate()
        isUseAnimation = animated
        isFinished = true
        // If the minShow time is set, calculate how long the HUD was shown,
        // and postpone the hiding operation if necessary
        if (minShowTime > 0.0 && showStarted != nil) {
            let interval = Date().timeIntervalSince(showStarted!)
            if(interval < minShowTime) {
                let timer = Timer(timeInterval: (minShowTime - interval), target: self, selector: #selector(handleMinShowTimer(_:)), userInfo: nil, repeats: false)
                RunLoop.current.add(timer, forMode: .commonModes)
                minShowTimer = timer
            }
        } else {
            // ... otherwise hide the HUD immediately
            hideUsingAnimation(isUseAnimation!)
        }
    }
    
    func hide(animated: Bool, afterDelay delay: TimeInterval) {
        let timer = Timer(timeInterval: delay, target: self, selector: #selector(handleHideTimer(_:)), userInfo: animated, repeats: false)
        RunLoop.current.add(timer, forMode: .commonModes)
        hideDelayTimer = timer
    }
    
    // MARK: Timer callbacks
    func handleGraceTimer(_ timer: Timer) {
        // Show the HUD only if the task is still running
        if(!isFinished!) {
            showUsingAnimation(isUseAnimation!)
        }
    }
    
    func handleMinShowTimer(_ timer: Timer) {
        hideUsingAnimation(isUseAnimation!)
    }
    
    func handleHideTimer(_ timer: Timer) {
        hide(animated: timer.userInfo as! Bool)
    }
    
    // MARK: Internal show & hide operations
    func showUsingAnimation(_ animation: Bool) {
        // Cancel any previous animations
        bezelView?.layer.removeAllAnimations()
        backgroundView?.layer.removeAllAnimations()
        
        // Cancel any scheduled hideDelayed: calls
        hideDelayTimer?.invalidate()
        
        showStarted = Date()
        alpha = 1.0
        
        // Needed in case we hide and re-show with the same Progress object attached.
        setProgressDiaplayLinkEnabled(true)
        
        if(animation) {
            animateIn(true, withType: animationType, completion: nil)
        } else {
            self.bezelView?.alpha = CGFloat(self.layer.opacity)
            self.backgroundView?.alpha = 1
        }
    }
    
    func hideUsingAnimation(_ animated: Bool) {
        if (animated && showStarted != nil) {
            self.showStarted = nil
            animateIn(false, withType: animationType, completion: { finished in
                self.done()
            })
        } else {
            showStarted = nil
            bezelView?.alpha = 0
            backgroundView?.alpha = 1
            done()
        }
    }
    
    func animateIn(_ animatingIn: Bool, withType type: HubAnimation, completion: ((Bool) -> Void)?) {
        // Automatically determine the correct zoom animation type
        if (type == .zoom) {
            //type = animatingIn ? .zoomIn : .zoomOut
        }
        
        let small = CGAffineTransform(scaleX: 0.5, y: 0.5)
        let big = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        // TODO: fill
        
        
    }
    
    func done() {
        // TODO: fill
    }
    
    
    // MARK: Progress
    func setProgressDiaplayLinkEnabled(_ enabled: Bool) {
        // We're using CADisplayLink, because Progress can change very quickly and observing it may starve the main thread,
        // so we're refreshing the progress only every frame draw
        if(enabled && (progressObject != nil)) {
            // Only create if not already active.
            if((progressObjectDisplayLink) != nil) {
                self.progressObjectDisplayLink = CADisplayLink(target: self, selector: #selector(updateProgressFromProgressObject))
            }
        } else {
            progressObjectDisplayLink = nil
        }
    }
    
    func updateProgressFromProgressObject() {
        progress = Float((progressObject?.fractionCompleted)!)
    }
}

public enum ProgressHubBackgroundStyle {
    case solidColor, blur
}

public class ProgressHubBackgroundView: UIView {
    var style: ProgressHubBackgroundStyle?
    var color: UIColor?
    
    
}
