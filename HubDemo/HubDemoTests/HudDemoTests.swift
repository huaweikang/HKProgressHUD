//
//  HudDemoTests.swift
//  HudDemoTests
//
//  Created by kang huawei on 2017/3/21.
//  Copyright © 2017年 huaweikang. All rights reserved.
//

import XCTest
@testable import HudDemo

class HudDemoTests: XCTestCase {
    
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
    
    
    // MARK: HKProgressHUD delegate
    
}
