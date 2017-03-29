//
//  ViewController.swift
//  HudDemoTV
//
//  Created by kang huawei on 2017/3/28.
//  Copyright © 2017年 huaweikang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func showHud(_ sender: UIButton) {
        sender.isEnabled = false
        print("click button.")
        
        let hud = HKProgressHUD.show(addedToView: self.view, animated: true)
        // Set the determinate mode to show task progress
        hud.mode = .determinate
        hud.label?.text = NSLocalizedString("Loading...", comment: "hud loading title")
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Do something useful in the background and update the hud periodically.
            self.doSomeWorkWithProgess()
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    
    func doSomeWorkWithProgess() {
        var progress: Float = 0.0
        while (progress < 1.0) {
            progress += 0.01
            DispatchQueue.main.async {
                HKProgressHUD.hudForView(self.view)?.progress = progress
            }
            usleep(50000)
        }
    }
}

