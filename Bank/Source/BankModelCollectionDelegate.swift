//
//  BankModelCollectionDelegate.swift
//  Remote
//
//  Created by Jason Cardwell on 5/15/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
import Foundation
import CoreData
import DataModel
import MoonKit

final class BankModelCollectionDelegate: NSObject, BankModelCollection, Printable {

  var name: String { return collection?.name ?? label ?? "" }
  var label: String?
  var icon: UIImage?
  var collection: BankModelCollection?

  var fetchedItems: NSFetchedResultsController? {
    didSet {
      if let fetchedItems = fetchedItems,
        managedObjectClassName = fetchedItems.fetchRequest.entity?.managedObjectClassName,
        managedObjectClass = NSClassFromString(managedObjectClassName) as? NSManagedObject.Type
        where managedObjectClass.conformsToProtocol(NamedModel.self)
      {
        var error: NSError?
        fetchedItems.performFetch(&error)
        MSHandleError(error)
      } else { fetchedItems = nil }
    }
  }

  var items: [NamedModel] {
    return collection?.items ?? fetchedItems?.fetchedObjects as? [NamedModel] ?? []
  }

  var fetchedCollections: NSFetchedResultsController? {
    didSet {
      if let fetchedCollections = fetchedCollections,
        managedObjectClassName = fetchedCollections.fetchRequest.entity?.managedObjectClassName,
        managedObjectClass = NSClassFromString(managedObjectClassName) as? NSManagedObject.Type
        where managedObjectClass.conformsToProtocol(ModelCollection.self)
      {
        var error: NSError?
        fetchedCollections.performFetch(&error)
        MSHandleError(error)
      } else { fetchedCollections = nil }
    }
  }

  var collections: [ModelCollection] {
    return collection?.collections ?? fetchedCollections?.fetchedObjects as? [ModelCollection] ?? []
  }

  var previewable: Bool { return collection?.previewable == true }

  override var description: String {
    var result = "BankModelCollectionDelegate:\n"
    result += "\tlabel = \(toString(label))\n"
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