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

/** Protocol inheriting from `BankDisplayItem` for actual items of interest */
@objc protocol BankDisplayItemModel: RenameableModel {

  class func isPreviewable()   -> Bool  // Whether items of the conforming type may be previewed
  class func isEditable()      -> Bool  // Whether items of the conforming type may be edited in a detail controller

  var previewable:   Bool { get }
  var editable:      Bool { get }

  var preview: UIImage? { get }
  var thumbnail: UIImage? { get }
  func save()
  func delete()
  func rollback()

  func detailController() -> UIViewController

}

func sortedByName<T: NamedModel>(array: [T]) -> [T] { return array.sorted{$0.0.name < $0.1.name} }
func sortedByName<T: NamedModel>(array: [T]?) -> [T]? { return array?.sorted{$0.0.name < $0.1.name} }
func sortByName<T: NamedModel>(inout array: [T]) { array.sort{$0.0.name < $0.1.name} }
func sortByName<T: NamedModel>(inout array: [T]?) { array?.sort{$0.0.name < $0.1.name} }

/** Protocol inheriting from `BankDisplayItem` for types that serve as a category for `BankDisplayItemModel` objects */
@objc protocol BankDisplayItemCategory: class, NSObjectProtocol {

  var title: String { get }

  var items: [BankDisplayItemModel] { get }

  var previewableItems:   Bool { get }
  var editableItems:      Bool { get }

  func save()
  func delete()
  func rollback()

  var subcategories:  [BankDisplayItemCategory] { get }
  var parentCategory: BankDisplayItemCategory?   { get }
}

func categoryPath(category: BankDisplayItemCategory?) -> String? {
  if category == nil { return nil }
  var path: [String] = [category!.title]
  var tempCategory = category!.parentCategory
  while tempCategory != nil {
    path.append(tempCategory!.title)
    tempCategory = tempCategory!.parentCategory
  }
  return "/".join(path.reverse())
}

/** Protocol for types that wish to display Bank item details */
@objc protocol BankDetailController: class, NSObjectProtocol {

  init?(item: BankDisplayItemModel)

}

/** Protocol for types that want to display Bank toolbars, or other assets */
protocol BankController: class {

  func exportBankObjects()  // Called from export bar button action
  func importBankObjects()  // Called from import bar button action
  func searchBankObjects()  // Called from search bar button action

}

class Bank {

  struct RootCategory {
    let label: String
    let icon: UIImage
    let subcategories: [BankDisplayItemCategory]
    let items: [BankDisplayItemModel]
    let previewableItems:   Bool
    let editableItems:      Bool

    init(label: String,
         icon: UIImage,
         subcategories: [BankDisplayItemCategory] = [],
         items: [BankDisplayItemModel] = [],
         previewableItems: Bool = false,
         editableItems: Bool = false)
    {
      self.label = label
      self.icon = icon
      self.subcategories = subcategories
      self.items = items
      self.previewableItems = previewableItems
      self.editableItems = editableItems
    }
  }

  /// A private structure to encapsulate the bank's constant properties
  ////////////////////////////////////////////////////////////////////////////////
  private struct BankProperties {

    // Fonts
    static let labelFont                  = UIFont(name: "Elysio-Medium", size: 15.0)!
    static let boldLabelFont              = UIFont(name: "Elysio-Bold",   size: 17.0)!
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

    static let titleTextAttributes = [ NSFontAttributeName:            BankProperties.boldLabelFont,
                                       NSForegroundColorAttributeName: BankProperties.labelColor ]
  }
  /// Font accessors
  ////////////////////////////////////////////////////////////////////////////////

	class var labelFont                  : UIFont  { return BankProperties.labelFont     }
	class var boldLabelFont              : UIFont  { return BankProperties.boldLabelFont }
	class var infoFont                   : UIFont  { return BankProperties.infoFont      }

  /// Color accessors
  ////////////////////////////////////////////////////////////////////////////////

  class var labelColor                 : UIColor { return BankProperties.labelColor      }
	class var infoColor                  : UIColor { return BankProperties.infoColor       }
  class var backgroundColor            : UIColor { return BankProperties.backgroundColor }

  /// Keyboard
  ////////////////////////////////////////////////////////////////////////////////

  class var keyboardAppearance: UIKeyboardAppearance { return BankProperties.keyboardAppearance }

  /// Metrics
  ////////////////////////////////////////////////////////////////////////////////

  class var defaultRowHeight: CGFloat { return BankProperties.defaultRowHeight }

  /// Styles
  ////////////////////////////////////////////////////////////////////////////////

  class var separatorStyle: UITableViewCellSeparatorStyle { return BankProperties.separatorStyle }

  class var titleTextAttributes: [NSString : NSObject] { return BankProperties.titleTextAttributes }


  /**
  toolbarItemsForController:

  :param: controller BankController

  :returns: [UIBarButtonItem]
  */
  class func toolbarItemsForController(controller: BankController, addingItems items: [UIBarItem]? = nil) -> [UIBarItem] {
    let exportBarItem = ToggleImageBarButtonItem(image: BankProperties.exportBarItemImage,
                                                 toggledImage: BankProperties.exportBarItemImageSelected) {
                                                   _ in controller.exportBankObjects()
                                                 }
    let spacer = UIBarButtonItem.fixedSpace(-10.0)
    let importBarItem = ToggleImageBarButtonItem(image: BankProperties.importBarItemImage,
                                                 toggledImage: BankProperties.importBarItemImageSelected) {
                                                   _ in controller.importBankObjects()
                                                 }
    let flex = UIBarButtonItem.flexibleSpace()
    let searchBarItem = ToggleImageBarButtonItem(image: BankProperties.searchBarItemImage,
                                                 toggledImage: BankProperties.searchBarItemImageSelected) {
                                                   _ in controller.searchBankObjects()
                                                 }
    var toolbarItems: [UIBarItem] = [spacer, exportBarItem, spacer, importBarItem, spacer, flex]
    if let middleItems = items { toolbarItems += middleItems }
    toolbarItems += [flex, spacer, searchBarItem, spacer]
    return  toolbarItems
  }

  class var dismissBarButtonItem: BarButtonItem {
    return BarButtonItem(barButtonSystemItem: .Done, action: { (Void) -> Void in
      MSRemoteAppController.sharedAppController().showMainMenu()
    })
  }

  class var rootCategories: [RootCategory] {
    return [ ComponentDevice.rootCategory,
             IRCode.rootCategory,
             Image.rootCategory,
             Manufacturer.rootCategory,
             NetworkDevice.rootCategory,
             Preset.rootCategory ]
  }
}
