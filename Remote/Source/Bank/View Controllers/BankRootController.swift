//
//  BankRootControllerTableViewController.swift
//  Remote
//
//  Created by Jason Cardwell on 9/25/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import UIKit

private let RootCellIdentifier = "RootCell"

@objc(BankRootController)
class BankRootController: UITableViewController {

  /**
  loadView
  */
  override func loadView() {

    title = "Bank"

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
  init
  */
  override init() {
    rootItems = Bank.registeredClasses() as [String]
    super.init()
  }

  /**
  init:bundle:

  :param: nibNameOrNil String?
  :param: nibBundleOrNil NSBundle?
  */
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    rootItems = Bank.registeredClasses() as [String]
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  /**
  initWithStyle:

  :param: style UITableViewStyle
  */
  override init(style: UITableViewStyle) {
    rootItems = Bank.registeredClasses() as [String]
    super.init(style: style)
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) {
    rootItems = Bank.registeredClasses() as [String]
    super.init(coder: aDecoder)
  }

  /**
  viewWillAppear:

  :param: animated Bool
  */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismiss")
  }

  private var rootItems: [String]

  /**
  dismiss
  */
  func dismiss() {
    MSRemoteAppController.sharedAppController().dismissViewController(Bank.viewController(), completion: nil)
  }

  /**
  importBankObject
  */
  private func importBankObject() { logInfo("not yet implemented", __FUNCTION__) }

  /**
  exportBankObject
  */
  private func exportBankObject() { logInfo("not yet implemented", __FUNCTION__) }

  /**
  searchBankObjects
  */
  private func searchBankObjects() { logInfo("not yet implemented", __FUNCTION__) }

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
    if let itemClass = NSClassFromString(rootItems[indexPath.row]) as? BankableModelObject.Type {
      let collectionController = BankCollectionController(itemClass: itemClass)
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
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return rootItems.count }

  
  /**
  tableView:cellForRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath

  :returns: UITableViewCell
  */
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(RootCellIdentifier, forIndexPath: indexPath) as BankRootCell
    cell.bankableModelClassName = rootItems[indexPath.row]
    return cell
  }

}
