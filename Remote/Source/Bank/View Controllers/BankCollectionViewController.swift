//
//  BankCollectionViewController.swift
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
private let ListSegmentImage           = UIImage(named:"399-gray-list1")
private let ThumbnailSegmentImage      = UIImage(named:"822-gray-photo-2")
private let SearchBarItemImage         = UIImage(named:"708-gray-search")
private let IndicatorImage             = UIImage(named:"1040-gray-checkmark")
private let IndicatorImageSelected     = UIImage(named:"1040-gray-checkmark-selected")
private let TextFieldTextColor         = UIColor(RGBAHexString:"#9FA0A4FF")

private let ListItemCellSize      = CGSize(width: 320.0, height: 38.0)
private let ThumbnailItemCellSize = CGSize(width: 100.0, height: 100.0)
private let HeaderSize            = CGSize(width: 320.0, height: 38.0)

@objc(BankCollectionViewController)
class BankCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate, UITextFieldDelegate {

  private(set) lazy var allItems: NSFetchedResultsController! = {
    let controller = self.itemClass.allItems()
    controller?.delegate = self
    return controller }()

	private(set) var itemClass: BankableModelObject.Type

	private var updatesBlock: NSBlockOperation?
	private var hiddenSections = [Int]()

  private var previewController: BankPreviewViewController? {
    get {
      if self.previewController == nil { self.previewController = BankPreviewViewController() }
      return self.previewController
    }
    set { self.previewController = newValue }
  }

  private lazy var zoomView: BankCollectionZoomView! = {
    let nibContents = NSBundle.mainBundle().loadNibNamed("BankCollectionZoomView", owner: self, options: nil)
    return nibContents[0] as? BankCollectionZoomView
    }()

	private var layout:            BankCollectionLayout!
	private var exportAlertAction: UIAlertAction?
  private var existingFiles:     [String]! {
    didSet {
      if let files = existingFiles {
        let filesString = "\n\t".join(files)
        logDebug("existing json files in documents directory:\n\t\(filesString)", __FUNCTION__)
      }
    }
  }

	private var exportSelection = [BankableModelObject]()

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

	private var zoomedItem:                 BankableModelObject?
	private var swipeToDeleteCellIndexPath: NSIndexPath?


	/**
	initWithItemClass:

	:param: itemClass BankableModel.Type
	*/
  init(itemClass: BankableModelObject.Type) {
		self.itemClass = itemClass
		super.init(nibName: nil, bundle: nil)
	}

	/**
	init:

	:param: aDecoder NSCoder
	*/
	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	/**
	loadView
	*/
	override func loadView() {

    // Create the collection layout
		layout = BankCollectionLayout()
		layout.itemSize = CGSize(width: 100.0, height: 100.0)

    // Create the collection view
		collectionView = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: layout)
		collectionView!.backgroundColor = UIColor.whiteColor()

    // Register header and cell classes
    collectionView!.registerClass(BankCollectionViewHeader.self,
      forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
             withReuseIdentifier: BankCollectionViewHeader.identifier)
    collectionView!.registerClass(BankCollectionViewCell.self,
       forCellWithReuseIdentifier: BankCollectionViewCell.listIdentifier)
    collectionView!.registerClass(BankCollectionViewCell.self,
       forCellWithReuseIdentifier: BankCollectionViewCell.thumbnailIdentifier)

    // Create the toolbar items
    let exportBarItem = UIBarButtonItem(image: ExportBarItemImage, style: .Plain, target: self, action: "exportBankObject:")
    let spacer = UIBarButtonItem.fixedSpace(20.0)
    let importBarItem = UIBarButtonItem(image: ImportBarItemImage, style: .Plain, target: self, action: "importBankObject:")
    let flex = UIBarButtonItem.flexibleSpace()
    let displayOptions = UISegmentedControl(items: [ListSegmentImage, ThumbnailSegmentImage])
    let searchBarItem = UIBarButtonItem(image: SearchBarItemImage, style: .Plain, target: self, action: "searchBankObjects:")

    toolbarItems = itemClass.isThumbnailable()
      ? [exportBarItem, spacer, importBarItem, flex, displayOptions, flex, searchBarItem]
      : [exportBarItem, spacer, importBarItem, flex, searchBarItem]

