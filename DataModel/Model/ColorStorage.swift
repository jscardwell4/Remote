//
//  ColorStorage.swift
//  Remote
//
//  Created by Jason Cardwell on 4/10/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(ColorStorage)
public final class ColorStorage: ModelObject, ModelStorage {

  public var dictionary: OrderedDictionary<String, UIColor> {
    get {
      willAccessValueForKey("dictionary")
      let dictionary = primitiveValueForKey("dictionary") as! MSDictionary
      didAccessValueForKey("dictionary")
      return dictionary as! OrderedDictionary<String, UIColor>
    }
    set {
      willChangeValueForKey("dictionary")
      setPrimitiveValue(newValue as MSDictionary, forKey: "dictionary")
      didChangeValueForKey("dictionary")
    }
  }

  public subscript(key: String) -> UIColor? {
    get { return dictionary[key] }
    set { var d = dictionary; d[key] = newValue; dictionary = d }
  }

  override public var jsonValue: JSONValue {
    return (ObjectJSONValue(super.jsonValue)! + ObjectJSONValue(dictionary)).jsonValue
  }

}
