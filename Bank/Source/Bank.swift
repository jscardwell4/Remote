//
//  Bank.swift
//  Remote
//
//  Created by Jason Cardwell on 9/27/14.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit
import DataModel

@objc protocol Detailable { func detailController() -> UIViewController }
@objc protocol Previewable { var preview: UIImage { get }; var thumbnail: UIImage { get } }

protocol BankItemSelectionDelegate {
  func bankController(bankController: BankController, didSelectItem item: EditableModel)
}

/** Protocol for types that want to display Bank toolbars, or other assets */
protocol BankController: class {

  var exportSelection: [MSJSONExport] { get }
  var exportSelectionMode: Bool { get set }

  func selectAllExportableItems() // Called from select all bar button action
  func importFromFile(fileURL: NSURL)

}

protocol SearchableBankController: BankController {

  func searchBankObjects()  // Called from search bar button action

}

//struct BankRootCategory<SubcategoryType:ModelCategory, ItemType:EditableModel> {
//  let label: String
//  let icon: UIImage
//  let subcategories: [SubcategoryType]
//  let items: [ItemType]
//  let previewableItems:   Bool
//  let editableItems:      Bool
//
//  init(label: String,
//    icon: UIImage,
//    subcategories: [SubcategoryType] = [],
//    items: [ItemType] = [],
//    previewableItems: Bool = false,
//    editableItems: Bool = false)
//  {
//    self.label = label
//    self.icon = icon
//    self.subcategories = subcategories
//    self.items = items
//    self.previewableItems = previewableItems
//    self.editableItems = editableItems
//  }
//}

class Bank {


  /// The bank's constant class properties
  ////////////////////////////////////////////////////////////////////////////////

  // Fonts
  static let labelFont                  = UIFont(name: "Elysio-Medium", size: 15.0)!
  static let boldLabelFont              = UIFont(name: "Elysio-Bold",   size: 17.0)!
  static let largeBoldLabelFont         = UIFont(name: "Elysio-Bold",   size: 18.0)!
  static let infoFont                   = UIFont(name: "Elysio-Light",  size: 15.0)!

  // Colors
  static let labelColor                 = UIColor(r: 59, g: 60, b: 64, a:255)!
  static let infoColor                  = UIColor(r:159, g:160, b:164, a:255)!
  static let backgroundColor            = UIColor.whiteColor()

  // Images
  static let exportBarItemImage         = UIImage(named:"702-share-toolbar")!
  static let exportBarItemImageSelected = UIImage(named:"702-share-toolbar-selected")!
  static let importBarItemImage         = UIImage(named:"703-download-toolbar")!
  static let importBarItemImageSelected = UIImage(named:"703-download-toolbar-selected")!
  static let searchBarItemImage         = UIImage(named:"708-search-toolbar")!
  static let searchBarItemImageSelected = UIImage(named:"708-search-toolbar-selected")!

  static let defaultRowHeight: CGFloat = 38.0
  static let separatorStyle: UITableViewCellSeparatorStyle = .None
  static let keyboardAppearance: UIKeyboardAppearance = .Dark

  static let titleTextAttributes = [ NSFontAttributeName:            Bank.boldLabelFont,
                                     NSForegroundColorAttributeName: Bank.labelColor ]

  /**
  toolbarItemsForController:

  :param: controller BankController

  :returns: [UIBarButtonItem]
  */
  class func toolbarItemsForController(controller: BankController, addingItems items: [UIBarItem]? = nil) -> [UIBarItem] {

    let exportBarItem = ToggleImageBarButtonItem(
      image: Bank.exportBarItemImage,
      toggledImage: Bank.exportBarItemImageSelected) {
        (item: ToggleBarButtonItem) -> Void in
          controller.exportSelectionMode = item.isToggled
    }

    let spacer = UIBarButtonItem.fixedSpace(-10.0)

