# HKProgressHUD

[![Build Status](https://travis-ci.org/huaweikang/HKProgressHUD.svg?branch=master)](https://travis-ci.org/huaweikang/HKProgressHUD)
[![codecov](https://codecov.io/gh/huaweikang/HKProgressHUD/branch/master/graph/badge.svg)](https://codecov.io/gh/huaweikang/HKProgressHUD)
![CocoaPod Platform](https://img.shields.io/cocoapods/p/HKProgressHUD.svg?style=flat)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/HKProgressHUD.svg?style=flat)](https://cocoapods.org/pods/HKProgressHUD)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application)
[![License: MIT](https://img.shields.io/cocoapods/l/HKProgressHUD.svg?style=flat)](http://opensource.org/licenses/MIT)

`HKProgressHUD` is an iOS drop-in class in pure-Swift that displays a translucent HUD with an indicator and/or labels while work is being done in a background thread. The HUD is meant as a replacement for the undocumented, private `UIKit` `UIProgressHUD` with some additional features.This project is heavily inspired by the popular [MBProgressHUD](https://github.com/jdg/MBProgressHUD).

## Requirements
`HKProgressHUD` works on iOS 8+.
You will need the latest developer tools in order to build `HKProgressHUD`. Old Xcode versions might work, but compatibility will not be explicitly maintained.

## Adding HKProgressHUD to your project

### CocoaPods

[CocoaPods](http://cocoapods.org) is the recommended way to add HKProgressHUD to your project.

1. Add a pod entry for HKProgressHUD to your Podfile `pod 'HKProgressHUD', '~> 0.8.0'`
2. Update the pod(s) by running `pod update`.

### Carthage

1. Add HKProgressHUD to your Cartfile. e.g., `github "huaweikang/HKProgressHUD" ~> 0.8.0`
2. Run `carthage update`
3. Follow the rest of the [standard Carthage installation instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) to add HKProgressHUD to your project.

### Source files

Alternatively you can directly add the `HKProgressHUD.swift` and `ProgressView.swift` source files to your project.

## Usage

The main guideline you need to follow when dealing with HKProgressHUD while running long-running tasks is keeping the main thread work-free, so the UI can be updated promptly. The recommended way of using HKProgressHUD is therefore to set it up on the main thread and then spinning the task, that you want to perform, off onto a new thread.

```swift
let hud = HKProgressHUD.show(addedToView: self.view, animated: true)
DispatchQueue.global(qos: .userInitiated).async {
    // Do something...
    DispatchQueue.main.async {
    hud.hide(animated: true)
    }
}
```

You can add the HUD on any view or window. It is however a good idea to avoid adding the HUD to certain `UIKit` views with complex view hierarchies - like `UITableView` or `UICollectionView`. Those can mutate their subviews in unexpected ways and thereby break HUD display. 

If you need to configure the HUD you can do this by using the HKProgressHUD reference that show(addedToView:animated:) returns.

```swift
let hud = HKProgressHUD.show(addedToView: (self.navigationController?.view)!, animated: true)
hud.mode = .annularDeterminate
hud.label?.text = "Loading..."
DispatchQueue.global(qos: .userInitiated).async {
    // Do something...
    DispatchQueue.main.async {
    hud.hide(animated: true)
    }
}
```

You can also use a `Progress` object and HKProgressHUD will update itself when there is progress reported through that object.

```swift
let hud = HKProgressHUD.show(addedToView: (self.navigationController?.view)!, animated: true)
hud.mode = .annularDeterminate
hud.label?.text = "Loading..."
let progress = Progress(totalUnitCount: 100)
hud.progressObject = progress;
```

UI updates should always be done on the main thread.

If you need to run your long-running task in the main thread, you should perform it with a slight delay, so UIKit will have enough time to update the UI (i.e., draw the HUD) before you block the main thread with your task.

```swift
HKProgressHUD.show(addedToView: self.view, animated: true)
DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(3), execute: {
      // Do something...
      HKProgressHUD.hide(addedToView: self.view, animated: false)
 })
```

You should be aware that any HUD updates issued inside the above block won't be displayed until the block completes.

For more examples, including how to use HKProgressHUD with asynchronous operations such as NSURLConnection, take a look at the bundled demo project. 

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).

## Change-log

A brief summary of each HKProgressHUD release can be found in the [CHANGELOG](CHANGELOG.md).
