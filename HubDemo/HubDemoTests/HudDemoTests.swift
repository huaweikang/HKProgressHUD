//
//  HudDemoTests.swift
//  HudDemoTests
//
//  Created by kang huawei on 2017/3/21.
//  Copyright © 2017年 huaweikang. All rights reserved.
//

import XCTest
@testable import HudDemo

class HudDemoTests: XCTestCase, HKProgressHUDDelegate {
    
    var hideExpectation: XCTestExpectation?
    var hideChecks: (() -> Void)?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNonAnimatedConveniencehudPresentation() {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        let rootView = rootViewController?.view
        
        let hud = HKProgressHUD.show(addedToView: rootView!, animated: false)
        XCTAssertNotNil(hud, "hud should be created.")
        checkhudVisible(hud, rootView: rootView!)
        XCTAssertFalse((hud.bezelView?.layer.animationKeys()?.contains("opacity"))!, "The opcity should not be animated.")
        XCTAssertTrue(HKProgressHUD.hide(addedToView: rootView!, animated: false), "hud should be found and removed")
        checkhudHiddenAndRemoved(hud, rootView: rootView!)
        XCTAssertFalse(HKProgressHUD.hide(addedToView: rootView!, animated: false), "A subsequent hud hide operation should fail")
    }
    
    func checkhudVisible(_ hud: HKProgressHUD, rootView: UIView) {
        XCTAssertTrue(hud.superview === rootView, "hud not be added to the view")
        XCTAssertTrue(HKProgressHUD.hudForView(rootView) === hud, "hud should be found via the operation")
        XCTAssertTrue(hud.alpha == 1.0, "hud should be visible.")
        XCTAssertFalse(hud.isHidden, "hud should be visible.")
        XCTAssertTrue(hud.bezelView?.alpha == 1.0, "hud bezel view should be visible")
    }
    
    func checkhudHiddenAndRemoved(_ hud: HKProgressHUD, rootView: UIView) {
        XCTAssertFalse(rootView.subviews.contains(hud), "The hud should be removed.")
        XCTAssertTrue(hud.alpha == 0.0, "hud should be invisible")
        XCTAssertNil(hud.superview, "hud should not have a superview")
    }
    
