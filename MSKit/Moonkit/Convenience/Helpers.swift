//
//  helpers.swift
//  Gyre-Swift
//
//  Created by Jason Cardwell on 6/30/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

private let fileManager = NSFileManager.defaultManager()

@objc public class MoonFunctions {

  ////////////////////////////////////////////////////////////////////////////////
  /// MARK: - File paths
  ////////////////////////////////////////////////////////////////////////////////


  /**
  libraryPath

  :returns: String?
  */
  @objc public class func libraryPath() -> String? {
    let urls = fileManager.URLsForDirectory(NSSearchPathDirectory.LibraryDirectory,
                                  inDomains: NSSearchPathDomainMask.UserDomainMask)
    return ((urls.count > 0 && urls[0] is NSURL) ? (urls[0] as! NSURL).path : nil)
  }

  /**
  libraryPathToFile:

  :param: file String

  :returns: String?
  */
  @objc public class func libraryPathToFile(file: String) -> String? {
    return libraryPath()?.stringByAppendingPathComponent(file)
  }

  /**
  cachePath

  :returns: String?
  */
  @objc public class func cachePath() -> String? {
    return libraryPathToFile("Caches/\(NSBundle.mainBundle().bundleIdentifier)")
  }

  /**
  cachePathToFile:

  :param: file String

  :returns: String?
  */
  @objc public class func cachePathToFile(file: String) -> String? {
    return cachePath()?.stringByAppendingPathComponent(file)
  }

  /**
  documentsPath

  :returns: String?
  */
  @objc public class func documentsPath() -> String! {
    let urls = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory,
                                                     inDomains: NSSearchPathDomainMask.UserDomainMask)
    return ((urls.count > 0 && urls[0] is NSURL) ? (urls[0] as! NSURL).path : nil)
  }

  /**
  documentsDirectoryContents

  :returns: [String]
  */
  @objc public class func documentsDirectoryContents() -> [String] {
    var error: NSError? = nil
    let directoryContents = fileManager.contentsOfDirectoryAtPath(documentsPath(), error: &error) as? [String]
    MSHandleError(error, message: "failed to get directory contents")
    return directoryContents ?? []
  }

  /**
  documentsPathToFile:

  :param: file String

  :returns: String?
  */
  @objc public class func documentsPathToFile(file: String) -> String? {
    return documentsPath()?.stringByAppendingPathComponent(file)
  }

}
////////////////////////////////////////////////////////////////////////////////
/// MARK: - Exceptions
////////////////////////////////////////////////////////////////////////////////


public func MSRaiseException(name:String, reason:String, userinfo:[NSObject:AnyObject]? = nil) {
  NSException(name: name, reason: reason, userInfo: userinfo).raise()
}
