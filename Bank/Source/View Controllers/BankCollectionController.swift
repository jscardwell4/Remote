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
import Settings

// TODO: Viewing mode changes need to respect whether category items are `previewable`
  enum Mode { case Default, Selection }

final class BankCollectionController: UICollectionViewController, BankItemSelectiveViewingModeController {

  override var description: String {
    return "\(super.description), collectionDelegate = {\n\(toString(collectionDelegate).indentedBy(4))\n}"
  }

  /** The object supplying subcategories and/or items for the collection */
  let collectionDelegate: BankModelDelegate

  /** Enumeration for specifying the controller's current role, browsing or selecting */

  private let mode: Mode

  /** The current cell, if any, that has revealed the delete button */
  private var cellShowingDelete: BankCollectionCell?

  /** Object expecting to receive a callback when the user selects a bank item from our collection */
  internal var selectionDelegate: BankItemSelectionDelegate?

  /**
  showingDeleteDidChange:

  :param: cell BankCollectionCell
  */
  func showingDeleteDidChange(cell: BankCollectionCell) {
    cellShowingDelete?.hideDelete()
    cellShowingDelete = cell.showingDelete ? cell : nil
  }

  /** Convenience for the `collectionViewLayout` type cast appropriately */
  private var layout: BankCollectionLayout { return collectionViewLayout as! BankCollectionLayout }

  /** Whether viewing mode segmented control should be displayed */
  var selectiveViewingEnabled: Bool { return collectionDelegate.previewable == true }

  /** Specifies whether the collection should be displayed as a list or as thumbnails */
  var viewingMode: Bank.ViewingMode = .List {
    didSet {
      layout.viewingMode = viewingMode
      displayOptionsControl?.selectedSegmentIndex = viewingMode.rawValue
    }
  }

  /**
  Default initializer establishes the collection and mode for the controller

  :param: collectionDelegate ModelCollection
  :param: mode Mode = .Default
  */
  init(collectionDelegate d: BankModelDelegate, mode m: Mode = .Default) {
  	collectionDelegate = d; mode = m
    super.init(collectionViewLayout: BankCollectionLayout())
    d.collectionsDidChange = {[unowned self] _ in self.collectionView?.reloadSections(NSIndexSet(index: 0)) }
    d.itemsDidChange = {[unowned self] _ in self.collectionView?.reloadSections(NSIndexSet(index: 1)) }
    if mode == .Default {
	    exportButton = Bank.exportBarButtonItemForController(self)
	    selectAllButton = Bank.selectAllButtonForController(self)
	  }
  }

  /** Segmented control for toggling viewing mode when the collection supports thumbnails  */
  internal weak var displayOptionsControl: ToggleImageSegmentedControl?

  /** Set by the bank when bottom toolbar items are generated */
  weak var createItemBarButton: ToggleBarButtonItem?

  required init(coder aDecoder: NSCoder) { fatalError("init(coder aDecoder: NSCoder) not supported") }

  /** loadView */
  override func loadView() {

    title = collectionDelegate.name

    collectionView = {
      // Create the collection view and register cell classes
      let v = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: self.layout)
      v.backgroundColor = Bank.backgroundColor
      BankCollectionCategoryCell.registerWithCollectionView(v)
      BankCollectionItemCell.registerWithCollectionView(v)
      return v
    }()

    // Get the bottom toolbar items when not in `Selection` mode
    if mode == .Default {
      toolbarItems = Bank.toolbarItemsForController(self)
      createItemBarButton?.enabled = (collectionDelegate.createItem != nil || collectionDelegate.createCollection != nil)
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

    if collectionDelegate.previewable != true { viewingMode = .List }
    else if let viewingModeSetting: Bank.ViewingMode = SettingsManager.valueForSetting(Bank.ViewingModeKey) {
      viewingMode = viewingModeSetting
    }
  }


  // MARK: - Exporting items


  private(set) var exportSelection: [JSONValueConvertible] = []
  private(set) var exportSelectionIndices: [NSIndexPath] = []

  var exportButton: BlockBarButtonItem!
  var selectAllButton: BlockBarButtonItem!

