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
class HTTPCommand: SendCommand {

  /** The url for the http request sent by `ConnectionManager`. */
  @NSManaged var url: NSURL

  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    dictionary["class"] = "http"
    safeSetValue(url.absoluteString, forKey: "url", inDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }

  /**
  updateWithData:

  :param: data [NSObject:AnyObject]!
  */
  override func updateWithData(data: [NSObject:AnyObject]!) {
    super.updateWithData(data)
    if let urlString = data["url"] as? String,
      let url = NSURL(string: urlString) {
        self.url = url
    }
  }

}