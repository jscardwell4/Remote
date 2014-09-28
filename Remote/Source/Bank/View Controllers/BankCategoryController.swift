//
//  BankCategoryController.swift
//  Remote
//
//  Created by Jason Cardwell on 9/27/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

private let CategoryCellIdentifier = "CategoryCell"

@objc(BankCategoryController)
class BankCategoryController: UITableViewController, BankController {

  var categoryItems: [BankableCategory] = []
  var categoryItemClass: BankableModelObject.Type?

  /**
  initWithItemClass:

  :param: itemClass BankableModelObject.Type
  */
  init(itemClass: BankableModelObject.Type) {
    super.init(style: .Plain)
  	categoryItemClass = itemClass
  	categoryItems = (categoryItemClass!.rootCategories() as? [BankableCategory]) ?? []
  }

  /**
  initWithItems:

  :param: items [BankableCategory]
  */
  init(items: [BankableCategory]) {
    super.init(style: .Plain)
    categoryItems = items
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  /**
  init:bundle:

  :param: nibNameOrNil String?
  :param: nibBundleOrNil NSBundle?
  */
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  /** loadView */
  override func loadView() {

    title = categoryItemClass?.directoryLabel()
    if title == nil && categoryItems.count > 0 { title = categoryItems[0].parentCategory?.name }
    navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName           : Bank.BoldLabelFont,
                                                                NSForegroundColorAttributeName: Bank.LabelColor ]
    tableView = {
      let tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: .Plain)
      tableView.backgroundColor = UIColor.whiteColor()
      tableView.registerClass(BankCategoryCell.self, forCellReuseIdentifier: CategoryCellIdentifier)
      tableView.separatorStyle = .None
      tableView.rowHeight = 38.0
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
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismiss")
  }

  /** dismiss */
  func dismiss() { MSRemoteAppController.sharedAppController().showMainMenu() }

  /** importBankObject */
  func importBankObjects() { logInfo("not yet implemented", __FUNCTION__) }

  /** exportBankObject */
  func exportBankObjects() { logInfo("not yet implemented", __FUNCTION__) }

  /** searchBankObjects */
  func searchBankObjects() { logInfo("not yet implemented", __FUNCTION__) }

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - UITableViewDelegate
////////////////////////////////////////////////////////////////////////////////
extension BankCategoryController: UITableViewDelegate {

  /**
  tableView:didSelectRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath
  */
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let category = categoryItems[indexPath.row]
    if let subcategories = category.subCategories?.allObjects {
      if subcategories.count == 0 {
        if let allItems = category.allItems?.allObjects {
          let vc = BankCollectionController(objects: allItems as [BankableModelObject])
          navigationController?.pushViewController(vc, animated: true)
        }
      } else {
        let vc = BankCategoryController(items: subcategories as [BankableCategory])
        navigationController?.pushViewController(vc, animated: true)
      }
    } else if let allItems = category.allItems?.allObjects {
      let vc = BankCollectionController(objects: allItems as [BankableModelObject])
      navigationController?.pushViewController(vc, animated: true)
    }
  }

}

////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Table view data source
////////////////////////////////////////////////////////////////////////////////////////////////////
extension BankCategoryController: UITableViewDataSource {

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
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return categoryItems.count }


  /**
  tableView:cellForRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath

  :returns: UITableViewCell
  */
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(CategoryCellIdentifier, forIndexPath: indexPath) as BankCategoryCell
    let category = categoryItems[indexPath.row]
    cell.labelText = category.name
    return cell
  }

}
