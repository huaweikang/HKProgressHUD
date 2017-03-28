# HKProgressHUD

[![Build Status](https://travis-ci.org/huaweikang/HKProgressHUD.svg?branch=master)](https://travis-ci.org/huaweikang/HKProgressHUD)
[![codecov](https://codecov.io/gh/huaweikang/HKProgressHUD/branch/master/graph/badge.svg)](https://codecov.io/gh/huaweikang/HKProgressHUD)
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

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).

## Change-log

A brief summary of each HKProgressHUD release can be found in the [CHANGELOG](CHANGELOG.md).
