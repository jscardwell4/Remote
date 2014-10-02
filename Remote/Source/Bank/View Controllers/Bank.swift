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

/** Base protocol for objects that can be displayed in Bank table or collection cells */
@objc(BankDisplayItem) protocol BankDisplayItem: class, NamedModel {

  optional class var label: String   { get }  // Text to use for root directory
  optional class var icon:  UIImage? { get }  // Image to use for root directory

  class var isThumbnailable: Bool { get }  // Whether items of the conforming type may have thumbnails
  class var isPreviewable:   Bool { get }  // Whether items of the conforming type may be previewed
  class var isDetailable:    Bool { get }  // Whether items of the conforming type may be opened in a detail controller
  class var isEditable:      Bool { get }  // Whether items of the conforming type may be edited in a detail controller

}

/** Protocol inheriting from `BankDisplayItem` for actual items of interest */
@objc(BankDisplayItemModel) protocol BankDisplayItemModel: BankDisplayItem {

  var detailController: BankDetailController { get }

//  typealias CategoryType: BankableModelCategory

//  optional var category: CategoryType { get }

  optional var preview: UIImage { get }

  optional var thumbnail: UIImage { get }

}

/** Protocol inheriting from `BankDisplayItem` for types that serve as a category for `BankDisplayItemModel` objects */
@objc(BankDisplayItemCategory) protocol BankDisplayItemCategory: BankDisplayItem {
//
//  typealias ItemType: BankDisplayItemModel
//
//  var items: [ItemType] { get }
//
  optional var subcategories:  [Self] { get }
//
//  optional var parentCategory: BankDisplayItemCategory?   { get }
//
}

/** Protocol for types that wish to display Bank item details */
@objc(BankDetailController) protocol BankDetailController: class {

  init(item: BankableModelObject, editing: Bool)

}

/** Protocol for types that want to display Bank toolbars, or other assets */
protocol BankController: class {

  func exportBankObjects()  // Called from export bar button action
  func importBankObjects()  // Called from import bar button action
  func searchBankObjects()  // Called from search bar button action

}

class Bank {

  /// A private structure to encapsulate the bank's constant properties
  ////////////////////////////////////////////////////////////////////////////////
  private struct BankProperties {

    // Fonts
    static let labelFont                  = UIFont(name: "Elysio-Medium", size: 15.0)
    static let boldLabelFont              = UIFont(name: "Elysio-Bold",   size: 17.0)
    static let infoFont                   = UIFont(name: "Elysio-Light",  size: 15.0)

    // Colors
    static let labelColor                 = UIColor(r: 59, g: 60, b: 64, a:255)
    static let infoColor                  = UIColor(r:159, g:160, b:164, a:255)

    // Images
    static let exportBarItemImage         = UIImage(named:"702-share")
    static let exportBarItemImageSelected = UIImage(named:"702-share-selected")
    static let importBarItemImage         = UIImage(named:"703-download")
    static let importBarItemImageSelected = UIImage(named:"703-download-selected")
    static let searchBarItemImage         = UIImage(named:"708-search")
    static let searchBarItemImageSelected = UIImage(named:"708-search-selected")

  }

  /// Font accessors
  ////////////////////////////////////////////////////////////////////////////////

	class var LabelFont                  : UIFont  { return BankProperties.labelFont     }
	class var BoldLabelFont              : UIFont  { return BankProperties.boldLabelFont }
	class var InfoFont                   : UIFont  { return BankProperties.infoFont      }

  /// Color accessors
  ////////////////////////////////////////////////////////////////////////////////

  class var LabelColor                 : UIColor { return BankProperties.labelColor    }
	class var InfoColor                  : UIColor { return BankProperties.infoColor     }

  /**
  toolbarItemsForController:

  :param: controller BankController

  :returns: [UIBarButtonItem]
  */
  class func toolbarItemsForController(controller: BankController) -> [UIBarButtonItem] {
    let exportBarItem = ToggleBarButtonItem(image: BankProperties.exportBarItemImage,
                                            toggledImage: BankProperties.exportBarItemImageSelected) {
                                              _ in controller.exportBankObjects()
                                            }
    let spacer = UIBarButtonItem.fixedSpace(20.0)
    let importBarItem = ToggleBarButtonItem(image: BankProperties.importBarItemImage,
                                            toggledImage: BankProperties.importBarItemImageSelected) {
                                              _ in controller.importBankObjects()
                                            }
    let flex = UIBarButtonItem.flexibleSpace()
    let searchBarItem = ToggleBarButtonItem(image: BankProperties.searchBarItemImage,
                                            toggledImage: BankProperties.searchBarItemImageSelected) {
                                              _ in controller.searchBankObjects()
                                            }
    return  [exportBarItem, spacer, importBarItem, flex, searchBarItem]
  }
}
