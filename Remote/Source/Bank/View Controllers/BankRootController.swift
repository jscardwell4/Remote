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

private let RootCellIdentifier = "RootCell"

/** An array containing the names of all direct subclasses of the `BankableModelObject` class */
/*
private let RegisteredClasses: [String] = {
  var bankableModelClasses: [String] = []
  var outcount: UInt32 = 0
  let allClasses = objc_copyClassList(&outcount)
  for i in 0..<outcount {
    if let anyClass: AnyClass = allClasses[Int(i)] {
      if let anySuperClass: AnyClass = class_getSuperclass(anyClass) {
        let anySuperClassName = NSStringFromClass(anySuperClass)
        if anySuperClassName == NSStringFromClass(BankableModelObject.self) {
          bankableModelClasses.append(NSStringFromClass(anyClass))
        }
      }
    }
  }
  bankableModelClasses.sort(<)
  return bankableModelClasses
  }()

*/
class BankRootController: UITableViewController, BankController {

  /** loadView */
  override func loadView() {

    title = "Bank"
    navigationController?.navigationBar.titleTextAttributes = Bank.titleTextAttributes
    tableView = {
      let tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: .Plain)
      tableView?.backgroundColor = Bank.backgroundColor
      tableView?.registerClass(BankRootCell.self, forCellReuseIdentifier: RootCellIdentifier)
      tableView?.separatorStyle = Bank.separatorStyle
      tableView?.rowHeight = Bank.defaultRowHeight
      return tableView
    }()

    toolbarItems = Bank.toolbarItemsForController(self)

  }

  /**
  viewWillAppear:

  :param: animated Bool
  */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.rightBarButtonItem = Bank.dismissBarButtonItem
    navigationController?.toolbarHidden = false
  }

  /** importBankObject */
  func importBankObjects() { MSLogInfo("not yet implemented") }

  /** exportBankObject */
  func exportBankObjects() { MSLogInfo("not yet implemented") }

  /** searchBankObjects */
  func searchBankObjects() { MSLogInfo("not yet implemented") }

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - UITableViewDelegate
////////////////////////////////////////////////////////////////////////////////
extension BankRootController: UITableViewDelegate {

  /**
  tableView:didSelectRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath
  */
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//    if let bankableModelClass = NSClassFromString(RegisteredClasses[indexPath.row]) as? BankableModelObject.Type {
//      let vc = bankableModelClass.isCategorized()
//                 ? BankCategoryController(itemClass: bankableModelClass)
//                 : BankCollectionController(itemClass: bankableModelClass)
//      navigationController?.pushViewController(vc, animated: true)
//    }
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
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int { return 1 }

  /**
  tableView:numberOfRowsInSection:

  :param: tableView UITableView
  :param: section Int

  :returns: Int
  */
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 0 } // RegisteredClasses.count }


  /**
  tableView:cellForRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath

  :returns: UITableViewCell
  */
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(RootCellIdentifier, forIndexPath: indexPath) as BankRootCell
//    if let bankableModelClass = NSClassFromString(RegisteredClasses[indexPath.row]) as? BankableModelObject.Type {
//      cell.bankableModelClass = bankableModelClass
//    }
    return cell
  }

}
