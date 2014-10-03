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
private let CategoryCellHeight: CGFloat = 38.0

class BankCategoryController: UIViewController, BankController, UITableViewDataSource, UITableViewDelegate {

  var category: BankDisplayItemCategory?
  var subcategories: [BankDisplayItemCategory] = []
  var categoryItemClass: BankableModelObject.Type?

  weak var categoryItems: BankCollectionController?

  private weak var tableView: UITableView!

  /**
  initWithItemClass:

  :param: itemClass BankableModelObject.Type
  */
  init(itemClass: BankableModelObject.Type) {
    super.init(nibName: nil, bundle: nil)
  	categoryItemClass = itemClass
//  	subcategories = categoryItemClass!.rootCategories
    let categoryTree = recursiveDescription(subcategories, level: 0, {$0.name}, {$0.subcategories})
    println(categoryTree)
  }

  /**
  initWithItems:

  :param: items [BankDisplayItemCategory]
  */
  init(category: BankDisplayItemCategory) {
    super.init(nibName: nil, bundle: nil)
    self.category = category
    self.subcategories = category.subcategories
    if category.items.count > 0 {
        categoryItems = {
          let categoryItems = BankCollectionController(items: category.items)
          self.addChildViewController(categoryItems)
          categoryItems.didMoveToParentViewController(self)
          return categoryItems
        }()
    }
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

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

    view = UIView(frame: UIScreen.mainScreen().bounds)

    title = categoryItemClass?.label()
    if title == nil && subcategories.count > 0 { title = subcategories[0].parentCategory?.name }

    navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName           : Bank.boldLabelFont,
                                                                NSForegroundColorAttributeName: Bank.labelColor ]
    tableView = {
      let tableView = UITableView.newForAutolayout()
      tableView.backgroundColor = UIColor.whiteColor()
      tableView.registerClass(BankCategoryCell.self, forCellReuseIdentifier: CategoryCellIdentifier)
      tableView.separatorStyle = .None
      tableView.rowHeight = CategoryCellHeight
      tableView.delegate = self
      tableView.dataSource = self
      self.view.addSubview(tableView)
      return tableView
    }()

    if categoryItems != nil {
      let items = categoryItems!.view
      items.setTranslatesAutoresizingMaskIntoConstraints(false)
      view.addSubview(items)
    }



    toolbarItems = Bank.toolbarItemsForController(self)


    view.setNeedsUpdateConstraints()
  }

  /**
  updateViewConstraints
  */
  override func updateViewConstraints() {
    let identifier = "Internal"
    if view.constraintsWithIdentifier(identifier).count == 0 {
      if categoryItems != nil {
        let h = CGFloat(subcategories.count) * CategoryCellHeight
        view.constrainWithFormat("|[table]| :: |[items]| :: V:|[table(==\(h))][items]|",
                           views: ["table": tableView, "items": categoryItems!.view],
                      identifier: identifier)
      } else {
        view.constrainWithFormat("|[table]| :: V:|[table]|", views: ["table": tableView], identifier: identifier)
      }
    }
    super.updateViewConstraints()
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
  func importBankObjects() { MSLogInfo("not yet implemented") }

  /** exportBankObject */
  func exportBankObjects() { MSLogInfo("not yet implemented") }

  /** searchBankObjects */
  func searchBankObjects() { MSLogInfo("not yet implemented") }

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
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    // Get the selected category
    let selectedCategory = subcategories[indexPath.row]

    // Check if there are any subcategories
    if selectedCategory.subcategories.count > 0 {

      // We need to push another category controller
      navigationController?.pushViewController(BankCategoryController(category: selectedCategory), animated: true)

    }

    // Otherwise we can just push a collection controller
    else if selectedCategory.items.count > 0 {

      navigationController?.pushViewController(BankCollectionController(items: selectedCategory.items), animated: true)

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
  func numberOfSectionsInTableView(tableView: UITableView) -> Int { return 1 }

  /**
  tableView:numberOfRowsInSection:

  :param: tableView UITableView
  :param: section Int

  :returns: Int
  */
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return subcategories.count }


  /**
  tableView:cellForRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath

  :returns: UITableViewCell
  */
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(CategoryCellIdentifier, forIndexPath: indexPath) as BankCategoryCell
    let category = subcategories[indexPath.row]
    cell.labelText = category.name
    return cell
  }

}
