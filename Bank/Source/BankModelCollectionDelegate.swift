//
//  BankModelCollectionDelegate.swift
//  Remote
//
//  Created by Jason Cardwell on 6/29/15.
//  Copyright © 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import DataModel
import MoonKit

final class BankModelCollectionDelegate: BankModelDelegate {

  // MARK: - Properties

  /** Optional collection that may be used to generate `items` and `collections` */
  let collection: BankModelCollection

  /** Whether the collection supports viewing an image representation of its items */
  override var previewable: Bool { return collection.previewable == true }

  // MARK: - Entity-based methods and properties

  /**
  Determines if the provided entities repesent an acceptable collection to item relationship and returns the item's
  property name for the collection relationship if it is.

  - parameter collection: NSEntityDescription
  - parameter item: NSEntityDescription

  - returns: Bool
  */
  private static func propertyForRelationshipPair(collection: NSEntityDescription, _ item: NSEntityDescription) -> String? {
    var collectionToItem = collection.relationshipsWithDestinationEntity(item)
    if collectionToItem.count > 0 {
      var itemToCollection = item.relationshipsWithDestinationEntity(collection)
      if itemToCollection.count > 0 {
        collectionToItem = collectionToItem.filter {$0.toMany == true}
        itemToCollection = itemToCollection.filter {$0.toMany == false}
        let collectionToItemInverted = compressedMap(collectionToItem) {$0.inverseRelationship}
        let itemToCollectionInverted = compressedMap(itemToCollection) {$0.inverseRelationship}
        if collectionToItemInverted.count == collectionToItem.count
          && itemToCollectionInverted.count == itemToCollection.count
        {
          collectionToItem = collectionToItem.filter {itemToCollectionInverted.contains($0)}
          itemToCollection = itemToCollection.filter {collectionToItemInverted.contains($0)}
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

  - parameter entity: NSEntityDescription
  - parameter name: String

  - returns: NSFetchedResultsController
  */
  private func fetchedResultsForEntity(entity: NSEntityDescription,
    withAttributeName name: String) -> NSFetchedResultsController
  {
    let request = NSFetchRequest()
    request.entity = entity
    request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    request.predicate = ∀"\(name).uuid == '\(collection.uuid)'"
    return NSFetchedResultsController(fetchRequest: request,
      managedObjectContext: collection.managedObjectContext!,
      sectionNameKeyPath: nil,
      cacheName: nil)
  }


  // MARK: - Initialization

  /**
  Initialize with an actual collection, collection must have a valid managed object context

  - parameter c: BankModelCollection
  */
  init?(collection c: BankModelCollection) {
    collection = c

    // Check for a valid context before continuing with collection delegate initialization
    if let context = c.managedObjectContext {

      // Get the root type as subclass of the `ModelObject` type
      if let type = c.dynamicType.self as? ModelObject.Type {

        rootType = type
        let rootEntity = rootType.entityDescription

        itemType = collection.itemType as? ModelObject.Type
        if itemType != nil {
          itemToRootAttributeName =
            BankModelCollectionDelegate.propertyForRelationshipPair(rootEntity, itemType!.entityDescription)
        } else { itemToRootAttributeName = nil }

        collectionType = collection.collectionType as? ModelObject.Type
        if collectionType != nil {
          collectionToRootAttributeName =
            BankModelCollectionDelegate.propertyForRelationshipPair(rootEntity, collectionType!.entityDescription)
        } else { collectionToRootAttributeName = nil }

        super.init(name: c.name, context: context)

        itemTransaction = BankModelCollectionDelegate.itemTransactionForCollection(collection)
        collectionTransaction = BankModelCollectionDelegate.collectionTransactionForCollection(collection)

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
        super.init(name: c.name, context: context)
        return nil
      }
    }

      // Without a valid context, initialization fails
    else {
      rootType = ModelObject.self;
      itemType = nil;
      collectionType = nil;
      itemToRootAttributeName = nil;
      collectionToRootAttributeName = nil
      super.init(name: c.name, context: NSManagedObjectContext())
      return nil
    }
  }

  /**
  itemTransactionForCollection:

  - parameter collection: C

  - returns: ItemCreationTransaction?
  */
  private static func itemTransactionForCollection(collection: BankModelCollection) -> ItemCreationTransaction? {

    if let context = collection.managedObjectContext {

      let label = collection.itemLabel ?? "New Item"

      switch collection {

      case let c as FormCreatableItemBankModelCollection:
        return FormTransaction(label: label, form: c.itemCreationForm(context: context)) {
          form in
          let (success, error) = DataManager.saveContext(context) {_ = c.createItemWithForm(form, context: $0)}
          MSHandleError(error)
          return success
        }

      case let c as DiscoverCreatableItemBankModelCollection:
        return DiscoveryTransaction(label: label,
          beginDiscovery: {c.beginItemDiscovery(context: context, presentForm: $0)},
          endDiscovery: {c.endItemDiscovery()})

      case let c as CustomCreatableItemBankModelCollection:
        return CustomTransaction(label: label) {
          didCancel, didCreate -> UIViewController in

          let handler: (ModelObject) -> Void = {
            object in
            let (_, error) = DataManager.saveContext(context)
            MSHandleError(error)
            didCreate(object)
          }
          return c.itemCreationControllerWithContext(context, cancellationHandler: didCancel, creationHandler: handler)
        }

      default: return nil
      }

    } else { return nil }
  }


  /**
  collectionTransactionForCollection:

  - parameter collection: C

  - returns: ItemCreationTransaction?
  */
  private static func collectionTransactionForCollection(collection: BankModelCollection) -> ItemCreationTransaction? {

    if let context = collection.managedObjectContext {

      let label = collection.collectionLabel ?? "New Collection"

      switch collection {

      case let c as FormCreatableCollectionBankModelCollection:
        return FormTransaction(label: label, form: c.collectionCreationForm(context: context)) {
          form in
          let (success, error) = DataManager.saveContext(context) {_ = c.createCollectionWithForm(form, context: $0)}
          MSHandleError(error)
          return success
        }

      case let c as DiscoverCreatableCollectionBankModelCollection:
        return DiscoveryTransaction(label: label,
          beginDiscovery: {c.beginCollectionDiscovery(context: context, presentForm: $0)},
          endDiscovery: {c.endCollectionDiscovery()})

      case let c as CustomCreatableCollectionBankModelCollection:
        return CustomTransaction(label: label) {
          didCancel, didCreate -> UIViewController in

          let handler: (ModelObject) -> Void = {
            object in
            let (_, error) = DataManager.saveContext(context)
            MSHandleError(error)
            didCreate(object)
          }
          return c.collectionCreationControllerWithContext(context,
            cancellationHandler: didCancel,
            creationHandler: handler)
        }

      default: return nil
      }

    } else { return nil }
  }

}
