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

private let ExportBarItemImage         = UIImage(named:"702-gray-share")
private let ExportBarItemImageSelected = UIImage(named:"702-gray-share-selected")
private let ImportBarItemImage         = UIImage(named:"703-gray-download")
private let ImportBarItemImageSelected = UIImage(named:"703-gray-download-selected")
private let ListSegmentImage           = UIImage(named:"399-gray-list1") // 1073-gray-grid-1
private let ThumbnailSegmentImage      = UIImage(named:"822-gray-photo-2") // 1076-gray-grid-4
private let SearchBarItemImage         = UIImage(named:"708-gray-search")
private let IndicatorImage             = UIImage(named:"1040-gray-checkmark")
private let IndicatorImageSelected     = UIImage(named:"1040-gray-checkmark-selected")
private let TextFieldTextColor         = UIColor(RGBAHexString:"#9FA0A4FF")
private let CellIdentifier             = "Cell"
private let HeaderIdentifier           = "Header"

@objc(BankCollectionController)
class BankCollectionController: UICollectionViewController {

  let collectionItems: NSFetchedResultsController
  let collectionItemClass: BankableModelObject.Type

	private var updatesBlock: NSBlockOperation?
	private var hiddenSections = [Int]()

  private lazy var zoomView: BankCollectionZoom? = BankCollectionZoom(frame: self.view.bounds, delegate: self)

  private var exportAlertAction: UIAlertAction?
  private var existingFiles:     [String]! {
    didSet {
      if let files = existingFiles {
        let filesString = "\n\t".join(files)
        logDebug("existing json files in documents directory:\n\t\(filesString)", __FUNCTION__)
      }
    }
  }

  private var layout: BankCollectionLayout { return collectionViewLayout as BankCollectionLayout }

	private lazy var exportSelection = [BankableModelObject]()

  private var exportSelectionMode: Bool = false {
    didSet {

      // Create some variables to hold values for common actions to perform
      var rightBarButtonItems: [UIBarButtonItem]
      var cellIndicatorImage: UIImage?
      var exportBarItemImage: UIImage

      // Determine if we are entering or leaving export selection mode
      if exportSelectionMode {

        exportSelection.removeAll(keepCapacity: false)  // If entering, make sure our export items collection is empty

        // And, make sure no cells are selected
        if let indexPaths = collectionView!.indexPathsForSelectedItems() as? [NSIndexPath] {
          for indexPath in indexPaths { collectionView!.deselectItemAtIndexPath(indexPath, animated: true) }
        }

        // Set right bar button items
        rightBarButtonItems = [ UIBarButtonItem(title: "Export", style: .Done, target: self, action: "confirmExport:"),
                                UIBarButtonItem(title: "Select All", style: .Plain, target: self, action: "selectAll:") ]


        cellIndicatorImage = IndicatorImage              // Set indicator image
        exportBarItemImage = ExportBarItemImageSelected  // Set export bar item image


      } else {
        exportAlertAction = nil  // Make sure we don't leave a dangling alert action
        rightBarButtonItems = [ UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismiss:") ]
        exportBarItemImage = ExportBarItemImage  // Set export bar item image

      }

      collectionView!.allowsMultipleSelection = exportSelectionMode  // Update selection mode

      navigationItem.rightBarButtonItems = rightBarButtonItems  // Update right bar button items

      // Update image for export toolbar button
      if var items = toolbarItems as? [UIBarButtonItem] {
        items[0] = UIBarButtonItem(image: exportBarItemImage, style: .Plain, target: self, action: "exportBankObject:")
        self.setToolbarItems(items, animated: true)
      }

      // Update visible cells
      collectionView?.setValue(cellIndicatorImage, forKeyPath: "visibleCells.indicatorImage")

    }
  }

	private var useListView = true

	/**
	initWithItemClass:

	:param: collectionItemClass BankableModel.Type
	*/
  init(itemClass: BankableModelObject.Type) {
		collectionItemClass = itemClass
    collectionItems = collectionItemClass.allItems()
    super.init(collectionViewLayout: BankCollectionLayout())
    collectionItems.delegate = self
    if !collectionItemClass.isSectionable() { layout.includeSectionHeaders = false }
	}

  /**
  initWithItems:

  :param: items NSFetchedResultsController
  */
  init(items: NSFetchedResultsController) {
    collectionItems = items
    collectionItemClass = NSClassFromString(items.fetchRequest.entity.managedObjectClassName) as BankableModelObject.Type
    super.init(collectionViewLayout: BankCollectionLayout())
    collectionItems.delegate = self
    if !collectionItemClass.isSectionable() { layout.includeSectionHeaders = false }
  }

	/**
	init:

	:param: aDecoder NSCoder
	*/
	required init(coder aDecoder: NSCoder) {
    let collectionItemClassName = aDecoder.decodeObjectForKey("collectionItemClass") as String
    collectionItemClass = NSClassFromString(collectionItemClassName) as BankableModelObject.Type
    collectionItems = collectionItemClass.allItems()
    super.init(coder: aDecoder)
    collectionItems.delegate = self
    if !collectionItemClass.isSectionable() { layout.includeSectionHeaders = false }
	}

	/**
	loadView
	*/
	override func loadView() {

    title = collectionItemClass.directoryLabel()

    collectionView = { [unowned self] in

      // Create the collection layout
      self.layout.viewingMode = .List

      // Create the collection view
      let collectionView = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: self.layout)
      collectionView.backgroundColor = UIColor.whiteColor()

      // Register header and cell classes
      collectionView.registerClass(BankCollectionCell.self, forCellWithReuseIdentifier: CellIdentifier)
      collectionView.registerClass(BankCollectionHeader.self,
        forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
               withReuseIdentifier: HeaderIdentifier)
      return collectionView

    }()

    toolbarItems = {[unowned self] in

      // Create the toolbar items
      let exportBarItem = UIBarButtonItem(image: ExportBarItemImage, style: .Plain, target: self, action: "exportBankObject:")
      let spacer = UIBarButtonItem.fixedSpace(20.0)
      let importBarItem = UIBarButtonItem(image: ImportBarItemImage, style: .Plain, target: self, action: "importBankObject:")
      let flex = UIBarButtonItem.flexibleSpace()

      let displayOptions = UISegmentedControl(items: [ListSegmentImage, ThumbnailSegmentImage])
      displayOptions.selectedSegmentIndex = 0
      displayOptions.addTarget(self, action: "segmentedControlValueDidChange:", forControlEvents: .ValueChanged)

      let displayOptionsItem = UIBarButtonItem(customView: displayOptions)
      let searchBarItem = UIBarButtonItem(image: SearchBarItemImage, style: .Plain, target: self, action: "searchBankObjects:")


      return self.collectionItemClass.isThumbnailable()
               ? [exportBarItem, spacer, importBarItem, flex, displayOptionsItem, flex, searchBarItem]
               : [exportBarItem, spacer, importBarItem, flex, searchBarItem]
    }()

  }

