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
import class Settings.SettingsManager

// TODO: Viewing mode changes need to respect whether category items are `previewable`
// ???: Is it possible to animate bottom toolbar changes?


final class BankCollectionController: UICollectionViewController, BankItemSelectiveViewingModeController {

  typealias ViewingMode = Bank.ViewingMode
  typealias ItemScale = BankCollectionLayout.ItemScale

  // MARK: - Descriptions
  override var description: String {
    return "\(super.description), collectionDelegate = {\n\(String(collectionDelegate).indentedBy(4))\n}"
  }

  // MARK: - Properties

  /** The object supplying subcategories and/or items for the collection */
  let collectionDelegate: BankModelDelegate

  /** Object expecting to receive a callback when the user selects a bank item from our collection */
  var selectionDelegate: BankItemSelectionDelegate?

  private let itemCreationDelegate = BankItemCreationDelegate()

  /** Whether viewing mode segmented control should be displayed */
  var selectiveViewingEnabled: Bool { return collectionDelegate.previewable == true }

  /** Specifies whether the collection should be displayed as a list or as thumbnails */
  var viewingMode: Bank.ViewingMode = .List {
    didSet {
      layout.viewingMode = viewingMode
      displayOptionsControl?.selectedSegmentIndex = viewingMode.rawValue
    }
  }

  /** The creation mode supported by the controller's collection delegate */
  var creationMode: Bank.CreationMode { return collectionDelegate.creationMode }

  var creationContext: NSManagedObjectContext? { return collectionDelegate.managedObjectContext }

  /** Whether model changes should be saved up to persistent store */
  var propagateChanges = true

  /** Segmented control for toggling viewing mode when the collection supports thumbnails  */
  weak var displayOptionsControl: ToggleImageSegmentedControl?

  /** Set by the bank when bottom toolbar items are generated */
  weak var createItemBarButton: ToggleBarButtonItem?

  /** Set by the bank when bottom toolbar items are generated */
  weak var discoverItemBarButton: ToggleBarButtonItem?

  // MARK: Private

  /** Enumeration for specifying the controller's current role, browsing or selecting */
  enum Mode { case Default, Selection }

  private let mode: Mode

  /** The current cell, if any, that has revealed the delete button */
  private var cellShowingDelete: BankCollectionCell?

  /** Convenience for the `collectionViewLayout` type cast appropriately */
  private var layout: BankCollectionLayout { return collectionViewLayout as! BankCollectionLayout }

  /** Track items changes */
  private var itemsChanges: [BankModelDelegate.Change] = []

  /** Track collections changes */
  private var collectionsChanges: [BankModelDelegate.Change] = []

  // MARK: - Callbacks

  func beginDelegateItemsChanges(delegate: BankModelDelegate) { itemsChanges.removeAll() }

  func endDelegateItemsChanges(delegate: BankModelDelegate) {
    let insertions = itemsChanges.filter {$0.type == .Insert && $0.newIndexPath != nil}
                                 .map {NSIndexPath(forItem: $0.newIndexPath!.item, inSection: 1)}
    let deletions  = itemsChanges.filter {$0.type == .Delete && $0.indexPath != nil}
                                 .map {NSIndexPath(forItem: $0.indexPath!.item, inSection: 1)}
    let updates    = itemsChanges.filter {$0.type == .Update && $0.indexPath != nil}
                                 .map {NSIndexPath(forItem: $0.indexPath!.item, inSection: 1)}
    let moves = itemsChanges.filter {$0.type == .Move && $0.indexPath != nil && $0.newIndexPath != nil}
    let block: () -> Void = {
      if insertions.count > 0 { self.collectionView?.insertItemsAtIndexPaths(insertions) }
      if deletions.count > 0 { self.collectionView?.deleteItemsAtIndexPaths(deletions) }
      if updates.count > 0 { self.collectionView?.reloadItemsAtIndexPaths(updates) }
      for move in moves {
        self.collectionView?.moveItemAtIndexPath(NSIndexPath(forItem: move.indexPath!.item, inSection: 1),
                                     toIndexPath: NSIndexPath(forItem: move.newIndexPath!.item, inSection: 1))
      }
    }
    collectionView?.performBatchUpdates(block, completion: nil)
  }

  func delegateItemsDidChange(delegate: BankModelDelegate, change: BankModelDelegate.Change) { itemsChanges.append(change) }

