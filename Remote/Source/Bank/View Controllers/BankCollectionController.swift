//
//  BankCollectionController.swift
//  Remote
//
//  Created by Jason Cardwell on 9/18/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

// TODO: Add editing state or swipe-to-delete

private let IndicatorImage             = UIImage(named:"1040-checkmark-toolbar")!
private let IndicatorImageSelected     = UIImage(named:"1040-checkmark-toolbar-selected")!
private let TextFieldTextColor         = UIColor(RGBAHexString:"#9FA0A4FF")
private let ItemCellIdentifier         = "ItemCell"
private let CategoryCellIdentifier     = "CategoryCell"
private let HeaderIdentifier           = "Header"

@objc(BankCollectionController)
class BankCollectionController: UICollectionViewController, BankController {

  var category: BankDisplayItemCategory!

  private var cellShowingDelete: BankCollectionCell?

  /**
  showingDeleteDidChange:

  :param: cell BankCollectionCell
  */
  func showingDeleteDidChange(cell: BankCollectionCell) {
    cellShowingDelete?.hideDelete()
    cellShowingDelete = cell.showingDelete ? cell : nil
  }

  private var layout: BankCollectionLayout { return collectionViewLayout as BankCollectionLayout }

  private var exportSelection: [MSJSONExport] = []

  let exportButton = UIBarButtonItem(title: "Export", style: .Done, target: nil, action: "confirmExport:")
  let selectAllButton = UIBarButtonItem(title: "Select All", style: .Plain, target: nil, action: "selectAll:")

  private var exportSelectionMode: Bool = false {
    didSet {

      // Create some variables to hold values for common actions to perform
      var rightBarButtonItems: [UIBarButtonItem]
      var cellIndicatorImage: UIImage?

      // Determine if we are entering or leaving export selection mode
      if exportSelectionMode {

        exportSelection.removeAll(keepCapacity: false)  // If entering, make sure our export items collection is empty

        // And, make sure no cells are selected
        if let indexPaths = collectionView.indexPathsForSelectedItems() as? [NSIndexPath] {
          for indexPath in indexPaths { collectionView.deselectItemAtIndexPath(indexPath, animated: true) }
        }

        // Set right bar button items
        rightBarButtonItems = [exportButton, selectAllButton]


        cellIndicatorImage = IndicatorImage  // Set indicator image


      } else {
        
        rightBarButtonItems = [ Bank.dismissBarButtonItem ]

      }

      collectionView.allowsMultipleSelection = exportSelectionMode  // Update selection mode

      navigationItem.rightBarButtonItems = rightBarButtonItems  // Update right bar button items

      // Update visible cells
      collectionView.setValue(cellIndicatorImage, forKeyPath: "visibleCells.indicatorImage")

    }
  }

  var viewingMode: BankCollectionAttributes.ViewingMode = .List {
    didSet { layout.viewingMode = viewingMode; displayOptionsControl?.selectedSegmentIndex = viewingMode.rawValue }
  }

  /**
  initWithCategory:

  :param: category BankDisplayItemCategory
  */
  init?(category: BankDisplayItemCategory) {
    super.init(collectionViewLayout: BankCollectionLayout())
    self.category = category
    exportButton.target = self
    selectAllButton.target = self
  }

  private weak var displayOptionsControl: ToggleImageSegmentedControl?

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** loadView */
  override func loadView() {

    title = category.title

    collectionView = {

      // Create the collection view
      let collectionView = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: self.layout)
      collectionView.backgroundColor = Bank.backgroundColor

      // Register header and cell classes
      collectionView.registerClass(BankCollectionCategoryCell.self, forCellWithReuseIdentifier: CategoryCellIdentifier)
      collectionView.registerClass(BankCollectionItemCell.self, forCellWithReuseIdentifier: ItemCellIdentifier)
      return collectionView

    }()


