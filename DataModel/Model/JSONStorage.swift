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
public final class JSONStorage: ModelObject {

  public var rawDictionary: OrderedDictionary<String, String> {
    get {
      willAccessValueForKey("dictionary")
      let dictionary = primitiveValueForKey("dictionary") as! MSDictionary
      didAccessValueForKey("dictionary")
      return dictionary as! OrderedDictionary<String, String>
    }
    set {
      willChangeValueForKey("dictionary")
      setPrimitiveValue(MSDictionary(newValue), forKey: "dictionary")
      didChangeValueForKey("dictionary")
    }
  }

//  public subscript(key: String) -> AnyObject? {
//    get { return dictionary[key] }
//    set {
//      var d = dictionary
//      d[key] = newValue
//      dictionary = d
//    }
//  }

//  override public var jsonValue: JSONValue {
//    if let superValue = ObjectJSONValue(super.jsonValue),
//      value = ObjectJSONValue(JSONValue(dictionary))
//    {
//      return .Object(superValue.value + value.value)
//    } else { return .Null }
//  }
}