  func beginDelegateCollectionsChanges(delegate: BankModelDelegate) { collectionsChanges.removeAll() }

  func endDelegateCollectionsChanges(delegate: BankModelDelegate) {
    let insertions = collectionsChanges.filter {$0.type == .Insert && $0.newIndexPath != nil}
                                       .map {NSIndexPath(forItem: $0.newIndexPath!.item, inSection: 0)}
    let deletions  = collectionsChanges.filter {$0.type == .Delete && $0.indexPath != nil}
                                       .map {NSIndexPath(forItem: $0.indexPath!.item, inSection: 0)}
    let updates    = collectionsChanges.filter {$0.type == .Update && $0.indexPath != nil}
                                       .map {NSIndexPath(forItem: $0.indexPath!.item, inSection: 0)}
    let moves = collectionsChanges.filter {$0.type == .Move && $0.indexPath != nil && $0.newIndexPath != nil}
    let block: () -> Void = {
      if insertions.count > 0 { self.collectionView?.insertItemsAtIndexPaths(insertions) }
      if deletions.count > 0 { self.collectionView?.deleteItemsAtIndexPaths(deletions) }
      if updates.count > 0 { self.collectionView?.reloadItemsAtIndexPaths(updates) }
      for move in moves {
        self.collectionView?.moveItemAtIndexPath(NSIndexPath(forItem: move.indexPath!.item, inSection: 0),
                                     toIndexPath: NSIndexPath(forItem: move.newIndexPath!.item, inSection: 0))
      }
    }
    collectionView?.performBatchUpdates(block, completion: nil)
  }


  func delegateCollectionsDidChange(delegate: BankModelDelegate, change: BankModelDelegate.Change) {
    collectionsChanges.append(change)
  }

  /**
  showingDeleteDidChange:

  - parameter cell: BankCollectionCell
  */
  func showingDeleteDidChange(cell: BankCollectionCell) {
    cellShowingDelete?.hideDelete()
    cellShowingDelete = cell.showingDelete ? cell : nil
  }

  // MARK: - Initialization

  /**
  Default initializer establishes the collection and mode for the controller

  - parameter collectionDelegate: ModelCollection
  - parameter mode: Mode = .Default
  */
  init(collectionDelegate d: BankModelDelegate, mode m: Mode = .Default) {
  	collectionDelegate = d; mode = m
    let layout = BankCollectionLayout()
    layout.itemScale = ItemScale(width: .OneAcross, height: 38)
    super.init(collectionViewLayout: layout)
    d.beginItemsChanges = beginDelegateItemsChanges
    d.endItemsChanges = endDelegateItemsChanges
    d.itemsDidChange = delegateItemsDidChange
    d.beginCollectionsChanges = beginDelegateCollectionsChanges
    d.endCollectionsChanges = endDelegateCollectionsChanges
    d.collectionsDidChange = delegateCollectionsDidChange
    itemCreationDelegate.presentingController = self
    if mode == .Default {
	    exportButton = Bank.exportBarButtonItemForController(self)
	    selectAllButton = Bank.selectAllButtonForController(self)
	  }
  }

  required init?(coder aDecoder: NSCoder) { fatalError("init?(coder aDecoder: NSCoder) not supported") }

  // MARK: - View lifecycle

  /** updateViewingMode */
  private func updateViewingMode() {
    if collectionDelegate.previewable != true { viewingMode = .List }
    else if let viewingModeSetting: Bank.ViewingMode = SettingsManager.valueForSetting(Bank.ViewingModeKey) {
      viewingMode = viewingModeSetting
    }
  }

  /** loadView */
  override func loadView() {

    title = collectionDelegate.name

    collectionView = {
      // Create the collection view and register cell classes
      let v = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: self.layout)
      v.backgroundColor = Bank.backgroundColor
      BankCollectionCategoryCell.registerWithCollectionView(v)
      BankCollectionItemCell.registerWithCollectionView(v)
      v.registerClass(ItemCellZoom.self,
        forSupplementaryViewOfKind: BankCollectionLayout.SupplementaryZoomKind,
        withReuseIdentifier: "Zoom")
      return v
    }()

    // Get the bottom toolbar items when not in `Selection` mode
    if mode == .Default { toolbarItems = Bank.toolbarItemsForController(self) }