  deinit { view.removeFromSuperview() }

  /**
  viewWillAppear:

  :param: animated Bool
  */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismiss:")

    // ???: Should we reload data here?
    // collectionView?.reloadData()
  }

  /**
  updateViewConstraints
  */
  override func updateViewConstraints() {
    super.updateViewConstraints()

    let identifier = "Internal"

    if view.constraintsWithIdentifier(identifier).count == 0 && zoomView != nil && zoomView!.superview === view {
      view.constrainWithFormat("zoom.center = self.center", views: ["zoom": zoomView!], identifier: identifier)
    }

  }


  ////////////////////////////////////////////////////////////////////////////////
  /// MARK: - Exporting items
  ////////////////////////////////////////////////////////////////////////////////


  /**
  refreshExistingFiles
  */
  private func refreshExistingFiles() {
    let attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_BACKGROUND, -1)
    let queue = dispatch_queue_create("com.moondeerstudios.background", attr)

    // Create closure since sticking this directly in the dispatch block crashes compiler
    let updateFiles = {[unowned self] (files: [String]) -> Void in self.existingFiles = files }

    dispatch_async(queue) {
      var directoryContents = MoonFunctions.documentsDirectoryContents()
                              .filter{$0.hasSuffix(".json")}
                                .map{$0[0 ..< ($0.length - 5)]}
      dispatch_async(dispatch_get_main_queue(), {updateFiles(directoryContents)})
    }
  }

  /**
  confirmExport:

  :param: sender AnyObject
  */
  func confirmExport(sender: AnyObject?) {

    var alert: UIAlertController

    // Check if we actually have any items selected for export
    if exportSelection.count > 0 {

      // Refresh our list of existing file names for checking during file export
      refreshExistingFiles()
      
      // Create the controller with export title and filename message
      alert = UIAlertController(title:          "Export Selection",
                                message:        "Enter a name for the exported file",
                                preferredStyle: .Alert)

      // Add the text field
      alert.addTextFieldWithConfigurationHandler{ [unowned self] in
        $0.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        $0.textColor = TextFieldTextColor
        $0.delegate = self
      }

      // Add the cancel button
      alert.addAction(
        UIAlertAction(title: "Cancel", style: .Cancel) { [unowned self] (action) in
          self.exportSelectionMode = false
          self.dismissViewControllerAnimated(true, completion: nil)
        })

      // Create the export action
      exportAlertAction = UIAlertAction(title: "Export", style: .Default){ [unowned self, alert] (action) in
        let text = (alert.textFields as [UITextField])[0].text
        precondition(text.length > 0 && text ∉ self.existingFiles, "text field should not be empty or match an existing file")
        let pathToFile = MoonFunctions.documentsPathToFile(text + ".json")
        self.exportSelectionToFile(pathToFile!)
        self.exportSelectionMode = false
        self.dismissViewControllerAnimated(true, completion: nil)
      }

      alert.addAction(exportAlertAction!)  // Add the action to the controller

    }

    // If not, let the user know our dilemma
    else {

      // Create the controller with export title and error message
      alert = UIAlertController(title:          "Export Selection",
                                message:        "No items have been selected, what do you suggest I export…hummmn?",
                                preferredStyle: .ActionSheet)

      // Add a button to dismiss
      alert.addAction(
        UIAlertAction(title: "Alright", style: .Default) { [unowned self] (action) in
          self.dismissViewControllerAnimated(true, completion: nil)
        })

    }

    presentViewController(alert, animated: true, completion: nil)  // Present the controller

  }

  /**
  exportSelectionToFile:

  :param: file String
  */
  private func exportSelectionToFile(file: String) { (exportSelection as NSArray).JSONString.writeToFile(file) }

  /**
  exportBankObject:

  :param: sender AnyObject?
  */
  func exportBankObject(sender: AnyObject?) { exportSelectionMode = !exportSelectionMode }


  ////////////////////////////////////////////////////////////////////////////////
  /// MARK: - Actions
  ////////////////////////////////////////////////////////////////////////////////

   /**
  deleteItem:

  :param: item BankableModelObject
  */
  func deleteItem(item: BankableModelObject) { if item.editable { item.managedObjectContext.deleteObject(item) } }

  /**
  editItem:

  :param: item BankableModelObject
  */
  func editItem(item: BankableModelObject) {
    navigationController?.pushViewController(item.editingViewController(), animated: true)
  }

  /**
  detailItem:

  :param: item BankableModelObject
  */
  func detailItem(item: BankableModelObject) {
    navigationController?.pushViewController(item.detailViewController(), animated: true)
  }

  /**
  toggleItemsForSection:

  :param: section Int
  */
  func toggleItemsForSection(section: Int) {
    if hiddenSections ∋ section { hiddenSections = hiddenSections.filter{$0 != section} }
    else                        { hiddenSections.append(section) }
    collectionView?.reloadSections(NSIndexSet(index: section))
  }

  /**
  segmentedControlValueDidChange:

  :param: sender UISegmentedControl
  */
  func segmentedControlValueDidChange(sender: UISegmentedControl) {
    useListView = sender.selectedSegmentIndex == 0
    layout.viewingMode = useListView ? .List : .Thumbnail
    layout.invalidateLayout()
  }

  /**
  importBankObject:

  :param: sender AnyObject?
  */
  func importBankObject(sender: AnyObject?) { logInfo("item import not yet implemented", __FUNCTION__)  }

  /**
  searchBankObjects:

  :param: sender AnyObject?
  */
  func searchBankObjects(sender: AnyObject?) { logInfo("item search not yet implemented", __FUNCTION__)  }

  /**
  dismiss:

  :param: sender AnyObject?
  */
  func dismiss(sender: AnyObject?) { MSRemoteAppController.sharedAppController().showMainMenu()  }


  ////////////////////////////////////////////////////////////////////////////////
  /// MARK: - Zooming a cell's item
  ////////////////////////////////////////////////////////////////////////////////


  private var zoomedItem: BankableModelObject?

  /**
  zoomItem:

  :param: item BankableModelObject
  */
  func zoomItem(item: BankableModelObject) {

    zoomedItem = item

    if let zoom = zoomView {

      zoom.item = item
      zoom.backgroundImage = view.blurredSnapshot()
      view.addSubview(zoom)
      view.setNeedsUpdateConstraints()

    }

  }

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - BankCollectionZoomDelegate
////////////////////////////////////////////////////////////////////////////////
extension BankCollectionController: BankCollectionZoomDelegate {

