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

public class EditableModelObject: IndexedModelObject, EditableModel {
  @NSManaged public var user: Bool

  /** save */
  public func save() {
    guard let moc = managedObjectContext else { return }
    do { try DataManager.saveContext(moc, options: [.Propagating]) } catch { logError(error) }
  }

  /** delete */
  public func delete() {
    guard let moc = managedObjectContext else { return }
    do { try DataManager.saveContext(moc, withBlock: {$0.deleteObject(self)}) } catch { logError(error) }
  }

  // TODO: Returning true for all Editable model objects, this should not be the case when shipping app
  public var editable: Bool { return true } //user }

  /** rollback */
  public func rollback() { guard let moc = managedObjectContext else { return }; moc.performBlockAndWait { moc.rollback() } }
  
  /**
  updateWithData:

  - parameter data: ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    if let user = Bool(data["user"]) { self.user = user }
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["user"] = user.jsonValue
    return obj.jsonValue
  }

  override public var description: String { return "\(super.description)\n\tuser = \(user)" }
}
