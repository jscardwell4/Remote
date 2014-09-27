//
//  BankItemDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 9/26/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

@objc(BankItemDetailController)
class BankItemDetailController: UITableViewController {

  struct Section {
    var title: String?
    var rows: [Row]
  }

  struct Row {
    var identifier: String
    var isEditable: Bool
    var configureCell: (BankItemDetailCell) -> Void
  }

  var sections: [Section] = []

  class var DefaultRowHeight:  CGFloat { return 38.0  }
  class var PreviewRowHeight:  CGFloat { return 291.0 }
  class var TextViewRowHeight: CGFloat { return 140.0 }
  class var TableRowHeight:    CGFloat { return 120.0 }

  let item: BankableModelObject!
  weak var nameTextField: UITextField!

  /**
  init:bundle:

  :param: nibNameOrNil String?
  :param: nibBundleOrNil NSBundle?
  */
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  /**
  initWithStyle:

  :param: style UITableViewStyle
  */
  override init(style: UITableViewStyle) {
    super.init(style: style)
  }

  /**
  initWithCoder:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }


  /**
  initWithItem:

  :param: item BankableModelObject
  */
  required init(item: BankableModelObject, editing: Bool) {
    super.init(style: .Grouped)
    self.item = item
    self.editing = editing
    hidesBottomBarWhenPushed = true
  }

  /**
  initWithItem:

  :param: item BankableModelObject
  */
  convenience init(item: BankableModelObject) {
    self.init(item: item, editing: false)
  }

  override func loadView() {
    tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: .Grouped)
    tableView.rowHeight = BankItemDetailController.DefaultRowHeight
    tableView.sectionHeaderHeight = 10.0
    tableView.sectionFooterHeight = 10.0
    tableView.allowsSelection = false
    tableView.separatorStyle = .None
    tableView.delegate = self
    tableView.dataSource = self
    BankItemDetailCell.registerIdentifiersWithTableView(tableView)
    nameTextField = { [unowned self] in
      let textField = UITextField(frame: CGRect(x: 70, y: 70, width: 180, height: 30))
      textField.placeholder = "Name"
      textField.font = UIFont(name: "Elysio-Bold", size: 17.0)
      textField.keyboardAppearance = .Dark
      textField.adjustsFontSizeToFitWidth = true
      textField.returnKeyType = .Done
      textField.enablesReturnKeyAutomatically = true
      textField.textAlignment = .Center
      textField.clearsOnBeginEditing = true
      textField.delegate = self
      self.navigationItem.titleView = textField
      return textField
    }()
    navigationItem.rightBarButtonItem = editButtonItem()
  }

  /** updateDisplay */
  func updateDisplay() {
    nameTextField.text = item.name
    navigationItem.rightBarButtonItem?.enabled = item.editable
    tableView.reloadData()
  }

  /**
  viewWillAppear:

  :param: animated Bool
  */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    updateDisplay()
  }

  /**
  setEditing:animated:

  :param: editing Bool
  :param: animated Bool
  */
  override func setEditing(editing: Bool, animated: Bool) {
    if self.editing != editing {
      navigationItem.leftBarButtonItem = editing
                                           ? UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
                                           : nil
      nameTextField.userInteractionEnabled = editing
      navigationItem.rightBarButtonItem?.title = editing ? "Save" : "Edit"
      navigationItem.rightBarButtonItem?.action = editing ? "save" : "edit"
      super.setEditing(editing, animated: animated)
    }
  }

  /** cancel */
  func cancel() {
    let moc = item.managedObjectContext
    moc.performBlockAndWait{
      moc.processPendingChanges()
      moc.rollback()
    }
    setEditing(false, animated: true)
    updateDisplay()
  }

  /** edit */
  func edit() { if !editing { setEditing(true, animated: true) } }

  /** save */
  func save() {
    let moc = item.managedObjectContext
    moc.performBlockAndWait{
      moc.processPendingChanges()
      var error: NSError?
      moc.save(&error)
      handleError(error, __FUNCTION__)
    }
    setEditing(false, animated: true)
  }

  var expandedRows: [NSIndexPath] = []

  /**
  cellForRowAtIndexPath:

  :param: indexPath NSIndexPath

  :returns: BankItemDetailCell
  */
  func cellForRowAtIndexPath(indexPath: NSIndexPath) -> BankItemDetailCell! {
    return tableView.cellForRowAtIndexPath(indexPath) as? BankItemDetailCell
  }
  

  /**
  identifierForIndexPath:

  :param: indexPath NSIndexPath

  :returns: String?
  */
  private func identifierForIndexPath(indexPath: NSIndexPath) -> String? {
    var identifier: String?
    if indexPath.section < sections.count {
      let section = sections[indexPath.section]
      if indexPath.row < section.rows.count {
        let row = section.rows[indexPath.row]
        identifier = row.identifier
      }
    }
    return identifier
  }

  /**
  dequeueCellForIndexPath:

  :param: indexPath NSIndexPath

  :returns: BankItemDetailCell?
  */
  func dequeueCellForIndexPath(indexPath: NSIndexPath) -> BankItemDetailCell? {
    var cell: BankItemDetailCell?

    if let identifier = identifierForIndexPath(indexPath) {
      if BankItemDetailCell.isValidIdentifier(identifier) {
        cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? BankItemDetailCell
        cell?.shouldShowPicker = {[unowned self] (c: BankItemDetailCell!) -> Bool in
          self.tableView.beginUpdates()
          self.expandedRows.append(indexPath)
          return true
        }
        cell?.shouldHidePicker = {[unowned self] (c: BankItemDetailCell!) -> Bool in
          self.tableView.beginUpdates()
          self.expandedRows = self.expandedRows.filter{$0 != indexPath}
          return true
        }
        cell?.didShowPicker = {[unowned self] (c: BankItemDetailCell!) in self.tableView.endUpdates() }
        cell?.didHidePicker = {[unowned self] (c: BankItemDetailCell!) in self.tableView.endUpdates() }
      }
    }

    return cell
  }

  /**
  decorateCell:forIndexPath:

  :param: cell BankItemDetailCell
  :param: indexPath NSIndexPath
  */
  private func decorateCell(cell: BankItemDetailCell, forIndexPath indexPath: NSIndexPath) {
    if indexPath.section < sections.count {
      let section = sections[indexPath.section]
      if indexPath.row < section.rows.count {
        let row = section.rows[indexPath.row]
        row.configureCell(cell)
      }
    }
  }

}

