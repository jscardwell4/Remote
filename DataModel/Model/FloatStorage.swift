//
//  FloatStorage.swift
//  Remote
//
//  Created by Jason Cardwell on 4/10/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(FloatStorage)
public final class FloatStorage: ModelObject, ModelStorage {

  public var dictionary: OrderedDictionary<String, Float> {
    get {
      willAccessValueForKey("dictionary")
      let dictionary = primitiveValueForKey("dictionary") as! MSDictionary
      didAccessValueForKey("dictionary")
      return dictionary as! OrderedDictionary<String, Float>
    }
    set {
      willChangeValueForKey("dictionary")
      setPrimitiveValue(newValue as MSDictionary, forKey: "dictionary")
      didChangeValueForKey("dictionary")
    }
  }

  public subscript(key: String) -> Float? {
    get { return dictionary[key] }
    set { var d = dictionary; d[key] = newValue; dictionary = d }
  }

  override public var jsonValue: JSONValue {
    if let superValue = ObjectJSONValue(super.jsonValue),
      value = ObjectJSONValue(JSONValue(dictionary))
    {
      return .Object(superValue.value + value.value)
    } else { return .Null }
  }

}
