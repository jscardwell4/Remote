//
//  BankableModelCategory.swift
//  Remote
//
//  Created by Jason Cardwell on 10/2/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MoonKit

class BankableModelCategory: NamedModelObject, BankItemCategory {

  override class func requiresUniqueNaming() -> Bool { return true }

  class func itemType() -> BankableModelObject.Type { return BankableModelObject.self }
  var title: String { return name ?? "" }
  var items: [BankModel] { get { return [] } set {} }
  var subcategories: [BankItemCategory] { get { return [] } set {} }
  var parentCategory: BankItemCategory?

  var totalItemCount: Int { return recursiveItemCountForCategory(self) }

  var previewableItems:   Bool { return self.dynamicType.itemType().conformsToProtocol(Previewable)   }
  var editableItems:      Bool { return true }

  var editable: Bool { return true }


  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override func JSONDictionary() -> MSDictionary { return super.JSONDictionary() }

}
