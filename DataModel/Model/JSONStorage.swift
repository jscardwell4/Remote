//
//  JSONStorage.swift
//  Remote
//
//  Created by Jason Cardwell on 4/7/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(JSONStorage)
public final class JSONStorage: ModelObject, ModelStorage {

  private var rawDictionary: OrderedDictionary<String, String> {
    get {
      willAccessValueForKey("dictionary")
      let dictionary = primitiveValueForKey("dictionary") as! MSDictionary
      didAccessValueForKey("dictionary")
      return dictionary as? OrderedDictionary<String, String> ?? [:]
    }
    set {
      willChangeValueForKey("dictionary")
      setPrimitiveValue(newValue as MSDictionary, forKey: "dictionary")
      didChangeValueForKey("dictionary")
    }
  }

  public var dictionary: OrderedDictionary<String, JSONValue> {
    get { return rawDictionary.compressedMap({JSONValue(rawValue: $1)}) }
    set { rawDictionary = newValue.map({$1.rawValue}) }
  }

  public subscript(key: String) -> JSONValue? {
    get { return dictionary[key] }
    set { var d = dictionary; d[key] = newValue; dictionary = d }
  }

  override public var jsonValue: JSONValue {
    return (ObjectJSONValue(super.jsonValue)! + ObjectJSONValue(dictionary)).jsonValue
  }
}

