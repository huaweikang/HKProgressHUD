//
//  ViewController.swift
//  hudDemo
//
//  Created by kang huawei on 2017/3/21.
//  Copyright © 2017年 huaweikang. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    let examples = [
        ("Indeterminate mode", #selector(indeterminateExample)),
        ("With label", #selector(labelExample)),
        ("With details label", #selector(detailsLabelExample)),
        ("On window", #selector(windowExample)),
        ("Bar determinate mode", #selector(barDeterminateExample)),
        ("Determinate mode", #selector(determinateExample)),
        ("Annular determinate mode", #selector(annularDeterminateExample)),
        ("Custom view", #selector(customViewExample)),
        ("Text Only", #selector(textExample)),
        ("With action button", #selector(cancelationExample)),
        ("Determinate with Progress", #selector(determinateProgressExample)),
        ("Mode swithing", #selector(modeSwitchExample)),
        ("Dim background", #selector(dimBackgroundExample)),
        ("Colored", #selector(colorExample))
                    ]

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
        self.title = "HUD Test"
        
    }
    
    // MARK: Examples
    func indeterminateExample() {
        // Show the hud on the root view (self.view is a scrollable table view and thus not suitable,
        // as the hud would move with the content as we scroll).
        let hud = HKProgressHUD.show(addedToView: (self.navigationController?.view)!, animated: true)
        
        // Fire off an asynchronous task, giving UIKit the opportunity to redraw wit the hud added to the
        // view hierarchy.
        DispatchQueue.global(qos: .userInitiated).async {
            self.doSomeWork()
            
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    func labelExample() {
        let hud = HKProgressHUD.show(addedToView: (self.navigationController?.view)!, animated: true)
        
        // Set label text
        hud.label?.text = NSLocalizedString("Loading...", comment: "hud loading title")
        // You can set other lable properties
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.doSomeWork()
            
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    func detailsLabelExample() {
        let hud = HKProgressHUD.show(addedToView: (self.navigationController?.view)!, animated: true)
        
        // Set label text
        hud.label?.text = NSLocalizedString("Loading...", comment: "hud loading title")
        // Set details label text.
        hud.detailsLabel?.text = NSLocalizedString("Pasing data\n(1/1)", comment: "hud title")
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.doSomeWork()
            
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    func windowExample() {
        // Cover the entire screen.
        let hud = HKProgressHUD.show(addedToView: self.view.window!, animated: true)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.doSomeWork()
            
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    
    func barDeterminateExample() {
        let hud = HKProgressHUD.show(addedToView: (self.navigationController?.view)!, animated: true)
        hud.mode = .determinateHorizontalBar
        hud.label?.text = "Loading..."
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Do something useful in the background and update the hud periodically.
            self.doSomeWorkWithProgess()
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    
    func determinateExample() {
        let hud = HKProgressHUD.show(addedToView: (self.navigationController?.view)!, animated: true)
        
        // Set determinate mode
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
    
    func annularDeterminateExample() {
        let hud = HKProgressHUD.show(addedToView: (self.navigationController?.view)!, animated: true)
        
        // Set annular determinate mode
        hud.mode = .annularDeterminate
        hud.label?.text = NSLocalizedString("Loading...", comment: "hud loading title")
        DispatchQueue.global(qos: .userInitiated).async {
            // Do something useful in the background and update the hud periodically.
            self.doSomeWorkWithProgess()
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    
    func customViewExample() {
        let hud = HKProgressHUD.show(addedToView: (self.navigationController?.view)!, animated: true)
        // Set the custom view mode
        hud.mode = .customView
        // Set a checkmark
        hud.customView = UIImageView(image: #imageLiteral(resourceName: "Checkmark"))
        hud.isSquare = true
        hud.label?.text = NSLocalizedString("Done", comment: "hud done title")
        hud.hide(animated: true, afterDelay: 3.0)
    }
    
    func textExample() {
        let hud = HKProgressHUD.show(addedToView: (self.navigationController?.view)!, animated: true)
        
        // Set the Text mode
        hud.mode = .text
        hud.label?.text = NSLocalizedString("Message here!", comment: "hud message title")
        // Move to bottom center.
        hud.offset = CGPoint(x: 0, y: HKProgressHUD.maxOffset)
        hud.hide(animated: true, afterDelay: 3.0)
    }
    
    func cancelationExample() {
        let hud = HKProgressHUD.show(addedToView: (self.navigationController?.view)!, animated: true)
        
        // Set the determinate mode
        hud.mode = .determinate
        hud.label?.text = NSLocalizedString("Loading...", comment: "hud loading title")
        
        // Configure the button
        hud.button?.setTitle(NSLocalizedString("cancel", comment: "hud cancel button title"), for: .normal)
        hud.button?.addTarget(self, action: #selector(cancelWork(sender:)), for: .touchUpInside)
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Do something useful in the background and update the hud periodically.
            self.doSomeWorkWithProgess()
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    
    func determinateProgressExample() {
        let hud = HKProgressHUD.show(addedToView: (self.navigationController?.view)!, animated: true)
        
        // Set the determinate mode
        hud.mode = .determinate
        hud.label?.text = NSLocalizedString("Loading...", comment: "hud loading title")
        
        // Set up Progress
        hud.progressObject = Progress(totalUnitCount: 100)
        
        // Configure the button
        hud.button?.setTitle(NSLocalizedString("cancel", comment: "hud cancel button title"), for: .normal)
        hud.button?.addTarget(hud.progressObject, action: #selector(Progress.cancel), for: .touchUpInside)
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Do something useful in the background and update the hud periodically.
            self.doSomeWork(forProgressObject: hud.progressObject!)
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    
    func modeSwitchExample() {
        let hud = HKProgressHUD.show(addedToView: (self.navigationController?.view)!, animated: true)
        
        // Set some text to show the initial status.
        hud.label?.text = NSLocalizedString("Preparing", comment: "hud preparing title")
        // Set min size
        hud.minSize = CGSize(width: 150, height: 100)
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Do something useful in the background and update the hud periodically.
            self.doSomeWorkWithMixedProgress()
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    
    func dimBackgroundExample() {
        let hud = HKProgressHUD.show(addedToView: (self.navigationController?.view)!, animated: true)
        
        // Change the background view style and color
        hud.backgroundView?.style = .solidColor
        hud.backgroundView?.color = UIColor(white: 0, alpha: 0.1)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.doSomeWork()
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    
    func colorExample() {
        let hud = HKProgressHUD.show(addedToView: (self.navigationController?.view)!, animated: true)
        hud.contentColor = UIColor(red: 0, green: 0.6, blue: 0.7, alpha: 1)
        
        // Set the label text.
        hud.label?.text = NSLocalizedString("Loading...", comment: "hud loading title")
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.doSomeWork()
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    
    
    // MARK - Tasks
    func doSomeWork() {
        sleep(3)
    }
    
    var canceled = false
    
    func cancelWork(sender: AnyObject) {
        self.canceled = true
    }
    
    func doSomeWorkWithProgess() {
        var progress: Float = 0.0
        canceled = false
        while (progress < 1.0) {
            if (self.canceled) {
                break
            }
            progress += 0.01
            DispatchQueue.main.async {
                HKProgressHUD.hudForView((self.navigationController?.view)!)?.progress = progress
            }
            usleep(50000)
        }
    }
    
    func doSomeWork(forProgressObject progress: Progress) {
        // just increases the progress indicator
        while progress.fractionCompleted < 1.0 {
            if progress.isCancelled {
                break
            }
            progress.becomeCurrent(withPendingUnitCount: 1)
            progress.resignCurrent()
            usleep(50000)
        }
    }
    
    func doSomeWorkWithMixedProgress() {
        let hud = HKProgressHUD.hudForView((self.navigationController?.view)!)
        
        // Indetermimate mode
        sleep(2)
        // Switch to deteminate mode
        DispatchQueue.main.async {
            hud?.mode = .determinate
            hud?.label?.text = NSLocalizedString("Loading", comment: "hud loading title")
        }
        doSomeWorkWithProgess()
        
        // Back to indeter mode
        DispatchQueue.main.async {
            hud?.mode = .indeterminate
            hud?.label?.text = NSLocalizedString("Cleaning up...", comment: "hud cleaning up title")
        }
        sleep(2)
        DispatchQueue.main.sync {
            let image = #imageLiteral(resourceName: "Checkmark").withRenderingMode(.alwaysTemplate)
            let imageView = UIImageView(image: image)
            hud?.customView = imageView
            hud?.mode = .customView
            hud?.label?.text = NSLocalizedString("Completed", comment: "hud completed title")
        }
        sleep(2)
    }

    
    // MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "exampleCell"
        let exapmle = examples[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = exapmle.0
        cell.textLabel?.textColor = self.view.tintColor
        cell.textLabel?.textAlignment = .center
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = cell.textLabel?.textColor.withAlphaComponent(0.1)
        return cell
    }
    
    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let example = examples[indexPath.row]
        perform(example.1)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
            tableView.deselectRow(at: indexPath, animated: true)
        })
    }
}

