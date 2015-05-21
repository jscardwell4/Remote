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

public class BankController: UIViewController, BankItemImportExportController {

  @IBOutlet var buttons: [ImageButtonView]!

  enum RootCategory: Int, Printable {
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

  :param: fileURL NSURL
  */
  func importFromFile(fileURL: NSURL) {}

  /**
  Invoked by buttons to push a root category's items

  :param: button ImageButtonView
  */
  private func buttonAction(button: ImageButtonView) {
    if let rootCategory = RootCategory(rawValue: button.tag) {
      MSLogDebug("rootCategory = \(rootCategory)")
      let collectionDelegate: BankModelDelegate
      switch rootCategory {
        case .Presets:
          collectionDelegate = BankModelDelegate(name: "Presets", context: context)
          collectionDelegate.createItem = BankModelDelegate.createTransactionWithLabel("Category",
                                                                         creatableType: PresetCategory.self,
                                                                               context: context)
        collectionDelegate.setFetchedCollections(PresetCategory.objectsInContext(context,
                                                                   withPredicate: ∀"parentCategory == NULL",
                                                                        sortedBy: "name"))
        case .NetworkDevices:
          collectionDelegate = BankModelDelegate(name: "Network Devices", context: context)
          collectionDelegate.setFetchedItems(NetworkDevice.objectsInContext(context, sortedBy: "name"))

        case .ComponentDevices:
          collectionDelegate = BankModelDelegate(name: "Component Devices", context: context)
          collectionDelegate.setFetchedItems(ComponentDevice.objectsInContext(context, sortedBy: "name"))
          collectionDelegate.createItem = BankModelDelegate.createTransactionWithLabel("Component Device",
                                                                         creatableType: ComponentDevice.self,
                                                                               context: context)
        case .Manufacturers:
          collectionDelegate = BankModelDelegate(name: "Manufacturers", context: context)
          collectionDelegate.createItem = BankModelDelegate.createTransactionWithLabel("Manufacturer",
                                                                         creatableType: Manufacturer.self,
                                                                               context: context)
          collectionDelegate.setFetchedItems(Manufacturer.objectsInContext(context, sortedBy: "name"))
        case .Images:
          collectionDelegate = BankModelDelegate(name: "Images", context: context)
          collectionDelegate.createItem = BankModelDelegate.createTransactionWithLabel("Category",
                                                                         creatableType: ImageCategory.self,
                                                                               context: context)
          collectionDelegate.setFetchedCollections(ImageCategory.objectsInContext(context,
                                                                    withPredicate: ∀"parentCategory == NULL",
                                                                         sortedBy: "name"))

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

  :param: animated Bool
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
