//
//  SendCommand.swift
//  Remote
//
//  Created by Jason Cardwell on 3/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(SendCommand)
class SendCommand: Command {
  override var operation: CommandOperation {
    return SendCommandOperation(command: self)
  }
}