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

  class func isThumbnailable() -> Bool { return false }
  class func isEditable() -> Bool { return false }
  class func isPreviewable() -> Bool { return false }
  class func isDetailable() -> Bool { return false }
  class func label() -> String? { return nil }
  class func icon() -> UIImage? { return nil }

  var items: [BankableModelObject] { return [] }
  var subcategories: [BankDisplayItemCategory] { return [] }
  var parentCategory: BankDisplayItemCategory? { return nil }
}