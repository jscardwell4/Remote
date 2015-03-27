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

//public protocol ModelCollection {
//  typealias ItemType: PathIndexedModel
//  var items: [ItemType] { get set }
//  func itemWithIndex(index: PathModelIndex) -> ItemType?
//}

//public protocol NestingModelCollection: ModelCollection {
//   typealias NestedType: PathIndexedModel
//  var subcategories: [NestedType] { get set }
//  func subcategoryWithIndex(index: PathModelIndex) -> NestedType?
//}

//public protocol ModelCollectionItem: EditableModel {
//  typealias CollectionType
//  var collection: CollectionType? { get set }
//}

//public protocol RootedModel: PathIndexedModel {
//  static func itemWithIndex<T:PathIndexedModel>(index: PathModelIndex, context: NSManagedObjectContext) -> T?
//  static func rootItemWithIndex(index: PathModelIndex, context: NSManagedObjectContext) -> Self?
//}

// MARK: - Base editable model classes
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

}

// MARK: - Support functions

/**
findByIndex:idx:

:param: c C
:param: idx String

:returns: C.Generator.Element?
*/
//public func findByIndex<C:CollectionType where C.Generator.Element:PathIndexedModel>(c: C, idx: PathModelIndex) -> C.Generator.Element? {
//  return findFirst(c, {$0.index == idx})
//}

//func indexForItem<T:PathIndexedModel>(model: T) -> ModelIndex { return "\(model.name)" }

/**
itemWithIndex:withRoot:

:param: index ModelIndex
:param: root U

:returns: T?
*/
//public func itemWithIndexFromRoot<T:PathIndexedModel, U:RootedModel
//  where U:NestingModelCollection, U.NestedType == U>(index:PathModelIndex, root: U) -> T?
//{
//  if root.index == index { return root as? T }
//  var i = 2
//  var currentCategory = root
//  while i < index.count - 1 {
//    if let category = currentCategory.subcategoryWithIndex(index[0..<i++]) { currentCategory = category } else { return nil }
//  }
//  if let category = currentCategory.subcategoryWithIndex(index) { return category as? T }
//  if let categoryItem = currentCategory.itemWithIndex(index) { return categoryItem as? T }
//
//  return nil
//}

