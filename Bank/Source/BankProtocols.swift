//
//  BankProtocols.swift
//  Remote
//
//  Created by Jason Cardwell on 3/27/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit
import DataModel

// MARK: - Detailable protocol

protocol DelegateDetailable: NamedModel, EditableModel {
  func sectionIndexForController(controller: BankCollectionDetailController) -> BankModelDetailDelegate.SectionIndex
}

protocol RelatedItemCreatable: DelegateDetailable {
  var relatedItemCreationTransactions: [ItemCreationTransaction] { get }
}

// MARK: - Previewable protocol

/** Protocol for objects that can supply an image representation */
protocol Previewable {
  var preview: UIImage? { get }
  var thumbnail: UIImage? { get }
}

// Mark: - Form creatable protocol
typealias FormPresentation = (Form) -> Void
typealias FormSubmission = (Form) -> Void
typealias ProcessedForm = (Form) -> Bool

protocol FormCreatable: Model {
  static func creationForm(context context: NSManagedObjectContext) -> Form
  static func createWithForm(form: Form, context: NSManagedObjectContext) -> Self?
}

protocol DiscoverCreatable: Model {
  static func beginDiscovery(context context: NSManagedObjectContext, presentForm: (Form, ProcessedForm) -> Void) -> Bool
  static func endDiscovery()
}

protocol CustomCreatable: Model {
  static func creationControllerWithContext(context: NSManagedObjectContext,
                        cancellationHandler didCancel: () -> Void,
                            creationHandler didCreate: (ModelObject) -> Void) -> UIViewController?
}

// MARK: - Bank colleciton protocols

/** Protocol for objects that can supply bank items or collections */
@objc protocol BankItemCollection: Named {
  optional var itemType: CollectedModel.Type { get }
  optional var collectionType: ModelCollection.Type { get }
  optional var items: [CollectedModel] { get }
  optional var collections: [ModelCollection] { get }
  optional var previewable: Bool { get }
  optional var itemLabel: String { get }
  optional var collectionLabel: String { get }
}

/** Protocol for models that implement `BankItemCollection` */
@objc protocol BankModelCollection: BankItemCollection, NamedModel {}

@objc protocol FormCreatableItem: BankModelCollection {
  func itemCreationForm(context context: NSManagedObjectContext) -> Form
  func createItemWithForm(form: Form, context: NSManagedObjectContext) -> Bool
  var itemLabel: String { get }
}

@objc protocol FormCreatableCollection: BankModelCollection {
  func collectionCreationForm(context context: NSManagedObjectContext) -> Form
  func createCollectionWithForm(form: Form, context: NSManagedObjectContext) -> Bool
  var collectionLabel: String { get }
}

@objc protocol DiscoverCreatableItem: BankModelCollection {
  func beginItemDiscovery(context context: NSManagedObjectContext, presentForm: (Form, ProcessedForm) -> Void) -> Bool
  func endItemDiscovery()
  var itemLabel: String { get }

}

@objc protocol DiscoverCreatableCollection: BankModelCollection {
  func beginCollectionDiscovery(context context: NSManagedObjectContext, presentForm: (Form, ProcessedForm) -> Void) -> Bool
  func endCollectionDiscovery()
  var collectionLabel: String { get }
}

@objc protocol CustomCreatableItem: BankModelCollection {
  func itemCreationControllerWithContext(context: NSManagedObjectContext,
                   cancellationHandler didCancel: () -> Void,
                       creationHandler didCreate: (ModelObject) -> Void) -> UIViewController?
  var itemLabel: String { get }
}

@objc protocol CustomCreatableCollection: BankModelCollection {
  func collectionCreationControllerWithContext(context: NSManagedObjectContext,
                         cancellationHandler didCancel: () -> Void,
                             creationHandler didCreate: (ModelObject) -> Void) -> UIViewController?
  var collectionLabel: String { get }
}

// MARK: - View controller related protocols

/** Protocol for objects that want to present a bank item controller and receive a callback on item selection */
public protocol BankItemSelectionDelegate {
  func bankController(bankController: UIViewController, didSelectItem item: EditableModel)
}

/** Protocol for types that want to support a toolbar control for switching between viewing modes */
protocol BankItemSelectiveViewingModeController: class {
  var selectiveViewingEnabled: Bool { get }
  var viewingMode: Bank.ViewingMode { get set }
  weak var displayOptionsControl: ToggleImageSegmentedControl? { get set }
}

/** Protocol for types that want import/export bar button items in bottom toolbar */
protocol BankItemImportExportController: class {

  var exportSelection: [JSONValueConvertible] { get }
  var exportSelectionMode: Bool { get set }

  func selectAllExportableItems() // Called from select all bar button action
  func importFromFile(fileURL: NSURL)

}

/** Protocol for types that want create bar button item in bottom toolbar */
protocol BankItemCreationController: class {
  var creationMode: Bank.CreationMode { get } // Whether new items are created manually, via discovery, both, or neither
  var creationContext: NSManagedObjectContext? { get } // Context used in creation transactions
  func discoverBankItem()                     // Called from create item bar button action when creationMode == .Discovery
  func createBankItem()                       // Called from create item bar button action when creationMode == .Manual
  weak var createItemBarButton: ToggleBarButtonItem? { get set }
  weak var discoverItemBarButton: ToggleBarButtonItem? { get set }
}

protocol ItemCreationTransaction {
  var label: String { get }
  var creationMode: Bank.CreationMode { get } // Whether new items are created manually, via discovery, both, or neither
}

protocol ItemCreationTransactionProvider {
  var transactions: [ItemCreationTransaction] { get } // All available creation transactions
  var creationMode: Bank.CreationMode         { get } // Whether new items are created manually, via discovery, both, or neither

}

/** Protocol for types that want search bar button item in bottom toolbar */
protocol BankItemSearchableController: class {
  func searchBankObjects()  // Called from search bar button action
}
