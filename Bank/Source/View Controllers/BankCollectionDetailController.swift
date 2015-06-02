//
//  BankCollectionDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 6/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit
import DataModel

class BankCollectionDetailController: UICollectionViewController {

  typealias Section = BankModelDetailDelegate.Section
  typealias Row = Section.Row
  typealias Header = BankCollectionDetailSectionHeader
  typealias Cell = BankCollectionDetailCell
  typealias SectionKey = BankModelDetailDelegate.SectionKey
  typealias SectionIndex = BankModelDetailDelegate.SectionIndex

  // MARK: - Properties

  let itemDelegate: BankModelDetailDelegate

  private(set) var didCancel: Bool = false

  private(set) weak var cellDisplayingPicker: BankCollectionDetailButtonCell?

  // MARK: - Initializers

  /**
  Initialize with an item's delegate

  :param: itemDelegate BankModelDetailDelegate
  */
  init(itemDelegate delegate: BankModelDetailDelegate) {
    itemDelegate = delegate
    super.init(collectionViewLayout: BankCollectionDetailLayout())
    hidesBottomBarWhenPushed = true
  }

  required init(coder aDecoder: NSCoder) { fatalError("init(coder aDecoder: NSCoder) not supported") }

  // MARK: - Loading

  /** loadSections */
  func loadSections() { itemDelegate.loadSections(controller: self) }

  /** loadView */
  override func loadView() {
    title = itemDelegate.item.name
    navigationItem.rightBarButtonItem = editButtonItem()

    let textField = UITextField(frame: CGRect(x: 70, y: 70, width: 180, height: 30))
    textField.placeholder = "Name"
    textField.font = Bank.boldLabelFont
    textField.textColor = Bank.labelColor
    textField.keyboardAppearance = Bank.keyboardAppearance
    textField.adjustsFontSizeToFitWidth = true
    textField.returnKeyType = .Done
    textField.textAlignment = .Center
    textField.delegate = self
    navigationItem.titleView = textField

    collectionView = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: self.collectionViewLayout)
    collectionView!.backgroundColor = Bank.backgroundColor
    Cell.registerIdentifiersWithCollectionView(collectionView!)
    Header.registerIdentifiersWithCollectionView(collectionView!)
  }

  // MARK: - Updating


  /** Configures right bar button item, resets `didCancel` flag, configures visible cells, loads sections and reloads data */
  func updateDisplay() {
    navigationItem.rightBarButtonItem?.enabled = itemDelegate.item.editable
    (navigationItem.titleView as? UITextField)?.text = itemDelegate.item.name
    didCancel = false
    configureVisibleCells()
    loadSections()
    collectionView?.reloadData()
 }

 /**
 reloadItemAtIndexPath:

 :param: indexPath NSIndexPath
 */
 func reloadItemAtIndexPath(indexPath: NSIndexPath) { collectionView?.reloadItemsAtIndexPaths([indexPath]) }

 func reloadSection(section: Section) { collectionView?.reloadSections(NSIndexSet(index: section.section)) }

  /**
  Updates display

  :param: animated Bool
  */
  override func viewWillAppear(animated: Bool) { super.viewWillAppear(animated); updateDisplay() }

  /** Invokes `configureCell` for each `Row` associated with a visible cell */
  func configureVisibleCells() {
    if let indexPaths = collectionView?.indexPathsForVisibleItems() as? [NSIndexPath],
      cells = collectionView?.visibleCells() as? [Cell]
    {
      apply(zip(indexPaths, cells)) { indexPath, cell in self[indexPath]?.configureCell(cell) }
    }
  }

  // MARK: - Navigation bar actions

  /**
  Updates `navigationItem` and the calls `super`'s implementation, if current value for `editing` differs from parameter

  :param: editing Bool
  :param: animated Bool
  */
  override func setEditing(editing: Bool, animated: Bool) {
    if self.editing != editing {
      navigationItem.leftBarButtonItem = editing
                                           ? UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
                                           : nil
      navigationItem.rightBarButtonItem?.title  = editing ? "Save" : "Edit"
      navigationItem.rightBarButtonItem?.action = editing ? "save" : "edit"
      if let textField = navigationItem.titleView as? UITextField {
        textField.userInteractionEnabled = editing
        if textField.isFirstResponder() { textField.resignFirstResponder() }
      }
      super.setEditing(editing, animated: animated)
    }
  }

  /** Invokes `rollback` on `item`, sets `didCancel` flag to true, sets `editing` to false and refresh display */
  func cancel() {
    itemDelegate.item.rollback()
    didCancel = true
    setEditing(false, animated: true)
    updateDisplay()
  }

  /** edit */
  func edit() { if !editing { setEditing(true, animated: true) } }

  /** Invokes `save` on `item` if the item is `Editable`. Afterwards, `editing` is set to `false` */
  func save() { itemDelegate.item.save(); setEditing(false, animated: true) }

  // MARK: - Subscripting

  /**
  Accessor for `Row` objects by `NSIndexPath`

  :param: indexPath NSIndexPath

  :returns: Row?
  */
  subscript(indexPath: NSIndexPath) -> Row? { return self[indexPath.row, indexPath.section] }

  /**
  Accessor for `Section` objects by index

  :param: section Int

  :returns: Section?
  */
  subscript(section: Int) -> Section? {
    return section < itemDelegate.sections.count ? itemDelegate.sections.values[section] : nil
  }

  /**
  Accessor for the `Row` identified by row and section

  :param: row Int
  :param: section Int

  :returns: Row?
  */
  subscript(row: Int, section: Int) -> Row? { return self[section]?[row] }

}

