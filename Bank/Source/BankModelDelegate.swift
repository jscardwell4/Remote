//
//  BankModelDelegate.swift
//  Remote
//
//  Created by Jason Cardwell on 5/15/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
import Foundation
import CoreData
import DataModel
import MoonKit


@objc class BankModelDelegate {

  typealias CreateAction = (FormViewController.FieldValues) -> Void
  typealias Fields = FormViewController.FieldCollection
  typealias CreateTransaction = (label: String, fields: Fields, action: CreateAction)

  /**
  Generates a `CreateTransaction` given a label, a `FormCreation` type, and a managed object context

  :param: label String
  :param: creatableType T.Type
  :param: context NSManagedObjectContext

  :returns: CreateTransaction
  */
  class func createTransactionWithLabel<T:FormCreatable>(label: String,
                                           creatableType: T.Type,
                                                 context: NSManagedObjectContext) -> CreateTransaction
  {
    return (label: label, fields: creatableType.formFields(context: context), action: {
      if let _ = creatableType.createWithFormValues($0, context: context) {
        DataManager.saveContext(context, propagate: true) {
          if !$0 { MSHandleError($1, message: "failed to save new manufacturer") }
        }
      }
    })
  }

  /**
  Initalize with name, icon and context expecting to have `fetchedItems` and/or `fetchedCollections` set at some point

  :param: n String
  :param: i UIImage?
  :param: context NSManagedObjectContext
  */
  init(name n: String, icon i: UIImage?, context: NSManagedObjectContext) {
    name = n
    icon = i
    managedObjectContext = context
  }

  var itemsDidChange: ((BankModelDelegate) -> Void)?
  var collectionsDidChange: ((BankModelDelegate) -> Void)?

  var createItem: CreateTransaction?
  var createCollection: CreateTransaction?

  /** The context used for core data fetches */
  let managedObjectContext: NSManagedObjectContext

  /** A name that may be used as a label or title for the collection */
  let name: String

  /** Optional image that may be used to represent the collection */
  let icon: UIImage?

  /**
  Sets the `fetchedItems` results controller

  :param: fetchedItems NSFetchedResultsController
  */
  func setFetchedItems(fetchedItems: NSFetchedResultsController) {
    if let managedObjectClassName = fetchedItems.fetchRequest.entity?.managedObjectClassName,
      managedObjectClass = NSClassFromString(managedObjectClassName) as? NSManagedObject.Type
      where managedObjectClass.conformsToProtocol(NamedModel.self)
    {
      fetchedItems.delegate = self
      self.fetchedItems = fetchedItems
    }
  }

  /** The results controller that provides the objects for the `items` array */
  private var fetchedItems: NSFetchedResultsController? {
    didSet {
      fetchedItems?.delegate = self
      var error: NSError?
      fetchedItems?.performFetch(&error)
      MSHandleError(error)
    }
  }

  /** The items belonging to this collection */
  var items: [NamedModel] { return fetchedItems?.fetchedObjects as? [NamedModel] ?? [] }

  /**
  Sets the `fetchedCollections` results controller

  :param: fetchedCollections NSFetchedResultsController
  */
  func setFetchedCollections(fetchedCollections: NSFetchedResultsController) {
    if let managedObjectClassName = fetchedCollections.fetchRequest.entity?.managedObjectClassName,
      managedObjectClass = NSClassFromString(managedObjectClassName) as? NSManagedObject.Type
      where managedObjectClass.conformsToProtocol(ModelCollection.self)
    {
      fetchedCollections.delegate = self
      self.fetchedCollections = fetchedCollections
    }
  }

  /** The results controller that provides objects for the `collections` array */
  private var fetchedCollections: NSFetchedResultsController? {
    didSet {
      fetchedCollections?.delegate = self
      var error: NSError?
      fetchedCollections?.performFetch(&error)
      MSHandleError(error)
    }
  }

  /** The child collections belonging to this collection */
  var collections: [ModelCollection] { return fetchedCollections?.fetchedObjects as? [ModelCollection] ?? [] }

  /** Whether the collection supports viewing an image representation of its items */
  var previewable: Bool { return false }

}

extension BankModelDelegate: Printable {

  var description: String {
    var result = "BankModelCollectionDelegate:\n"
    result += "\tlabel = \(toString(name))\n"
    result += "\ticon = \(toString(icon))\n"
    result += "\tcollections = "
    let collections = self.collections
    if collections.count == 0 { result += "[]\n" }
    else { result += "{\n" + "\n\n".join(collections.map({toString($0)})).indentedBy(8) + "\n\t}\n" }
    result += "items = "
    let items = self.items
    if items.count == 0 { result += "[]\n" }
    else { result += "{\n" + "\n\n".join(items.map({toString($0)})).indentedBy(8) + "\n\t}\n" }
    return result
  }

}

extension BankModelDelegate: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    if controller === fetchedItems { itemsDidChange?(self) }
    else if controller === fetchedCollections { collectionsDidChange?(self) }
  }
}

