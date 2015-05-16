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
import Elysio
import Glyphish

@objc final public class Bank {

  // MARK: - ViewingMode type

  enum ViewingMode: Int {
    case List, Thumbnail
    init(rawValue: Int) { self = rawValue == 1 ? .Thumbnail : .List }
  }

  static func initialize() {
    SettingsManager.registerSettingWithKey(Bank.ViewingModeKey,
                          withDefaultValue: .List,
                              fromDefaults: {ViewingMode(rawValue: ($0 as? NSNumber)?.integerValue ?? 0)},
                                toDefaults: {$0.rawValue})
    Image.registerBundle(Bank.bundle, forLocationValue: "$bank")
    Image.registerBundle(Glyphish.bundle, forLocationValue: "$glyphish")
  }

  public static let ViewingModeKey = "BankViewingModeKey"
  public static let bundle = NSBundle(forClass: Bank.self)

  /**
  bankImageNamed:

  :param: named String

  :returns: UIImage?
  */
  public static func bankImageNamed(named: String) -> UIImage? {
    return UIImage(named: named, inBundle: bundle, compatibleWithTraitCollection: nil)
  }

  /// The bank's constant class properties
  ////////////////////////////////////////////////////////////////////////////////

  // Fonts
  public static let labelFont               = Elysio.mediumFontWithSize(15)
  public static let boldLabelFont           = Elysio.boldFontWithSize(17)
  public static let largeBoldLabelFont      = Elysio.boldFontWithSize(18)
  public static let infoFont                = Elysio.lightFontWithSize(15)
  public static let actionFont              = Elysio.regularItalicFontWithSize(15)
  public static let formLabelFont           = Elysio.regularFontWithSize(16)
  public static let formControlFont         = Elysio.regularItalicFontWithSize(16)
  public static let formControlSelectedFont = Elysio.boldItalicFontWithSize(16)

  // Colors
  public static let labelColor           = UIColor(r: 59, g: 60, b: 64, a:255)!
  public static let infoColor            = UIColor(r:159, g:160, b:164, a:255)!
  public static let backgroundColor      = UIColor.whiteColor()
  public static let actionColor          = UIColor(r: 0,   g: 175, b: 255, a: 255)!
  public static let formLabelTextColor   = UIColor(white: 0.2, alpha: 1.0)
  public static let formControlTextColor = UIColor(white: 0.49019608, alpha: 1.0)

  // Images
  static let exportBarItemImage            = Glyphish.imageNamed("702-share")!
  static let exportBarItemImageSelected    = Glyphish.imageNamed("702-share-selected")!
  static let importBarItemImage            = Glyphish.imageNamed("703-download")!
  static let importBarItemImageSelected    = Glyphish.imageNamed("703-download-selected")!
  static let searchBarItemImage            = Glyphish.imageNamed("708-search")!
  static let searchBarItemImageSelected    = Glyphish.imageNamed("708-search-selected")!
  static let createBarItemImage            = Glyphish.imageNamed("907-plus-rounded-square")!
  static let createBarItemImageSelected    = Glyphish.imageNamed("907-plus-rounded-square-selected")!
  static let listBarItemImage              = Glyphish.imageNamed("1073-grid-1-toolbar")!
  static let listBarItemImageSelected      = Glyphish.imageNamed("1073-grid-1-toolbar-selected")!
  static let thumbnailBarItemImage         = Glyphish.imageNamed("1076-grid-4-toolbar")!
  static let thumbnailBarItemImageSelected = Glyphish.imageNamed("1076-grid-4-toolbar-selected")!
  static let indicatorImage                = Glyphish.imageNamed("1040-checkmark")!
  static let indicatorImageSelected        = Glyphish.imageNamed("1040-checkmark-selected")!
  static let componentDevicesImage         = Glyphish.imageNamed("969-television")!
  static let irCodesImage                  = Bank.bankImageNamed("tv-remote")!
  static let imagesImage                   = Glyphish.imageNamed("926-photos")!
  static let manufacturersImage            = Glyphish.imageNamed("1022-factory")!
  static let networkDevicesImage           = Glyphish.imageNamed("937-wifi-signal")!
  static let presetsImage                  = Glyphish.imageNamed("1059-sliders")!

  static let defaultRowHeight: CGFloat = 38.0
  static let separatorStyle: UITableViewCellSeparatorStyle = .None
  static let keyboardAppearance: UIKeyboardAppearance = .Dark

  static let titleTextAttributes = [ NSFontAttributeName:            Bank.boldLabelFont,
                                     NSForegroundColorAttributeName: Bank.labelColor ]

