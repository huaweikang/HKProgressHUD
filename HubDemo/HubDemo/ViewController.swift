//
//  ViewController.swift
//  HubDemo
//
//  Created by kang huawei on 2017/3/21.
//  Copyright © 2017年 huaweikang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setUp() {
        self.title = "Hub Test"
        
        let hub = ProgressHub.show(addedToView: self.view, animated: true)
        hub.mode = .determinateHorizontalBar
        hub.label?.text = "Loading..."
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Do something useful in the background and update the HUD periodically.
            self.doSomeWorkWithProgess()
            DispatchQueue.main.async {
                hub.hide(animated: true)
            }
        }
    }
    
    var canceled = false
    func doSomeWorkWithProgess() {
        var progress: Float = 0.0
        canceled = false
        while (progress < 1.0) {
            if (self.canceled) {
                break
            }
            progress += 0.01
            DispatchQueue.main.async {
                ProgressHub.hubForView(self.view)?.progress = progress
            }
            usleep(50000)
        }
    }

}