// MARK: - UICollectionViewDataSource

extension BankCollectionDetailController: UICollectionViewDataSource {

  /**
  numberOfSectionsInCollectionView:

  :param: collectionView UICollectionView

  :returns: Int
  */
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return itemDelegate.sections.count
  }

  /**
  collectionView:numberOfItemsInSection:

  :param: collectionView UICollectionView
  :param: section Int

  :returns: Int
  */
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self[section]?.count ?? 0
  }

  /**
  collectionView:cellForItemAtIndexPath:

  :param: collectionView UICollectionView
  :param: indexPath NSIndexPath

  :returns: UICollectionViewCell
  */
  override func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
  {
    let identifier = self[indexPath]!.identifier
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier.rawValue,
                                                        forIndexPath: indexPath) as! Cell

    // Set picker related handlers if the cell is a button cell
    if let buttonCell = cell as? BankCollectionDetailButtonCell {

      // Set handler for showing picker row for this button cell
      buttonCell.showPickerRow = {

        // Check if we are already showing a picker row
        if let cell = self.cellDisplayingPicker {

          // Remove existing picker row
          cell.hidePickerView()

          // Return false if this handler was invoked by the same cell
          if cell === $0 { return false }

        }

        // Ensure we actually have a picker row to insert
        if $0.detailPickerRow == nil { return false }

        if let cellIndexPath = self.collectionView?.indexPathForCell($0) {

          // Create an index path for the row after the button cell's row
          let pickerPath = NSIndexPath(forRow: cellIndexPath.row + 1, inSection: cellIndexPath.section)

          // Insert row into our section
          self.itemDelegate.sections.values[pickerPath.section].insertRow($0.detailPickerRow!,
                                                                  atIndex: pickerPath.row,
                                                                   forKey: "Picker")

          self.collectionView?.insertItemsAtIndexPaths([pickerPath])

          // Scroll to the inserted row
          self.collectionView?.scrollToItemAtIndexPath(pickerPath, atScrollPosition: .CenteredVertically, animated: true)

          // Update reference to cell displaying picker row
          self.cellDisplayingPicker = $0

          return true
        }

        return false
      }

      // Set handler for hiding picker row for this button cell
      buttonCell.hidePickerRow = {

        // Check if the cell invoking this handler is actually the cell whose picker we are showing
        if self.cellDisplayingPicker !== $0 { return false }

        if let cellIndexPath = self.collectionView?.indexPathForCell($0) {

          // Create an index path for the row after the button cell's row
          let pickerPath = NSIndexPath(forRow: cellIndexPath.row + 1, inSection: cellIndexPath.section)

          if !(self[pickerPath] is BankCollectionDetailPickerRow) { return false }

          // Remove the row from our section
          self[pickerPath.section]?.removeRowAtIndex(pickerPath.row)

          self.collectionView?.deleteItemsAtIndexPaths([pickerPath])

          // Update reference to cell displaying picker row
          self.cellDisplayingPicker = nil

          return true
        }

        return false
      }

    } // end if

    self[indexPath]?.configureCell(cell)
    return cell
  }

  /**
  collectionView:viewForSupplementaryElementOfKind:atIndexPath:

  :param: collectionView UICollectionView
  :param: kind String
  :param: indexPath NSIndexPath

  :returns: UICollectionReusableView
  */
  override func collectionView(collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
                   atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
  {
    assert(kind == "Header")
    let detailSection = itemDelegate.sections.values[indexPath.section]
    let identifier = detailSection.identifier.rawValue
    let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                                                   withReuseIdentifier: identifier,
                                                          forIndexPath: indexPath) as! Header
    detailSection.configureHeader(header)
    return header
  }

}