    // Refresh our list of existing file names for checking during file export
    refreshExistingFiles()

  }

  /**
  viewWillAppear:

  :param: animated Bool
  */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismiss:")
    collectionView?.reloadData()
  }

  /**
  didReceiveMemoryWarning
  */
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    previewController = nil
    zoomView = nil
    updatesBlock = nil
    allItems = nil
  }


  /**
  updateViewConstraints
  */
  override func updateViewConstraints() {
    super.updateViewConstraints()

    if zoomView != nil && zoomView!.superview != nil {
      let format = "\n".join(["zoom.centerX = view.centerX", "zoom.centerY = view.centerY"])
      let views = ["zoom": zoomView!, "view": view]
      view.addConstraints(NSLayoutConstraint.constraintsByParsingString(format, views: views))
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
  zoomItem:

  :param: item BankableModelObject
  */
  func zoomItem(item: BankableModelObject) {

    zoomedItem = item

    if let zoom = zoomView {

      zoom.item = item
      zoom.backgroundImageView.image = view.snapshot().applyBlurWithRadius(3.0,
                                                                 tintColor: UIColor(white: 1.0, alpha: 0.5),
                                                     saturationDeltaFactor: 1.8,
                                                                 maskImage: nil)
      view.addSubview(zoom)
      view.setNeedsUpdateConstraints()

    }

  }

  /**
  previewItem:

  :param: item BankableModelObject
  */
  func previewItem(item: BankableModelObject) {
    if let controller = previewController {
      controller.image = item.preview
      presentViewController(controller, animated: true, completion: nil)
    }
  }

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
    useListView = Bool(sender.selectedSegmentIndex == 0)
    collectionView?.collectionViewLayout.invalidateLayout()
    collectionView?.reloadData()
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
  func dismiss(sender: AnyObject?) {
    MSRemoteAppController.sharedAppController().dismissViewController(Bank.viewController(), completion: nil)
  }

  /**
  dismissZoom:

  :param: sender AnyObject?
  */
  func dismissZoom(sender: AnyObject?) {
    if let zoom = zoomView {
      zoom.removeFromSuperview()
      var viewController: UIViewController?
      if let button = sender as? UIButton {
        if button === zoom.editButton { viewController = zoomedItem!.editingViewController() }
        else if button === zoom.detailButton { viewController = zoomedItem!.detailViewController() }
      }
      if viewController != nil { navigationController?.pushViewController(viewController!, animated: true) }
    }

  }

  /**
  selectAll:

  :param: sender AnyObject!
  */
  override func selectAll(sender: AnyObject!) {
    if exportSelectionMode {
      for (sectionNumber, section) in enumerate(allItems.sections as [NSFetchedResultsSectionInfo]) {
        for row in 0..<section.numberOfObjects {
          let indexPath = NSIndexPath(forRow: row, inSection: sectionNumber)
          collectionView!.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .None)
          let cell = collectionView!.cellForItemAtIndexPath(indexPath) as BankCollectionViewCell
          cell.indicatorImage = IndicatorImageSelected
          exportSelection.append(cell.item!)
        }
      }
    }
  }

  /**
  deselectAll:

  :param: sender AnyObject!
  */
  func deselectAll(sender: AnyObject!) {
    for indexPath in collectionView!.indexPathsForSelectedItems() as [NSIndexPath] {
      collectionView!.deselectItemAtIndexPath(indexPath, animated: true)
    }
  }

  ////////////////////////////////////////////////////////////////////////////////
  /// MARK: - Collection view data source
  ////////////////////////////////////////////////////////////////////////////////


  /**
  collectionView:numberOfItemsInSection:

  :param: collectionView UICollectionView
  :param: section Int

  :returns: Int
  */
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return hiddenSections ∋ section ? 0 : (allItems.sections as [NSFetchedResultsSectionInfo])[section].numberOfObjects
  }

  /**
  collectionView:cellForItemAtIndexPath:

  :param: collectionView UICollectionView
  :param: indexPath NSIndexPath

  :returns: UICollectionViewCell
  */
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

    let identifer = useListView ? BankCollectionViewCell.listIdentifier : BankCollectionViewCell.thumbnailIdentifier

    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifer, forIndexPath:indexPath) as BankCollectionViewCell
    cell.item = (allItems[indexPath] as BankableModelObject)
    cell.detailActionHandler = {[unowned self] (cell) in self.detailItem(cell.item!)}
    cell.imageActionHandler  = {[unowned self] (cell) in self.previewItem(cell.item!)}

    return cell
  }

  /**
  numberOfSectionsInCollectionView:

  :param: collectionView UICollectionView

  :returns: Int
  */
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return (allItems.sections as [NSFetchedResultsSectionInfo]).count
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
                                          withReuseIdentifier: BankCollectionViewHeader.identifier,
                                                 forIndexPath: indexPath) as BankCollectionViewHeader
      header.controller = self
      header.section    = indexPath.section
      header.title      = (allItems.sections as [NSFetchedResultsSectionInfo])[indexPath.section].name

      view = header
    }

    return view ?? UICollectionReusableView()
  }


  ////////////////////////////////////////////////////////////////////////////////
  /// MARK: - Collection view delegate
  ////////////////////////////////////////////////////////////////////////////////


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
    (cell as BankCollectionViewCell).indicatorImage = exportSelectionMode ? IndicatorImage : nil
  }

  /**
  collectionView:didDeselectItemAtIndexPath:

  :param: collectionView UICollectionView
  :param: indexPath NSIndexPath
  */
  override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {

    let cell = collectionView.cellForItemAtIndexPath(indexPath) as BankCollectionViewCell

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

    let cell = collectionView.cellForItemAtIndexPath(indexPath) as BankCollectionViewCell

    // Check if we are selecting items to export
    if exportSelectionMode {
      exportSelection.append(cell.item!)             // Add to our collection of items to export
      cell.indicatorImage = IndicatorImageSelected  // Change indicator to selected
    }

    // Otherwise we push the item's detail view controller
    else { navigationController?.pushViewController(cell.item!.detailViewController(), animated:true) }

  }

  /**
  collectionView:canPerformAction:forItemAtIndexPath:withSender:

  :param: collectionView UICollectionView
  :param: action Selector
  :param: indexPath NSIndexPath
  :param: sender AnyObject!

  :returns: Bool
  */
  override func collectionView(collectionView: UICollectionView,
              canPerformAction action: Selector,
            forItemAtIndexPath indexPath: NSIndexPath,
                    withSender sender: AnyObject!) -> Bool
  {
    return (action == "deleteItemForCell:" && (allItems[indexPath] as BankableModelObject).editable)
  }


  ////////////////////////////////////////////////////////////////////////////////
  /// MARK: - Collection view delegate - flow layout
  ////////////////////////////////////////////////////////////////////////////////


  /**
  collectionView:layout:sizeForItemAtIndexPath:

  :param: collectionView UICollectionView
  :param: collectionViewLayout UICollectionViewLayout
  :param: indexPath NSIndexPath

  :returns: CGSize
  */
  func      collectionView(collectionView: UICollectionView,
                    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
  {

    var size = CGSize()

    if useListView { size = ListItemCellSize }

    else {

      let maxSize = ThumbnailItemCellSize
      let item = allItems[indexPath] as BankableModelObject

      var imageSize = CGSize()

      if let itemImage = item.preview { imageSize = itemImage.size }

      var fittedSize = CGSizeAspectMappedToSize(imageSize, maxSize, true)

      if fittedSize.width < maxSize.width   { fittedSize.width  = ceil(fittedSize.width)  }
      if fittedSize.height < maxSize.height { fittedSize.height = ceil(fittedSize.height) }

      if CGSizeContainsSize(maxSize, fittedSize) { size = fittedSize } else { size = CGSize() }

    }

    return size

  }

  /**
  collectionView:layout:referenceSizeForHeaderInSection:

  :param: collectionView UICollectionView
  :param: collectionViewLayout UICollectionViewLayout
  :param: section Int

  :returns: CGSize
  */
  func      collectionView(collectionView: UICollectionView,
                   layout collectionViewLayout: UICollectionViewLayout,
  referenceSizeForHeaderInSection section: Int) -> CGSize
  {
    return itemClass.isSectionable() ? HeaderSize : CGSize()
  }

  ////////////////////////////////////////////////////////////////////////////////
  /// MARK: - Fetched results controller delegate
  ////////////////////////////////////////////////////////////////////////////////


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


  ////////////////////////////////////////////////////////////////////////////////
  /// MARK: - UITextFieldDelegate
  ////////////////////////////////////////////////////////////////////////////////

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
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
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
