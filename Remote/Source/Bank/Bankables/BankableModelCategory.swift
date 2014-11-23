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

class BankableModelCategory: NamedModelObject, BankDisplayItemCategory {

  override class func requiresUniqueNaming() -> Bool { return true }

  var title: String { return name ?? "" }
  var items: [BankDisplayItemModel] { get { return [] } set {} }
  var subcategories: [BankDisplayItemCategory] { get { return [] } set {} }
  var parentCategory: BankDisplayItemCategory?

  var previewableItems:   Bool { return BankableModelObject.isPreviewable()   }
  var editableItems:      Bool { return BankableModelObject.isEditable()      }

  var editable: Bool { return true }

}
