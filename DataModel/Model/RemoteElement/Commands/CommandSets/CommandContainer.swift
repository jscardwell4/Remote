//
//  CommandContainer.swift
//  Remote
//
//  Created by Jason Cardwell on 3/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(CommandContainer)
public class CommandContainer: NamedModelObject {

  var containerIndex: OrderedDictionary<String, NSURL> {
    get {
      willAccessValueForKey("containerIndex")
      let containerIndex = primitiveValueForKey("containerIndex") as! OrderedDictionary<String, NSURL>
      didAccessValueForKey("containerIndex")
      return containerIndex
    }
    set {
      willChangeValueForKey("containerIndex")
      setPrimitiveValue(newValue, forKey: "containerIndex")
      didChangeValueForKey("containerIndex")
    }
  }
  @NSManaged public var buttonGroup: ButtonGroup?

  public var count: Int { return containerIndex.count }

}