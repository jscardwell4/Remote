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

func logDebug(message: String, file: String, function: String, line: Int) {
  MSLog.log(false,
      level: ddLogLevel,
       flag: LOG_FLAG_DEBUG,
    context: ddLogContext,
       file: file,
   function: function,
       line: Int32(line),
        tag: nil,
    message: message)
}
