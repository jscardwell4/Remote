//
//  IRCodeSet.swift
//  Remote
//
//  Created by Jason Cardwell on 9/27/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(IRCodeSet)
class IRCodeSet: NamedModelObject, BankableCategory {

  @NSManaged var codes: NSSet?
  @NSManaged var manufacturer: Manufacturer?

  var allItems: NSSet? { return codes }

}
