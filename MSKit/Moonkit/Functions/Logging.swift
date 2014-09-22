//
//  Logging.swift
//  MSKit
//
//  Created by Jason Cardwell on 9/18/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation

private var globalLogLevel:   Int32 = LOG_LEVEL_DEBUG
private var globalLogContext: Int32 = LOG_CONTEXT_CONSOLE

/**
logMessage:function:level:flag:context:

:param: message String
:param: function String
:param: level Int32
:param: flag Int32
:param: context Int32 = globalLogContext
*/
public func logMessage(message: String, function: String, level: Int32, flag: Int32, context: Int32 = globalLogContext) {
  MSLog.log(false, level: level, flag: flag, context: context, function: function, message: message)
}

/**
logDebug:function:level:

:param: message String
:param: function String
:param: level Int32 = globalLogLevel
*/
public func logDebug (message: String, function: String, level: Int32 = globalLogLevel) {
  logMessage(message, function, level, LOG_FLAG_DEBUG)
}

/**
logError:function:level:

:param: message String
:param: function String
:param: level Int32 = globalLogLevel
*/
public func logError (message: String, function: String, level: Int32 = globalLogLevel) {
  logMessage(message, function, level, LOG_FLAG_ERROR)
}

/**
logWarn:function:level:

:param: message String
:param: function String
:param: level Int32 = globalLogLevel
*/
public func logWarn (message: String, function: String, level: Int32 = globalLogLevel) {
  logMessage(message, function, level, LOG_FLAG_WARN)
}

/**
logInfo:function:level:

:param: message String
:param: function String
:param: level Int32 = globalLogLevel
*/
public func logInfo (message: String, function: String, level: Int32 = globalLogLevel) {
  logMessage(message, function, level, LOG_FLAG_INFO)
}

/**
logVerbose:function:level:

:param: message String
:param: function String
:param: level Int32 = globalLogLevel
*/
public func logVerbose(message: String, function: String, level: Int32 = globalLogLevel) {
  logMessage(message, function, level, LOG_FLAG_VERBOSE)
}

/**
setGlobalLogLevel:

:param: level Int32
*/
public func setGlobalLogLevel(level: Int32) { globalLogLevel = level }

/**
setGlobalLogContext:

:param: context Int32
*/
public func setGlobalLogContext(context: Int32) { globalLogContext = context }