extension BankCollectionDetailController: BankCollectionDetailLayoutDataSource {

  /**
  collectionView:itemTypesInSection:

  :param: collectionView UICollectionView
  :param: section Int

  :returns: [BankCollectionDetailLayout.ItemType]
  */
  func collectionView(collectionView: UICollectionView,
   itemTypesInSection section: Int) -> [BankCollectionDetailLayout.ItemType]
  {
    return map(itemDelegate.sections.values[section].rows, {$0.identifier})
  }

  /**
  headerTypesInCollectionView:

  :param: collectionView UICollectionView

  :returns: [BankCollectionDetailLayout.HeaderType?]
  */
  func headerTypesInCollectionView(collectionView: UICollectionView) -> [BankCollectionDetailLayout.HeaderType?] {
    return map(itemDelegate.sections.values, {$0.title != nil ? $0.identifier : nil})
  }

}

extension BankCollectionDetailController: UICollectionViewDelegate {

  /**
  collectionView:willDisplayCell:forItemAtIndexPath:

  :param: collectionView UICollectionView
  :param: cell UICollectionViewCell
  :param: indexPath NSIndexPath
  */
  override func collectionView(collectionView: UICollectionView,
               willDisplayCell cell: UICollectionViewCell,
            forItemAtIndexPath indexPath: NSIndexPath)
  {
    (cell as? Cell)?.editing = editing
  }

  /**
  collectionView:didSelectItemAtIndexPath:

  :param: collectionView UICollectionView
  :param: indexPath NSIndexPath
  */
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    self[indexPath]?.select?()
  }

}

/// MARK: - UITextFieldDelegate
////////////////////////////////////////////////////////////////////////////////

extension BankCollectionDetailController: UITextFieldDelegate {

  /**
  textFieldShouldReturn:

  :param: textField UITextField

  :returns: Bool
  */
  func textFieldShouldReturn(textField: UITextField) -> Bool { textField.resignFirstResponder(); return false }

  /**
  textFieldDidEndEditing:

  :param: textField UITextField
  */
  func textFieldDidEndEditing(textField: UITextField) {
    if textField.text?.length > 0 { itemDelegate.item.name = textField.text }
    else { textField.text = itemDelegate.item.name }
  }

}


/// MARK: - Utility functions

extension BankCollectionDetailController {

  /**
  Attempts to have navigation controller push the specified view controller

  :param: controller UIViewController
  */
  func pushController(controller: UIViewController) {
    (UIApplication.sharedApplication().keyWindow?.rootViewController as? UINavigationController)?
      .pushViewController(controller, animated: true)
  }

}

