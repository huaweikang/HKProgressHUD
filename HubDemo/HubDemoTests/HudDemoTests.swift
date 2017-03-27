//
//  HubDemoTests.swift
//  HubDemoTests
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
    
    func testNonAnimatedConvenienceHubPresentation() {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        let rootView = rootViewController?.view
        
        let hub = HKProgressHUD.show(addedToView: rootView!, animated: false)
        XCTAssertNotNil(hub, "Hub should be created.")
        checkHubVisible(hub, rootView: rootView!)
        XCTAssertFalse((hub.bezelView?.layer.animationKeys()?.contains("opacity"))!, "The opcity should not be animated.")
        XCTAssertTrue(HKProgressHUD.hide(addedToView: rootView!, animated: false), "Hub should be found and removed")
        checkHubHiddenAndRemoved(hub, rootView: rootView!)
        XCTAssertFalse(HKProgressHUD.hide(addedToView: rootView!, animated: false), "A subsequent Hub hide operation should fail")
    }
    
    func checkHubVisible(_ hub: HKProgressHUD, rootView: UIView) {
        XCTAssertTrue(hub.superview === rootView, "hub not be added to the view")
        XCTAssertTrue(HKProgressHUD.hubForView(rootView) === hub, "Hub should be found via the operation")
        XCTAssertTrue(hub.alpha == 1.0, "hub should be visible.")
        XCTAssertFalse(hub.isHidden, "hub should be visible.")
        XCTAssertTrue(hub.bezelView?.alpha == 1.0, "hub bezel view should be visible")
    }
    
    func checkHubHiddenAndRemoved(_ hub: HKProgressHUD, rootView: UIView) {
        XCTAssertFalse(rootView.subviews.contains(hub), "The Hub should be removed.")
        XCTAssertTrue(hub.alpha == 0.0, "Hub should be invisible")
        XCTAssertNil(hub.superview, "Hub should not have a superview")
    }
    
    
    // MARK: HKProgressHUD delegate
    
}
