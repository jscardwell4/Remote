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
    return "\(super.description), collectionDelegate = {\n\(toString(collectionDelegate).indentedBy(4))\n}"
  }

  // MARK: - Properties

  /** The object supplying subcategories and/or items for the collection */
  let collectionDelegate: BankModelDelegate

  /** Object expecting to receive a callback when the user selects a bank item from our collection */
  var selectionDelegate: BankItemSelectionDelegate?

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
  var creationMode: Bank.CreationMode {
    var canCreate = false
    var canDiscover = false

    func testTransaction(transaction: BankItemCreationControllerTransaction) {
      switch transaction {
        case is BankModelDelegate.CreationTransaction,
             is BankModelDelegate.CustomTransaction:
          canCreate = true
        case is BankModelDelegate.DiscoveryTransaction:
          canDiscover = true
        default:
          break
      }
    }

    if let transaction = collectionDelegate.itemTransaction { testTransaction(transaction) }
    if let transaction = collectionDelegate.collectionTransaction { testTransaction(transaction) }

    switch (canCreate, canDiscover) {
      case (true, true):   return .Both
      case (true, false) : return .Manual
      case (false, true):  return .Discovery
      default:             return .None
    }
  }

  private var endDiscovery: (() -> Void)?

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
                                 .map {NSIndexPath(forRow: $0.newIndexPath!.row, inSection: 1)}
    let deletions  = itemsChanges.filter {$0.type == .Delete && $0.indexPath != nil}
                                 .map {NSIndexPath(forRow: $0.indexPath!.row, inSection: 1)}
    let updates    = itemsChanges.filter {$0.type == .Update && $0.indexPath != nil}
                                 .map {NSIndexPath(forRow: $0.indexPath!.row, inSection: 1)}
    let moves = itemsChanges.filter {$0.type == .Move && $0.indexPath != nil && $0.newIndexPath != nil}
    let block: () -> Void = {
      if insertions.count > 0 { self.collectionView?.insertItemsAtIndexPaths(insertions) }
      if deletions.count > 0 { self.collectionView?.deleteItemsAtIndexPaths(deletions) }
      if updates.count > 0 { self.collectionView?.reloadItemsAtIndexPaths(updates) }
      for move in moves {
        self.collectionView?.moveItemAtIndexPath(NSIndexPath(forRow: move.indexPath!.row, inSection: 1),
                                     toIndexPath: NSIndexPath(forRow: move.newIndexPath!.row, inSection: 1))
      }
    }
    collectionView?.performBatchUpdates(block, completion: nil)
  }

  func delegateItemsDidChange(delegate: BankModelDelegate, change: BankModelDelegate.Change) { itemsChanges.append(change) }

  func beginDelegateCollectionsChanges(delegate: BankModelDelegate) { collectionsChanges.removeAll() }

  func endDelegateCollectionsChanges(delegate: BankModelDelegate) {
    let insertions = collectionsChanges.filter {$0.type == .Insert && $0.newIndexPath != nil}
                                       .map {NSIndexPath(forRow: $0.newIndexPath!.row, inSection: 0)}
    let deletions  = collectionsChanges.filter {$0.type == .Delete && $0.indexPath != nil}
                                       .map {NSIndexPath(forRow: $0.indexPath!.row, inSection: 0)}
    let updates    = collectionsChanges.filter {$0.type == .Update && $0.indexPath != nil}
                                       .map {NSIndexPath(forRow: $0.indexPath!.row, inSection: 0)}
    let moves = collectionsChanges.filter {$0.type == .Move && $0.indexPath != nil && $0.newIndexPath != nil}
    let block: () -> Void = {
      if insertions.count > 0 { self.collectionView?.insertItemsAtIndexPaths(insertions) }
      if deletions.count > 0 { self.collectionView?.deleteItemsAtIndexPaths(deletions) }
      if updates.count > 0 { self.collectionView?.reloadItemsAtIndexPaths(updates) }
      for move in moves {
        self.collectionView?.moveItemAtIndexPath(NSIndexPath(forRow: move.indexPath!.row, inSection: 0),
                                     toIndexPath: NSIndexPath(forRow: move.newIndexPath!.row, inSection: 0))
      }
    }
    collectionView?.performBatchUpdates(block, completion: nil)
  }


  func delegateCollectionsDidChange(delegate: BankModelDelegate, change: BankModelDelegate.Change) {
    collectionsChanges.append(change)
  }

  /**
  showingDeleteDidChange:

  :param: cell BankCollectionCell
  */
  func showingDeleteDidChange(cell: BankCollectionCell) {
    cellShowingDelete?.hideDelete()
    cellShowingDelete = cell.showingDelete ? cell : nil
  }

  // MARK: - Initialization

  /**
  Default initializer establishes the collection and mode for the controller

  :param: collectionDelegate ModelCollection
  :param: mode Mode = .Default
  */
  init(collectionDelegate d: BankModelDelegate, mode m: Mode = .Default) {
  	collectionDelegate = d; mode = m
    let layout = BankCollectionLayout()
    layout.itemScale = ItemScale(width: .OneAcross, height: 38)
//    super.init(collectionViewLayout: BankCollectionLayout())
    super.init(collectionViewLayout: layout)
    d.beginItemsChanges = beginDelegateItemsChanges
    d.endItemsChanges = endDelegateItemsChanges
    d.itemsDidChange = delegateItemsDidChange
    d.beginCollectionsChanges = beginDelegateCollectionsChanges
    d.endCollectionsChanges = endDelegateCollectionsChanges
    d.collectionsDidChange = delegateCollectionsDidChange
    if mode == .Default {
	    exportButton = Bank.exportBarButtonItemForController(self)
	    selectAllButton = Bank.selectAllButtonForController(self)
	  }
  }

  required init(coder aDecoder: NSCoder) { fatalError("init(coder aDecoder: NSCoder) not supported") }

  // MARK: - View lifecycle

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
    if mode == .Default { toolbarItems = Bank.toolbarItemsForController(self) }

  }

  /**
  viewWillAppear:

  :param: animated Bool
  */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    title = collectionDelegate.name
    exportSelectionMode = false
    navigationItem.rightBarButtonItem = Bank.dismissButton
    if collectionDelegate.previewable != true { viewingMode = .List }
    else if let viewingModeSetting: Bank.ViewingMode = SettingsManager.valueForSetting(Bank.ViewingModeKey) {
      viewingMode = viewingModeSetting
    }
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
  itemForIndexPath:

  :param: indexPath NSIndexPath

  :returns: NamedModel?
  */
  private func itemForIndexPath(indexPath: NSIndexPath) -> NamedModel? {
    return indexPath.section == 1 ? collectionDelegate.itemAtIndex(indexPath.row) : nil
  }

  /**
  Returns the model corresponding the specified index path as returned by the collection delegate.

  :param: indexPath NSIndexPath

  :returns: NamedModel?
  */
  private func modelForIndexPath(indexPath: NSIndexPath) -> NamedModel? {
    return collectionDelegate.modelAtIndexPath(indexPath)
  }

  /**
  deleteItemAtIndexPath:

  :param: indexPath NSIndexPath
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
        if let nestedCollection = collectionDelegate.collectionAtIndex(indexPath.row) as? BankModelCollection,
          collectionDelegate = BankModelCollectionDelegate(collection: nestedCollection)
        {
          let controller = BankCollectionController(collectionDelegate: collectionDelegate, mode: mode)
          controller.selectionDelegate = selectionDelegate
          navigationController?.pushViewController(controller, animated: true)
        }

      default:
        if mode == .Default {
          if let detailableItem = itemForIndexPath(indexPath) as? Detailable {
            navigationController?.pushViewController(detailableItem.detailController(), animated: true)
          }
        }
    }
  }

  /** Holds the index path of the currently zoomed item, if any */
  private var zoomedItemIndexPath: NSIndexPath?

  /**
  zoomItemForCell:

  :param: indexPath NSIndexPath
  */
  func zoomItemForCell(cell: BankCollectionCell) {
    if layout.zoomedItem != nil { layout.zoomedItem = nil }
    else if let indexPath = collectionView?.indexPathForCell(cell), item = itemForIndexPath(indexPath) as? Previewable {
      layout.zoomedItem = indexPath
//      zoomedItemIndexPath = indexPath
//      let zoomView = BankCollectionZoomView(frame: view.bounds, delegate: self)
//      zoomView.item = item
////      zoomView.backgroundImage = view.blurredSnapshot()
//      zoomView.showEditButton = mode == .Default
//      zoomView.showDetailButton = mode == .Default
//      collectionView?.addSubview(zoomView)
//      collectionView?.constrain("zoom.center = self.center", views: ["zoom": zoomView])
    }
  }

  // MARK: Private actions

  /**
  Creates a fresh `PopOverView` with the specified actions

  :param: actions [String:(PopOverView) -> Void]

  :returns: PopOverView
  */
  private func popOverWithActions(actions: [String:(PopOverView) -> Void], location: PopOverView.Location) -> PopOverView {
    let popOverView = PopOverView(autolayout: true)
    popOverView.location = location
    popOverView.highlightedTextColor = Bank.actionColor
    apply(actions) {popOverView.addLabel(label: $0, withAction: $1)}
    return popOverView
  }

  /**
  presentPopOverWithActions:

  :param: actions [String:(PopOverView) -> Void]
  :param: button UIBarButtonItem
  */
  private func presentPopOverWithActions(actions: [String:(PopOverView) -> Void], above button: UIBarButtonItem) {
    // TODO: Add animation and more appearance customization
    let popOverView = popOverWithActions(actions, location: .Bottom)

    if let presentingView = createItemBarButton?.customView {
      view.window?.addSubview(popOverView)
      view.window?.constrain(popOverView.centerX => presentingView.centerX, popOverView.bottom => presentingView.top)
    }
  }

  /**
  presentPopOverWithActions:below:

  :param: actions [String:(PopOverView) -> Void]
  :param: button UIBarButtonItem
  */
  private func presentPopOverWithActions(actions: [String:(PopOverView) -> Void], below button: UIBarButtonItem) {
    // TODO: Add animation and more appearance customization
    let popOverView = popOverWithActions(actions, location: .Top)

    if let presentingView = button.customView {
      view.window?.addSubview(popOverView)
      view.window?.constrain(popOverView.centerX => presentingView.centerX, popOverView.top => presentingView.bottom)
    }
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

  private func transact(transaction: BankModelDelegate.CreationTransaction) { presentForm(transaction) }
  private func transact(transaction: BankModelDelegate.DiscoveryTransaction) { beginDiscoveryTransaction(transaction) }
  private func transact(transaction: BankModelDelegate.CustomTransaction) { presentCustom(transaction) }
  private func transact(transaction: BankItemCreationControllerTransaction) {
    switch transaction {
      case let t as BankModelDelegate.CreationTransaction:  presentForm(t)
      case let t as BankModelDelegate.CustomTransaction:    presentCustom(t)
      case let t as BankModelDelegate.DiscoveryTransaction: beginDiscoveryTransaction(t)
      default:                                              break
    }
  }


  /**
  presentCustom:

  :param: transaction BankModelDelegate.CustomTransaction
  */
  private func presentCustom(transaction: BankModelDelegate.CustomTransaction) {
    let dismissController = {self.dismissViewControllerAnimated(true) {self.createItemBarButton?.isToggled = false}}
    let didCreate: (ModelObject) -> Void = { _ in
      DataManager.propagatingSaveFromContext(self.collectionDelegate.managedObjectContext)
      dismissController()
    }
    let controller = transaction.controller(didCancel: dismissController, didCreate: didCreate)
    presentViewController(controller, animated: true, completion: nil)
  }

  /**
  Presents a `FormViewController` using the specifed creation transaction

  :param: transaction BankModelDelegate.CreationTransaction
  */
  private func presentForm(transaction: BankModelDelegate.CreationTransaction) {
    let dismissController = {self.dismissViewControllerAnimated(true) {self.createItemBarButton?.isToggled = false}}
    let didSubmit: FormSubmission = {
      if transaction.processedForm($0) { DataManager.propagatingSaveFromContext(self.collectionDelegate.managedObjectContext) }
      dismissController()
    }
    let formViewController = FormViewController(form: transaction.form, didSubmit: didSubmit, didCancel: dismissController)
    presentViewController(formViewController, animated: true, completion: nil)
  }

  /**
  beginDiscoveryTransaction:

  :param: transaction BankModelDelegate.DiscoveryTransaction
  */
  private func beginDiscoveryTransaction(transaction: BankModelDelegate.DiscoveryTransaction) {
    endDiscovery = transaction.endDiscovery
    let context = collectionDelegate.managedObjectContext
    let formPresentation: (Form, ProcessedForm) -> Void = {
      form, processedForm in

        let dismissController = {
          self.dismissViewControllerAnimated(true) { self.discoverItemBarButton?.isToggled = false }
        }
        let didSubmit: FormSubmission = {
          _ in
          if processedForm(form) { DataManager.propagatingSaveFromContext(context) }
          dismissController()
        }
        let formViewController = FormViewController(form: form, didSubmit: didSubmit, didCancel: dismissController)
        self.presentViewController(formViewController, animated: true, completion: nil)
    }
    transaction.beginDiscovery(formPresentation)
  }

  /** discoverBankItem */
  func discoverBankItem() {

    if discoverItemBarButton?.isToggled == false {
      endDiscovery?()
      endDiscovery = nil
    } else {
      switch (collectionDelegate.itemTransaction as? BankModelDelegate.DiscoveryTransaction,
              collectionDelegate.collectionTransaction as? BankModelDelegate.DiscoveryTransaction)
      {

        // Display popover if there are multiple valid discover transactions
        case let (discoverItem, discoverCollection) where discoverItem != nil && discoverCollection != nil:
        if let button = discoverItemBarButton {
          presentPopOverWithActions([discoverItem!.label: {$0.removeFromSuperview(); self.transact(discoverItem!)},
                                     discoverCollection!.label: {$0.removeFromSuperview(); self.transact(discoverCollection!)}],
                              above: button)
        }

        case let (discoverItem, discoverCollection) where discoverItem != nil && discoverCollection == nil:
          transact(discoverItem!)

        case let (discoverItem, discoverCollection) where discoverItem == nil && discoverCollection != nil:
          transact(discoverCollection!)

        // Don't do anything if we have no valid create transactions
        default:
          assert(false, "discover bar button item should only be enabled if delegate has at least one valid transaction")
      }
    }
  }

  /** createBankItem */
  func createBankItem() {
    switch (collectionDelegate.itemTransaction, collectionDelegate.collectionTransaction) {

      case let (.Some(item), .Some(collection)):
        if let button = createItemBarButton {
          presentPopOverWithActions([item.label: {$0.removeFromSuperview(); self.transact(item)},
                                     collection.label: {$0.removeFromSuperview(); self.transact(collection)}],
                              above: button)
        }
      case let (.Some(item), nil):               transact(item)
      case let (nil,         .Some(collection)): transact(collection)

      // Don't do anything if we have no valid create transactions
      default:
        assert(false, "create bar button item should only be enabled if delegate has at least one valid transaction")
    }
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
      let collections = reduce(0..<collectionDelegate.numberOfCollections, Array<ModelCollection>(), {
        if let collection = self.collectionDelegate.collectionAtIndex($1) { return $0 + [collection] } else { return $0 }
      })
      let items = reduce(0..<collectionDelegate.numberOfItems, Array<NamedModel>(), {
        if let item = self.collectionDelegate.itemAtIndex($1) { return $0 + [item] } else { return $0 }
      })
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
    return section == 0 ? collectionDelegate.numberOfCollections  : collectionDelegate.numberOfItems
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
        if let collection = collectionDelegate.collectionAtIndex(indexPath.row) {
          cell.collection = collection
          if mode == .Default {
            if (collection as? Editable)?.editable == true { cell.deleteAction = {[unowned cell] in self.deleteModelForCel(cell)} }
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
  numberOfSectionsInCollectionView:

  :param: collectionView UICollectionView

  :returns: Int
  */
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int { return 2 }

}

extension BankCollectionController: ZoomingCollectionViewLayoutDelegate {

  /**
  zoomedItemSize

  :returns: CGSize
  */
  func sizeForZoomedItemAtIndexPath(indexPath: NSIndexPath) -> CGSize {
    if indexPath == layout.zoomedItem, let model = modelForIndexPath(indexPath) as? Previewable, image = model.preview {
      let (w, h) = image.size.unpack()
      let ratio = Ratio(w, h)
      let width = min(w, collectionView?.bounds.width ?? 0)
      let height = ratio.denominatorForNumerator(width)
      return CGSize(width: width, height: height)
    } else { return CGSize.zeroSize } //layout.itemSize }
  }
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
