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

public class BankRootController: UITableViewController, BankController {

  static let RootCellIdentifier = "RootCell"

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

  private(set) var exportSelection: [MSJSONExport] = []
  var exportSelectionMode: Bool = false

  /** selectAllExportableItems */
  func selectAllExportableItems() {}

  /**
  importFromFile:

  :param: fileURL NSURL
  */
  func importFromFile(fileURL: NSURL) {}

  var rootCategories: [Bank.RootCategory] = []

  /**
  viewWillAppear:

  :param: animated Bool
  */
  override public func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.rightBarButtonItem = Bank.dismissButton
    navigationController?.toolbarHidden = false
    rootCategories = Bank.rootCategories
  }

  /** importBankObject */
  func importBankObjects() { MSLogInfo("not yet implemented") }

  /** exportBankObject */
  func exportBankObjects() { MSLogInfo("not yet implemented") }

  /** searchBankObjects */
  func searchBankObjects() { MSLogInfo("not yet implemented") }

}

// MARK: - UITableViewDelegate

extension BankRootController: UITableViewDelegate {

  /**
  tableView:didSelectRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath
  */
  override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let rootCategory = rootCategories[indexPath.row]
    let collection = BankSurrogateCategory(title: rootCategory.label,
                                         collections: rootCategory.collections,
                                         items: rootCategory.items)
    let collectionController = BankCollectionController(collection: collection)!
    navigationController?.pushViewController(collectionController, animated: true)
  }

}

////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Table view data source
////////////////////////////////////////////////////////////////////////////////////////////////////
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
    return rootCategories.count
  }


  /**
  tableView:cellForRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath

  :returns: UITableViewCell
  */
  override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(self.dynamicType.RootCellIdentifier,
                                              forIndexPath: indexPath) as! BankRootCell
    cell.rootCategory = rootCategories[indexPath.row]
    return cell
  }

}
