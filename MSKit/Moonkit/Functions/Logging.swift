//
//  Logging.swift
//  MSKit
//
//  Created by Jason Cardwell on 9/18/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation

var ddLogLevel:   Int32 = LOG_LEVEL_DEBUG
var ddLogContext: Int32 = LOG_CONTEXT_CONSOLE

func logMessage(message: String, function: String, level: Int32, flag: Int32) {
  if (ddLogLevel & level) == level {
    MSLog.log(false,
        level: ddLogLevel,
         flag: flag,
      context: ddLogContext,
         file: "",
     function: function,
         line: 0,
          tag: nil,
      message: message)
  }
}

func logDebug  (m: String, f: String) { logMessage(m, f, LOG_LEVEL_DEBUG,   LOG_FLAG_DEBUG)   }
func logError  (m: String, f: String) { logMessage(m, f, LOG_LEVEL_ERROR,   LOG_FLAG_ERROR)   }
func logWarn   (m: String, f: String) { logMessage(m, f, LOG_LEVEL_WARN,    LOG_FLAG_WARN)    }
func logInfo   (m: String, f: String) { logMessage(m, f, LOG_LEVEL_INFO,    LOG_FLAG_INFO)    }
func logVerbose(m: String, f: String) { logMessage(m, f, LOG_LEVEL_VERBOSE, LOG_FLAG_VERBOSE) }

func setLogLevel(level: Int32) { ddLogLevel = level }
