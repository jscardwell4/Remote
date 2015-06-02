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

  struct CustomTransaction: BankItemCreationControllerTransaction {
    let label: String
    let controller: CustomController
  }

  struct DiscoveryTransaction: BankItemCreationControllerTransaction {
    let label: String
    let beginDiscovery: ((Form, ProcessedForm) -> Void) -> Void
    let endDiscovery: () -> Void
  }

  struct CreationTransaction: BankItemCreationControllerTransaction {
    let label: String
    let form: Form
    let processedForm: ProcessedForm
  }

  typealias CustomController = (didCancel: () -> Void, didCreate: (ModelObject) -> Void) -> UIViewController
  typealias BeginEndChangeCallback = (BankModelDelegate) -> Void
  typealias ChangeCallback = (BankModelDelegate, Change) -> Void

  // MARK: - Transactions

  var itemTransaction: BankItemCreationControllerTransaction?
  var collectionTransaction: BankItemCreationControllerTransaction?

  /**
  Generates a `CreateTransaction` given a label, a `FormCreatable` type, and a managed object context

  :param: label String
  :param: creatableType T.Type
  :param: context NSManagedObjectContext

  :returns: CreateTransaction
  */
  class func createTransactionWithLabel<T:FormCreatable>(label: String,
                                              creatableType: T.Type,
                                              context: NSManagedObjectContext) -> CreationTransaction
  {
    return CreationTransaction(label: label, form: creatableType.creationForm(context: context)) {
      form in
        let (success, error) = DataManager.saveContext(context) {_ = creatableType.createWithForm(form, context: $0)}
        MSHandleError(error, message: "failed to save new \(toString(creatableType))")
        return success
    }
  }

  /**
  Generates a `DiscoverTransaction` given a label, a `DiscoverCreatable` type, and a managed object context

  :param: label String
  :param: discoverableType T.Type
  :param: context NSManagedObjectContext

  :returns: DiscoverTransaction
  */
  class func discoverTransactionWithLabel<T:DiscoverCreatable>(label: String,
                                              discoverableType: T.Type,
                                                       context: NSManagedObjectContext) -> DiscoveryTransaction
  {
    let beginDiscovery: ((Form, ProcessedForm) -> Void) -> Void = {
      discoverableType.beginDiscovery(context: context, presentForm: $0)
    }
    let endDiscovery: () -> Void = {discoverableType.endDiscovery()}
    return DiscoveryTransaction(label: label, beginDiscovery: beginDiscovery, endDiscovery: endDiscovery)
  }

  /**
  Generates a `CustomTransaction` given a `CustomCreatable` type, a label, and a managed object context

  :param: label String
  :param: customType T.Type
  :param: context NSManagedObjectContext

  :returns: CustomTransaction
  */
  class func customTransactionWithLabel<T:CustomCreatable>(label: String,
                                                customType: T.Type,
                                                   context: NSManagedObjectContext) -> CustomTransaction
  {
    return CustomTransaction(label: label) {
      didCancel, didCreate -> UIViewController in
      let handler: (ModelObject) -> Void = {
        object in
          let (_, error) = DataManager.saveContext(context)
          MSHandleError(error)
          didCreate(object)
      }
      return customType.creationControllerWithContext(context, cancellationHandler: didCancel, creationHandler: handler)

    }
  }

  // MARK: - Initialization

  /**
  Initalize with name, icon and context expecting to have `fetchedItems` and/or `fetchedCollections` set at some point

  :param: n String
  :param: i UIImage?
  :param: context NSManagedObjectContext
  */
  init(name n: String, context: NSManagedObjectContext) { name = n; managedObjectContext = context }

  // MARK: - Root collection support

  /** A name that may be used as a label or title for the collection */
  let name: String

  /** Whether the collection supports viewing an image representation of its items */
  var previewable: Bool { return false }

  // MARK: - Callbacks
  typealias Change = (type: NSFetchedResultsChangeType, indexPath: NSIndexPath?, newIndexPath: NSIndexPath?)

  var beginItemsChanges: BeginEndChangeCallback?
  var endItemsChanges: BeginEndChangeCallback?
  var itemsDidChange: ChangeCallback?

  var beginCollectionsChanges: BeginEndChangeCallback?
  var endCollectionsChanges: BeginEndChangeCallback?
  var collectionsDidChange: ChangeCallback?

  // MARK: - Managed object context

  /** The context used for core data fetches */
  let managedObjectContext: NSManagedObjectContext


  // MARK: - Retrieve by index path

  /**
  Return model corresponding to the specified index path

  :param: indexPath NSIndexPath

  :returns: NamedModel?
  */
  func modelAtIndexPath(indexPath: NSIndexPath) -> NamedModel? {
    switch indexPath.section {
      case 0:  return collectionAtIndex(indexPath.row)
      case 1:  return itemAtIndex(indexPath.row)
      default: return nil
    }
  }

  // MARK: - Items collection

  var numberOfItems: Int { return (fetchedItems?.sections?[0] as? NSFetchedResultsSectionInfo)?.numberOfObjects ?? 0 }

  /**
  itemAtIndex:

  :param: index Int

  :returns: NamedModel?
  */
  func itemAtIndex(index: Int) -> NamedModel? {
    return fetchedItems?.objectAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? NamedModel
  }

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

  // MARK: - Collections collection

  var numberOfCollections: Int {
    return (fetchedCollections?.sections?[0] as? NSFetchedResultsSectionInfo)?.numberOfObjects ?? 0
  }

  /**
  collectionAtIndex:

  :param: index Int

  :returns: ModelCollection
  */
  func collectionAtIndex(index: Int) -> ModelCollection? {
    return fetchedCollections?.objectAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? ModelCollection
  }

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

}

