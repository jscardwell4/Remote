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

var msLogLevel = LOG_LEVEL_DEBUG

private let IndicatorImage             = UIImage(named:"1040-checkmark-toolbar")!
private let IndicatorImageSelected     = UIImage(named:"1040-checkmark-toolbar-selected")!
private let TextFieldTextColor         = UIColor(RGBAHexString:"#9FA0A4FF")
private let ItemCellIdentifier         = "ItemCell"
private let CategoryCellIdentifier     = "CategoryCell"
private let HeaderIdentifier           = "Header"

@objc(BankCollectionController)
class BankCollectionController: UICollectionViewController, BankController {

  var category: BankDisplayItemCategory!

  private lazy var zoomView: BankCollectionZoom? = BankCollectionZoom(frame: self.view.bounds, delegate: self)

  private var exportAlertAction: UIAlertAction?
  private var existingFiles: [String] = []

  private var layout: BankCollectionLayout { return collectionViewLayout as BankCollectionLayout }

  private var exportSelection: [BankDisplayItemModel] = []

  private var exportSelectionMode: Bool = false {
    didSet {

      // Create some variables to hold values for common actions to perform
      var rightBarButtonItems: [UIBarButtonItem]
      var cellIndicatorImage: UIImage?

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


      } else {
        exportAlertAction = nil  // Make sure we don't leave a dangling alert action
        rightBarButtonItems = [ Bank.dismissBarButtonItem ]

      }

      collectionView!.allowsMultipleSelection = exportSelectionMode  // Update selection mode

      navigationItem.rightBarButtonItems = rightBarButtonItems  // Update right bar button items

      // Update visible cells
//      if let visibleCells = collectionView?.visibleCells() as? [UICollectionViewCell] {
//        let itemCells = visibleCells.filter{$0 is BankCollectionItemCell}
//        for itemCell in itemCells as [BankCollectionItemCell] { itemCell.indicatorImage = cellIndicatorImage }
//      }
      collectionView?.setValue(cellIndicatorImage, forKeyPath: "visibleCells.indicatorImage")

    }
  }

  private var useListView = true

  init?(category: BankDisplayItemCategory) {
    super.init(collectionViewLayout: BankCollectionLayout())
    self.category = category
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /**
  didMoveToParentViewController:

  :param: parent UIViewController?
  */
  /*
  override func didMoveToParentViewController(parent: UIViewController?) {
    super.didMoveToParentViewController(parent)
    if parent != nil { layout.includeSectionHeaders = false }
  }
  */

  /**
  loadView
  */
  override func loadView() {

    title = category.title
    layout.viewingMode = .List

    collectionView = {

      // Create the collection view
      let collectionView = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: self.layout)
      collectionView?.backgroundColor = Bank.backgroundColor

      // Register header and cell classes
      collectionView?.registerClass(BankCollectionCategoryCell.self, forCellWithReuseIdentifier: CategoryCellIdentifier)
      collectionView?.registerClass(BankCollectionItemCell.self, forCellWithReuseIdentifier: ItemCellIdentifier)
      collectionView?.registerClass(BankCollectionHeader.self,
        forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
               withReuseIdentifier: HeaderIdentifier)
      return collectionView

    }()


    toolbarItems = {

      var items = Bank.toolbarItemsForController(self)

      if self.category.thumbnailableItems {
        // Create the toolbar items
        if let displayOptions = ToggleImageSegmentedControl(items: [UIImage(named: "1073-grid-1-toolbar")!,
                                                                    UIImage(named: "1073-grid-1-toolbar-selected")!,
                                                                    UIImage(named: "1076-grid-4-toolbar")!,
                                                                    UIImage(named: "1076-grid-4-toolbar-selected")!])
        {
          displayOptions.selectedSegmentIndex = 0
          displayOptions.addTarget(self, action: "segmentedControlValueDidChange:", forControlEvents: .ValueChanged)
//          UIGraphicsBeginImageContextWithOptions(CGSize(width: 38.0, height: 38.0), false, 0.0)
//          let path = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: 38.0, height: 38.0), cornerRadius: 3.0)
//          path.stroke()
//          let image = UIGraphicsGetImageFromCurrentImageContext()
//          UIGraphicsEndImageContext()
//          let stretchableImage = image.resizableImageWithCapInsets(UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0))
//          let templateImage = image.imageWithRenderingMode(.AlwaysTemplate)
//          displayOptions.setBackgroundImage(templateImage, forState: .Normal, barMetrics: .Default)

          let displayOptionsItem = UIBarButtonItem(customView: displayOptions)

          items.insert(UIBarButtonItem.flexibleSpace(), atIndex: 4)
          items.insert(displayOptionsItem, atIndex: 4)
        }
      }

      return items
      }()

  }

  /**
  viewWillAppear:

  :param: animated Bool
  */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.rightBarButtonItem = Bank.dismissBarButtonItem

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
  private func exportSelectionToFile(file: String) {
    ((exportSelection as NSArray).JSONString as NSString).writeToFile(file as NSString)
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
  deleteItem:

  :param: item BankDisplayItemModel
  */
  func deleteItem(item: BankDisplayItemModel) {
    if item.editable { item.delete() }
  }

  /**
  editItem:

  :param: item BankDisplayItemModel
  */
  func editItem(item: BankDisplayItemModel) {
//    navigationController?.pushViewController(item.detailController!, animated: true)
  }

  /**
  detailItem:

  :param: item BankDisplayItemModel
  */
  func detailItem(item: BankDisplayItemModel) {
//    navigationController?.pushViewController(item.detailController!, animated: true)
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
  func importBankObjects() { MSLogInfo("item import not yet implemented")  }

  /**
  searchBankObjects:

  :param: sender AnyObject?
  */
  func searchBankObjects() { MSLogInfo("item search not yet implemented")  }


  ////////////////////////////////////////////////////////////////////////////////
  /// MARK: - Zooming a cell's item
  ////////////////////////////////////////////////////////////////////////////////


  private var zoomedItem: BankDisplayItemModel?

  /**
  zoomItem:

  :param: item BankDisplayItemModel
  */
  func zoomItem(item: BankDisplayItemModel) {

    zoomedItem = item

/*
    if let zoom = zoomView {

      zoom.item = item
      zoom.backgroundImage = view.blurredSnapshot()
      view.addSubview(zoom)
      view.setNeedsUpdateConstraints()

    }

*/
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
//    navigationController?.pushViewController(zoomedItem!.detailController!, animated: true)
  }

  /**
  didDismissForEditingZoomView:

  :param: zoom BankCollectionZoom
  */
  func didDismissForEditingZoomView(zoom: BankCollectionZoom) {
    precondition(zoom === zoomView, "exactly who's zoom view is this, anyway?")
    zoom.removeFromSuperview()
//    navigationController?.pushViewContrboller(zoomedItem!.editingController!, animated: true)
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

//      if let controller = collectionItemsController {
//        // Enumerate all the sections
//        for (sectionNumber, section) in enumerate(controller.sections as [NSFetchedResultsSectionInfo]) {
//
//          // Enumerate the items in this section
//          for row in 0..<section.numberOfObjects {
//
//            // Create the index path
//            let indexPath = NSIndexPath(forRow: row, inSection: sectionNumber)
//
//            // Get the corresponding item
//            let item = controller.objectAtIndexPath(indexPath) as BankDisplayItemModel
//
//            // Add the item to our export selection
//            exportSelection.append(item)
//
//            // Select the cell
//            collectionView!.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .None)
//
//            // Update the cell if it is visible
//            if let cell = collectionView!.cellForItemAtIndexPath(indexPath) as? BankCollectionItemCell {
//              cell.indicatorImage = IndicatorImageSelected
//            }
//
//          }
//
//        }
//
//      }

      // TODO: Add selection when using `collectionItems`

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
        if let cell = collectionView!.cellForItemAtIndexPath(indexPath) as? BankCollectionItemCell {
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
        cell.labelText = subcategory.title
        return cell

      default:
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ItemCellIdentifier,
                                                            forIndexPath: indexPath) as BankCollectionItemCell
        let item = category.items[indexPath.row]
        cell.item = item
        cell.previewActionHandler = {self.zoomItem(item)}
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

    if let bankCell = cell as? BankCollectionItemCell {
      bankCell.indicatorImage = (exportSelectionMode
                                  ? (contains(exportSelection){bankCell.item!.isEqual($0)} ? IndicatorImageSelected : IndicatorImage)
                                  : nil)
    }
  }

  /**
  collectionView:didDeselectItemAtIndexPath:

  :param: collectionView UICollectionView
  :param: indexPath NSIndexPath
  */
  override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {

    if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? BankCollectionItemCell {

      // Check if we are selecting items to export
      if exportSelectionMode {
        exportSelection = exportSelection.filter{!cell.item!.isEqual($0)}  // Remove from our collection of items to export
        cell.indicatorImage = IndicatorImage                               // Change the indicator to normal
      }

    }

  }

  /**
  collectionView:didSelectItemAtIndexPath:

  :param: collectionView UICollectionView
  :param: indexPath NSIndexPath
  */
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

    if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? BankCollectionItemCell {

      // Check if we are selecting items to export
      if exportSelectionMode {
        exportSelection.append(cell.item!)             // Add to our collection of items to export
        cell.indicatorImage = IndicatorImageSelected  // Change indicator to selected
      }

      // Otherwise we push the item's detail view controller
      //else { navigationController?.pushViewController(cell.item!.detailController!, animated:true) }

    }

    else if indexPath.section == 0 {

      let subcategory = category.subcategories[indexPath.row]
      if let controller = BankCollectionController(category: subcategory) {
        navigationController?.pushViewController(controller, animated: true)
      }
    }

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
