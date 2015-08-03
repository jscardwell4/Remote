//
//  ItemCreationTransaction.swift
//  Remote
//
//  Created by Jason Cardwell on 7/20/15.
//  Copyright © 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit
import DataModel

struct CustomTransaction: ItemCreationTransaction {
  typealias CustomController = (didCancel: () -> Void, didCreate: (ModelObject) -> Void) -> UIViewController?

  let label: String
  let controller: CustomController
  let creationMode = Bank.CreationMode.Manual

  /**
  Memberwise initializer

  - parameter label: String
  - parameter controller: CustomController
  */
  init(label: String, controller: CustomController) { self.label = label; self.controller = controller }

  /**
  Generates a `CustomTransaction` given a `CustomCreatable` type, a label, and a managed object context

  - parameter label: String
  - parameter customType: T.Type
  - parameter context: NSManagedObjectContext
  */
  init<T:CustomCreatable>(label: String, customType: T.Type, context: NSManagedObjectContext) {
    let controller: CustomController = {
      didCancel, didCreate -> UIViewController? in
      let handler: (ModelObject) -> Void = {
        object in
        do {
          try DataManager.saveContext(context)
        } catch {
          logError(error)
        }

        didCreate(object)
      }
      return customType.creationControllerWithContext(context, cancellationHandler: didCancel, creationHandler: handler)
    }
    self.init(label: label, controller: controller)
  }

  /**
  Transaction for creating a new item for the specified collection

  - parameter collection: T
  */
  init<T:BankModelCollection where T:CustomCreatableItem>(newItemFor collection: T) {
    assert(collection.managedObjectContext != nil)
    self.init(label: collection.itemLabel) {
      didCancel, didCreate -> UIViewController? in

      let handler: (ModelObject) -> Void = {
        object in
        do {
          try DataManager.saveContext(collection.managedObjectContext!)
        } catch {
          logError(error)
        }

        didCreate(object)
      }
      return collection.itemCreationControllerWithContext(collection.managedObjectContext!,
                                      cancellationHandler: didCancel,
                                          creationHandler: handler)
    }
  }

  /**
  Transaction for creating a new collection for the specified collection

  - parameter collection: T
  */
  init<T:BankModelCollection where T:CustomCreatableCollection>(newCollectionFor collection: T) {
    assert(collection.managedObjectContext != nil)
    self.init(label: collection.collectionLabel) {
      didCancel, didCreate -> UIViewController? in

      let handler: (ModelObject) -> Void = {
        object in
        do {
          try DataManager.saveContext(collection.managedObjectContext!)
        } catch {
          logError(error)
        }

        didCreate(object)
      }
      return collection.collectionCreationControllerWithContext(collection.managedObjectContext!,
                                            cancellationHandler: didCancel,
                                                creationHandler: handler)
    }
  }
}

struct FormTransaction: ItemCreationTransaction {
  let label: String
  let form: Form
  let processedForm: ProcessedForm
  let creationMode = Bank.CreationMode.Manual

  /**
  Memberwise initializer

  - parameter label: String
  - parameter form: Form
  - parameter processedForm: ProcessedForm
  */
  init(label: String, form: Form, processedForm: ProcessedForm) {
    self.label = label
    self.form = form
    self.processedForm = processedForm
  }

  /**
  Generates a `FormTransaction` given a label, a `FormCreatable` type, and a managed object context

  - parameter label: String
  - parameter creatableType: T.Type
  - parameter context: NSManagedObjectContext
  */
  init<T:FormCreatable>(label: String, creatableType: T.Type, context: NSManagedObjectContext) {
    let form = creatableType.creationForm(context: context)
    let processedForm: ProcessedForm = {
      f in

      do {
        try DataManager.saveContext(context, withBlock: {_ = creatableType.createWithForm(f, context: $0)})
        return true
      } catch {
        logError(error, message: "failed to save new \(toString(creatableType))")
        return false
      }
    }
    self.init(label: label, form: form, processedForm: processedForm)
  }

  /**
  Transaction for creating a new item for the specified collection

  - parameter collection: T
  */
  init<T:BankModelCollection where T:FormCreatableItem>(newItemFor collection: T) {
    assert(collection.managedObjectContext != nil)
    self.init(label: collection.itemLabel, form: collection.itemCreationForm(context: collection.managedObjectContext!)) {
      f in
      do {
        try DataManager.saveContext(collection.managedObjectContext!, withBlock: {_ = collection.createItemWithForm(f, context: $0)})
        return true
      } catch {
        logError(error)
        return false
      }
    }

  }

  /**
  Transaction for creating a new collection for the specified collection

  - parameter collection: T
  */
  init<T:BankModelCollection where T:FormCreatableCollection>(newCollectionFor collection: T) {
    assert(collection.managedObjectContext != nil)
    self.init(label: collection.collectionLabel, form: collection.collectionCreationForm(context: collection.managedObjectContext!)) {
      f in
      do {
        try DataManager.saveContext(collection.managedObjectContext!, withBlock: {_ = collection.createCollectionWithForm(f, context: $0)})
        return true
      } catch {
        logError(error)
        return false
      }
    }

  }
}

struct DiscoveryTransaction: ItemCreationTransaction {

  typealias BeginAction = ((Form, ProcessedForm) -> Void) -> Void
  typealias EndAction = () -> Void

  let label: String
  let beginDiscovery: BeginAction
  let endDiscovery: EndAction
  let creationMode = Bank.CreationMode.Discovery

  /**
  Memberwise initializer

  - parameter label: String
  - parameter begin: BeginAction
  - parameter end: EndAction
  */
  init(label: String, begin: BeginAction, end: EndAction) { self.label = label; beginDiscovery = begin; endDiscovery = end }

  /**
  Generates a `DiscoverTransaction` given a label, a `DiscoverCreatable` type, and a managed object context

  - parameter label: String
  - parameter discoverableType: T.Type
  - parameter context: NSManagedObjectContext
  */
//  init<T:DiscoverCreatable>(label: String, discoverableType: T.Type, context: NSManagedObjectContext) {
//    let begin: BeginAction = { discoverableType.beginDiscovery(context: context, presentForm: $0) }
//    let end: EndAction = {discoverableType.endDiscovery()}
//    self.init(label: label, begin: begin, end: end)
//  }

  /**
  Transaction for discovering a new item for the specified collection

  - parameter collection: T
  */
  init<T:BankModelCollection where T:DiscoverCreatableItem>(discoverItemFor collection: T) {
    assert(collection.managedObjectContext != nil)
    self.init(label: collection.itemLabel,
              begin: {collection.beginItemDiscovery(context: collection.managedObjectContext!, presentForm: $0)},
              end: {collection.endItemDiscovery()})
  }

  /**
  Transaction for discovering a new collection for the specified collection

  - parameter collection: T
  */
  init<T:BankModelCollection where T:DiscoverCreatableCollection>(discoverCollectionFor collection: T) {
    assert(collection.managedObjectContext != nil)
    self.init(label: collection.collectionLabel,
      begin: {collection.beginCollectionDiscovery(context: collection.managedObjectContext!, presentForm: $0)},
      end: {collection.endCollectionDiscovery()})
  }
}
