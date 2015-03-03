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
class DictionaryStorage: NSManagedObject {

  @NSManaged var primitiveDictionary: NSDictionary
  var dictionary: [NSObject:AnyObject] {
    get {
      willAccessValueForKey("dictionary")
      let dictionary = primitiveDictionary
      didAccessValueForKey("dictionary")
      return dictionary as [NSObject:AnyObject]
    }
    set {
      willChangeValueForKey("dictionary")
      primitiveDictionary = newValue
      didChangeValueForKey("dictionary")
    }
  }

  subscript(key: NSObject) -> AnyObject? {
    get { return dictionary[key] }
    set { var d = dictionary; d[key] = newValue; dictionary = d }
  }
}