    updateViewingMode()

  }

  /**
  viewWillAppear:

  - parameter animated: Bool
  */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    title = collectionDelegate.name
    exportSelectionMode = false
    navigationItem.rightBarButtonItem = Bank.dismissButton
    updateViewingMode()
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    title = ""
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
        if let indexPaths = collectionView?.indexPathsForSelectedItems() {
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

  - parameter sender: AnyObject
  */
  func confirmExport(sender: AnyObject?) {
    ImportExportFileManager.confirmExportOfItems(exportSelection) { _ in self.exportSelectionMode = false }
  }

  // MARK: - Actions

  /**
  itemForIndexPath:

  - parameter indexPath: NSIndexPath

  - returns: NamedModel?
  */
  private func itemForIndexPath(indexPath: NSIndexPath) -> NamedModel? {
    return indexPath.section == 1 ? collectionDelegate.itemAtIndex(indexPath.item) : nil
  }

  /**
  Returns the model corresponding the specified index path as returned by the collection delegate.

  - parameter indexPath: NSIndexPath

  - returns: NamedModel?
  */
  private func modelForIndexPath(indexPath: NSIndexPath) -> NamedModel? {
    return collectionDelegate.modelAtIndexPath(indexPath)
  }

  /**
  deleteItemAtIndexPath:

  - parameter indexPath: NSIndexPath
  */
  func deleteModelForCel(cell: BankCollectionCell) {
  	if mode == .Default,
      let indexPath = collectionView?.indexPathForCell(cell),
      model = modelForIndexPath(indexPath) as? Editable
    {
      model.delete() // Should trigger delegate callbacks
      DataManager.propagatingSaveFromContext(collectionDelegate.managedObjectContext)
	  }
  }

  /**
  editItem:

  - parameter item: Editable
  */
  func editItem(item: protocol<DelegateDetailable, Editable>) {
  	if mode == .Default {
	    let detailController = BankCollectionDetailController(itemDelegate: BankModelDetailDelegate(item: item))
	    detailController.editing = true
	    navigationController?.pushViewController(detailController, animated: true)
	  }
  }

  /**
  detailItemAtIndexPath:

  - parameter indexPath: NSIndexPath
  */
  func detailItemAtIndexPath(indexPath: NSIndexPath) {
    switch indexPath.section {
      case 0:
        if let nestedCollection = collectionDelegate.collectionAtIndex(indexPath.item) as? BankModelCollection,
          collectionDelegate = BankModelCollectionDelegate(collection: nestedCollection)
        {
          let controller = BankCollectionController(collectionDelegate: collectionDelegate, mode: mode)
          controller.selectionDelegate = selectionDelegate
          navigationController?.pushViewController(controller, animated: true)
        }

      default:
        if mode == .Default {
          if let detailableItem = itemForIndexPath(indexPath) as? DelegateDetailable {
            let itemDelegate = BankModelDetailDelegate(item: detailableItem)
            let itemDetailController = BankCollectionDetailController(itemDelegate: itemDelegate)
            navigationController?.pushViewController(itemDetailController, animated: true)
          }
        }
    }
  }

  /** Holds the index path of the currently zoomed item, if any */
  private var zoomedItemIndexPath: NSIndexPath?

  /**
  zoomItemForCell:

  - parameter indexPath: NSIndexPath
  */
  func zoomItemForCell(cell: BankCollectionCell) {
    if layout.zoomedItem != nil { layout.zoomedItem = nil }
    else if let indexPath = collectionView?.indexPathForCell(cell) where itemForIndexPath(indexPath) as? Previewable != nil {
      layout.zoomedItem = indexPath
    }
  }

}

// MARK: - Item creation

extension BankCollectionController: BankItemCreationController {

  /** discoverBankItem */
  func discoverBankItem() {
    if discoverItemBarButton?.isToggled == false { itemCreationDelegate.endDiscovery() }
    else { itemCreationDelegate.discoverBankItemWithProvider(collectionDelegate) }
  }

  /** createBankItem */
  func createBankItem() { itemCreationDelegate.createBankItemWithProvider(collectionDelegate) }

}

// MARK: - Import/export

extension BankCollectionController: BankItemImportExportController {

