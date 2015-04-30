//
//  DictionaryStorage.swift
//  Remote
//
//  Created by Jason Cardwell on 11/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(DictionaryStorage)
public class DictionaryStorage: ModelObject, ModelStorage {

  public var dictionary: OrderedDictionary<String, AnyObject> {
    get {
      willAccessValueForKey("dictionary")
      let dictionary = primitiveValueForKey("dictionary") as! MSDictionary
      didAccessValueForKey("dictionary")
      return dictionary as! OrderedDictionary<String, AnyObject>
    }
    set {
      willChangeValueForKey("dictionary")
      setPrimitiveValue(newValue as MSDictionary, forKey: "dictionary")
      didChangeValueForKey("dictionary")
    }
  }

  public subscript(key: String) -> AnyObject? {
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

