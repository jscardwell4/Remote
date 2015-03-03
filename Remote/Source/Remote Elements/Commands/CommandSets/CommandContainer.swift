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
class CommandContainer: NamedModelObject {

  @NSManaged var index: MSDictionary
  @NSManaged var buttonGroup: ButtonGroup?

  var count: Int { return index.count }

}