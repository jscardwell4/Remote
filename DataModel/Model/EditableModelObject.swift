//
//  EditableModelObject.swift
//  Remote
//
//  Created by Jason Cardwell on 3/20/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

public class EditableModelObject: NamedModelObject, EditableModel {
  @NSManaged public var user: Bool

  /** save */
  public func save() { if let moc = managedObjectContext { DataManager.saveContext(moc, propagate: true) } }

  /** delete */
  public func delete() {
    if let moc = self.managedObjectContext {
      moc.performBlockAndWait { moc.processPendingChanges(); moc.deleteObject(self) }
      DataManager.saveContext(moc, propagate: true)
    }
  }

  public var editable: Bool { return user }

  /** rollback */
  public func rollback() { if let moc = self.managedObjectContext { moc.performBlockAndWait { moc.rollback() } } }
  
  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    if let user = data["user"] as? NSNumber { self.user = user.boolValue }
  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  override public func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    appendValueForKey("user", toDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()
    
    return dictionary
  }

  override public var description: String { return "\(super.description)\n\tuser = \(user)" }
}
