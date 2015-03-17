//
//  SendIRCommand.swift
//  Remote
//
//  Created by Jason Cardwell on 3/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

/**
  `SendIRCommand` subclasses `Command` to send IR commands via <ConnectionManager> to networked
  IR receivers that control the user's home theater system. At this time, only
  [iTach](http://www.globalcache.com/products/itach) devices from Global Caché are supported.
*/
@objc(SendIRCommand)
class SendIRCommand: SendCommand {

  @NSManaged var portOverride: NSNumber

  @NSManaged var code: IRCode

  var device: ComponentDevice { return code.device }
  var networkDevice: NetworkDevice? { return device.networkDevice }

  var commandString: String {
    return "sendir,1:\(device.port),<tag>,\(code.frequency),\(code.repeatCount),\(code.offset),\(code.onOffPattern)"
  }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    if let codeData = data["code"] as? [String:AnyObject], let moc = managedObjectContext,
      let code = IRCode.fetchOrImportObjectWithData(codeData, context: moc) {
        self.code = code
    }
  }

  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    dictionary["class"] = "sendir"
    dictionary["code.uuid"] = code.uuid
    setIfNotDefault("portOverride", forKey: "port-override", inDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }

}