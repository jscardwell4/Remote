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
    LogManager.addConsoleLoggers()
    MSLogDebug("main bundle: '\(NSBundle.mainBundle().bundlePath)'")
  }

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
    let fileManager = NSFileManager.defaultManager()
    let path = "/Users/Moondeer/Projects/MSRemote/Remote/Bank/Resources/JSON"
    var error: NSError?
    let contents = fileManager.contentsOfDirectoryAtPath(path, error: &error)
    if let c = contents where !MSHandleError(error, message: "error retrieving directory contents") {
      MSLogVerbose("\n".join(c))
    }

    return true
  }
}

