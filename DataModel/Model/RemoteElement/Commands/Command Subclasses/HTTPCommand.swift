//
//  HTTPCommand.swift
//  Remote
//
//  Created by Jason Cardwell on 3/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

/**
  `HTTPCommand` subclasses `Command` to send a one way http request. Currently this can be use with
  a networked device that receives commands via a server that parses url parameters such as Insteon
  SmartLinc (http://www.insteon.net/2412N-smartlinc-central-controller.html) controllers.
*/
@objc(HTTPCommand)
public final class HTTPCommand: SendCommand {

  /** The url for the http request sent by `ConnectionManager`. */
  @NSManaged public var url: NSURL

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["url"] = url.absoluteString?.jsonValue
    return obj.jsonValue
  }

  override public var description: String {
    var result = super.description
    result += "\n\turl = \(toString(url.absoluteString))"
    return result
  }

  /**
  updateWithData:

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    if let urlString = String(data["url"]), url = NSURL(string: urlString) { self.url = url }
  }

}