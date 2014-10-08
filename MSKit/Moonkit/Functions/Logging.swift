//
//  Logging.swift
//  MSKit
//
//  Created by Jason Cardwell on 9/18/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import Lumberjack

/**
MSLogMessage:flag:function:line:level:context:

:param: message String
:param: flag Int32
:param: function String = __FUNCTION__
:param: line Int = __LINE__
:param: level Int32 = msLogLevel
:param: context Int32 = LOG_CONTEXT_DEFAULT
*/
public func MSLogMessage(message: String,
                    flag: Int32,
                function: String = __FUNCTION__,
                    line: Int32 = __LINE__,
                   level: Int32 = LOG_LEVEL_DEBUG,
                 context: Int32 = LOG_CONTEXT_DEFAULT)
{
  MSLog.log(false, level: level, flag: flag, context: context, function: function, message: message)
}

/**
MSLogDebug:function:line:level:context:

:param: message String
:param: function String = __FUNCTION__
:param: line Int = __LINE__
:param: level Int32 = msLogLevel
:param: context Int32 = LOG_CONTEXT_DEFAULT
*/
public func MSLogDebug(message: String,
              function: String = __FUNCTION__,
                  line: Int32 = __LINE__,
                 level: Int32 = LOG_LEVEL_DEBUG,
               context: Int32 = LOG_CONTEXT_DEFAULT)
{
  MSLogMessage(message, LOG_FLAG_DEBUG, function: function, line: line, level: level, context: context)
}

/**
MSLogError:function:line:level:context:

:param: message String
:param: function String = __FUNCTION__
:param: line Int = __LINE__
:param: level Int32 = msLogLevel
:param: context Int32 = LOG_CONTEXT_DEFAULT
*/
public func MSLogError(message: String,
              function: String = __FUNCTION__,
                  line: Int32 = __LINE__,
                 level: Int32 = LOG_LEVEL_DEBUG,
               context: Int32 = LOG_CONTEXT_DEFAULT)
{
  MSLogMessage(message, LOG_FLAG_ERROR, function: function, line: line, level: level, context: context)
}

/**
MSLogInfo:function:line:level:context:

:param: message String
:param: function String = __FUNCTION__
:param: line Int = __LINE__
:param: level Int32 = msLogLevel
:param: context Int32 = LOG_CONTEXT_DEFAULT
*/
public func MSLogInfo(message: String,
             function: String = __FUNCTION__,
                 line: Int32 = __LINE__,
                level: Int32 = LOG_LEVEL_DEBUG,
              context: Int32 = LOG_CONTEXT_DEFAULT)
{
  MSLogMessage(message, LOG_FLAG_INFO, function: function, line: line, level: level, context: context)
}

/**
MSLogWarn:function:line:level:context:

:param: message String
:param: function String = __FUNCTION__
:param: line Int = __LINE__
:param: level Int32 = msLogLevel
:param: context Int32 = LOG_CONTEXT_DEFAULT
*/
public func MSLogWarn(message: String,
             function: String = __FUNCTION__,
                 line: Int32 = __LINE__,
                level: Int32 = LOG_LEVEL_DEBUG,
              context: Int32 = LOG_CONTEXT_DEFAULT)
{
  MSLogMessage(message, LOG_FLAG_WARN, function: function, line: line, level: level, context: context)
}

/**
MSLogVerbose:function:line:level:context:

:param: message String
:param: function String = __FUNCTION__
:param: line Int = __LINE__
:param: level Int32 = msLogLevel
:param: context Int32 = LOG_CONTEXT_DEFAULT
*/
public func MSLogVerbose(message: String,
                function: String = __FUNCTION__,
                    line: Int32 = __LINE__,
                   level: Int32 = LOG_LEVEL_DEBUG,
                 context: Int32 = LOG_CONTEXT_DEFAULT)
{
  MSLogMessage(message, LOG_FLAG_VERBOSE, function: function, line: line, level: level, context: context)
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
