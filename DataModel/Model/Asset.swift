//
//  Asset.swift
//  Remote
//
//  Created by Jason Cardwell on 4/11/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(Asset)
public final class Asset: ModelObject {

  @NSManaged public var location: String!
  @NSManaged public var name: String?
  @NSManaged public var images: Set<Image>?

  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    if let location = String(data["location"]) {
      self.location = location
      name = location.lastPathComponent.stringByDeletingPathExtension
    }
    if let name = String(data["name"]) { self.name = name }
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["location"] = location?.jsonValue
    obj["name"] = name?.jsonValue
    return obj.jsonValue
  }
}
