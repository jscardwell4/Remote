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


@objc class BankModelDelegate: NSObject {

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

  - parameter label: String
  - parameter creatableType: T.Type
  - parameter context: NSManagedObjectContext

  - returns: CreateTransaction
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

  - parameter label: String
  - parameter discoverableType: T.Type
  - parameter context: NSManagedObjectContext

  - returns: DiscoverTransaction
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

  - parameter label: String
  - parameter customType: T.Type
  - parameter context: NSManagedObjectContext

  - returns: CustomTransaction
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

  - parameter n: String
  - parameter i: UIImage?
  - parameter context: NSManagedObjectContext
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

  - parameter indexPath: NSIndexPath

  - returns: NamedModel?
  */
  func modelAtIndexPath(indexPath: NSIndexPath) -> NamedModel? {
    switch indexPath.section {
      case 0:  return collectionAtIndex(indexPath.row)
      case 1:  return itemAtIndex(indexPath.row)
      default: return nil
    }
  }

  // MARK: - Items collection

  var numberOfItems: Int { return fetchedItems?.sections?[0].numberOfObjects ?? 0 }

  /**
  itemAtIndex:

  - parameter index: Int

  - returns: NamedModel?
  */
  func itemAtIndex(index: Int) -> NamedModel? {
    return fetchedItems?.objectAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? NamedModel
  }

  /** The results controller that provides the objects for the `items` array */
  var fetchedItems: NSFetchedResultsController? {
    didSet {
      if let managedObjectClassName = fetchedItems?.fetchRequest.entity?.managedObjectClassName,
        managedObjectClass = NSClassFromString(managedObjectClassName) as? NSManagedObject.Type
        where managedObjectClass.conformsToProtocol(NamedModel.self)
      {
        fetchedItems?.delegate = self
        do {
          try fetchedItems?.performFetch()
        } catch {
          MSHandleError(error as NSError)
        }
      }
    }
  }

  // MARK: - Collections collection

  var numberOfCollections: Int { return fetchedCollections?.sections?[0].numberOfObjects ?? 0 }

  /**
  collectionAtIndex:

  - parameter index: Int

  - returns: ModelCollection
  */
  func collectionAtIndex(index: Int) -> ModelCollection? {
    return fetchedCollections?.objectAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? ModelCollection
  }

  /** The results controller that provides objects for the `collections` array */
  var fetchedCollections: NSFetchedResultsController? {
    didSet {
      if let managedObjectClassName = fetchedCollections?.fetchRequest.entity?.managedObjectClassName,
        managedObjectClass = NSClassFromString(managedObjectClassName) as? NSManagedObject.Type
        where managedObjectClass.conformsToProtocol(ModelCollection.self)
      {
        fetchedCollections?.delegate = self
        do {
          try fetchedCollections?.performFetch()
        } catch {
          MSHandleError(error as NSError)
        }
      }
    }
  }

  // MARK: - Descriptions

  override var description: String {
    var result = "BankModelCollectionDelegate:\n"
    result += "\tlabel = \(String(name))\n"
    result += "\tcollections = "
    let collections = fetchedCollections?.fetchedObjects ?? []
    if collections.count == 0 { result += "[]\n" }
    else { result += "{\n" + "\n\n".join(collections.map({toString($0)})).indentedBy(8) + "\n\t}\n" }
    result += "items = "
    let items = fetchedItems?.fetchedObjects ?? []
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
  didChangeObject anObject: NSManagedObject,
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
