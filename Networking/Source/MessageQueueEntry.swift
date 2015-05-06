//
//  MessageQueueEntry.swift
//  Remote
//
//  Created by Jason Cardwell on 5/05/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit

struct MessageQueueEntry {

  /** `message` as `NSData` */
  var data: NSData? { return message.dataUsingEncoding(NSUTF8StringEncoding) }

  /** The message being sent */
  var message: String

  /** Generalized storage space */
  var userInfo: [NSObject:AnyObject] = [:]

  var completion: ((Bool, String?, NSError?) -> Void)?

  /**
  initWithMessage:completion:

  :param: message String
  :param: completion ((Bool, String, NSError?) -> Void)? = nil
  */
  init(message: String, completion: ((Bool, String?, NSError?) -> Void)? = nil) {
    self.message = message
    self.completion = completion
  }

}