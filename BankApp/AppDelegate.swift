//
//  AppDelegate.swift
//  Bank
//
//  Created by Jason Cardwell on 3/20/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import UIKit
import MoonKit
import Bank

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  override class func initialize() {
    MSLog.addTaggingTTYLogger()
    MSLog.addTaggingASLLogger()
    (DDTTYLogger.sharedInstance().logFormatter() as! MSLogFormatter).includeObjectName = false
    MSLogDebug("main bundle: '\(NSBundle.mainBundle().bundlePath)'")
  }

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.

    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window?.backgroundColor = UIColor.whiteColor()
    window?.makeKeyAndVisible()
    window?.rootViewController = UINavigationController(rootViewController: BankRootController())

    return true
  }

}

