//
//  MessageQueueEntry.swift
//  Remote
//
//  Created by Jason Cardwell on 5/05/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit

protocol MessageData {
  var msg: String { get }
  var data: NSData { get }
}


struct MessageQueueEntry<T:MessageData> {

  typealias Callback = ConnectionManager.Callback

  var messageData: T

  /** The message being sent */
  var message: String { return messageData.msg }

  /** The message being sent as data */
  var data: NSData { return messageData.data }

  /** Generalized storage space */
  var userInfo: [NSObject:AnyObject]

  /** Optional callback to invoke after a corresponding response has been received for the message */
  let completion: Callback?

  /**
  initWithMessage:completion:

  - parameter message: String
  - parameter completion: ((Bool, String, NSError?) -> Void)? = nil
  */
  init(messageData: T, userInfo: [NSObject:AnyObject] = [:], completion: Callback? = nil) {
    self.messageData = messageData
    self.userInfo = userInfo
    self.completion = completion
  }

}