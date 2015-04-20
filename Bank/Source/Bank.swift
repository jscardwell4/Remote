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
import Settings

@objc final public class Bank {

  enum ViewingMode: Int {
    case List, Thumbnail
    init(rawValue: Int) { self = rawValue == 1 ? .Thumbnail : .List }
  }

  class func initialize() {
    SettingsManager.registerSettingWithKey(Bank.viewingModeKey,
                          withDefaultValue: .List,
                              fromDefaults: {ViewingMode(rawValue: ($0 as? NSNumber)?.integerValue ?? 0)},
                                toDefaults: {$0.rawValue})
    Image.registerBundle(Bank.bankBundle, forLocationValue: Bank.imageLocation)

  }

  public static let viewingModeKey = "BankViewingModeKey"
  private static let imageLocation = "$bank"
  private static let bankBundle = NSBundle(forClass: Bank.self)

  /**
  bankImageNamed:

  :param: named String

  :returns: UIImage?
  */
  public static func bankImageNamed(named: String) -> UIImage? {
    return UIImage(named: named, inBundle: bankBundle, compatibleWithTraitCollection: nil)
  }

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
  static let exportBarItemImage            = Bank.bankImageNamed("702-share-toolbar")!
  static let exportBarItemImageSelected    = Bank.bankImageNamed("702-share-toolbar-selected")!
  static let importBarItemImage            = Bank.bankImageNamed("703-download-toolbar")!
  static let importBarItemImageSelected    = Bank.bankImageNamed("703-download-toolbar-selected")!
  static let searchBarItemImage            = Bank.bankImageNamed("708-search-toolbar")!
  static let searchBarItemImageSelected    = Bank.bankImageNamed("708-search-toolbar-selected")!
  static let listBarItemImage              = Bank.bankImageNamed("1073-grid-1-toolbar")!
  static let listBarItemImageSelected      = Bank.bankImageNamed("1073-grid-1-toolbar-selected")!
  static let thumbnailBarItemImage         = Bank.bankImageNamed("1076-grid-4-toolbar")!
  static let thumbnailBarItemImageSelected = Bank.bankImageNamed("1076-grid-4-toolbar-selected")!
  static let indicatorImage                = Bank.bankImageNamed("1040-checkmark-toolbar")!
  static let indicatorImageSelected        = Bank.bankImageNamed("1040-checkmark-toolbar-selected")!
  static let componentDevicesImage         = Bank.bankImageNamed("969-television")!
  static let irCodesImage                  = Bank.bankImageNamed("tv-remote")!
  static let imagesImage                   = Bank.bankImageNamed("926-photos")!
  static let manufacturersImage            = Bank.bankImageNamed("1022-factory")!
  static let networkDevicesImage           = Bank.bankImageNamed("937-wifi-signal")!
  static let presetsImage                  = Bank.bankImageNamed("1059-sliders")!

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
    return BlockBarButtonItem(title: "Select All", style: .Plain, action: { controller.selectAllExportableItems() })
  }

  /** A bar button item that asks the application to return to the main menu */
  static let dismissButton: UIBarButtonItem? = {
    var dismissButton: UIBarButtonItem? = nil
      let isBankTest = Bool(string: NSProcessInfo.processInfo().environment["BANK_TEST"] as? String)
      if !isBankTest {
        dismissButton = BlockBarButtonItem(barButtonSystemItem: .Done, action: {
          if let url = NSURL(string: "mainmenu") { UIApplication.sharedApplication().openURL(url) }
        })
      }
      return dismissButton
    }()

  /** A simple structure for packaging top level bank category data for consumption by `BankRootController` */
  struct RootCategory: Printable {
    let label: String
    let icon: UIImage
    let collections: [ModelCollection]
    let items: [NamedModel]

    init(label: String,
      icon: UIImage,
      collections: [ModelCollection] = [],
      items: [NamedModel] = [])
    {
      self.label = label
      self.icon = icon
      self.collections = collections
      self.items = items
    }

    var description: String {
      var result = "RootCategory:\n"
      result += "\tlabel = \(label)\n"
      result += "\ticon = \(icon)\n"
      result += "\tcollections = "
      if collections.count == 0 { result += "[]\n" }
      else { result += "{\n" + "\n\n".join(collections.map({toString($0)})).indentedBy(8) + "\n\t}\n" }
      result += "items = "
      if items.count == 0 { result += "[]\n" }
      else { result += "{\n" + "\n\n".join(items.map({toString($0)})).indentedBy(8) + "\n\t}\n" }
      return result
    }
  }

  class var rootCategories: [RootCategory] {
    let context = DataManager.rootContext
    let componentDeviceRoot = RootCategory(
      label: "Component Devices",
      icon: componentDevicesImage,
      items: ComponentDevice.objectsInContext(context, sortBy: "name") as? [ComponentDevice] ?? []
    )
    let irCodeRoot = RootCategory(
      label: "IR Codes",
      icon: irCodesImage,
      collections: IRCodeSet.objectsInContext(context, sortBy: "name") as? [IRCodeSet] ?? []
    )
    let imageRoot = RootCategory(
      label: "Images",
      icon: imagesImage,
      collections: ImageCategory.objectsMatchingPredicate(∀"parentCategory == NULL",
                                                    sortBy: "name",
                                                   context: context) as? [ImageCategory] ?? []
    )
    let manufacturerRoot = RootCategory(
      label: "Manufacturers",
      icon: manufacturersImage,
      items: Manufacturer.objectsInContext(context, sortBy: "name") as? [Manufacturer] ?? []
    )
    let networkDeviceRoot = RootCategory(
      label: "Network Devices",
      icon: networkDevicesImage,
      items: NetworkDevice.objectsInContext(context, sortBy: "name") as? [NetworkDevice] ?? []
    )
    let presetRoot = RootCategory(
      label: "Presets",
      icon: presetsImage,
      collections: PresetCategory.objectsMatchingPredicate(∀"parentCategory == NULL",
                                                    sortBy: "name",
                                                   context: context) as? [PresetCategory] ?? []
    )
    return [componentDeviceRoot, irCodeRoot, imageRoot, manufacturerRoot, networkDeviceRoot, presetRoot]
  }
}