// MARK: - Descriptions

extension BankModelDelegate: Printable {

  var description: String {
    var result = "BankModelCollectionDelegate:\n"
    result += "\tlabel = \(toString(name))\n"
    result += "\tcollections = "
    let collections = (fetchedCollections?.fetchedObjects as? [ModelCollection]) ?? []
    if collections.count == 0 { result += "[]\n" }
    else { result += "{\n" + "\n\n".join(collections.map({toString($0)})).indentedBy(8) + "\n\t}\n" }
    result += "items = "
    let items = (fetchedItems?.fetchedObjects as? [NamedModel]) ?? []
    if items.count == 0 { result += "[]\n" }
    else { result += "{\n" + "\n\n".join(items.map({toString($0)})).indentedBy(8) + "\n\t}\n" }
    return result
  }

}

// MARK: - NSFetchedResultsControllerDelegate methods

extension BankModelDelegate: NSFetchedResultsControllerDelegate {

  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    MSLogDebug("")
    if controller === fetchedItems { beginItemsChanges?(self) }
    else if controller === fetchedCollections { beginCollectionsChanges?(self) }
  }

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    MSLogDebug("")
    if controller === fetchedItems { endItemsChanges?(self) }
    else if controller === fetchedCollections { endCollectionsChanges?(self) }
  }

  func controller(controller: NSFetchedResultsController,
  didChangeObject anObject: AnyObject,
      atIndexPath indexPath: NSIndexPath?,
    forChangeType type: NSFetchedResultsChangeType,
    newIndexPath: NSIndexPath?)
  {
    let change: Change = (type: type, indexPath: indexPath, newIndexPath: newIndexPath)
    if controller === fetchedItems { itemsDidChange?(self, change) }
    else if controller === fetchedCollections { collectionsDidChange?(self, change) }

    MSLogDebug(",".join("object = \((anObject as! NamedModel).name)",
                        "indexPath = \(toString(indexPath)), type = \(type)",
                        "newIndexPath = \(toString(newIndexPath))"))
  }

  func controller(controller: NSFetchedResultsController,
 didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
          atIndex sectionIndex: Int,
    forChangeType type: NSFetchedResultsChangeType)
  {
    MSLogDebug("sectionInfo = \(toString(sectionInfo)), sectionIndex = \(sectionIndex), type = \(type)")
  }

}

// MARK: - Delegate for a model collection object

final class BankModelCollectionDelegate<C:BankModelCollection>: BankModelDelegate {

  // MARK: - Properties

  /** Optional collection that may be used to generate `items` and `collections` */
  let collection: C

  /** Whether the collection supports viewing an image representation of its items */
  override var previewable: Bool { return collection.previewable == true }

  // MARK: - BankModelDelegate overrides

  override func setFetchedCollections(fetchedCollections: NSFetchedResultsController) {}
  override func setFetchedItems(fetchedItems: NSFetchedResultsController) {}

  // MARK: - Entity-based methods and properties

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
      if collectionToItemInverted.count == collectionToItem.count
         && itemToCollectionInverted.count == itemToCollection.count
      {
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

  :param: collection C

  :returns: BankItemCreationControllerTransaction?
  */
  private static func itemTransactionForCollection(collection: C) -> BankItemCreationControllerTransaction? {

    if let context = collection.managedObjectContext {

      let label = collection.itemLabel ?? "New Item"

      switch collection {

        case let c as FormCreatableItemBankModelCollection:
          return CreationTransaction(label: label, form: c.itemCreationForm(context: context)) {
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

  :param: collection C

  :returns: BankItemCreationControllerTransaction?
  */
  private static func collectionTransactionForCollection(collection: C) -> BankItemCreationControllerTransaction? {

    if let context = collection.managedObjectContext {

      let label = collection.collectionLabel ?? "New Collection"

      switch collection {

        case let c as FormCreatableCollectionBankModelCollection:
          return CreationTransaction(label: label, form: c.collectionCreationForm(context: context)) {
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