final class BankModelCollectionDelegate<C:BankModelCollection>: BankModelDelegate {

  /** Optional collection that may be used to generate `items` and `collections` */
  let collection: C

  /** Whether the collection supports viewing an image representation of its items */
  override var previewable: Bool { return collection.previewable == true }

  override func setFetchedCollections(fetchedCollections: NSFetchedResultsController) {}
  override func setFetchedItems(fetchedItems: NSFetchedResultsController) {}

  /**
  Determines if the provided entities repesent an acceptable collection to item relationship and returns the item's
  property name for the collection relationship if it is.

  :param: collection NSEntityDescription
  :param: item NSEntityDescription

  :returns: Bool
  */
  private static func propertyForRelationshipPair(collection: NSEntityDescription, _ item: NSEntityDescription) -> String? {
    if var collectionToItem = collection.relationshipsWithDestinationEntity(item) as? [NSRelationshipDescription]
      where collectionToItem.count > 0,
      var itemToCollection = item.relationshipsWithDestinationEntity(collection) as? [NSRelationshipDescription]
      where itemToCollection.count > 0
    {
      collectionToItem = collectionToItem.filter {$0.toMany == true}
      itemToCollection = itemToCollection.filter {$0.toMany == false}
      let collectionToItemInverted = compressedMap(collectionToItem) {$0.inverseRelationship}
      let itemToCollectionInverted = compressedMap(itemToCollection) {$0.inverseRelationship}
      if collectionToItemInverted.count == collectionToItem.count && itemToCollectionInverted.count == itemToCollection.count {
        collectionToItem = collectionToItem.filter {contains(itemToCollectionInverted, $0)}
        itemToCollection = itemToCollection.filter {contains(collectionToItemInverted, $0)}
        if let collectionRelationship = collectionToItem.first where collectionToItem.count == 1,
          let itemRelationship = itemToCollection.first where itemToCollection.count == 1,
          let collectionInverseRelationship = collectionRelationship.inverseRelationship
          where collectionInverseRelationship == itemRelationship,
          let itemInverseRelationship = itemRelationship.inverseRelationship
          where itemInverseRelationship == collectionRelationship
        {
          return collectionInverseRelationship.name
        }
      }
    }

    return nil
  }

  let rootType: ModelObject.Type
  let itemType: ModelObject.Type?
  let collectionType: ModelObject.Type?

  let itemToRootAttributeName: String?
  let collectionToRootAttributeName: String?

  /**
  Creates a fetched results controller, assuming collection has been set and has a valid managed object context

  :param: entity NSEntityDescription
  :param: name String

  :returns: NSFetchedResultsController
  */
  private func fetchedResultsForEntity(entity: NSEntityDescription, withAttributeName name: String) -> NSFetchedResultsController {
    let request = NSFetchRequest()
    request.entity = entity
    request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    request.predicate = ∀"\(name).uuid == '\(collection.uuid)'"
    return NSFetchedResultsController(fetchRequest: request,
                                      managedObjectContext: collection.managedObjectContext!,
                                      sectionNameKeyPath: nil,
                                      cacheName: nil)
  }


  /**
  Initialize with an actual collection, collection must have a valid managed object context

  :param: c BankModelCollection
  */
  init?(collection c: C) {
    collection = c

    // Check for a valid context before continuing with collection delegate initialization
    if let context = c.managedObjectContext {

      // Get the root type as subclass of the `ModelObject` type
      if let type = c.dynamicType.self as? ModelObject.Type {

        rootType = type
        let rootEntity = rootType.entityDescription

        itemType = collection.itemType as? ModelObject.Type
        if itemType != nil {
          itemToRootAttributeName = BankModelCollectionDelegate.propertyForRelationshipPair(rootEntity, itemType!.entityDescription)
        } else { itemToRootAttributeName = nil }

        collectionType = collection.collectionType as? ModelObject.Type
        if collectionType != nil {
          collectionToRootAttributeName = BankModelCollectionDelegate.propertyForRelationshipPair(rootEntity, collectionType!.entityDescription)
        } else { collectionToRootAttributeName = nil }

        super.init(name: c.name, icon: nil, context: context)

        if let entity = itemType?.entityDescription, name = itemToRootAttributeName {
          fetchedItems = fetchedResultsForEntity(entity, withAttributeName: name)
        }

        if let entity = collectionType?.entityDescription, name = collectionToRootAttributeName {
          fetchedCollections = fetchedResultsForEntity(entity, withAttributeName: name)
        }
      }

      // Otherwise bug out
      else {
        rootType = ModelObject.self
        itemType = nil
        collectionType = nil
        itemToRootAttributeName = nil
        collectionToRootAttributeName = nil
        super.init(name: c.name, icon: nil, context: context)
        return nil
      }
    }

    // Without a valid context, initialization fails
    else {
      rootType = ModelObject.self; itemType = nil; collectionType = nil; itemToRootAttributeName = nil; collectionToRootAttributeName = nil
      super.init(name: c.name, icon: nil, context: NSManagedObjectContext())
      return nil
    }
  }


}



