extension BankItemDetailController: UITableViewDelegate {

  /**
  tableView:editingStyleForRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath

  :returns: UITableViewCellEditingStyle
  */
  override func         tableView(tableView: UITableView,
    editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
  {
    return .None
  }

}

extension BankItemDetailController: UITableViewDataSource {

  /**
  tableView:cellForRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath

  :returns: UITableViewCell
  */
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = dequeueCellForIndexPath(indexPath)
    precondition(cell != nil, "we should have been able to dequeue a valid cell")
    decorateCell(cell!, forIndexPath: indexPath)
    return cell!
  }

  /**
  numberOfSectionsInTableView:

  :param: tableView UITableView

  :returns: Int
  */
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return sections.count
  }


  /**
  tableView:numberOfRowsInSection:

  :param: tableView UITableView
  :param: section Int

  :returns: Int
  */
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section < sections.count ? sections[section].rows.count : 0
  }

  /**
  tableView:titleForHeaderInSection:

  :param: tableView UITableView
  :param: section Int

  :returns: String?
  */
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return section < sections.count ? sections[section].title : nil
  }

  /**
  tableView:heightForRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath

  :returns: CGFloat
  */
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    var height: CGFloat = 0.0
    if let identifier = identifierForIndexPath(indexPath) {
      switch identifier {
        case BankItemCellTextViewStyleIdentifier: height = BankItemDetailController.TextViewRowHeight
        case BankItemCellImageStyleIdentifier:    height = BankItemDetailController.PreviewRowHeight
        case BankItemCellTableStyleIdentifier:    height = BankItemDetailController.TableRowHeight
        default:                                  height = BankItemDetailController.DefaultRowHeight
      }
    }
    return height
  }

  /**
  tableView:canEditRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath

  :returns: Bool
  */
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    if indexPath.section < sections.count {
      let section = sections[indexPath.section]
      if indexPath.row < section.rows.count {
        let row = section.rows[indexPath.row]
        return row.isEditable
      }
    }
    return false
  }

}

extension BankItemDetailController: UITextFieldDelegate {

  /**
  textFieldDidEndEditing:

  :param: textField UITextField
  */
  func textFieldDidEndEditing(textField: UITextField) {
    if textField === nameTextField && textField.text?.length > 0 { item.name = textField.text }
  }

}