    toolbarItems = {

      // Check if we should include viewing mode control
      if self.category.previewableItems {

        // Create the segmented control
        let displayOptions = ToggleImageSegmentedControl(items: [UIImage(named: "1073-grid-1-toolbar")!,
                                                                 UIImage(named: "1073-grid-1-toolbar-selected")!,
                                                                 UIImage(named: "1076-grid-4-toolbar")!,
                                                                 UIImage(named: "1076-grid-4-toolbar-selected")!])
        displayOptions.selectedSegmentIndex = self.viewingMode.rawValue
        displayOptions.toggleAction = {[unowned self] control in
          self.viewingMode = BankCollectionAttributes.ViewingMode(rawValue: control.selectedSegmentIndex)!
          SettingsManager.setValue(self.viewingMode.rawValue, forSetting: .BankViewingMode)
        }
        let displayOptionsItem = UIBarButtonItem(customView: displayOptions)
        self.displayOptionsControl = displayOptions

        // Return the toolbar with segmented control added
        return Bank.toolbarItemsForController(self, addingItems: [displayOptionsItem])
      }

      // Otherwise return the default toolbar items
      return Bank.toolbarItemsForController(self)
    }()

  }

  /**
  viewWillAppear:

  :param: animated Bool
  */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    exportSelectionMode = false
    navigationItem.rightBarButtonItem = Bank.dismissBarButtonItem

    if let modeSettingValue = SettingsManager.valueForSetting(.BankViewingMode) as? NSNumber {
      if let mode = BankCollectionAttributes.ViewingMode(rawValue: modeSettingValue.integerValue) {
        viewingMode = mode
      }
    }
  }


  ////////////////////////////////////////////////////////////////////////////////
  /// MARK: - Exporting items
  ////////////////////////////////////////////////////////////////////////////////


  /**
  confirmExport:

  :param: sender AnyObject
  */
  func confirmExport(sender: AnyObject?) {
    ImportExportFileManager.confirmExportOfItems(exportSelection) {
      (success: Bool) -> Void in
        self.exportSelectionMode = false
    }
  }

  /**
  exportBankObject:

  :param: sender AnyObject?
  */
  func exportBankObjects() { exportSelectionMode = !exportSelectionMode }


  ////////////////////////////////////////////////////////////////////////////////
  /// MARK: - Actions
  ////////////////////////////////////////////////////////////////////////////////


  /**
  deleteItemAtIndexPath:

  :param: indexPath NSIndexPath
  */
  func deleteItemAtIndexPath(indexPath: NSIndexPath) {
    switch indexPath.section {
      case 0:
        let subcategory = category.subcategories[indexPath.row]
        category.subcategories.removeAtIndex(indexPath.row)
        subcategory.delete()

      default:
        let item = category.items[indexPath.row]
        category.items.removeAtIndex(indexPath.row)
        item.delete()

    }
    collectionView.deleteItemsAtIndexPaths([indexPath])
  }

  /**
  editItem:

  :param: item BankDisplayItemModel
  */
  func editItem(item: BankDisplayItemModel) {
    let detailController = item.detailController()
    detailController.editing = true
    navigationController?.pushViewController(detailController, animated: true)
  }

  /**
  detailItemAtIndexPath:

  :param: indexPath NSIndexPath
  */
  func detailItemAtIndexPath(indexPath: NSIndexPath) {
    switch indexPath.section {
      case 0:
        if let controller = BankCollectionController(category: category.subcategories[indexPath.row]) {
          navigationController?.pushViewController(controller, animated: true)
        }
      default:
        navigationController?.pushViewController(category.items[indexPath.row].detailController(), animated: true)
    }
  }

  /**
  importBankObject:

  :param: sender AnyObject?
  */
  func importBankObjects() { MSLogInfo("item import not yet implemented")  }


  ////////////////////////////////////////////////////////////////////////////////
  /// MARK: - Zooming a cell's item
  ////////////////////////////////////////////////////////////////////////////////


  private var zoomedItemIndexPath: NSIndexPath?

  /**
  zoomItemAtIndexPath:

  :param: indexPath NSIndexPath
  */
  func zoomItemAtIndexPath(indexPath: NSIndexPath) {
    precondition(indexPath.section == 1, "we should only be zooming actual items")
    let zoomView = BankCollectionZoomView(frame: view.bounds, delegate: self)
    zoomView.item = category.items[indexPath.row]
    zoomView.backgroundImage = view.blurredSnapshot()
    view.addSubview(zoomView)
    view.constrainWithFormat("zoom.center = self.center", views: ["zoom": zoomView])
  }

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - BankCollectionZoomViewDelegate
////////////////////////////////////////////////////////////////////////////////
extension BankCollectionController: BankCollectionZoomViewDelegate {

  /**
  didDismissZoomView:

  :param: zoom BankCollectionZoomView
  */
  func didDismissZoomView(zoomView: BankCollectionZoomView) {
    zoomView.removeFromSuperview()
    zoomedItemIndexPath = nil
  }

  /**
  didDismissForDetailZoomView:

  :param: zoom BankCollectionZoomView
  */
  func didDismissForDetailZoomView(zoomView: BankCollectionZoomView) {
    zoomView.removeFromSuperview()
    detailItemAtIndexPath(zoomedItemIndexPath!)
    zoomedItemIndexPath = nil
  }

