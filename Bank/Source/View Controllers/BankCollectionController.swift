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
import DataModel

// TODO: Viewing mode changes need to respect whether category items are `previewable`

class BankCollectionController: UICollectionViewController, BankController {

	private let itemCellIdentifier = "ItemCell"
	private let categoryCellIdentifier = "CategoryCell"

  var collection: BankModelCollection!

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
      }
      else if let dismissButton = Bank.dismissButton { rightBarButtonItems = [dismissButton] }
      else { rightBarButtonItems = [] }

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
  initWithCollection:mode:

  :param: collection ModelCollection
  :param: mode Mode = .Default
  */
  init?(collection: BankModelCollection, mode: Mode = .Default) {
  	self.mode = mode
    super.init(collectionViewLayout: BankCollectionLayout())
    self.collection = collection
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

    title = collection.name

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
        // FIXME:
//	      if self.collection is PreviewableCategory {
//
//	        // Create the segmented control
//	        let displayOptions = ToggleImageSegmentedControl(items: [Bank.bankImageNamed("1073-grid-1-toolbar"),
//	                                                                 Bank.bankImageNamed("1073-grid-1-toolbar-selected"),
//	                                                                 Bank.bankImageNamed("1076-grid-4-toolbar"),
//	                                                                 Bank.bankImageNamed("1076-grid-4-toolbar-selected")])
//	        displayOptions.selectedSegmentIndex = self.viewingMode.rawValue
//	        displayOptions.toggleAction = {[unowned self] control in
//	          self.viewingMode = BankCollectionAttributes.ViewingMode(rawValue: control.selectedSegmentIndex)!
//            //FIXME: Circular dependency
////	          SettingsManager.setValue(self.viewingMode.rawValue, forSetting: .BankViewingMode)
//	        }
//	        let displayOptionsItem = UIBarButtonItem(customView: displayOptions)
//	        self.displayOptionsControl = displayOptions
//
//	        // Return the toolbar with segmented control added
//	        return Bank.toolbarItemsForController(self, addingItems: [displayOptionsItem])
//	      }

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
    navigationItem.rightBarButtonItem = Bank.dismissButton

    //FIXME: Circular dependency
//    if !(category is PreviewableCategory) { viewingMode = .List }
//    else if let modeSettingValue = SettingsManager.valueForSetting(.BankViewingMode) as? NSNumber {
//      viewingMode = BankCollectionAttributes.ViewingMode(rawValue: modeSettingValue.integerValue) ?? .List
//    }
  }


  // MARK: - Exporting items



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


  // MARK: - Actions


  /**
  nestedCollectionForIndexPath:

  :param: indexPath NSIndexPath

  :returns: ModelCollection?
  */
  private func nestedCollectionForIndexPath(indexPath: NSIndexPath) -> ModelCollection? {
    if indexPath.section == 0,
      let nestingCollection = collection as? NestingModelCollection,
      collections = nestingCollection.collections where collections.count > indexPath.row
    {
      return collections[indexPath.row]
    } else { return nil }
  }

  /**
  itemForIndexPath:

  :param: indexPath NSIndexPath

  :returns: NamedModel?
  */
  private func itemForIndexPath(indexPath: NSIndexPath) -> NamedModel? {
    if indexPath.section == 1,
      let items = collection.items where items.count > indexPath.row
    {
      return items[indexPath.row]
    } else { return nil }
  }

  /**
  itemForIndexPath:ofType:

  :param: indexPath NSIndexPath
  :param: type T.Type

  :returns: T?
  */
  private func itemForIndexPath<T>(indexPath: NSIndexPath, ofType type: T.Type) -> T? {
    switch indexPath.section {
      case 0:  return nestedCollectionForIndexPath(indexPath) as? T
      default: return itemForIndexPath(indexPath) as? T
    }
  }

  /**
  editableItemForIndexPath:

  :param: indexPath NSIndexPath

  :returns: Editable?
  */
  private func editableItemForIndexPath(indexPath: NSIndexPath) -> Editable? {
    return itemForIndexPath(indexPath, ofType: Editable.self)
  }

  /**
  detailableItemForIndexPath:

  :param: indexPath NSIndexPath

  :returns: Detailable?
  */
  private func detailableItemForIndexPath(indexPath: NSIndexPath) -> Detailable? {
    return itemForIndexPath(indexPath, ofType: Detailable.self)
  }

  /**
  previewableItemForIndexPath:

  :param: indexPath NSIndexPath

  :returns: Previewable?
  */
  private func previewableItemForIndexPath(indexPath: NSIndexPath) -> Previewable? {
    return itemForIndexPath(indexPath, ofType: Previewable.self)
  }

  /**
  deleteItemAtIndexPath:

  :param: indexPath NSIndexPath
  */
  func deleteItemAtIndexPath(indexPath: NSIndexPath) {
  	if mode == .Default {
      editableItemForIndexPath(indexPath)?.delete()
	    collectionView?.deleteItemsAtIndexPaths([indexPath])
      // ???: will deleting the items refresh the section?
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
        if let nestedCollection = nestedCollectionForIndexPath(indexPath) as? BankModelCollection,
          controller = BankCollectionController(collection: nestedCollection, mode: mode)
        {
          controller.selectionDelegate = selectionDelegate
          navigationController?.pushViewController(controller, animated: true)
        }

      default:
        if mode == .Default {
          if let detailableItem = detailableItemForIndexPath(indexPath) {
            navigationController?.pushViewController(detailableItem.detailController(), animated: true)
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

  // MARK: - Zooming a cell's item



  private var zoomedItemIndexPath: NSIndexPath?

  /**
  zoomItemAtIndexPath:

  :param: indexPath NSIndexPath
  */
  func zoomItemAtIndexPath(indexPath: NSIndexPath) {
    precondition(indexPath.section == 1, "we should only be zooming actual items")
    zoomedItemIndexPath = indexPath
    let zoomView = BankCollectionZoomView(frame: view.bounds, delegate: self)
    zoomView.item = previewableItemForIndexPath(indexPath)
    zoomView.backgroundImage = view.blurredSnapshot()
    zoomView.showEditButton = mode == .Default
    zoomView.showDetailButton = mode == .Default
    view.addSubview(zoomView)
    view.constrain("zoom.center = self.center", views: ["zoom": zoomView])
  }

}

// MARK: - BankCollectionZoomViewDelegate

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

// MARK: - Selecting/deselecting

extension BankCollectionController {

  /** selectAllExportableItems */
  func selectAllExportableItems() {

    // Make sure we are in export selection mode
    if exportSelectionMode && mode == .Default{

      exportSelection.removeAll(keepCapacity: true)
      var capacity = 0
      if let nestingCollection = collection as? NestingModelCollection, collections = nestingCollection.collections {
        capacity += collections.count
      }
      if let items = collection.items { capacity += items.count }
      exportSelection.reserveCapacity(capacity)

      if let nestingCollection = collection as? NestingModelCollection, collections = nestingCollection.collections {
        for (i, collection) in enumerate(collections) {
          if let exportCollection = collection as? MSJSONExport {
            exportSelection.append(exportCollection)
            if let cell = collectionView?.cellForItemAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as? BankCollectionCell {
              cell.showIndicator(true, selected: true)
            }
          }
        }
      }

      if let items = collection.items {
        for (i, item) in enumerate(items) {
          if let exportItem = item as? MSJSONExport {
            exportSelection.append(exportItem)
            if let cell = collectionView?.cellForItemAtIndexPath(NSIndexPath(forRow: i, inSection: 1)) as? BankCollectionCell {
              cell.showIndicator(true, selected: true)
            }
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

// MARK: - UICollectionViewDataSource

extension BankCollectionController: UICollectionViewDataSource {

  /**
  collectionView:numberOfItemsInSection:

  :param: collectionView UICollectionView
  :param: section Int

  :returns: Int
  */
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return (section == 0 ? (collection as? NestingModelCollection)?.collections?.count  : collection.items?.count) ?? 0
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
        if let collection = nestedCollectionForIndexPath(indexPath) {
          cell.collection = collection
          if mode == .Default {
            if (collection as? Editable)?.editable == true { cell.deleteAction = {self.deleteItemAtIndexPath(indexPath)} }
            cell.showingDeleteDidChange = showingDeleteDidChange
          } else {
            cell.swipeToDelete = false
          }
        }
        return cell

      default:
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(itemCellIdentifier,
                                                            forIndexPath: indexPath) as! BankCollectionItemCell
        if let item = itemForIndexPath(indexPath) {
          cell.item = item
          if mode == .Default {
            if (item as? Editable)?.editable == true { cell.deleteAction = {self.deleteItemAtIndexPath(indexPath)} }
            cell.showingDeleteDidChange = showingDeleteDidChange
          } else {
            cell.showChevron = false
            cell.swipeToDelete = false
          }
          cell.previewActionHandler = {self.zoomItemAtIndexPath(indexPath)}
        }
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

// MARK: - UICollectionViewDelegate

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
      	if cell is BankCollectionItemCell, let editableModel = (cell as! BankCollectionItemCell).item as? EditableModel {
	      	cell.showIndicator(true, selected: true)
	        selectionDelegate?.bankController(self, didSelectItem: editableModel)
        }

        // Otherwise check if the cell is a category cell
        else if cell is BankCollectionCategoryCell { detailItemAtIndexPath(indexPath) }

      }

    }

  }

}
