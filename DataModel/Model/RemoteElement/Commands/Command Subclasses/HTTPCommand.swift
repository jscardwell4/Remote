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
    var dict = super.jsonValue.value as! JSONValue.ObjectValue

    dict["class"] = "http"
    dict["url"] = JSONValue(url.absoluteString)
    return .Object(dict)
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