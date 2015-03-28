//
//  AppDelegate.swift
//  DataModelApp
//
//  Created by Jason Cardwell on 3/28/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import UIKit
import MoonKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  override class func initialize() {
    MSLog.addTaggingTTYLogger()
    MSLog.addTaggingASLLogger()
    (DDTTYLogger.sharedInstance().logFormatter() as! MSLogFormatter).includeObjectName = false
    MSLogDebug("main bundle: '\(NSBundle.mainBundle().bundlePath)'")
  }

}

