//
//  Logging.swift
//  MSKit
//
//  Created by Jason Cardwell on 9/18/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import CocoaLumberjack


public class LogManager {

  public struct LogFlag: RawOptionSetType {
    public private(set) var rawValue: Int32
    public init(rawValue: Int32) { self.rawValue = rawValue }
    public init(nilLiteral: ()) { rawValue = 0 }
    public static var allZeros: LogFlag { return LogFlag.None }
    public static var None:     LogFlag = LogFlag(rawValue: 0b00000)
    public static var Error:    LogFlag = LogFlag(rawValue: 0b00001)
    public static var Warn:     LogFlag = LogFlag(rawValue: 0b00010)
    public static var Info:     LogFlag = LogFlag(rawValue: 0b00100)
    public static var Debug:    LogFlag = LogFlag(rawValue: 0b01000)
    public static var Verbose:  LogFlag = LogFlag(rawValue: 0b10000)
  }

  public struct LogLevel: RawOptionSetType {
    public private(set) var rawValue: Int32
    public init(rawValue: Int32) { self.rawValue = rawValue }
    public init(flags: LogFlag) { rawValue = flags.rawValue }
    public init(nilLiteral: ()) { rawValue = 0 }
    public static var allZeros: LogLevel { return LogLevel.Off }
    public static var Off:      LogLevel = LogLevel(flags: LogFlag.None)
    public static var Error:    LogLevel = LogLevel(flags: LogFlag.Error)
    public static var Warn:     LogLevel = LogLevel.Error | LogLevel(flags: LogFlag.Warn)
    public static var Info:     LogLevel = LogLevel.Warn  | LogLevel(flags: LogFlag.Info)
    public static var Debug:    LogLevel = LogLevel.Info | LogLevel(flags: LogFlag.Debug)
    public static var Verbose:  LogLevel = LogLevel.Debug | LogLevel(flags: LogFlag.Verbose)
    public static var All:      LogLevel = ~LogLevel.Off
  }



  private struct LogManagerGlobals {

    static var logLevel: LogLevel = .Warn
    static var registeredLogLevels: [String:LogLevel] = [:]

  }

  public class var logLevel: LogLevel { get { return LogManagerGlobals.logLevel } set { LogManagerGlobals.logLevel = newValue } }

  /**
  logLevelForFile:

  :param: file String

  :returns: LogLevel
  */
  public class func logLevelForFile(file: String) -> LogManager.LogLevel {
    return LogManagerGlobals.registeredLogLevels[file] ?? LogManagerGlobals.logLevel
  }

  /**
  setLogLevel:forFile:

  :param: level LogManager.LogLevel
  :param: file String = __FILE__
  */
  public class func setLogLevel(level: LogManager.LogLevel, forFile file: String = __FILE__) {
    LogManagerGlobals.registeredLogLevels[file] = level
  }

}

/**
MSLogMessage:flag:function:line:level:context:

:param: message String
:param: flag LogManager.LogFlag
:param: function String = __FUNCTION__
:param: line Int = __LINE__
:param: context Int32 = LOG_CONTEXT_CONSOLE
*/
public func MSLogMessage(message: String,
                    flag: LogManager.LogFlag,
                function: String = __FUNCTION__,
                    line: Int32 = __LINE__,
                    file: String = __FILE__,
                 context: Int32 = LOG_CONTEXT_CONSOLE)
{
  MSLog.log(false,
      level: LogManager.logLevelForFile(file).rawValue,
       flag: flag.rawValue,
    context: context,
   function: function,
    message: message)
}


/**
MSLogDebug:function:line:level:context:

:param: message String
:param: function String = __FUNCTION__
:param: line Int = __LINE__
:param: context Int32 = LOG_CONTEXT_CONSOLE
*/
public func MSLogDebug(message: String,
              function: String = __FUNCTION__,
                  line: Int32 = __LINE__,
                  file: String = __FILE__,
               context: Int32 = LOG_CONTEXT_CONSOLE)
{
  MSLogMessage(message, .Debug, function: function, file: file, line: line, context: context)
}

/**
MSLogError:function:line:level:context:

:param: message String
:param: function String = __FUNCTION__
:param: line Int = __LINE__
:param: context Int32 = LOG_CONTEXT_CONSOLE
*/
public func MSLogError(message: String,
              function: String = __FUNCTION__,
                  line: Int32 = __LINE__,
                  file: String = __FILE__,
               context: Int32 = LOG_CONTEXT_CONSOLE)
{
  MSLogMessage(message, .Error, function: function, file: file, line: line, context: context)
}

/**
MSLogInfo:function:line:level:context:

:param: message String
:param: function String = __FUNCTION__
:param: line Int = __LINE__
:param: context Int32 = LOG_CONTEXT_CONSOLE
*/
public func MSLogInfo(message: String,
             function: String = __FUNCTION__,
                 line: Int32 = __LINE__,
                 file: String = __FILE__,
              context: Int32 = LOG_CONTEXT_CONSOLE)
{
  MSLogMessage(message, .Info, function: function, file: file, line: line, context: context)
}

/**
MSLogWarn:function:line:level:context:

:param: message String
:param: function String = __FUNCTION__
:param: line Int = __LINE__
:param: context Int32 = LOG_CONTEXT_CONSOLE
*/
public func MSLogWarn(message: String,
             function: String = __FUNCTION__,
                 line: Int32 = __LINE__,
                 file: String = __FILE__,
              context: Int32 = LOG_CONTEXT_CONSOLE)
{
  MSLogMessage(message, .Warn, function: function, file: file, line: line, context: context)
}

/**
MSLogVerbose:function:line:level:context:

:param: message String
:param: function String = __FUNCTION__
:param: line Int = __LINE__
:param: context Int32 = LOG_CONTEXT_CONSOLE
*/
public func MSLogVerbose(message: String,
                function: String = __FUNCTION__,
                    line: Int32 = __LINE__,
                    file: String = __FILE__,
                 context: Int32 = LOG_CONTEXT_CONSOLE)
{
  MSLogMessage(message, .Verbose, function: function, file: file, line: line, context: context)
}

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
MSHandleError:message:function:line:

:param: error NSError?
:param: message String? = nil
:param: function String = __FUNCTION__
:param: line Int = __LINE__

:returns: Bool
*/
public func MSHandleError(error: NSError?,
                  message: String? = nil,
                 function: String = __FUNCTION__,
                     line: Int32 = __LINE__) -> Bool
{
  if error == nil { return false }
  let logMessage = String("-Error- \(message ?? String())\n\(detailedDescriptionForError(error!, depth: 0))")
  MSLogError(logMessage, function: function, line: line)
  return true
}

/**
recursiveDescription<T>:description:subelements:

:param: base [T]
:param: description (T) -> String
:param: subelements (T) -> [T]
*/
public func recursiveDescription<T>(base: [T], level: Int = 0, description: (T) -> String, subelements:(T) -> [T]) -> String {
  var result = ""
  let indent = "\t" * level
  for object in base {
    result += indent + description(object) + "\n"
    for subelement in subelements(object) {
      result += recursiveDescription([subelement], level: level + 1, description, subelements)
    }
  }
  return result
}