  /** selectAllExportableItems */
  func selectAllExportableItems() {

    // Make sure we are in export selection mode
    if exportSelectionMode && mode == .Default{

      exportSelection.removeAll(keepCapacity: true)
      exportSelectionIndices.removeAll(keepCapacity: true)
      let collections = (0..<collectionDelegate.numberOfCollections).reduce(Array<ModelCollection>(), combine: {
        if let collection = self.collectionDelegate.collectionAtIndex($1) { return $0 + [collection] } else { return $0 }
      })
      let items = (0..<collectionDelegate.numberOfItems).reduce(Array<NamedModel>(), combine: {
        if let item = self.collectionDelegate.itemAtIndex($1) { return $0 + [item] } else { return $0 }
      })
      let capacity = collections.count + items.count
      exportSelection.reserveCapacity(capacity)
      exportSelectionIndices.reserveCapacity(capacity)

      for (i, collection) in collections.enumerate() {
        if let exportCollection = collection as? JSONValueConvertible {
          exportSelection.append(exportCollection)
          let indexPath = NSIndexPath(forItem: i, inSection: 0)
          exportSelectionIndices.append(indexPath)
          if let cell = collectionView?.cellForItemAtIndexPath(indexPath) as? BankCollectionCell {
            cell.showIndicator(true, selected: true)
          }
        }
      }

      for (i, item) in items.enumerate() {
        if let exportItem = item as? JSONValueConvertible {
          exportSelection.append(exportItem)
          let indexPath = NSIndexPath(forItem: i, inSection: 1)
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

  - parameter fileURL: NSURL
  */
  func importFromFile(fileURL: NSURL) { print("importFromFile(fileURL: \(fileURL.absoluteString))") }


}

// MARK: - UICollectionViewDataSource

extension BankCollectionController {

  /**
  collectionView:numberOfItemsInSection:

  - parameter collectionView: UICollectionView
  - parameter section: Int

  - returns: Int
  */
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return section == 0 ? collectionDelegate.numberOfCollections  : collectionDelegate.numberOfItems
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
    switch indexPath.section {
      case 0:
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(BankCollectionCategoryCell.cellIdentifier,
                                                            forIndexPath: indexPath) as! BankCollectionCategoryCell
        if let collection = collectionDelegate.collectionAtIndex(indexPath.item) {
          cell.collection = collection
          if mode == .Default {
            if (collection as? Editable)?.editable == true {
              cell.deleteAction = {[unowned cell] in self.deleteModelForCel(cell)}
            }
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
            if (item as? Editable)?.editable == true { cell.deleteAction = {[unowned cell] in self.deleteModelForCel(cell)} }
            cell.showingDeleteDidChange = showingDeleteDidChange
          } else {
            cell.showChevron = false
            cell.swipeToDelete = false
          }
          cell.previewActionHandler = {self.zoomItemForCell(cell)}
        }
        return cell
    }
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
    let zoomView = collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                                                     withReuseIdentifier: "Zoom",
                                                            forIndexPath: indexPath) as! ItemCellZoom
    if let item = itemForIndexPath(indexPath) as? Previewable { zoomView.image = item.preview }
    zoomView.action = {[unowned self] in self.layout.zoomedItem = nil}
    return zoomView
  }

  /**
  numberOfSectionsInCollectionView:

  - parameter collectionView: UICollectionView

  - returns: Int
  */
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int { return 2 }

}

// MARK: - UICollectionViewDelegate

extension BankCollectionController {

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
    if let selectedIndexPaths = collectionView.indexPathsForSelectedItems() where selectedIndexPaths ∋ indexPath {
      (cell as! BankCollectionCell).showIndicator(exportSelectionMode, selected: true)
    } else {
      (cell as! BankCollectionCell).showIndicator(exportSelectionMode, selected: false)
    }
  }

  /**
  collectionView:didDeselectItemAtIndexPath:

  - parameter collectionView: UICollectionView
  - parameter indexPath: NSIndexPath
  */
  override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
    if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? BankCollectionCell {
      // Check if we are selecting items to export
      if exportSelectionMode, let idx = exportSelectionIndices.indexOf(indexPath) {
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

  - parameter collectionView: UICollectionView
  - parameter indexPath: NSIndexPath
  */
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

  	// Check if the cell is showing it's delete control
  	if cellShowingDelete != nil { cellShowingDelete!.hideDelete() }

    // Dismiss zoomed item
    else if layout.zoomedItem == indexPath { layout.zoomedItem = nil }

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
