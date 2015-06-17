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

  public enum StorageType: Int, CustomStringConvertible {
    case Undefined, File, Bundle, Data
    public var description: String {
      switch self {
        case .Undefined: return "Undefined"
        case .File:      return "File"
        case .Bundle:    return "Bundle"
        case .Data:      return "Data"
      }
    }
  }

  public var storageType: StorageType {
    switch (path, name, data) {
      case (_, _, .Some):     return .Data
      case (.Some, .Some, _): return .Bundle
      case (.Some, _, _):     return .File
      default:                return .Undefined
    }
  }

  @NSManaged public var path: String?
  @NSManaged public var name: String?
  @NSManaged public var data: NSData?
  @NSManaged public var images: Set<Image>?

  override public func updateWithData(data: ObjectJSONValue) {
    MSLogDebug("data = \(data)")
    super.updateWithData(data)
    path = String(data["path"])
    name = String(data["name"])
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    switch storageType {
      case .File:   obj["path"] = path?.jsonValue
      case .Bundle: obj["name"] = name?.jsonValue
      default:      break
    }
    return obj.jsonValue
  }
}
