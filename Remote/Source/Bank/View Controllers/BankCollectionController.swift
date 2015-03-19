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

// TODO: Viewing mode changes need to respect whether category items are `previewable`

class BankCollectionController: UICollectionViewController, BankController {

	private let itemCellIdentifier = "ItemCell"
	private let categoryCellIdentifier = "CategoryCell"

  var category: BankCategory!

  enum Mode { case Default, Selection }

  private let mode: Mode

  private var cellShowingDelete: BankCollectionCell?


  var selectionDelegate: BankItemSelectionDelegate?

  /**
  showingDeleteDidChange:

  :param: cell BankCollectionCell
  */
  func showingDeleteDidChange(cell: BankCollectionCell) {
    cellShowingDelete?.hideDelete()
    cellShowingDelete = cell.showingDelete ? cell : nil
  }

  private var layout: BankCollectionLayout { return collectionViewLayout as! BankCollectionLayout }

  private(set) var exportSelection: [MSJSONExport] = []

  var exportButton: BlockBarButtonItem!
  var selectAllButton: BlockBarButtonItem!

  var exportSelectionMode: Bool = false {
    didSet {

      // Create some variables to hold values for common actions to perform
      var rightBarButtonItems: [UIBarButtonItem]
      var showIndicator = false

      // Determine if we are entering or leaving export selection mode
      if exportSelectionMode {

        exportSelection.removeAll(keepCapacity: false)  // If entering, make sure our export items collection is empty

        // And, make sure no cells are selected
        if let indexPaths = collectionView?.indexPathsForSelectedItems() as? [NSIndexPath] {
          for indexPath in indexPaths { collectionView?.deselectItemAtIndexPath(indexPath, animated: true) }
        }

        // Set right bar button items
        rightBarButtonItems = [exportButton, selectAllButton]

        showIndicator = true


      } else {

        rightBarButtonItems = [ Bank.dismissBarButtonItem ]

      }

      collectionView?.allowsMultipleSelection = exportSelectionMode  // Update selection mode

      navigationItem.rightBarButtonItems = rightBarButtonItems  // Update right bar button items

      // Update visible cells
      for cell in collectionView?.visibleCells() as! [BankCollectionCell] {
      	cell.showIndicator(showIndicator)
      }

    }
  }

  var viewingMode: BankCollectionAttributes.ViewingMode = .List {
    didSet { layout.viewingMode = viewingMode; displayOptionsControl?.selectedSegmentIndex = viewingMode.rawValue }
  }

  /**
  initWithCategory:

  :param: category BankItemCategory
  */
  init?(category: BankCategory, mode: Mode = .Default) {
  	self.mode = mode
    super.init(collectionViewLayout: BankCollectionLayout())
    self.category = category
    if mode == .Default {
	    exportButton = Bank.exportBarButtonItemForController(self)
	    selectAllButton = Bank.selectAllBarButtonItemForController(self)
	  }
  }

  private weak var displayOptionsControl: ToggleImageSegmentedControl?

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { mode = .Default; super.init(coder: aDecoder) }

  /** loadView */
  override func loadView() {

    title = category.name

    collectionView = {

      // Create the collection view
      let collectionView = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: self.layout)
      collectionView.backgroundColor = Bank.backgroundColor

      // Register header and cell classes
      collectionView.registerClass(BankCollectionCategoryCell.self, forCellWithReuseIdentifier: self.categoryCellIdentifier)
      collectionView.registerClass(BankCollectionItemCell.self, forCellWithReuseIdentifier: self.itemCellIdentifier)
      return collectionView

    }()

