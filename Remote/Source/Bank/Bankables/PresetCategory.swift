//
//  PresetCategory.swift
//  Remote
//
//  Created by Jason Cardwell on 9/27/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(PresetCategory)
class PresetCategory: NamedModelObject, BankableCategory {

  @NSManaged var subCategories: NSSet?
  @NSManaged var parentCategory: PresetCategory?
  @NSManaged var presets: NSSet?

  var allItems: NSSet? { return presets }

}