  /**
  didDismissZoomView:

  :param: zoom BankCollectionZoom
  */
  func didDismissZoomView(zoom: BankCollectionZoom) {
    precondition(zoom === zoomView, "exactly who's zoom view is this, anyway?")
    zoom.removeFromSuperview()
  }

  /**
  didDismissForDetailZoomView:

  :param: zoom BankCollectionZoom
  */
  func didDismissForDetailZoomView(zoom: BankCollectionZoom) {
    precondition(zoom === zoomView, "exactly who's zoom view is this, anyway?")
    zoom.removeFromSuperview()
    navigationController?.pushViewController(zoomedItem!.detailViewController(), animated: true)
  }

  /**
  didDismissForEditingZoomView:

  :param: zoom BankCollectionZoom
  */
  func didDismissForEditingZoomView(zoom: BankCollectionZoom) {
    precondition(zoom === zoomView, "exactly who's zoom view is this, anyway?")
    zoom.removeFromSuperview()
    navigationController?.pushViewController(zoomedItem!.editingViewController(), animated: true)
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

      // Enumerate all the sections
      for (sectionNumber, section) in enumerate(collectionItems.sections as [NSFetchedResultsSectionInfo]) {

        // Enumerate the items in this section
        for row in 0..<section.numberOfObjects {

          // Create the index path
          let indexPath = NSIndexPath(forRow: row, inSection: sectionNumber)

          // Get the corresponding item
          let item = collectionItems.objectAtIndexPath(indexPath) as BankableModelObject

          // Add the item to our export selection
          exportSelection.append(item)

          // Select the cell
          collectionView!.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .None)

          // Update the cell if it is visible
          if let cell = collectionView!.cellForItemAtIndexPath(indexPath) as? BankCollectionCell {
            cell.indicatorImage = IndicatorImageSelected
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
    if exportSelectionMode {

      // Remove all the items from export selection
      exportSelection.removeAll(keepCapacity: false)

      // Enumerate the selected index paths
      for indexPath in collectionView!.indexPathsForSelectedItems() as [NSIndexPath] {

        // Deselect the cell
        collectionView!.deselectItemAtIndexPath(indexPath, animated: true)

        // Update the cell image if it is visible
        if let cell = collectionView!.cellForItemAtIndexPath(indexPath) as? BankCollectionCell {
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
    var count = 0
      if let sections = collectionItems.sections as? [NSFetchedResultsSectionInfo] {
        if sections.count > section { count = sections[section].numberOfObjects }
      }
    return count
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
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier,
                                                        forIndexPath: indexPath) as BankCollectionCell
    cell.item = (collectionItems[indexPath] as BankableModelObject)
    cell.detailActionHandler   = {[unowned self] (cell) in self.detailItem(cell.item!)}
    cell.previewActionHandler  = {[unowned self] (cell) in self.zoomItem(cell.item!)}

    return cell
  }

  /**
  numberOfSectionsInCollectionView:

  :param: collectionView UICollectionView

  :returns: Int
  */
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return (collectionItems.sections as [NSFetchedResultsSectionInfo]).count
  }

  /**
  collectionView:viewForSupplementaryElementOfKind:atIndexPath:

  :param: collectionView UICollectionView
  :param: kind String
  :param: indexPath NSIndexPath

  :returns: UICollectionReusableView
  */
  override func        collectionView(collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
                          atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
  {
    var view: UICollectionReusableView?

    if kind == UICollectionElementKindSectionHeader {
      let header =
        collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                                          withReuseIdentifier: HeaderIdentifier,
                                                 forIndexPath: indexPath) as BankCollectionHeader
      let section = indexPath.section
      // FIXME: Crash when loading component device codes
      if let sections = collectionItems.sections as? [NSFetchedResultsSectionInfo] {
        if sections.count > section {
          let sectionInfo = sections[section]
          header.title = sectionInfo.name
          header.toggleActionHandler = {[unowned self] _ in
            (self.collectionViewLayout! as BankCollectionLayout).toggleItemsForSection(section)
          }
        }
      }
      header.title = (collectionItems.sections as [NSFetchedResultsSectionInfo])[indexPath.section].name

      view = header
    }

    return view ?? UICollectionReusableView()
  }

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

    let bankCell = cell as BankCollectionCell
    bankCell.indicatorImage = (exportSelectionMode
                                ? (exportSelection ∋ bankCell.item! ? IndicatorImageSelected : IndicatorImage)
                                : nil)
  }

  /**
  collectionView:didDeselectItemAtIndexPath:

  :param: collectionView UICollectionView
  :param: indexPath NSIndexPath
  */
  override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {

    let cell = collectionView.cellForItemAtIndexPath(indexPath) as BankCollectionCell

    // Check if we are selecting items to export
    if exportSelectionMode {
      exportSelection = exportSelection.filter{$0 != cell.item}  // Remove from our collection of items to export
      cell.indicatorImage = IndicatorImage                       // Change the indicator to normal
    }

  }

  /**
  collectionView:didSelectItemAtIndexPath:

  :param: collectionView UICollectionView
  :param: indexPath NSIndexPath
  */
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

    let cell = collectionView.cellForItemAtIndexPath(indexPath) as BankCollectionCell

    // Check if we are selecting items to export
    if exportSelectionMode {
      exportSelection.append(cell.item!)             // Add to our collection of items to export
      cell.indicatorImage = IndicatorImageSelected  // Change indicator to selected
    }

    // Otherwise we push the item's detail view controller
    else { navigationController?.pushViewController(cell.item!.detailViewController(), animated:true) }

  }

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - NSFetchedResultsControllerDelegate
////////////////////////////////////////////////////////////////////////////////
extension BankCollectionController: NSFetchedResultsControllerDelegate {

  /**
  controllerWillChangeContent:

  :param: controller NSFetchedResultsController
  */
  func controllerWillChangeContent(controller: NSFetchedResultsController) { updatesBlock = NSBlockOperation() }

  /**
  controller:didChangeSection:atIndex:forChangeType:

  :param: controller NSFetchedResultsController
  :param: sectionInfo NSFetchedResultsSectionInfo
  :param: sectionIndex Int
  :param: type NSFetchedResultsChangeType
  */
  func    controller(controller: NSFetchedResultsController,
    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
             atIndex sectionIndex: Int,
       forChangeType type: NSFetchedResultsChangeType)
  {
    updatesBlock?.addExecutionBlock { [unowned self] in
      switch type {
        case .Insert: self.collectionView?.insertSections(NSIndexSet(index:sectionIndex))
        case .Delete: self.collectionView?.deleteSections(NSIndexSet(index:sectionIndex))
        default: break
      }
    }
  }

  /**
  controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:

  :param: controller NSFetchedResultsController
  :param: anObject AnyObject
  :param: indexPath NSIndexPath?
  :param: type NSFetchedResultsChangeType
  :param: newIndexPath NSIndexPath?
  */
  func controller(controller: NSFetchedResultsController,
  didChangeObject anObject: AnyObject,
      atIndexPath indexPath: NSIndexPath?,
    forChangeType type: NSFetchedResultsChangeType,
     newIndexPath: NSIndexPath?)
  {
    updatesBlock?.addExecutionBlock{[unowned self] in
      switch type {
        case .Insert: self.collectionView?.insertItemsAtIndexPaths([newIndexPath!])
        case .Delete: self.collectionView?.deleteItemsAtIndexPaths([indexPath!])
        case .Move:   self.collectionView?.deleteItemsAtIndexPaths([indexPath!])
                      self.collectionView?.insertItemsAtIndexPaths([newIndexPath!])
        default: break
      }
    }
  }

  /**
  controllerDidChangeContent:

  :param: controller NSFetchedResultsController
  */
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    collectionView?.performBatchUpdates({[unowned self] in NSOperationQueue.mainQueue().addOperation(self.updatesBlock!) },
                             completion: nil)
  }

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - UITextFieldDelegate
////////////////////////////////////////////////////////////////////////////////
extension BankCollectionController: UITextFieldDelegate {

  /**
  textFieldShouldEndEditing:

  :param: textField UITextField

  :returns: Bool
  */
  func textFieldShouldEndEditing(textField: UITextField) -> Bool {
    if existingFiles ∋ textField.text {
      textField.textColor = UIColor(name:"fire-brick")
      return false
    }
    return true
  }

  /**
  textField:shouldChangeCharactersInRange:replacementString:

  :param: textField UITextField
  :param: range NSRange
  :param: string String

  :returns: Bool
  */
  func                  textField(textField: UITextField,
    shouldChangeCharactersInRange range: NSRange,
                replacementString string: String) -> Bool
  {
    let text = (range.length == 0
                       ? textField.text + string
                       : (textField.text as NSString).stringByReplacingCharactersInRange(range, withString:string))
    let nameInvalid = existingFiles ∋ text
    textField.textColor = nameInvalid ? UIColor(name: "fire-brick") : TextFieldTextColor
    exportAlertAction?.enabled = !nameInvalid
    return true
  }

  /**
  textFieldShouldReturn:

  :param: textField UITextField

  :returns: Bool
  */
  func textFieldShouldReturn(textField: UITextField) -> Bool { return false }

  /**
  textFieldShouldClear:

  :param: textField UITextField

  :returns: Bool
  */
  func textFieldShouldClear(textField: UITextField) -> Bool { return true }

}