    let importBarItem = ToggleImageBarButtonItem(
      image: Bank.importBarItemImage,
      toggledImage: Bank.importBarItemImageSelected) {
        (item: ToggleBarButtonItem) -> Void in

          struct ImportToggleActionProperties { static var fileController: DocumentSelectionController? }

          var fileController: DocumentSelectionController?

          // Create the file controller and add it
          if item.isToggled {

            fileController = DocumentSelectionController()
            ImportToggleActionProperties.fileController = fileController
            fileController!.didDismiss = {
              (documentSelectionController: DocumentSelectionController) -> Void in
                documentSelectionController.willMoveToParentViewController(nil)
                documentSelectionController.view.removeFromSuperview()
                documentSelectionController.removeFromParentViewController()
                item.toggle(nil)
                ImportToggleActionProperties.fileController = nil
            }
            fileController!.didSelectFile = {
              (documentSelectionController: DocumentSelectionController) -> Void in
                if let selectedFile = documentSelectionController.selectedFile {
                  controller.importFromFile(selectedFile)
                }
                documentSelectionController.willMoveToParentViewController(nil)
                documentSelectionController.view.removeFromSuperview()
                documentSelectionController.removeFromParentViewController()
                item.toggle(nil)
                ImportToggleActionProperties.fileController = nil
            }
            if let rootViewController =  UIApplication.sharedApplication().keyWindow?.rootViewController {
              let rootView = rootViewController.view
              rootViewController.addChildViewController(fileController!)
              fileController!.view.setTranslatesAutoresizingMaskIntoConstraints(false)
              if rootViewController is UINavigationController {
                rootViewController.view.insertSubview(fileController!.view, atIndex: 1)
              } else {
                rootViewController.view.addSubview(fileController!.view)
              }
              rootViewController.view.stretchSubview(fileController!.view)
            }

          }

          // Or remove the file controller
          else {
            fileController = ImportToggleActionProperties.fileController
            fileController?.willMoveToParentViewController(nil)
            fileController?.view.removeFromSuperview()
            fileController?.removeFromParentViewController()
            ImportToggleActionProperties.fileController = nil
          }

    }
    let flex = UIBarButtonItem.flexibleSpace()

    var toolbarItems: [UIBarItem] = [spacer, exportBarItem, spacer, importBarItem, spacer, flex]

    if let middleItems = items { toolbarItems += middleItems }

    toolbarItems += [flex, spacer]

    return  toolbarItems
  }

  /**
  toolbarItemsForController:

  :param: controller BankController

  :returns: [UIBarButtonItem]
  */
  class func toolbarItemsForController(controller: SearchableBankController,
                           addingItems items: [UIBarItem]? = nil) -> [UIBarItem]
  {
    var toolbarItems = toolbarItemsForController(controller as BankController, addingItems: items)
    let spacer = UIBarButtonItem.fixedSpace(-10.0)
    let searchBarItem = ToggleImageBarButtonItem(image: Bank.searchBarItemImage,
      toggledImage: Bank.searchBarItemImageSelected) {
        _ in controller.searchBankObjects()
    }
    toolbarItems += [searchBarItem, spacer]
    return  toolbarItems
  }


  /**
  exportBarButtonItemForController:

  :param: controller BankController

  :returns: BlockBarButtonItem
  */
  class func exportBarButtonItemForController(controller: BankController) -> BlockBarButtonItem {
    return BlockBarButtonItem(title: "Export", style: .Done, action: {
      () -> Void in
        let exportSelection = controller.exportSelection
        if exportSelection.count != 0 {
          ImportExportFileManager.confirmExportOfItems(controller.exportSelection) {
            (success: Bool) -> Void in
              controller.exportSelectionMode = false
          }
        }
    })
  }

  /**
  selectAllBarButtonItemForController:

  :param: controller BankController

  :returns: BlockBarButtonItem
  */
  class func selectAllBarButtonItemForController(controller: BankController) -> BlockBarButtonItem {
    return BlockBarButtonItem(title: "Select All", style: .Plain, action: {
      () -> Void in
        controller.selectAllExportableItems()
    })
  }

  class var dismissBarButtonItem: BlockBarButtonItem {
    return BlockBarButtonItem(barButtonSystemItem: .Done, action: {
      () -> Void in
      if let url = NSURL(string: "mainmenu") {
        UIApplication.sharedApplication().openURL(url)
      }
    })
  }

//  class var rootCategories: [BankRootCategory<ModelCategory,EditableModel>] {
//    return [ ComponentDevice.rootCategory,
//             IRCode.rootCategory,
//             Image.rootCategory,
//             Manufacturer.rootCategory,
//             NetworkDevice.rootCategory,
//             Preset.rootCategory ]
//  }
}
