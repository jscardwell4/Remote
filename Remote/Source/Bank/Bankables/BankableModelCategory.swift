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

  var previewableItems:   Bool { return BankableModelObject.isPreviewable()   }
  var editableItems:      Bool { return BankableModelObject.isEditable()      }

  func save() {
    managedObjectContext?.performBlockAndWait {
      self.managedObjectContext!.processPendingChanges()
      var error: NSError?
      self.managedObjectContext!.save(&error)
      MSHandleError(error, message: "save failed for '\(self.name)'")
    }
  }

  func delete() { managedObjectContext?.deleteObject(self) }

  func rollback() {
    managedObjectContext?.performBlockAndWait {
      self.managedObjectContext!.processPendingChanges()
      self.managedObjectContext!.rollback()
    }
  }

}
