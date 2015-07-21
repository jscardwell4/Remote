//
//  BankController.swift
//  Remote
//
//  Created by Jason Cardwell on 5/20/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import UIKit
import MoonKit
import DataModel
import Photos

public class BankController: UIViewController, BankItemImportExportController {

  @IBOutlet var buttons: [ImageButtonView]!

  enum RootCategory: Int, CustomStringConvertible {
    case Presets, NetworkDevices, ComponentDevices, Manufacturers, Images
    var description: String {
      switch self {
        case .Presets:          return "Presets"
        case .NetworkDevices:   return "NetworkDevices"
        case .ComponentDevices: return "ComponentDevices"
        case .Manufacturers:    return "Manufacturers"
        case .Images:           return "Images"
      }
    }
  }

  let context = DataManager.mainContext()

  private(set) var exportSelection: [JSONValueConvertible] = []
  var exportSelectionMode: Bool = false

  /** selectAllExportableItems */
  func selectAllExportableItems() {}

  /**
  importFromFile:

  - parameter fileURL: NSURL
  */
  func importFromFile(fileURL: NSURL) {}

  /**
  Invoked by buttons to push a root category's items

  - parameter button: ImageButtonView
  */
  private func buttonAction(button: ImageButtonView) {
    if let rootCategory = RootCategory(rawValue: button.tag) {
//      MSLogDebug("rootCategory = \(rootCategory)")
      let collectionDelegate: BankModelDelegate
      switch rootCategory {
        case .Presets:
          collectionDelegate = BankModelDelegate(name: "Presets", context: context)
          collectionDelegate.itemTransaction = FormTransaction(label:"Category",
                                                               creatableType: PresetCategory.self,
                                                               context: context)
        collectionDelegate.fetchedCollections = PresetCategory.objectsInContext(context,
                                                                  withPredicate: ∀"parentCategory == NULL",
                                                                       sortedBy: "name")
        case .NetworkDevices:
          collectionDelegate = BankModelDelegate(name: "Network Devices", context: context)
          collectionDelegate.fetchedItems = NetworkDevice.objectsInContext(context, sortedBy: "name")
          collectionDelegate.itemTransaction = DiscoveryTransaction(label: "Network Device",
                                                                    discoverableType: NetworkDevice.self,
                                                                    context: context)

        case .ComponentDevices:
          collectionDelegate = BankModelDelegate(name: "Component Devices", context: context)
          collectionDelegate.fetchedItems = ComponentDevice.objectsInContext(context, sortedBy: "name")
          collectionDelegate.itemTransaction = FormTransaction(label: "Component Device",
                                                               creatableType: ComponentDevice.self,
                                                               context: context)
        case .Manufacturers:
          collectionDelegate = BankModelDelegate(name: "Manufacturers", context: context)
          collectionDelegate.itemTransaction = FormTransaction(label: "Manufacturer",
                                                               creatableType: Manufacturer.self,
                                                               context: context)
          collectionDelegate.fetchedItems = Manufacturer.objectsInContext(context, sortedBy: "name")
        case .Images:
          collectionDelegate = BankModelDelegate(name: "Images", context: context)
          collectionDelegate.itemTransaction = FormTransaction(label: "Category",
                                                               creatableType: ImageCategory.self,
                                                               context: context)
          collectionDelegate.fetchedCollections = ImageCategory.objectsInContext(context,
                                                                   withPredicate: ∀"parentCategory == NULL",
                                                                        sortedBy: "name")

      }
      let collectionController = BankCollectionController(collectionDelegate: collectionDelegate)
      navigationController?.pushViewController(collectionController, animated: true)
    }
  }

   public override func viewDidLoad() {
    navigationController?.navigationBar.titleTextAttributes = Bank.titleTextAttributes

    toolbarItems = Bank.toolbarItemsForController(self)

    apply(buttons) {$0.actions.append(self.buttonAction)}
  }

  /**
  viewWillAppear:

  - parameter animated: Bool
  */
  override public func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    title = "Bank"
    navigationItem.rightBarButtonItem = Bank.dismissButton
    navigationController?.toolbarHidden = false
  }

  override public func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    title = ""
  }

  /** importBankObject */
  @IBAction func importBankObjects() { MSLogInfo("not yet implemented") }

  /** exportBankObject */
  @IBAction func exportBankObjects() { MSLogInfo("not yet implemented") }

  /** searchBankObjects */
  @IBAction func searchBankObjects() { MSLogInfo("not yet implemented") }

}