  /**
  Generates items for a view controller's bottom toolbar tailored to the protocols supported by the controller.

      ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
      ┃ export  import          viewing mode          search  create ┃
      ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  :param: controller UIViewController

  :returns: [UIBarButtonItem]
  */
  static func toolbarItemsForController(controller: UIViewController) -> [UIBarItem] {

    let totalWidth = UIScreen.mainScreen().bounds.width
    let outterWidth = floor(totalWidth / 3)
    let innerWidth = totalWidth - outterWidth * 2
    let outterItemWidth = outterWidth / 2
    let negativeSpacer = UIBarButtonItem.fixedSpace(-16)

    var toolbarItems: [UIBarItem] = []

    if let importExportController = controller as? BankItemImportExportController {

      let exportBarItem =
        ToggleImageBarButtonItem(image: Bank.exportBarItemImage, toggledImage: Bank.exportBarItemImageSelected) {
          importExportController.exportSelectionMode = $0.isToggled
        }
      exportBarItem.width = outterItemWidth

      let importBarItem =
        ToggleImageBarButtonItem(image: Bank.importBarItemImage, toggledImage: Bank.importBarItemImageSelected) {
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
                importExportController.importFromFile(selectedFile)
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
      importBarItem.width = outterItemWidth

      toolbarItems += [negativeSpacer, exportBarItem, negativeSpacer, importBarItem]
    } else {
      toolbarItems.append(UIBarButtonItem.fixedSpace(outterWidth))
    }

    if let selectiveViewController = controller as? BankItemSelectiveViewingModeController
      where selectiveViewController.selectiveViewingEnabled
    {

      // Create the segmented control
      let displayOptionsControl = ToggleImageSegmentedControl(items: [listBarItemImage,
                                                                      listBarItemImageSelected,
                                                                      thumbnailBarItemImage,
                                                                      thumbnailBarItemImageSelected])
      displayOptionsControl.selectedSegmentIndex = selectiveViewController.viewingMode.rawValue
      displayOptionsControl.toggleAction = { control in
        let viewingMode = ViewingMode(rawValue: control.selectedSegmentIndex)
        selectiveViewController.viewingMode = viewingMode
        SettingsManager.setValue(viewingMode, forSetting: Bank.ViewingModeKey)
      }
      let displayOptionsControlItem = UIBarButtonItem(customView: displayOptionsControl)
      displayOptionsControlItem.width = innerWidth
      selectiveViewController.displayOptionsControl = displayOptionsControl
      toolbarItems += [displayOptionsControlItem]
    } else {
      toolbarItems.append(UIBarButtonItem.fixedSpace(innerWidth))
    }

    if let searchableController = controller as? BankItemSearchableController {
      let searchBarItem =
        ToggleImageBarButtonItem(image: searchBarItemImage, toggledImage: searchBarItemImageSelected) {
          _ in searchableController.searchBankObjects()
        }
      searchBarItem.width = outterItemWidth
      toolbarItems += [negativeSpacer, searchBarItem]
    } else {
      toolbarItems.append(UIBarButtonItem.fixedSpace(floor(outterWidth/2)))
    }

    if let creationController = controller as? BankItemCreationController {
      let createBarItem =
        ToggleImageBarButtonItem(image: createBarItemImage, toggledImage: createBarItemImageSelected) {
          _ in creationController.createBankItem()
        }
      createBarItem.width = outterItemWidth
      toolbarItems += [negativeSpacer, createBarItem]
    } else {
      toolbarItems.append(UIBarButtonItem.fixedSpace(floor(outterWidth/2)))
    }

    return  toolbarItems
  }


  /**
  Bar button item for the right side of the navigation bar

  :param: controller BankItemImportExportController

  :returns: BlockBarButtonItem
  */
  static func exportBarButtonItemForController(controller: BankItemImportExportController) -> BlockBarButtonItem {
    return BlockBarButtonItem(title: "Export", style: .Done, action: {
        let sel = controller.exportSelection
        if sel.count != 0 {
          ImportExportFileManager.confirmExportOfItems(sel) { _ in controller.exportSelectionMode = false }
        }
    })
  }

  /**
  selectAllButtonForController:

  :param: controller BankItemImportExportController

  :returns: BlockBarButtonItem
  */
  static func selectAllButtonForController(controller: BankItemImportExportController) -> BlockBarButtonItem {
    return BlockBarButtonItem(title: "Select All", style: .Plain) { controller.selectAllExportableItems() }
  }

  /** A bar button item that asks the application to return to the main menu */
  static let dismissButton: UIBarButtonItem? = {
    var dismissButton: UIBarButtonItem? = nil
    let isBankTest = Bool(string: NSProcessInfo.processInfo().environment["BANK_TEST"] as? String)
    if !Bool(string: NSProcessInfo.processInfo().environment["BANK_TEST"] as? String) {
      dismissButton = BlockBarButtonItem(barButtonSystemItem: .Done) {
        if let url = NSURL(string: "mainmenu") { UIApplication.sharedApplication().openURL(url) }
      }
    }
    return dismissButton
    }()

  /**
  Applies font and text color to the provided form

  :param: form FormViewController
  */
  static func decorateForm(form: FormViewController) {
    form.labelFont           = formLabelFont
    form.labelTextColor      = formLabelTextColor
    form.controlFont         = formControlFont
    form.controlTextColor    = formControlTextColor
    form.controlSelectedFont = formControlSelectedFont

  }
}
