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
public final class SendIRCommand: SendCommand {

  @NSManaged public var portOverride: NSNumber

  @NSManaged public var code: IRCode

  public var componentDevice: ComponentDevice { return code.device }
  public var networkDevice: NetworkDevice? { return componentDevice.networkDevice }

  public var commandString: String {
    return "sendir,1:\(componentDevice.port),<tag>,\(code.frequency),\(code.repeatCount),\(code.offset),\(code.onOffPattern)"
  }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    
//    updateRelationshipFromData(data, forKey: "code")
//    if let codeData = data["code"] as? [String:AnyObject] {
//      println("codeData: \(codeData)")
//      if let rawCodeIndex = codeData["index"] as? String, codeIndex = PathIndex(rawValue: rawCodeIndex) {
//        println("codeIndex: \(codeIndex.rawValue)")
//        if let moc = managedObjectContext, code = IRCode.modelWithIndex(codeIndex, context: moc) {
//          println("code: \(code)")
//          self.code = code
//        }
//      }
//    }
    if let code: IRCode = relatedObjectWithData(data, forKey: "code") {
//      println(code)
      self.code = code
    }
  }

  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override public func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    dictionary["class"] = "sendir"
    dictionary["code.uuid"] = code.uuid
    appendValueForKey("portOverride", toDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }

}