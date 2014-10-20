//
//  NamedModelObject.swift
//  Remote
//
//  Created by Jason Cardwell on 10/18/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

extension NamedModelObject {

  /** save */
  func save() {
    let moc = self.managedObjectContext!
    moc.performBlockAndWait {
      moc.processPendingChanges()
      var error: NSError?
      moc.save(&error)
      MSHandleError(error, message: "save failed for '\(self.name)'")
    }
  }

  /** delete */
  func delete() {
    let moc = self.managedObjectContext!
    moc.performBlockAndWait { () -> Void in
      moc.deleteObject(self)
    }
    save()
  }

  /** rollback */
  func rollback() {
    let moc = self.managedObjectContext!
    moc.performBlockAndWait {
      moc.processPendingChanges()
      moc.rollback()
    }
  }

}