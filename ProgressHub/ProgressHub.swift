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
    
    // const
    let defaultPadding: CGFloat = 4.0
    let defaultLabelFontSize: CGFloat = 16.0
    let defaultDetailsLabelFontSize: CGFloat = 12.0
    
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
    // for test
    //public var mode: HudMode = .indeterminate
    public var mode: HudMode = .determinateHorizontalBar
    public var contentColor = UIColor(white: 0, alpha: 0.7)
    public var animationType: HubAnimation = .fade
    public var offset: CGPoint = CGPoint(x: 0, y: 0)
    public var margin: CGFloat = 20.0
    public var minSize:CGSize = CGSize.zero
    public var isSquare = true         // force the hub dimensions to be equal if possible
    public var isDefaultMotionEffectsEnabled = true
    public var minShowTime: TimeInterval = 0.0
    public var graceTime: TimeInterval = 0.0
    
    var activityIndicatorColor: UIColor?
    
    var isUseAnimation: Bool?
    var isFinished: Bool?
    var indicator: UIView?
    var showStarted: Date?
    var paddingConstraints: [NSLayoutConstraint]?
    var bezelConstraints: [NSLayoutConstraint]?
    var topSpacer: UIView?
    var bottomSpacer: UIView?
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
    
    public class func show(addedToView view: UIView, animated: Bool) -> ProgressHub {
        let hub = ProgressHub(withView: view)
        hub.removeFromSuperViewOnHide = true
        view.addSubview(hub)
        hub.show(animated: animated)
        return hub;
    }
    
    public class func hide(addedToView view: UIView, animated: Bool) -> Bool {
        let hub = hubForView(view)
        if (hub != nil) {
            hub?.removeFromSuperViewOnHide = true
            hub?.hide(animated: animated)
            return true
        }
        return false
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
    
    // MARK: Lifecycle
    func commonInit() {
        // default value
        self.isOpaque = false
        self.backgroundColor = UIColor.clear
        
        // Make it invaisible for now
        self.alpha = 0
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.layer.allowsGroupOpacity = false

        setupViews()
        updateIndicators()
        registerForNotifications()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    convenience init(withView view: UIView) {
        //assert(view != nil, "View must not be nil.")
        self.init(frame: view.bounds)
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
            showUsingAnimation(animated)
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
            self.bezelView?.alpha = 1
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
    
    func animateIn(_ animatingIn: Bool, withType: HubAnimation, completion: ((Bool) -> Void)?) {
        // Automatically determine the correct zoom animation type
        var type = withType
        if (type == .zoom) {
            type = animatingIn ? .zoomIn : .zoomOut
        }
        
        let small = CGAffineTransform(scaleX: 0.5, y: 0.5)
        let large = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        // Set starting state
        if (animatingIn && bezelView?.alpha == 0.0 && type == .zoomIn) {
            bezelView?.transform = small
        } else if (animatingIn && bezelView?.alpha == 0.0 && type == .zoomOut) {
            bezelView?.transform = large
        }
        
        let animations = { () -> Void in
            if (animatingIn) {
                self.bezelView?.transform = .identity
            } else if(!animatingIn && type == .zoomIn) {
                self.bezelView?.transform = large
            } else if(!animatingIn && type == .zoomOut) {
                self.bezelView?.transform = small
            }
            
            self.bezelView?.alpha = animatingIn ? 1.0 : 0.0
            self.backgroundView?.alpha = animatingIn ? 1.0: 0.0
        }
        
        // Spring animations are nicer
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: animations, completion: completion)
        
    }
    
    func done() {
        // TODO: fill
    }
    
    // MARK: UI
    func setupViews() {
        let defaultColor = contentColor
        
        backgroundView = ProgressHubBackgroundView(frame: self.bounds)
        backgroundView?.style = .solidColor
        backgroundView?.backgroundColor = UIColor.clear
        backgroundView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView?.alpha = 0
        addSubview(backgroundView!)
        
        bezelView = ProgressHubBackgroundView()
        bezelView?.translatesAutoresizingMaskIntoConstraints = false
        bezelView?.layer.cornerRadius = 5
        bezelView?.alpha = 0
        addSubview(bezelView!)
        updateBezelMotionEffects()
        
        label = UILabel()
        label?.adjustsFontSizeToFitWidth = false
        label?.textAlignment = .center
        label?.textColor = defaultColor
        label?.font = UIFont.boldSystemFont(ofSize: defaultLabelFontSize)
        label?.isOpaque = false
        label?.backgroundColor = UIColor.clear
        
        detailsLabel = UILabel()
        detailsLabel?.adjustsFontSizeToFitWidth = false
        detailsLabel?.textAlignment = .center
        detailsLabel?.textColor = defaultColor
        detailsLabel?.font = UIFont.boldSystemFont(ofSize: defaultDetailsLabelFontSize)
        detailsLabel?.isOpaque = false
        detailsLabel?.backgroundColor = UIColor.clear
        
        button = ProgressHubRoundedButton()
        button?.titleLabel?.textAlignment = .center
        button?.titleLabel?.font = UIFont.boldSystemFont(ofSize: defaultDetailsLabelFontSize)
        button?.setTitleColor(defaultColor, for: .normal)
        
        for view: UIView in [label!, detailsLabel!, button!] {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setContentCompressionResistancePriority(998.0, for: .horizontal)
            view.setContentCompressionResistancePriority(998.0, for: .vertical)
            bezelView?.addSubview(view)
        }
        
        topSpacer = UIView()
        topSpacer?.translatesAutoresizingMaskIntoConstraints = false
        topSpacer?.isHidden = true
        bezelView?.addSubview(topSpacer!)
        
        bottomSpacer = UIView()
        bottomSpacer?.translatesAutoresizingMaskIntoConstraints = false
        bottomSpacer?.isHidden = true
        bezelView?.addSubview(bottomSpacer!)
    }
    
    func updateIndicators() {
        // TODO: Add other type
        
        if(mode == .determinateHorizontalBar) {
            indicator?.removeFromSuperview()
            indicator = BarProgressView()
            bezelView?.addSubview(indicator!)
        } else {
            assert(false, "This mode has not be support.")
        }
        
        indicator?.translatesAutoresizingMaskIntoConstraints = false
        if let progressView = indicator as? ProgressView {
            progressView.setValue(progress, forKey: "progress")
        }
        
        indicator?.setContentCompressionResistancePriority(998, for: .horizontal)
        indicator?.setContentCompressionResistancePriority(998, for: .vertical)
        
        updateViews(forColor: contentColor)
        setNeedsUpdateConstraints()
    }
    
    func updateViews(forColor color: UIColor) {
        label?.textColor = color
        detailsLabel?.textColor = color
        button?.setTitleColor(color, for: .normal)
        
        // UIAppearance settings are prioritized. If they are preset the set color is ignored.
        
        if let barProgressView = indicator as? BarProgressView {
            // TODO: fix check appearance
            let appearance = BarProgressView.appearance(whenContainedInInstancesOf: [type(of: self)])
            barProgressView.progressColor = color
            barProgressView.lineColor = color
        }
    }
    
    func updateBezelMotionEffects() {
        // TODO: fill
    }
    
    // MARK: Layout
    public override func updateConstraints() {
        let metrics = ["margin": margin]
        
        var subviews: [UIView] = [topSpacer!, label!, detailsLabel!, button!, bottomSpacer!]
        if (indicator != nil) {
            subviews.insert(indicator!, at: 1)
        }
        
        // Remove existing constraints
        removeConstraints(constraints)
        topSpacer?.removeConstraints(topSpacer!.constraints)
        bottomSpacer?.removeConstraints(bottomSpacer!.constraints)
        if (bezelConstraints != nil) {
            bezelView?.removeConstraints(bezelConstraints!)
            bezelConstraints = [NSLayoutConstraint]()
        } else {
            bezelConstraints = [NSLayoutConstraint]()
        }
        
        // Center bezel in container (self), apply the offset if set
        var centeringConstraints = [NSLayoutConstraint]()
        centeringConstraints.append(NSLayoutConstraint(item: bezelView!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: offset.x))
        centeringConstraints.append(NSLayoutConstraint(item: bezelView!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: offset.y))
        apply(priority: 998, toConstraints: centeringConstraints)
        addConstraints(centeringConstraints)
        
        // Ensure minimum side margin is kept
        var sideConstraints = [NSLayoutConstraint]()
        sideConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-(>=margin)-[bezel]-(>=margin)-|", options: .alignAllTop, metrics: metrics, views: ["bezel": bezelView!]))
        sideConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=margin)-[bezel]-(>=margin)-|", options: .alignAllTop, metrics: metrics, views: ["bezel": bezelView!]))
        self.apply(priority: 999, toConstraints: sideConstraints)
        self.addConstraints(sideConstraints)
        
        // Minimum bezel size, if set
        let minimumSize = minSize
        if (minimumSize != CGSize.zero) {
            var miniSizeConstraints = [NSLayoutConstraint]()
            miniSizeConstraints.append(NSLayoutConstraint(item: bezelView!, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: minimumSize.width))
            miniSizeConstraints.append(NSLayoutConstraint(item: bezelView!, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: minimumSize.height))
            self.apply(priority: 997, toConstraints: miniSizeConstraints)
            bezelConstraints?.append(contentsOf: miniSizeConstraints)
        }
        
        // Square aspect ratio, if set
        if(isSquare) {
            let square = NSLayoutConstraint(item: bezelView!, attribute: .height, relatedBy: .equal, toItem: bezelView!, attribute: .width, multiplier: 1, constant: 0)
            square.priority = 997
            bezelConstraints?.append(square)
        }
        
        // Top and bottom spacing
        topSpacer?.addConstraint(NSLayoutConstraint(item: topSpacer!, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: margin))
        bottomSpacer?.addConstraint(NSLayoutConstraint(item: bottomSpacer!, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: margin))
        // Top and bottom spaces should be equal
        bezelConstraints?.append(NSLayoutConstraint(item: topSpacer!, attribute: .height, relatedBy: .equal, toItem: bottomSpacer!, attribute: .height, multiplier: 1, constant: 0))
        
        // Layout subviews in bezel
        paddingConstraints = [NSLayoutConstraint]()
        for (index, view) in subviews.enumerated() {
            // Center in bezel
            bezelConstraints?.append(NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: bezelView!, attribute: .centerX, multiplier: 1, constant: 0))
            // Ensure the minimum edge margin is kept
            bezelConstraints?.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-(>=margin)-[view]-(>=margin)-|", options: .alignAllTop, metrics: metrics, views: ["view": view]))
            // Element spacing
            if (index == 0) {
                // First, ensure spacing to bezel edge
                bezelConstraints?.append(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: bezelView!, attribute: .top, multiplier: 1, constant: 0))
            } else if (index == subviews.count - 1) {
                // Last, ensure spacing to bezel edge
                bezelConstraints?.append(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: bezelView!, attribute: .bottom, multiplier: 1, constant: 0))
            }
            
            if (index > 0) {
                // Has previous
                let padding = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: subviews[index - 1], attribute: .bottom, multiplier: 1, constant: 0)
                bezelConstraints?.append(padding)
                paddingConstraints?.append(padding)
            }
        }
        
        bezelView?.addConstraints(bezelConstraints!)
        updatePaddingConstraints()
        
        super.updateConstraints()
    }
    
    public override func layoutSubviews() {
        if (!needsUpdateConstraints()) {
            updatePaddingConstraints()
        }
        super.layoutSubviews()
    }
    
    func updatePaddingConstraints() {
        // Set padding dynamically, depending on whether the view is visible or not
        var hasVisibleAncestors = false
        for (_, padding) in paddingConstraints!.enumerated() {
            let firstView = padding.firstItem as! UIView
            let secondView = padding.secondItem as! UIView
            let firstVisible = !firstView.isHidden && firstView.intrinsicContentSize != CGSize.zero
            let secondVisible = !secondView.isHidden && secondView.intrinsicContentSize != CGSize.zero
            // Set if both views are visible or if there's a visible view on top that doesn't have padding
            // added relative to the current view yet
            padding.constant = (firstVisible && (secondVisible || hasVisibleAncestors)) ? defaultPadding : 0
            hasVisibleAncestors = hasVisibleAncestors || secondVisible
        }
    }
    
    func apply(priority: UILayoutPriority, toConstraints constraints: [NSLayoutConstraint]) {
        for constraint in constraints {
            constraint.priority = priority
        }
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
    
    // MARK: Notifications
    func registerForNotifications() {
        #if !os(tvOS)
            let nc = NotificationCenter.default
            nc.addObserver(self, selector: #selector(statusBarOrientationDidChange(_:)), name: .UIApplicationDidChangeStatusBarOrientation, object: nil)
        #endif
    }
    
    func unregisterFormNotifications() {
        #if !os(tvOS)
            let nc = NotificationCenter.default
            nc.removeObserver(self, name: .UIApplicationDidChangeStatusBarOrientation, object: nil)
        #endif
    }
    
#if !os(tvOS)
    func statusBarOrientationDidChange(_ notification: NSNotification) {
        if (superview != nil) {
            updateForCurrentOrientation(animated: true)
        }
    }
#endif
    func updateForCurrentOrientation(animated: Bool) {
        // TODO: fill
        print("need to fill updateForCurrentOrientation method.")
    }
}

public class ProgressHubBackgroundView: UIView {
    public enum BackgroundStyle {
        case solidColor, blur
    }
    
    // MARK: Appearance
    public var style: BackgroundStyle? {
        didSet {
            updateForBackgroundStyle()
        }
    }
    public var color: UIColor? {
        didSet {
            assert(color != nil, "The color should not be nil.")
            updateViews(forColor: color!)
        }
    }
    
    var effectView: UIVisualEffectView?
    #if !os(tvOS)
    var toolbar: UIToolbar?
    #endif
    
    // MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        style = .blur
        color = UIColor(white: 0.8, alpha: 0.6)
        
        self.clipsToBounds = true
        updateForBackgroundStyle()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    public override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
    
    // MARK: Views
    func updateForBackgroundStyle() {
        if (style == .blur) {
            let effect = UIBlurEffect(style: .light)
            effectView = UIVisualEffectView(effect: effect)
            self.addSubview(effectView!)
            effectView?.frame = self.bounds
            effectView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            backgroundColor = color
            layer.allowsGroupOpacity = false
        } else {
            effectView?.removeFromSuperview()
            effectView = nil
            backgroundColor = color
        }
    }
    
    func updateViews(forColor color: UIColor) {
        backgroundColor = color
    }
}

class ProgressHubRoundedButton: UIButton {
    
}
