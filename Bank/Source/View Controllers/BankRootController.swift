//
//  BankRootController.swift
//  Remote
//
//  Created by Jason Cardwell on 9/25/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC
import MoonKit
import DataModel

final public class BankRootController: UITableViewController, BankItemImportExportController {

  static let RootCellIdentifier = "RootCell"

  let context = DataManager.mainContext()

  /** Generates the collection delegates that will ultimately provide the controller's table data */
  func generateCollectionDelegates() {
    collectionDelegates.removeAll()

    let componentDeviceCollection = BankModelCollectionDelegate()
    componentDeviceCollection.label = "Component Devices"
    componentDeviceCollection.icon = Bank.componentDevicesImage
    componentDeviceCollection.fetchedItems = ComponentDevice.objectsInContext(context, sortedBy: "name")
    collectionDelegates.append(componentDeviceCollection)

    let irCodeCollection = BankModelCollectionDelegate()
    irCodeCollection.label = "IR Codes"
    irCodeCollection.icon = Bank.irCodesImage
    irCodeCollection.fetchedCollections = IRCodeSet.objectsInContext(context, sortedBy: "name")
    collectionDelegates.append(irCodeCollection)

    let imageCollection = BankModelCollectionDelegate()
    imageCollection.label = "Images"
    imageCollection.icon = Bank.imagesImage
    imageCollection.fetchedCollections = ImageCategory.objectsInContext(context,
                                                          withPredicate: ∀"parentCategory == NULL",
                                                               sortedBy: "name")
    collectionDelegates.append(imageCollection)

    let manufacturerCollection = BankModelCollectionDelegate()
    manufacturerCollection.label = "Manufacturers"
    manufacturerCollection.icon = Bank.manufacturersImage
    manufacturerCollection.fetchedItems = Manufacturer.objectsInContext(context, sortedBy: "name")
    collectionDelegates.append(manufacturerCollection)

    let networkDeviceCollection = BankModelCollectionDelegate()
    networkDeviceCollection.label = "Network Devices"
    networkDeviceCollection.icon = Bank.networkDevicesImage
    networkDeviceCollection.fetchedItems = NetworkDevice.objectsInContext(context, sortedBy: "name")
    collectionDelegates.append(networkDeviceCollection)

    let presetCollection = BankModelCollectionDelegate()
    presetCollection.label = "Presets"
    presetCollection.icon = Bank.presetsImage
    presetCollection.fetchedCollections = PresetCategory.objectsInContext(context,
                                                            withPredicate: ∀"parentCategory == NULL",
                                                                 sortedBy: "name")
    collectionDelegates.append(presetCollection)
  }


  /** loadView */
  override public func loadView() {

    title = "Bank"
    navigationController?.navigationBar.titleTextAttributes = Bank.titleTextAttributes
    tableView = {
      let tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: .Plain)
      tableView.backgroundColor = Bank.backgroundColor
      tableView.registerClass(BankRootCell.self, forCellReuseIdentifier: self.dynamicType.RootCellIdentifier)
      tableView.separatorStyle = Bank.separatorStyle
      tableView.rowHeight = Bank.defaultRowHeight
      return tableView
    }()

    toolbarItems = Bank.toolbarItemsForController(self)

  }

  private(set) var exportSelection: [JSONValueConvertible] = []
  var exportSelectionMode: Bool = false

  /** selectAllExportableItems */
  func selectAllExportableItems() {}

  /**
  importFromFile:

  :param: fileURL NSURL
  */
  func importFromFile(fileURL: NSURL) {}

  private var collectionDelegates: [BankModelCollectionDelegate] = []

  /**
  viewWillAppear:

  :param: animated Bool
  */
  override public func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.rightBarButtonItem = Bank.dismissButton
    navigationController?.toolbarHidden = false
    generateCollectionDelegates()
  }

  /** importBankObject */
  @IBAction func importBankObjects() { MSLogInfo("not yet implemented") }

  /** exportBankObject */
  @IBAction func exportBankObjects() { MSLogInfo("not yet implemented") }

  /** searchBankObjects */
  @IBAction func searchBankObjects() { MSLogInfo("not yet implemented") }

}

// MARK: - UITableViewDelegate

extension BankRootController: UITableViewDelegate {

  /**
  tableView:didSelectRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath
  */
  override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let collectionDelegate = collectionDelegates[indexPath.row]
    let collectionController = BankCollectionController(collection: collectionDelegate)!
    navigationController?.pushViewController(collectionController, animated: true)
  }

}

// MARK: - Table view data source

extension BankRootController: UITableViewDataSource {

  /**
  numberOfSectionsInTableView:

  :param: tableView UITableView!

  :returns: Int
  */
  override public func numberOfSectionsInTableView(tableView: UITableView) -> Int { return 1 }

  /**
  tableView:numberOfRowsInSection:

  :param: tableView UITableView
  :param: section Int

  :returns: Int
  */
  override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return collectionDelegates.count
  }


  /**
  tableView:cellForRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath

  :returns: UITableViewCell
  */
  override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(BankRootController.RootCellIdentifier,
                                              forIndexPath: indexPath) as! BankRootCell
    cell.collectionDelegate = collectionDelegates[indexPath.row]
    return cell
  }

}