    func testAnimatedConvenienceHUDPresentation() {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        let rootView = rootViewController?.view
        
        self.hideExpectation = expectation(description: "The hubWasHidden delegate should have been called.")
        let hud = HKProgressHUD.show(addedToView: rootView!, animated: true)
        hud.delegate = self
        
        XCTAssertNotNil(hud, "hud should be created.")
        checkhudVisible(hud, rootView: rootView!)
        XCTAssertTrue((hud.bezelView?.layer.animationKeys()?.contains("opacity"))!, "The opcity should be animated.")
        
        XCTAssertTrue(HKProgressHUD.hide(addedToView: rootView!, animated: true), "hud should be hide and removed.")
        
        XCTAssertTrue(rootView!.subviews.contains(hud), "hud should be part of root view hierarthy.")
        XCTAssertTrue(hud.alpha == 1.0, "hud should still be visible.")
        XCTAssertTrue(hud.superview === rootView, "hub should be added to th view.")
        XCTAssertTrue(hud.bezelView!.alpha == 0, "hub bezel should be animated out.")
        XCTAssertTrue((hud.bezelView?.layer.animationKeys()?.contains("opacity"))!, "opacity should be animated.")
        
        hideChecks = {
            self.checkhudHiddenAndRemoved(hud, rootView: rootView!)
            XCTAssertFalse(HKProgressHUD.hide(addedToView: rootView!, animated: true), "a subsequent hud hide should fail.")
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testCompletionBlock() {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        let rootView = rootViewController?.view
        self.hideExpectation = expectation(description: "The hubWasHidden delegate should have been called.")
        let completionExpection = expectation(description: "completionBlock: should have been called.")
        
        let hud = HKProgressHUD.show(addedToView: rootView!, animated: true)
        hud.delegate = self
        hud.completionBlock = {
            completionExpection.fulfill()
        }
        
        hud.hide(animated: true)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // MARK: Delay
    func testDelayedHide() {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        let rootView = rootViewController?.view
        self.hideExpectation = expectation(description: "The hubWasHidden delegate should have been called.")
        
        let hud = HKProgressHUD.show(addedToView: rootView!, animated: false)
        hud.delegate = self
        XCTAssertNotNil(hud, "hud should be created.")
        
        hud.hide(animated: false, afterDelay: 2)
        checkhudVisible(hud, rootView: rootView!)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1), execute: {
            self.checkhudVisible(hud, rootView: rootView!)
        })
        
        let hideCheckExpectation = expectation(description: "Hide check")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(3), execute: {
            self.checkhudHiddenAndRemoved(hud, rootView: rootView!)
            hideCheckExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        checkhudHiddenAndRemoved(hud, rootView: rootView!)
    }
    
    // MARK: Reuse
    func testNonAnimatedHudReuse() {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        let rootView = rootViewController?.view
        let hud = HKProgressHUD()
        rootView?.addSubview(hud)
        hud.show(animated: false)
        
        XCTAssertNotNil(hud, "hud should be created.")
        
        hud.hide(animated: false)
        hud.show(animated: false)
        
        checkhudVisible(hud, rootView: rootView!)
        
        hud.hide(animated: false)
        
        hud.removeFromSuperview()
    }
    
    func testUnfinishedHidingAnimation() {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        let rootView = rootViewController?.view
        let hud = HKProgressHUD.show(addedToView: rootView!, animated: false)
        
        hud.hide(animated: true)
        
        // Cancel all nimations
        hud.bezelView?.layer.removeAllAnimations()
        hud.backgroundView?.layer.removeAllAnimations()
        
        let hideCheckExpectation = expectation(description: "Hide check")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(3), execute: {
            // after grace time passes, hub should not be shown
            self.checkhudHiddenAndRemoved(hud, rootView: rootView!)
            hideCheckExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 5.0, handler: nil)
        checkhudHiddenAndRemoved(hud, rootView: rootView!)
    }
    
    func testAnimatedImmediateHudReuse() {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        let rootView = rootViewController?.view
        
        let hideExpectation = expectation(description: "hub should have been hidden.")
        
        let hud = HKProgressHUD(withView: rootView!)
        rootView?.addSubview(hud)
        
        XCTAssertNotNil(hud, "hud should be created.")
        
        hud.hide(animated: true)
        hud.show(animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1), execute: {
            self.checkhudVisible(hud, rootView: rootView!)
            
            hud.hide(animated: false)
            hud.removeFromSuperview()
            
            hideExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    // MARK: Min show time
    func testMinShowTime() {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        let rootView = rootViewController?.view
        self.hideExpectation = expectation(description: "The hubWasHidden delegate should have been called.")
        
        let hud = HKProgressHUD(withView: rootView!)
        rootView?.addSubview(hud)
        hud.delegate = self
        hud.removeFromSuperViewOnHide = true
        hud.minShowTime = 2
        hud.show(animated: true)
        
        XCTAssertNotNil(hud, "hud should be created.")
        
        hud.hide(animated: true)
        
        var checkAfterOneSecond = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1), execute: {
            self.checkhudVisible(hud, rootView: rootView!)
            checkAfterOneSecond = true
        })
        
        hideChecks = {
            XCTAssertTrue(checkAfterOneSecond)
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
        checkhudHiddenAndRemoved(hud, rootView: rootView!)
    }
    
    // MARK: Grace time
    func testGraceTime() {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        let rootView = rootViewController?.view
        self.hideExpectation = expectation(description: "The hubWasHidden delegate should have been called.")
        
        let hud = HKProgressHUD(withView: rootView!)
        hud.delegate = self
        hud.removeFromSuperViewOnHide = true
        hud.graceTime = 2.0
        rootView?.addSubview(hud)
        hud.show(animated: true)
        
        XCTAssertNotNil(hud, "hud should be created.")
        
        // The HUD should be added to the view but still hidden
        XCTAssertTrue(hud.superview === rootView, "The hud should be added to the view.")
        XCTAssertEqual(hud.alpha, 0, "The HUD should not be visible.")
        XCTAssertFalse(hud.isHidden, "The HUD should be visible.")
        XCTAssertEqual(hud.bezelView?.alpha, 0, "The HUD should not be visible.")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1), execute: {
            // The HUD should be added to the view but still hidden
            XCTAssertTrue(hud.superview === rootView, "The hud should be added to the view.")
            XCTAssertEqual(hud.alpha, 0, "The HUD should not be visible.")
            XCTAssertFalse(hud.isHidden, "The HUD should be visible.")
            XCTAssertEqual(hud.bezelView?.alpha, 0, "The HUD should not be visible.")
        })
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(3), execute: {
            // After the grace time passes, the HUD should be shown.
            self.checkhudVisible(hud, rootView: rootView!)
            hud.hide(animated: true)
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        checkhudHiddenAndRemoved(hud, rootView: rootView!)
    }
    
    
    
    // MARK: HKProgressHUD delegate
    func hudWasHidden(_ hud: HKProgressHUD) {
        if let checkAction = hideChecks {
            checkAction()
        }
        
        hideExpectation?.fulfill()
        hideExpectation = nil
    }
}
