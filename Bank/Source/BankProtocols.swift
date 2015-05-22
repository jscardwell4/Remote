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

/** Protocol for bank items that can be presented in a detail controller */
protocol Detailable {
  func detailController() -> UIViewController
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
  static func creationForm(#context: NSManagedObjectContext) -> Form
  static func createWithForm(form: Form, context: NSManagedObjectContext) -> Self?
}

protocol DiscoverCreatable: Model {
  static func beginDiscovery(#context: NSManagedObjectContext, presentForm: (Form, ProcessedForm) -> Void) -> Bool
  static func endDiscovery()
}

// MARK: - Bank colleciton protocols

/** Protocol for objects that can supply bank items or collections */
@objc protocol BankItemCollection: Named {
  optional var itemType: CollectedModel.Type { get }
  optional var collectionType: ModelCollection.Type { get }
  optional var items: [CollectedModel] { get }
  optional var collections: [ModelCollection] { get }
  optional var previewable: Bool { get }
}

/** Protocol for models that implement `BankItemCollection` */
@objc protocol BankModelCollection: BankItemCollection, NamedModel {}
protocol CreatableItemBankModelCollection: BankModelCollection {
  // typealias ItemType
//  static func itemTypeFormFields(#context: NSManagedObjectContext) -> FormViewController.FieldCollection
//  static func createItemTypeWithFormValues(values: FormViewController.FieldValues,
//                                           context: NSManagedObjectContext) -> CollectedModel?
}
protocol CreatableCollectionBankModelCollection: BankModelCollection {
  // typealias CollectionType
//  static func collectionTypeFormFields(#context: NSManagedObjectContext) -> FormViewController.FieldCollection
//  static func createCollectionTypeWithFormValues(values: FormViewController.FieldValues,
//                                                 context: NSManagedObjectContext) -> ModelCollection?
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
  func discoverBankItem()  // Called from create item bar button action when creationMode == .Discovery
  func createBankItem()    // Called from create item bar button action when creationMode == .Manual
  weak var createItemBarButton: ToggleBarButtonItem? { get set }
  weak var discoverItemBarButton: ToggleBarButtonItem? { get set }
}

/** Protocol for types that want search bar button item in bottom toolbar */
protocol BankItemSearchableController: class {
  func searchBankObjects()  // Called from search bar button action
}
