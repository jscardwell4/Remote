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

  // MARK: - Initializers

  /**
  Initialize with an item's delegate

  - parameter itemDelegate: BankModelDetailDelegate
  */
  init(itemDelegate delegate: BankModelDetailDelegate) {
    itemDelegate = delegate
    let layout = BankCollectionDetailLayout()
    super.init(collectionViewLayout: layout)
    layout.delegate = self
    hidesBottomBarWhenPushed = true
  }

  required init?(coder aDecoder: NSCoder) { fatalError("init?(coder aDecoder: NSCoder) not supported") }

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

 - parameter indexPath: NSIndexPath
 */
 func reloadItemAtIndexPath(indexPath: NSIndexPath) { collectionView?.reloadItemsAtIndexPaths([indexPath]) }

 func reloadSection(section: Section) { collectionView?.reloadSections(NSIndexSet(index: section.section)) }

  /**
  Updates display

  - parameter animated: Bool
  */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    toolbarItems = Bank.toolbarItemsForController(self)
    updateDisplay()
  }

  /** Invokes `configureCell` for each `Row` associated with a visible cell */
  func configureVisibleCells() {
    if let indexPaths = collectionView?.indexPathsForVisibleItems(),
      cells = collectionView?.visibleCells() as? [Cell]
    {
      apply(zip(indexPaths, cells)) { indexPath, cell in self[indexPath]?.configureCell(cell) }
    }
  }

  // MARK: - Navigation bar actions

  /**
  Updates `navigationItem` and the calls `super`'s implementation, if current value for `editing` differs from parameter

  - parameter editing: Bool
  - parameter animated: Bool
  */
  override func setEditing(editing: Bool, animated: Bool) {
    if self.editing != editing {
      navigationItem.leftBarButtonItem = editing
                                           ? UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
                                           : nil
      navigationItem.rightBarButtonItem?.title  = editing ? "Save" : "Edit"
      navigationItem.rightBarButtonItem?.action = editing ? "save" : "edit"
      if !editing { view.endEditing(true) }
//      if let textField = navigationItem.titleView as? UITextField {
//        textField.userInteractionEnabled = editing
//        if textField.isFirstResponder() { textField.resignFirstResponder() }
//      }
      if let cells = collectionView?.visibleCells() as? [Cell] { apply(cells) {$0.editing = editing} }
      // TODO: Need to propagate changes here when editing has been completed
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

  - parameter indexPath: NSIndexPath

  - returns: Row?
  */
  subscript(indexPath: NSIndexPath) -> Row? { return self[indexPath.row, indexPath.section] }

  /**
  Accessor for `Section` objects by index

  - parameter section: Int

  - returns: Section?
  */
  subscript(section: Int) -> Section? {
    return section < itemDelegate.sections.count ? itemDelegate.sections.values[section] : nil
  }

  /**
  Accessor for the `Row` identified by row and section

  - parameter row: Int
  - parameter section: Int

  - returns: Row?
  */
  subscript(row: Int, section: Int) -> Row? { return self[section]?[row] }

  /**
  itemTypesInSection:

  - parameter section: Int

  - returns: [BankCollectionDetailLayout.ItemType]
  */
  func itemTypesInSection(section: Int) -> [BankCollectionDetailLayout.ItemType] {
    return itemDelegate.sections.values[section].rows.map({$0.identifier})
  }

  var headerTypes: [BankCollectionDetailLayout.HeaderType?] {
    return itemDelegate.sections.values.map({$0.title != nil ? $0.identifier : nil})
  }

  private var endDiscovery: (() -> Void)?

}

// MARK: - UICollectionViewDataSource

extension BankCollectionDetailController {

  /**
  numberOfSectionsInCollectionView:

  - parameter collectionView: UICollectionView

  - returns: Int
  */
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return itemDelegate.sections.count
  }

  /**
  collectionView:numberOfItemsInSection:

  - parameter collectionView: UICollectionView
  - parameter section: Int

  - returns: Int
  */
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self[section]?.count ?? 0
  }

  /**
  collectionView:cellForItemAtIndexPath:

  - parameter collectionView: UICollectionView
  - parameter indexPath: NSIndexPath

  - returns: UICollectionViewCell
  */
  override func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
  {
    let identifier = self[indexPath]!.identifier
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier.rawValue,
                                                        forIndexPath: indexPath) as! Cell
    self[indexPath]?.configureCell(cell)

    return cell
  }

  /**
  collectionView:viewForSupplementaryElementOfKind:atIndexPath:

  - parameter collectionView: UICollectionView
  - parameter kind: String
  - parameter indexPath: NSIndexPath

  - returns: UICollectionReusableView
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

extension BankCollectionDetailController {

  /**
  collectionView:willDisplayCell:forItemAtIndexPath:

  - parameter collectionView: UICollectionView
  - parameter cell: UICollectionViewCell
  - parameter indexPath: NSIndexPath
  */
  override func collectionView(collectionView: UICollectionView,
               willDisplayCell cell: UICollectionViewCell,
            forItemAtIndexPath indexPath: NSIndexPath)
  {
    (cell as? Cell)?.editing = editing
  }

  /**
  collectionView:didSelectItemAtIndexPath:

  - parameter collectionView: UICollectionView
  - parameter indexPath: NSIndexPath
  */
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    (collectionView.cellForItemAtIndexPath(indexPath) as? BankCollectionDetailCell)?.select?()
  }

}

/// MARK: - UITextFieldDelegate
////////////////////////////////////////////////////////////////////////////////

extension BankCollectionDetailController: UITextFieldDelegate {

  /**
  textFieldShouldReturn:

  - parameter textField: UITextField

  - returns: Bool
  */
  func textFieldShouldReturn(textField: UITextField) -> Bool { textField.resignFirstResponder(); return false }

  /**
  textFieldDidEndEditing:

  - parameter textField: UITextField
  */
  func textFieldDidEndEditing(textField: UITextField) {
    if textField.text?.length > 0 { itemDelegate.item.name = textField.text! }
    else { textField.text = itemDelegate.item.name }
  }

}

// MARK: - Utility functions

extension BankCollectionDetailController {

  /**
  Attempts to have navigation controller push the specified view controller

  - parameter controller: UIViewController
  */
  func pushController(controller: UIViewController) {
    (UIApplication.sharedApplication().keyWindow?.rootViewController as? UINavigationController)?
      .pushViewController(controller, animated: true)
  }

}

