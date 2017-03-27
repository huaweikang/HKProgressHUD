//
//  HubDemoTests.swift
//  HubDemoTests
//
//  Created by kang huawei on 2017/3/21.
//  Copyright © 2017年 huaweikang. All rights reserved.
//

import XCTest
@testable import HudDemo

class HubDemoTests: XCTestCase {
    
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
        
        let hub = ProgressHub.show(addedToView: rootView!, animated: false)
        XCTAssertNotNil(hub, "Hub should be created.")
        checkHubVisible(hub, rootView: rootView!)
        XCTAssertFalse((hub.bezelView?.layer.animationKeys()?.contains("opacity"))!, "The opcity should not be animated.")
        XCTAssertTrue(ProgressHub.hide(addedToView: rootView!, animated: false), "Hub should be found and removed")
        checkHubHiddenAndRemoved(hub, rootView: rootView!)
        XCTAssertFalse(ProgressHub.hide(addedToView: rootView!, animated: false), "A subsequent Hub hide operation should fail")
    }
    
    func checkHubVisible(_ hub: ProgressHub, rootView: UIView) {
        XCTAssertTrue(hub.superview === rootView, "hub not be added to the view")
        XCTAssertTrue(ProgressHub.hubForView(rootView) === hub, "Hub should be found via the operation")
        XCTAssertTrue(hub.alpha == 1.0, "hub should be visible.")
        XCTAssertFalse(hub.isHidden, "hub should be visible.")
        XCTAssertTrue(hub.bezelView?.alpha == 1.0, "hub bezel view should be visible")
    }
    
    func checkHubHiddenAndRemoved(_ hub: ProgressHub, rootView: UIView) {
        XCTAssertFalse(rootView.subviews.contains(hub), "The Hub should be removed.")
        XCTAssertTrue(hub.alpha == 0.0, "Hub should be invisible")
        XCTAssertNil(hub.superview, "Hub should not have a superview")
    }
    
    
    // MARK: ProgressHub delegate
    
}
