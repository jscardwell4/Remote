//
//  helpers.swift
//  Gyre-Swift
//
//  Created by Jason Cardwell on 6/30/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation


////////////////////////////////////////////////////////////////////////////////
/// MARK: - File paths
////////////////////////////////////////////////////////////////////////////////


func libraryPath() -> String? {

  let fm = NSFileManager.defaultManager()
  let urls = fm.URLsForDirectory(NSSearchPathDirectory.LibraryDirectory,
                                 inDomains: NSSearchPathDomainMask.UserDomainMask)
  if urls.count > 0 && urls[0] is NSURL {

    let url = urls[0] as NSURL
    return url.path

  } else {

    return nil

  }

}

func libraryPathToFile(file: String) -> String? { return libraryPath()?.stringByAppendingPathComponent(file) }
func cachePath() -> String? { return libraryPathToFile("Caches/\(NSBundle.mainBundle().bundleIdentifier)") }
func cachePathToFile(file: String) -> String? { return cachePath()?.stringByAppendingPathComponent(file) }

func documentsPath() -> String? {

  let fm = NSFileManager.defaultManager()
  let urls = fm.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory,
                                 inDomains: NSSearchPathDomainMask.UserDomainMask)
  if urls.count > 0 && urls[0] is NSURL {

    let url = urls[0] as NSURL
    return url.path

  } else {

    return nil

  }

}

func documentsPathToFile(file: String) -> String? { return libraryPath()?.stringByAppendingPathComponent(file) }


////////////////////////////////////////////////////////////////////////////////
/// MARK: - Errors and logging
////////////////////////////////////////////////////////////////////////////////


/**
detailedDescriptionForError:depth:

:param: error NSError
:param: depth Int = 0

:returns: String
*/
func detailedDescriptionForError(error: NSError, depth: Int = 0) -> String {

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
aggregateErrorMessage:

:param: error NSError

:returns: String
*/
func aggregateErrorMessage(error: NSError, message:String! = nil) -> String {
  return "-Error-" + (message ?? "") + "\n\(detailedDescriptionForError(error, depth: 0))"
}

func printError(error:NSError, message:String! = nil) { println(aggregateErrorMessage(error, message: message)) }

func warning(message:String) { println("warning: \(message)")}
func info(message:String) { println("info: \(message)")}
func debug(message:String) { println("debug: \(message)")}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - Exceptions
////////////////////////////////////////////////////////////////////////////////


func raiseException(name:String, reason:String, userinfo:[NSObject:AnyObject]? = nil) {
  NSException(name: name, reason: reason, userInfo: userinfo).raise()
}
