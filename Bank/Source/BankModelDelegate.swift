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


  typealias BeginEndChangeCallback = (BankModelDelegate) -> Void
  typealias ChangeCallback = (BankModelDelegate, Change) -> Void

  // MARK: - Transactions

  var itemTransaction: ItemCreationTransaction?
  var collectionTransaction: ItemCreationTransaction?

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

// MARK: - ItemCreationTransactionProvider
extension BankModelDelegate: ItemCreationTransactionProvider {
  var transactions: [ItemCreationTransaction] { return compressed([itemTransaction, collectionTransaction]) }
}

// MARK: - NSFetchedResultsControllerDelegate methods

extension BankModelDelegate: NSFetchedResultsControllerDelegate {

  func controllerWillChangeContent(controller: NSFetchedResultsController) {
//    MSLogDebug("")
    if controller === fetchedItems { beginItemsChanges?(self) }
    else if controller === fetchedCollections { beginCollectionsChanges?(self) }
  }

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
//    MSLogDebug("")
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

//    MSLogDebug(", ".join("object = \((anObject as! NamedModel).name)",
//                        "indexPath = \(toString(indexPath)), type = \(type)",
//                        "newIndexPath = \(toString(newIndexPath))"))
  }

  func controller(controller: NSFetchedResultsController,
 didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
          atIndex sectionIndex: Int,
    forChangeType type: NSFetchedResultsChangeType)
  {
//    MSLogDebug("sectionInfo = \(toString(sectionInfo)), sectionIndex = \(sectionIndex), type = \(type)")
  }

}
