//
//  AppDelegate.swift
//  DataModelApp
//
//  Created by Jason Cardwell on 3/28/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import UIKit
import MoonKit
import DataModel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  override class func initialize() {
    MSLog.addTaggingTTYLogger()
    MSLog.addTaggingASLLogger()
    (DDTTYLogger.sharedInstance().logFormatter() as! MSLogFormatter).includeObjectName = false
    MSLogDebug("main bundle: '\(NSBundle.mainBundle().bundlePath)'")
  }

//  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
//    let entities = DataManager.stack.managedObjectModel.entities
//    MSLogDebug("entities:\n\(entities)")
//    return true
//  }
}

