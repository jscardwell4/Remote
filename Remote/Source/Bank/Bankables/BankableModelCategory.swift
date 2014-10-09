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

  var title: String { return name ?? "" }
  var items: [BankDisplayItemModel] { return [] }
  var subcategories: [BankDisplayItemCategory] { return [] }
  var parentCategory: BankDisplayItemCategory? { return nil }

  var thumbnailableItems: Bool { return BankableModelObject.isThumbnailable() }
  var previewableItems:   Bool { return BankableModelObject.isPreviewable()   }
  var detailableItems:    Bool { return BankableModelObject.isDetailable()    }
  var editableItems:      Bool { return BankableModelObject.isEditable()      }

  

}