    if mode == .Default {

	    toolbarItems = {

	      // Check if we should include viewing mode control
	      if self.category is PreviewableCategory {

	        // Create the segmented control
	        let displayOptions = ToggleImageSegmentedControl(items: [UIImage(named: "1073-grid-1-toolbar")!,
	                                                                 UIImage(named: "1073-grid-1-toolbar-selected")!,
	                                                                 UIImage(named: "1076-grid-4-toolbar")!,
	                                                                 UIImage(named: "1076-grid-4-toolbar-selected")!])
	        displayOptions.selectedSegmentIndex = self.viewingMode.rawValue
	        displayOptions.toggleAction = {[unowned self] control in
	          self.viewingMode = BankCollectionAttributes.ViewingMode(rawValue: control.selectedSegmentIndex)!
            //FIXME: Circular dependency
//	          SettingsManager.setValue(self.viewingMode.rawValue, forSetting: .BankViewingMode)
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

  }

  /**
  viewWillAppear:

  :param: animated Bool
  */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    exportSelectionMode = false
    navigationItem.rightBarButtonItem = Bank.dismissBarButtonItem

    //FIXME: Circular dependency
//    if !(category is PreviewableCategory) { viewingMode = .List }
//    else if let modeSettingValue = SettingsManager.valueForSetting(.BankViewingMode) as? NSNumber {
//      viewingMode = BankCollectionAttributes.ViewingMode(rawValue: modeSettingValue.integerValue) ?? .List
//    }
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


  ////////////////////////////////////////////////////////////////////////////////
  /// MARK: - Actions
  ////////////////////////////////////////////////////////////////////////////////


  /**
  deleteItemAtIndexPath:

  :param: indexPath NSIndexPath
  */
  func deleteItemAtIndexPath(indexPath: NSIndexPath) {
  	if mode == .Default {
	    switch indexPath.section {
	      case 0:
	        let subcategory = category.subcategories[indexPath.row] as BankCategory
          //FIXME: Disabled while getting models sorted
//	        category.subcategories.removeAtIndex(indexPath.row)
	        subcategory.delete()

	      default:
	        let item = category.items[indexPath.row] as BankModel
          //FIXME: Disabled while getting models sorted
//	        category.items.removeAtIndex(indexPath.row)
	        item.delete()

	    }
	    collectionView?.deleteItemsAtIndexPaths([indexPath])
	  }
  }

  /**
  editItem:

  :param: item Editable
  */
  func editItem(item: protocol<Detailable, Editable>) {
  	if mode == .Default {
	    let detailController = item.detailController()
	    detailController.editing = true
	    navigationController?.pushViewController(detailController, animated: true)
	  }
  }

  /**
  detailItemAtIndexPath:

  :param: indexPath NSIndexPath
  */
  func detailItemAtIndexPath(indexPath: NSIndexPath) {
    switch indexPath.section {
      case 0:
        if let controller = BankCollectionController(category: category.subcategories[indexPath.row], mode: mode) {
          controller.selectionDelegate = selectionDelegate
          navigationController?.pushViewController(controller, animated: true)
        }
      default:
        if mode == .Default {
          if let item = category.items[indexPath.row] as? Detailable {
            let controller = item.detailController()
            navigationController?.pushViewController(controller, animated: true)
          }
        }
    }
  }

  /**
  importFromFile:

  :param: fileURL NSURL
  */
  func importFromFile(fileURL: NSURL) {
    println("importFromFile(fileURL: \(fileURL.absoluteString))")
  }

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
    zoomedItemIndexPath = indexPath
    let zoomView = BankCollectionZoomView(frame: view.bounds, delegate: self)
    if let previewableItem = category.items[indexPath.row] as? Previewable {
      zoomView.item = previewableItem
    }
    zoomView.backgroundImage = view.blurredSnapshot()
    zoomView.showEditButton = mode == .Default
    zoomView.showDetailButton = mode == .Default
    view.addSubview(zoomView)
    view.constrain("zoom.center = self.center", views: ["zoom": zoomView])
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
    if mode == .Default { detailItemAtIndexPath(zoomedItemIndexPath!) }
    zoomedItemIndexPath = nil
  }

  /**
  didDismissForEditingZoomView:

  :param: zoom BankCollectionZoomView
  */
  func didDismissForEditingZoomView(zoomView: BankCollectionZoomView) {
    zoomView.removeFromSuperview()
    if mode == .Default {
      if let editableItem = zoomView.item as? protocol<Detailable, Editable> { editItem(editableItem) }
    }
    zoomedItemIndexPath = nil
  }

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - Selecting/deselecting
////////////////////////////////////////////////////////////////////////////////
extension BankCollectionController {

  /** selectAllExportableItems */
  func selectAllExportableItems() {

    // Make sure we are in export selection mode
    if exportSelectionMode && mode == .Default{

      exportSelection.removeAll(keepCapacity: true)
      exportSelection.reserveCapacity(category.subcategories.count + category.items.count)

      for (i, subcategory) in enumerate(category.subcategories) {
        if let exportCategory = subcategory as? MSJSONExport {
          exportSelection.append(exportCategory)
          if let cell = collectionView?.cellForItemAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as? BankCollectionCell {
            cell.showIndicator(true, selected: true)
          }
        }
      }

      for (i, item) in enumerate(category.items) {
        if let exportItem = item as? MSJSONExport {
          exportSelection.append(exportItem)
          if let cell = collectionView?.cellForItemAtIndexPath(NSIndexPath(forRow: i, inSection: 1)) as? BankCollectionCell {
            cell.showIndicator(true, selected: true)
          }
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
    if exportSelectionMode && mode == .Default {

      // Remove all the items from export selection
      exportSelection.removeAll(keepCapacity: false)

      // Enumerate the selected index paths
      for indexPath in collectionView?.indexPathsForSelectedItems() as! [NSIndexPath] {

        // Deselect the cell
        collectionView?.deselectItemAtIndexPath(indexPath, animated: true)

        // Update the cell image if it is visible
        if let cell = collectionView?.cellForItemAtIndexPath(indexPath) as? BankCollectionCell {
        	cell.showIndicator(true)
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(categoryCellIdentifier,
                                                            forIndexPath: indexPath) as! BankCollectionCategoryCell
        let subcategory = category.subcategories[indexPath.row]
        cell.category = subcategory
        if mode == .Default {
          if subcategory.editable { cell.deleteAction = {self.deleteItemAtIndexPath(indexPath)} }
          cell.showingDeleteDidChange = showingDeleteDidChange
        } else {
          cell.swipeToDelete = false
        }
        return cell

      default:
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(itemCellIdentifier,
                                                            forIndexPath: indexPath) as! BankCollectionItemCell
        let item = category.items[indexPath.row]
        cell.item = item
        if mode == .Default {
	        if item.editable { cell.deleteAction = {self.deleteItemAtIndexPath(indexPath)} }
	        cell.showingDeleteDidChange = showingDeleteDidChange
        } else {
          cell.showChevron = false
          cell.swipeToDelete = false
        }
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
    let isSelected = (collectionView.indexPathsForSelectedItems() as! [NSIndexPath]) ∋ indexPath
    if let bankCell = cell as? BankCollectionCell {
    	bankCell.showIndicator(exportSelectionMode, selected: isSelected)
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
        cell.showIndicator(true)
        if exportSelection.count == 0 { exportButton.enabled = false }
      } else if mode == .Selection {
      	cell.showIndicator(false)
      }
    }
  }

  /**
  collectionView:didSelectItemAtIndexPath:

  :param: collectionView UICollectionView
  :param: indexPath NSIndexPath
  */
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

  	// Check if the cell is showing it's delete control
  	if cellShowingDelete != nil { cellShowingDelete!.hideDelete() }

  	// Otherwise get the cell
  	else if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? BankCollectionCell {

  		// Check if we are in export mode
      if exportSelectionMode {

      	assert(mode == .Default)
        exportSelection.append(cell.exportItem!)
        cell.showIndicator(true, selected: true)
        if !exportButton.enabled { exportButton.enabled = true }

      }

      // Push detail if we are in default mode
      else if mode == .Default { detailItemAtIndexPath(indexPath) }

      // Otherwise, make sure we are in selection mode
      else if mode == .Selection {

      	// Check if the cell is an item cell
      	if cell is BankCollectionItemCell {
	      	cell.showIndicator(true, selected: true)
	        selectionDelegate?.bankController(self, didSelectItem: (cell as! BankCollectionItemCell).item!)
        }

        // Otherwise check if the cell is a category cell
        else if cell is BankCollectionCategoryCell { detailItemAtIndexPath(indexPath) }

      }

    }

  }

}
