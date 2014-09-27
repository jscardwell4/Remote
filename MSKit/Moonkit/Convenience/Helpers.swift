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
    return ((urls.count > 0 && urls[0] is NSURL) ? (urls[0] as NSURL).path : nil)
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
    return ((urls.count > 0 && urls[0] is NSURL) ? (urls[0] as NSURL).path : nil)
  }

  /**
  documentsDirectoryContents

  :returns: [String]
  */
  @objc public class func documentsDirectoryContents() -> [String] {
    var error: NSError? = nil
    let directoryContents = fileManager.contentsOfDirectoryAtPath(documentsPath(), error: &error) as? [String]
    if error != nil { logError(aggregateErrorMessage(error!, message: "failed to get directory contents"), __FUNCTION__) }
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
/// MARK: - Errors and logging
////////////////////////////////////////////////////////////////////////////////


/**
detailedDescriptionForError:depth:

:param: error NSError
:param: depth Int = 0

:returns: String
*/
public func detailedDescriptionForError(error: NSError, depth: Int = 0) -> String {

  var depthIndent = "  " * depth
  var message = "\(depthIndent)domain: \(error.domain)\n\(depthIndent)code: \(error.code)\n"

  if let reason = error.localizedFailureReason { message += "\(depthIndent)reason: \(reason)\n" }

  if let recoveryOptions = error.localizedRecoveryOptions as? [String] {
    let joinString = ",\n" + (" " * 18) + depthIndent
    message += "\(depthIndent)recovery options: \(joinString.join(recoveryOptions))\n"
  }

  if let suggestion = error.localizedRecoverySuggestion { message += "\(depthIndent)suggestion: \(suggestion)\n" }

  if let underlying: AnyObject = error.userInfo?[NSUnderlyingErrorKey] {

    if let underlyingError = underlying as? NSError {
      // Add information gathered from the underlying error
      message += "\(depthIndent)underlyingError:\n\(detailedDescriptionForError(underlyingError, depth: depth + 1))\n"
    }

    else if let underlyingErrors = underlying as? [NSError] {
      // Add information gathered from each underlying error
      let joinString = ",\n"
      message += "\(depthIndent)underlyingErrors:\n"
      message += joinString.join(underlyingErrors.map{detailedDescriptionForError($0, depth: depth + 1)}) + "\n"
    }

  }

  return message

}

/**
handleError:function:

:param: error NSError?
:param: function String

:returns: Bool
*/
public func handleError(error: NSError?, function: String, message: String? = nil) -> Bool {
  if let e = error { logDebug(aggregateErrorMessage(e, message: message), function); return true } else { return false }
}

/**
aggregateErrorMessage:

:param: error NSError

:returns: String
*/
public func aggregateErrorMessage(error: NSError, message:String! = nil) -> String {
  return "-Error-" + (message ?? "") + "\n\(detailedDescriptionForError(error, depth: 0))"
}

public func printError(error:NSError, message:String! = nil) { println(aggregateErrorMessage(error, message: message)) }

public func warning(message:String) { println("warning: \(message)")}
public func info(message:String) { println("info: \(message)")}
public func debug(message:String) { println("debug: \(message)")}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - Exceptions
////////////////////////////////////////////////////////////////////////////////


public func raiseException(name:String, reason:String, userinfo:[NSObject:AnyObject]? = nil) {
  NSException(name: name, reason: reason, userInfo: userinfo).raise()
}