  /**
  didDismissForEditingZoomView:

  :param: zoom BankCollectionZoomView
  */
  func didDismissForEditingZoomView(zoomView: BankCollectionZoomView) {
    zoomView.removeFromSuperview()
    editItem(zoomView.item!)
    zoomedItemIndexPath = nil
  }

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - Selecting/deselecting
////////////////////////////////////////////////////////////////////////////////
extension BankCollectionController {

  /**
  selectAll:

  :param: sender AnyObject!
  */
  override func selectAll(sender: AnyObject!) {

    // Make sure we are in export selection mode
    if exportSelectionMode {

      exportSelection.removeAll(keepCapacity: true)
      exportSelection.reserveCapacity(category.subcategories.count + category.items.count)

      for (i, subcategory) in enumerate(category.subcategories) {
        exportSelection.append(subcategory)
        let indexPath = NSIndexPath(forRow: i, inSection: 0)
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? BankCollectionCell {
          cell.indicatorImage = IndicatorImageSelected
        }
      }

      for (i, item) in enumerate(category.items) {
        exportSelection.append(item)
        let indexPath = NSIndexPath(forRow: i, inSection: 1)
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? BankCollectionCell {
          cell.indicatorImage = IndicatorImageSelected
        }
      }

    }

  }

  /**
  deselectAll:

  :param: sender AnyObject!
  */
  func deselectAll(sender: AnyObject!) {

    // Make sure we are in export selection mode
    if exportSelectionMode {

      // Remove all the items from export selection
      exportSelection.removeAll(keepCapacity: false)

      // Enumerate the selected index paths
      for indexPath in collectionView.indexPathsForSelectedItems() as [NSIndexPath] {

        // Deselect the cell
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)

        // Update the cell image if it is visible
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? BankCollectionCell {
          cell.indicatorImage = IndicatorImage
        }

      }

    }

  }

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - UICollectionViewDataSource
////////////////////////////////////////////////////////////////////////////////
extension BankCollectionController: UICollectionViewDataSource {

  /**
  collectionView:numberOfItemsInSection:

  :param: collectionView UICollectionView
  :param: section Int

  :returns: Int
  */
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return section == 0 ? category.subcategories.count  : category.items.count
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
    switch indexPath.section {
      case 0:
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CategoryCellIdentifier,
                                                            forIndexPath: indexPath) as BankCollectionCategoryCell
        let subcategory = category.subcategories[indexPath.row]
        cell.category = subcategory
        if subcategory.editable { cell.deleteAction = {self.deleteItemAtIndexPath(indexPath)} }
        cell.showingDeleteDidChange = showingDeleteDidChange
        return cell

      default:
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ItemCellIdentifier,
                                                            forIndexPath: indexPath) as BankCollectionItemCell
        let item = category.items[indexPath.row]
        cell.item = item
        if item.editable { cell.deleteAction = {self.deleteItemAtIndexPath(indexPath)} }
        cell.showingDeleteDidChange = showingDeleteDidChange
        cell.previewActionHandler = {self.zoomItemAtIndexPath(indexPath)}
        return cell
    }
  }

  /**
  numberOfSectionsInCollectionView:

  :param: collectionView UICollectionView

  :returns: Int
  */
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int { return 2 }

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - UICollectionViewDelegate
////////////////////////////////////////////////////////////////////////////////
extension BankCollectionController: UICollectionViewDelegate {

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
    let isSelected = (collectionView.indexPathsForSelectedItems() as [NSIndexPath]) ∋ indexPath
    if let bankCell = cell as? BankCollectionCell {
      bankCell.indicatorImage = exportSelectionMode ? (isSelected ? IndicatorImageSelected : IndicatorImage) : nil
    }
  }

  /**
  collectionView:didDeselectItemAtIndexPath:

  :param: collectionView UICollectionView
  :param: indexPath NSIndexPath
  */
  override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
    if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? BankCollectionCell {
      // Check if we are selecting items to export
      if exportSelectionMode {
        // Remove the item and update the cell's indicator image
        exportSelection.removeAtIndex((exportSelection as NSArray).indexOfObject(cell.exportItem!))
        cell.indicatorImage = IndicatorImage
        if exportSelection.count == 0 { exportButton.enabled = false }
      }
    }
  }

  /**
  collectionView:didSelectItemAtIndexPath:

  :param: collectionView UICollectionView
  :param: indexPath NSIndexPath
  */
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
  	if cellShowingDelete != nil {
      cellShowingDelete!.hideDelete()
    } else if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? BankCollectionCell {
      if exportSelectionMode {
        exportSelection.append(cell.exportItem!)
        cell.indicatorImage = IndicatorImageSelected
        if !exportButton.enabled { exportButton.enabled = true }
      } else {
        detailItemAtIndexPath(indexPath)
      }
    }
  }

}
