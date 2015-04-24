//
//  AppDelegate.swift
//  UIApp
//
//  Created by Jason Cardwell on 4/23/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import UIKit
import MoonKit
import DataModel
import UI

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  override class func initialize() {
    LogManager.addConsoleLoggers()
    MSLogDebug("main bundle: '\(NSBundle.mainBundle().bundlePath)'")
  }

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.

    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window?.backgroundColor = UIColor.whiteColor()
    window?.makeKeyAndVisible()

//    let wtf = DataManager.self
//    window?.rootViewController = UINavigationController()
    window?.rootViewController = UINavigationController(rootViewController: ActivityViewController())

    return true
  }

}

