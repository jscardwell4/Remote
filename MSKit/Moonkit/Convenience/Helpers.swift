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


func aggregateErrorMessage(error: NSError) -> String {
  var message = "-Error-\n"
  message += "Description: \(error.localizedDescription)\n"
  if let reason = error.localizedFailureReason    { message += "Reason: \(reason)\n"           }
  if let recoveryOptions = error.localizedRecoveryOptions {
    message += "Recovery Options:\n"
    for option : AnyObject in recoveryOptions  {
      if let optionString = option as? String { message += "\t\(optionString)\n" }
    }
  }
  if let suggestion = error.localizedRecoverySuggestion { message += "Suggestion: \(suggestion)\n" }

  return message
}

func printError(error:NSError, message:String! = nil) {
  println((message != nil ? "error: \(message)\n" : "") + aggregateErrorMessage(error))
}

func warning(message:String) { println("warning: \(message)")}
func info(message:String) { println("info: \(message)")}
func debug(message:String) { println("debug: \(message)")}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - Exceptions
////////////////////////////////////////////////////////////////////////////////


func raiseException(name:String, reason:String, userinfo:[NSObject:AnyObject]? = nil) {
  NSException(name: name, reason: reason, userInfo: userinfo).raise()
}
