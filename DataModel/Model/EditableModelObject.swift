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

// MARK: - Model related protocols
// MARK: EditableModel
@objc protocol EditableModel: NamedModel {
  var user: Bool { get }
  func save()
  func delete()
  func rollback()
}

// MARK: ModelCategory
protocol ModelCategory {
  typealias ItemType: IndexedEditableModel
  var items: [ItemType] { get set }
  func itemWithIndex(index: ModelIndex) -> ItemType?
}

// MARK: NestingModelCategory
protocol NestingModelCategory: ModelCategory {
  typealias NestedType: IndexedEditableModel
  var subcategories: [NestedType] { get set }
  func subcategoryWithIndex(index: ModelIndex) -> NestedType?
}

// MARK: ModelCategoryItem
protocol ModelCategoryItem: EditableModel { typealias CategoryType; var category: CategoryType? { get set } }

// MARK: RootedEditableModel
protocol RootedEditableModel: IndexedEditableModel {
  static func itemWithIndex<T:IndexedEditableModel>(index: ModelIndex, context: NSManagedObjectContext) -> T?
  static func rootItemWithIndex(index: ModelIndex, context: NSManagedObjectContext) -> Self?
}

// MARK: - Base editable model classes
class EditableModelObject: NamedModelObject, EditableModel {
  @NSManaged var user: Bool

  /** save */
  func save() { if let moc = managedObjectContext { DataManager.saveContext(moc, propagate: true) } }

  /** delete */
  func delete() {
    if let moc = self.managedObjectContext {
      moc.performBlockAndWait { moc.processPendingChanges(); moc.deleteObject(self) }
      DataManager.saveContext(moc, propagate: true)
    }
  }

  var editable: Bool { return true }

  /** rollback */
  func rollback() { if let moc = self.managedObjectContext { moc.performBlockAndWait { moc.rollback() } } }
  
  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    if let user = data["user"] as? NSNumber { self.user = user.boolValue }
  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    appendValueForKey("user", toDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()
    
    return dictionary
  }

}

protocol IndexedEditableModel: EditableModel {
  var index: ModelIndex { get }
  static func modelWithIndex(index: ModelIndex, context: NSManagedObjectContext) -> Self?
}

class IndexedEditableModelObject: EditableModelObject, IndexedEditableModel {
  
  var index: ModelIndex { return ModelIndex(name) }

  /**
  modelWithIndex:context:

  :param: index ModelIndex
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  class func modelWithIndex(index: ModelIndex, context: NSManagedObjectContext) -> Self? {
    return objectWithValue(index.rawValue, forAttribute: "name", context: context)
  }
}

// MARK: - Support functions

/**
findByIndex:idx:

:param: c C
:param: idx String

:returns: C.Generator.Element?
*/
func findByIndex<C:CollectionType where C.Generator.Element:IndexedEditableModel>(c: C, idx: ModelIndex) -> C.Generator.Element? {
  return findFirst(c, {$0.index == idx})
}

//func indexForItem<T:IndexedEditableModel>(model: T) -> ModelIndex { return "\(model.name)" }

/**
itemWithIndex:withRoot:

:param: index ModelIndex
:param: root U

:returns: T?
*/
func itemWithIndexFromRoot<T:IndexedEditableModel, U:RootedEditableModel
  where U:NestingModelCategory, U.NestedType == U>(index: ModelIndex, root: U) -> T?
{
  if root.index == index { return root as? T }
  var i = 2
  var currentCategory = root
  while i < index.count - 1 {
    if let category = currentCategory.subcategoryWithIndex(index[0..<i++]) { currentCategory = category } else { return nil }
  }
  if let category = currentCategory.subcategoryWithIndex(index) { return category as? T }
  if let categoryItem = currentCategory.itemWithIndex(index) { return categoryItem as? T }

  return nil
}