  var exportSelectionMode: Bool = false {
    didSet {

      // Create some variables to hold values for common actions to perform
      var rightBarButtonItems: [UIBarButtonItem]
      var showIndicator = false

      // Determine if we are entering or leaving export selection mode
      if exportSelectionMode {

        // If entering, make sure our export items collection is empty
        exportSelection.removeAll(keepCapacity: false)
        exportSelectionIndices.removeAll(keepCapacity: false)

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

      // Update selection mode
      collectionView?.allowsMultipleSelection = exportSelectionMode

      // Update right bar button items
      navigationItem.rightBarButtonItems = rightBarButtonItems

      // Update visible cells
      for cell in collectionView?.visibleCells() as! [BankCollectionCell] {
      	cell.showIndicator(showIndicator)
      }

    }
  }


  /**
  confirmExport:

  :param: sender AnyObject
  */
  func confirmExport(sender: AnyObject?) {
    ImportExportFileManager.confirmExportOfItems(exportSelection) { _ in self.exportSelectionMode = false }
  }


  // MARK: - Actions


  /**
  nestedCollectionForIndexPath:

  :param: indexPath NSIndexPath

  :returns: ModelCollection?
  */
  private func nestedCollectionForIndexPath(indexPath: NSIndexPath) -> ModelCollection? {
    return indexPath.section == 0 ? collectionDelegate.collections[indexPath.row] : nil
  }

  /**
  itemForIndexPath:

  :param: indexPath NSIndexPath

  :returns: NamedModel?
  */
  private func itemForIndexPath(indexPath: NSIndexPath) -> NamedModel? {
    return indexPath.section == 1 ? collectionDelegate.items[indexPath.row] : nil
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
          collectionDelegate = BankModelCollectionDelegate(collection: nestedCollection)
        {
          let controller = BankCollectionController(collectionDelegate: collectionDelegate, mode: mode)
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

  /** Holds the index path of the currently zoomed item, if any */
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

// MARK: - Zooming an item

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

// MARK: - Item creation

extension BankCollectionController: BankItemCreationController {
  func createBankItem() {

    func presentFormForTransaction(transaction: BankModelDelegate.CreateTransaction) {
      let dismissController = {self.dismissViewControllerAnimated(true, completion: {self.createItemBarButton?.isToggled = false})}
      let form = FormViewController(fields: transaction.fields,
                                    didSubmit: {_, values in transaction.action(values); dismissController()},
                                    didCancel: {_ in dismissController()})
      Bank.decorateForm(form)
      presentViewController(form, animated: true, completion: nil)
    }

    switch (collectionDelegate.createItem, collectionDelegate.createCollection) {
      // Display popover if there are multiple valid create transactions
      case let (createItem, createCollection) where createItem != nil && createCollection != nil:
        // TODO: Present popover to choose which transaction to begin
        break
      // Display controller for item creation if collection transaction is nil
      case let (createItem, createCollection) where createItem != nil && createCollection == nil:
        presentFormForTransaction(createItem!)

      // Display controller for collection creation if item transaction is nil
      case let (createItem, createCollection) where createItem == nil && createCollection != nil:
        presentFormForTransaction(createCollection!)

      // Don't do anything if we have no valid create transactions
      default:
        assert(false, "create bar button item should only be enabled if delegate has at least one valid transaction")
    }

//    if let form = collectionDelegate.createItemForm?() {
//      Bank.decorateForm(form)
//      presentViewController(form, animated: true, completion: nil)
//    }
  }
}

// MARK: - Import/export

extension BankCollectionController: BankItemImportExportController {

  /** selectAllExportableItems */
  func selectAllExportableItems() {

    // Make sure we are in export selection mode
    if exportSelectionMode && mode == .Default{

      exportSelection.removeAll(keepCapacity: true)
      exportSelectionIndices.removeAll(keepCapacity: true)
      let collections = collectionDelegate.collections
      let items = collectionDelegate.items
      let capacity = collections.count + items.count
      exportSelection.reserveCapacity(capacity)
      exportSelectionIndices.reserveCapacity(capacity)

      for (i, collection) in enumerate(collections) {
        if let exportCollection = collection as? JSONValueConvertible {
          exportSelection.append(exportCollection)
          let indexPath = NSIndexPath(forRow: i, inSection: 0)
          exportSelectionIndices.append(indexPath)
          if let cell = collectionView?.cellForItemAtIndexPath(indexPath) as? BankCollectionCell {
            cell.showIndicator(true, selected: true)
          }
        }
      }

      for (i, item) in enumerate(items) {
        if let exportItem = item as? JSONValueConvertible {
          exportSelection.append(exportItem)
          let indexPath = NSIndexPath(forRow: i, inSection: 1)
          exportSelectionIndices.append(indexPath)
          if let cell = collectionView?.cellForItemAtIndexPath(indexPath) as? BankCollectionCell {
            cell.showIndicator(true, selected: true)
          }
        }
      }

    }

  }

  /**
  importFromFile:

  :param: fileURL NSURL
  */
  func importFromFile(fileURL: NSURL) { println("importFromFile(fileURL: \(fileURL.absoluteString))") }


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
    return (section == 0 ? collectionDelegate.collections.count  : collectionDelegate.items.count) ?? 0
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(BankCollectionCategoryCell.cellIdentifier,
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(BankCollectionItemCell.cellIdentifier,
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
      if exportSelectionMode, let idx = find(exportSelectionIndices, indexPath) {
        // Remove the item and update the cell's indicator image
        exportSelection.removeAtIndex(idx)
        exportSelectionIndices.removeAtIndex(idx)
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
        exportSelectionIndices.append(indexPath)
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
