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
  let context: NSManagedObjectContext!

  lazy var nameTextField: UITextField =  {
    let textField = UITextField(frame: CGRect(x: 70, y: 70, width: 180, height: 30))
    textField.placeholder = "Name"
    textField.font = Bank.boldLabelFont
    textField.textColor = Bank.labelColor
    textField.keyboardAppearance = Bank.keyboardAppearance
    textField.adjustsFontSizeToFitWidth = true
    textField.returnKeyType = .Done
    textField.textAlignment = .Center
    textField.delegate = self
    return textField
    }()

  private(set) var didCancel: Bool = false

  private weak var cellDisplayingPicker: BankItemButtonCell?

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
  override init(style: UITableViewStyle) { super.init(style: style) }

  /**
  initWithCoder:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }


  /**
  initWithItem:

  :param: item BankDisplayItemModel
  */
  required init?(item: BankDisplayItemModel) {
    super.init(style: .Grouped)
    if let moc = (item as? BankableModelObject)?.managedObjectContext {
      context = CoreDataManager.childContextOfType(.MainQueueConcurrencyType, forContext: moc)
      if let objectID = (item as? BankableModelObject)?.objectID {
        self.item = context.existingObjectWithID(objectID, error: nil) as? BankableModelObject
      } else { return nil }
    } else { return nil }
    hidesBottomBarWhenPushed = true
  }

  /** loadView */
  override func loadView() {
    tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: .Grouped)
    tableView?.rowHeight = UITableViewAutomaticDimension
    tableView?.estimatedRowHeight = 200.0
    tableView?.sectionHeaderHeight = 10.0
    tableView?.sectionFooterHeight = 10.0
    tableView?.separatorStyle = .None
    tableView?.delegate = self
    tableView?.dataSource = self
    BankItemCell.registerIdentifiersWithTableView(tableView)
    navigationItem.titleView = nameTextField
    navigationItem.rightBarButtonItem = editButtonItem()
  }

  /** updateDisplay */
  func updateDisplay() {
    nameTextField.text = item.name
    navigationItem.rightBarButtonItem?.enabled = item?.editable ?? false
    didCancel = false
    configureVisibleCells()
  }

  /**
  viewWillAppear:

  :param: animated Bool
  */
  override func viewWillAppear(animated: Bool) { super.viewWillAppear(animated); updateDisplay() }

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
      if nameTextField.isFirstResponder() { nameTextField.resignFirstResponder() }
      navigationItem.rightBarButtonItem?.title = editing ? "Save" : "Edit"
      navigationItem.rightBarButtonItem?.action = editing ? "save" : "edit"
      super.setEditing(editing, animated: animated)
    }
  }

  /** cancel */
  func cancel() {
    item.rollback()
    didCancel = true
    apply(sections) { $0.reloadRows() }
    setEditing(false, animated: true)
    updateDisplay()
  }

  /** edit */
  func edit() { if !editing { setEditing(true, animated: true) } }

  /** save */
  func save() { item.save(); setEditing(false, animated: true) }

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
  */
  func reloadRowsAtIndexPaths(indexPaths: [NSIndexPath]) {
    for indexPath in indexPaths {
      if indexPath.section < sections.count {
        let section = sections[indexPath.section]
        if indexPath.row < section.rows.count {
          section.reloadRowAtIndex(indexPath.row)
        }
      }
    }
    configureCellsAtIndexPaths(indexPaths)
  }


  /** configureVisibleCells */
  func configureVisibleCells() {
    if let visibleIndexPaths = tableView.indexPathsForVisibleRows() as? [NSIndexPath] {
      configureCellsAtIndexPaths(visibleIndexPaths)
    }
  }

  /**
  configureCellsAtIndexPaths:

  :param: indexPaths [NSIndexPath]
  */
  func configureCellsAtIndexPaths(indexPaths: [NSIndexPath]) {
    applyToRowsAtIndexPaths(indexPaths) {
      (row: BankItemDetailRow) -> Void in
        if let cell = self.tableView.cellForRowAtIndexPath(row.indexPath) as? BankItemCell {
          row.configureCell(cell, forTableView: self.tableView)
        }
    }
  }

  /**
  applyToRowsAtIndexPaths:block:

  :param: indexPaths [NSIndexPath]
  :param: block (BankItemDetailRow) -> Void
  */
  func applyToRowsAtIndexPaths(indexPaths: [NSIndexPath], block: (BankItemDetailRow) -> Void) {
    if let visibleIndexPaths = tableView.indexPathsForVisibleRows() as? [NSIndexPath] {
      apply(rowsForIndexPaths(indexPaths ∩ visibleIndexPaths), block)
    }
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
  rowsForIndexPaths:

  :param: indexPaths [NSIndexPath]

  :returns: [BankItemDetailRow]
  */
  private func rowsForIndexPaths(indexPaths: [NSIndexPath]) -> [BankItemDetailRow] {
    var rows: [BankItemDetailRow] = []
    for indexPath in indexPaths { if let row = rowForIndexPath(indexPath) { rows.append(row) } }
    return rows
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
      if let buttonCell = cell as? BankItemButtonCell {
        buttonCell.didShowPicker = {
          (c: BankItemButtonCell) -> Void in
            if self.cellDisplayingPicker != nil {
              self.cellDisplayingPicker!.hidePickerView()
            }
            self.cellDisplayingPicker = c
            self.tableView.beginUpdates()
            self.tableView.endUpdates()

        }
        buttonCell.didHidePicker = {
          (c: BankItemButtonCell) -> Void in
            self.cellDisplayingPicker = nil
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        buttonCell.shouldShowPicker = {
          (c: BankItemButtonCell) -> Bool in
            if self.cellDisplayingPicker != nil {
              self.cellDisplayingPicker!.hidePickerView()
              return false
            } else {
              return true
            }
        }
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
    rowForIndexPath(indexPath)?.configureCell(cell, forTableView: tableView)
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
    if let row = rowForIndexPath(indexPath) { return row.editingStyle }
    else { return .None }
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
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int { return sections.count }


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
//  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//    var height: CGFloat = 0.0
//    if indexPath.section < sections.count {
//      let section = sections[indexPath.section]
//      if indexPath.row < section.rows.count {
//        let row = section.rows[indexPath.row]
//        height = row.height
//      }
//    }
//    if expandedRows ∋ indexPath { height += BankItemCell.pickerHeight }
//    return height
//  }

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

/// MARK: - UITextFieldDelegate
////////////////////////////////////////////////////////////////////////////////

extension BankItemDetailController: UITextFieldDelegate {

  /**
  textFieldShouldReturn:

  :param: textField UITextField

  :returns: Bool
  */
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    precondition(textField === nameTextField, "what other text fields are we delegating besides name label?")
    textField.resignFirstResponder()
    return false
  }

  /**
  textFieldDidEndEditing:

  :param: textField UITextField
  */
  func textFieldDidEndEditing(textField: UITextField) {
    precondition(textField === nameTextField, "what other text fields are we delegating besides name label?")
    if textField.text?.length > 0 { item.name = textField.text }
    else { textField.text = item.name }
  }

}
