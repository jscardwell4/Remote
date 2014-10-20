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

  var sections: [BankItemDetailSection] = []

  class var defaultRowHeight:  CGFloat { return 38.0  }
  class var previewRowHeight:  CGFloat { return 291.0 }
  class var textViewRowHeight: CGFloat { return 140.0 }
  class var switchRowHeight:   CGFloat { return 48.0  }
  class var tableRowHeight:    CGFloat { return 120.0 }

  let item: BankDisplayItemModel!
  weak var nameTextField: UITextField!

  private weak var cellDisplayingPicker: BankItemCell?

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
  override init?(style: UITableViewStyle) {
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

  :param: item BankDisplayItemModel
  */
  required init?(item: BankDisplayItemModel) {
    super.init(style: .Grouped)
    self.item = item
    hidesBottomBarWhenPushed = true
  }

  /** loadView */
  override func loadView() {
    tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: .Grouped)
    tableView?.rowHeight = BankItemDetailController.defaultRowHeight
    tableView?.sectionHeaderHeight = 10.0
    tableView?.sectionFooterHeight = 10.0
    tableView?.separatorStyle = .None
    tableView?.delegate = self
    tableView?.dataSource = self
    BankItemCell.registerIdentifiersWithTableView(tableView)
    nameTextField = { [unowned self] in
      let textField = UITextField(frame: CGRect(x: 70, y: 70, width: 180, height: 30))
      textField.placeholder = "Name"
      textField.font = Bank.boldLabelFont
      textField.textColor = Bank.labelColor
      textField.keyboardAppearance = Bank.keyboardAppearance
      textField.adjustsFontSizeToFitWidth = true
      textField.returnKeyType = .Done
      textField.textAlignment = .Center
      textField.delegate = self
      self.navigationItem.titleView = textField
      return textField
    }()
    navigationItem.rightBarButtonItem = editButtonItem()
  }

  /** updateDisplay */
  func updateDisplay() {
    nameTextField.text = item.name
    navigationItem.rightBarButtonItem?.enabled = item?.editable ?? false
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
    item.rollback()
    setEditing(false, animated: true)
    updateDisplay()
  }

  /** edit */
  func edit() { if !editing { setEditing(true, animated: true) } }

  /** save */
  func save() {
    item.save()
    setEditing(false, animated: true)
  }

  var expandedRows: [NSIndexPath] = []

  /**
  cellForRowAtIndexPath:

  :param: indexPath NSIndexPath

  :returns: BankItemCell
  */
  func cellForRowAtIndexPath(indexPath: NSIndexPath) -> BankItemCell! {
    return tableView?.cellForRowAtIndexPath(indexPath) as? BankItemCell
  }

  /**
  reloadRowsAtIndexPaths:animated:

  :param: indexPaths [NSIndexPath]
  :param: animated Bool = false
  */
  func reloadRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation = .None) {
    apply(unique(indexPaths.map{$0.section})){self.sections[$0].reloadRows()}
    tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
  }

  /**
  rowForIndexPath:

  :param: indexPath NSIndexPath

  :returns: Row?
  */
  private func rowForIndexPath(indexPath: NSIndexPath) -> BankItemDetailRow? {
    if indexPath.section < sections.count && indexPath.row < sections[indexPath.section].rows.count {
      return sections[indexPath.section].rows[indexPath.row]
    } else {
      return nil
    }
  }

  /**
  identifierForIndexPath:

  :param: indexPath NSIndexPath

  :returns: String?
  */
  private func identifierForIndexPath(indexPath: NSIndexPath) -> BankItemCell.Identifier? {
    return rowForIndexPath(indexPath)?.identifier
  }

  /**
  dequeueCellForIndexPath:

  :param: indexPath NSIndexPath

  :returns: BankItemCell?
  */
  func dequeueCellForIndexPath(indexPath: NSIndexPath) -> BankItemCell? {
    var cell: BankItemCell?

    if let identifier = identifierForIndexPath(indexPath) {
      cell = tableView.dequeueReusableCellWithIdentifier(identifier.rawValue, forIndexPath: indexPath) as? BankItemCell
       cell?.shouldShowPicker = {
        (c: BankItemCell!) -> Bool in
          if self.cellDisplayingPicker != nil {
            self.cellDisplayingPicker!.hidePickerView()
            return false
          }
          self.tableView.beginUpdates()
          self.cellDisplayingPicker = c
          self.expandedRows.append(indexPath)
          self.tableView.endUpdates()
          return true
      }
      cell?.shouldHidePicker = {
        (c: BankItemCell!) -> Bool in
          self.tableView.beginUpdates()
          self.cellDisplayingPicker = nil
          self.expandedRows = self.expandedRows.filter{$0 != indexPath}
          self.tableView.endUpdates()
          return true
      }
    }

    return cell
  }

  /**
  decorateCell:forIndexPath:

  :param: cell BankItemCell
  :param: indexPath NSIndexPath
  */
  private func decorateCell(cell: BankItemCell, forIndexPath indexPath: NSIndexPath) {
    rowForIndexPath(indexPath)?.configureCell(cell)
  }

}

/// MARK: - UITableViewDelegate
////////////////////////////////////////////////////////////////////////////////
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
    if let row = rowForIndexPath(indexPath) {
      return row.editingStyle
    } else {
      return .None
    }
  }

  /**
  tableView:willDisplayCell:forRowAtIndexPath:

  :param: tableView UITableView
  :param: cell UITableViewCell
  :param: indexPath NSIndexPath
  */
  override func tableView(tableView: UITableView,
          willDisplayCell cell: UITableViewCell,
        forRowAtIndexPath indexPath: NSIndexPath)
  {
    (cell as BankItemCell).isEditingState = editing
  }

  /**
  tableView:willSelectRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath

  :returns: NSIndexPath?
  */
//  override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
//    return rowForIndexPath(indexPath)?.selectionHandler != nil ? indexPath : nil
//  }

  /**
  tableView:didSelectRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath
  */
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    rowForIndexPath(indexPath)?.selectionHandler?()
  }

}

/// MARK: - UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////
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
    if indexPath.section < sections.count {
      let section = sections[indexPath.section]
      if indexPath.row < section.rows.count {
        let row = section.rows[indexPath.row]
        height = row.height
      }
    }
    if expandedRows ∋ indexPath { height += BankItemCell.pickerHeight }
    return height
  }

  /**
  tableView:canEditRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath

  :returns: Bool
  */
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }

  /**
  tableView:commitEditingStyle:forRowAtIndexPath:

  :param: tableView UITableView
  :param: editingStyle UITableViewCellEditingStyle
  :param: indexPath NSIndexPath
  */
  override func tableView(tableView: UITableView,
       commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath)
  {
    if editingStyle == .Delete {
      if let row = rowForIndexPath(indexPath) {
        if row.isDeletable {
          row.deletionHandler?()
          if row.deleteRemovesRow {
            sections[indexPath.section].reloadRows()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
          }
        }
      }
    }
  }

  /**
  tableView:editActionsForRowAtIndexPath:

  :param: tableView UITableView
  :param: indexPath NSIndexPath

  :returns: [AnyObject]?
  */
  override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
    return rowForIndexPath(indexPath)?.editActions
  }

}

extension BankItemDetailController: UITextFieldDelegate {

  /**
  textFieldDidEndEditing:

  :param: textField UITextField
  */
  func textFieldDidEndEditing(textField: UITextField) {
    if textField === nameTextField && textField.text?.length > 0 { item.name = textField.text }
    else { textField.text = item.name }
  }

}
