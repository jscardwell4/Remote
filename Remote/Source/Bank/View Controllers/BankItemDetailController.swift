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
class BankItemDetailController: UITableViewController, BankDetailController {

  struct Section {
    var title: String?
    var rows: [Row]
  }

  struct Row {
    var identifier: BankItemCell.Identifier
    var isEditable: Bool
    var configureCell: (BankItemCell) -> Void
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
  required init(item: BankableModelObject, editing: Bool = false) {
    super.init(style: .Grouped)
    self.item = item
    self.editing = editing
    hidesBottomBarWhenPushed = true
  }

  /** loadView */
  override func loadView() {
    tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: .Grouped)
    tableView.rowHeight = BankItemDetailController.DefaultRowHeight
    tableView.sectionHeaderHeight = 10.0
    tableView.sectionFooterHeight = 10.0
    tableView.allowsSelection = false
    tableView.separatorStyle = .None
    tableView.delegate = self
    tableView.dataSource = self
    BankItemCell.registerIdentifiersWithTableView(tableView)
    nameTextField = { [unowned self] in
      let textField = UITextField(frame: CGRect(x: 70, y: 70, width: 180, height: 30))
      textField.placeholder = "Name"
      textField.font = Bank.boldLabelFont
      textField.textColor = Bank.labelColor
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
      MSHandleError(error)
    }
    setEditing(false, animated: true)
  }

  var expandedRows: [NSIndexPath] = []

  /**
  cellForRowAtIndexPath:

  :param: indexPath NSIndexPath

  :returns: BankItemCell
  */
  func cellForRowAtIndexPath(indexPath: NSIndexPath) -> BankItemCell! {
    return tableView.cellForRowAtIndexPath(indexPath) as? BankItemCell
  }


  /**
  identifierForIndexPath:

  :param: indexPath NSIndexPath

  :returns: String?
  */
  private func identifierForIndexPath(indexPath: NSIndexPath) -> BankItemCell.Identifier? {
    var identifier: BankItemCell.Identifier?
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

  :returns: BankItemCell?
  */
  func dequeueCellForIndexPath(indexPath: NSIndexPath) -> BankItemCell? {
    var cell: BankItemCell?

    if let identifier = identifierForIndexPath(indexPath) {
      cell = tableView.dequeueReusableCellWithIdentifier(identifier.toRaw(), forIndexPath: indexPath) as? BankItemCell
      cell?.shouldShowPicker = {[unowned self] (c: BankItemCell!) -> Bool in
        self.tableView.beginUpdates()
        self.expandedRows.append(indexPath)
        return true
      }
      cell?.shouldHidePicker = {[unowned self] (c: BankItemCell!) -> Bool in
        self.tableView.beginUpdates()
        self.expandedRows = self.expandedRows.filter{$0 != indexPath}
        return true
      }
      cell?.didShowPicker = {[unowned self] (c: BankItemCell!) in self.tableView.endUpdates() }
      cell?.didHidePicker = {[unowned self] (c: BankItemCell!) in self.tableView.endUpdates() }
    }

    return cell
  }

  /**
  decorateCell:forIndexPath:

  :param: cell BankItemCell
  :param: indexPath NSIndexPath
  */
  private func decorateCell(cell: BankItemCell, forIndexPath indexPath: NSIndexPath) {
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
        case .TextView: height = BankItemDetailController.TextViewRowHeight
        case .Image:    height = BankItemDetailController.PreviewRowHeight
        case .Table:    height = BankItemDetailController.TableRowHeight
        default:        height = BankItemDetailController.DefaultRowHeight
      }
    }
    if expandedRows ∋ indexPath { height += BankItemCell.PickerHeight }
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
