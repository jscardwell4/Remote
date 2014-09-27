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

@objc(BankRootController)
class BankRootController: UITableViewController {

  /** loadView */
  override func loadView() {

    title = "Bank"
    navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName           : BankAppearance.BoldLabelFont,
                                                                NSForegroundColorAttributeName: BankAppearance.LabelColor ]
    tableView = {
      let tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: .Plain)
      tableView.backgroundColor = UIColor.whiteColor()
      tableView.registerClass(BankRootCell.self, forCellReuseIdentifier: RootCellIdentifier)
      tableView.separatorStyle = .None
      tableView.rowHeight = 38.0
      return tableView
    }()

    toolbarItems = {[unowned self] in
      let exportBarItem = UIBarButtonItem(image: UIImage(named:"702-gray-share"),
                                     style: .Plain,
                                    target: self,
                                    action: "exportBankObject")
      let spacer = UIBarButtonItem.fixedSpace(20.0)
      let importBarItem = UIBarButtonItem(image: UIImage(named:"703-gray-download"),
                                    style: .Plain,
                                   target: self,
                                   action: "importBankObject")
      let flex = UIBarButtonItem.flexibleSpace()

      let searchBarItem = UIBarButtonItem(image: UIImage(named:"708-gray-search"),
                                    style: .Plain,
                                   target: self,
                                   action: "searchBankObjects")

      return  [exportBarItem, spacer, importBarItem, flex, searchBarItem]
      }()

  }

  /**
  viewWillAppear:

  :param: animated Bool
  */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismiss")
    navigationController?.toolbarHidden = false
  }

  /** dismiss */
  func dismiss() { MSRemoteAppController.sharedAppController().showMainMenu() }

  /** importBankObject */
  func importBankObject() { logInfo("not yet implemented", __FUNCTION__) }

  /** exportBankObject */
  func exportBankObject() { logInfo("not yet implemented", __FUNCTION__) }

  /** searchBankObjects */
  func searchBankObjects() { logInfo("not yet implemented", __FUNCTION__) }

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
    if let bankableModelClass = NSClassFromString(RegisteredClasses[indexPath.row]) as? BankableModelObject.Type {
      let collectionController = BankCollectionController(itemClass: bankableModelClass)
      navigationController?.pushViewController(collectionController, animated: true)
    }
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
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return RegisteredClasses.count }


  /**
  tableView:cellForRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath

  :returns: UITableViewCell
  */
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(RootCellIdentifier, forIndexPath: indexPath) as BankRootCell
    if let bankableModelClass = NSClassFromString(RegisteredClasses[indexPath.row]) as? BankableModelObject.Type {
      cell.bankableModelClass = bankableModelClass
    }
    return cell
  }

}
