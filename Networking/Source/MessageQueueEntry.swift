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

  typealias Callback = (Bool, ErrorType?) -> Void

  var messageData: T

  /** The message being sent */
  var message: String { return messageData.msg }

  /** The message being sent as data */
  var data: NSData { return messageData.data }

  /** Generalized storage space */
  var info: [String:Any]

  /** Optional callback to invoke after a corresponding response has been received for the message */
  let completion: Callback?

  /**
  initWithMessageData:info:completion:

  - parameter d: T
  - parameter i: [String:Any]
  - parameter c: Callback? = nil
  */
  init(messageData d: T, info i: [String:Any] = [:], completion c: Callback? = nil) {
    messageData = d
    info = i
    completion = c
  }

}