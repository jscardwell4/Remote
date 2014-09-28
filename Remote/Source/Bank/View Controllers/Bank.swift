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

private let BankLabelFont     = UIFont(name: "Elysio-Medium", size: 15.0)
private let BankBoldLabelFont = UIFont(name: "Elysio-Bold",   size: 17.0)
private let BankInfoFont      = UIFont(name: "Elysio-Light",  size: 15.0)
private let BankLabelColor    = UIColor(r: 59, g: 60, b: 64, a:255)
private let BankInfoColor     = UIColor(r:159, g:160, b:164, a:255)
private let BankExportBarItemImage         = UIImage(named:"702-gray-share")
private let BankExportBarItemImageSelected = UIImage(named:"702-gray-share-selected")
private let BankImportBarItemImage         = UIImage(named:"703-gray-download")
private let BankImportBarItemImageSelected = UIImage(named:"703-gray-download-selected")
private let BankSearchBarItemImage         = UIImage(named:"708-gray-search")
private let BankSearchBarItemImageSelected = UIImage(named:"708-gray-search-selected")


protocol BankController: class {

  func exportBankObjects()
  func importBankObjects()
  func searchBankObjects()

}

class Bank {
	class var LabelFont                  : UIFont  { return BankLabelFont                  }
	class var BoldLabelFont              : UIFont  { return BankBoldLabelFont              }
	class var InfoFont                   : UIFont  { return BankInfoFont                   }
	class var LabelColor                 : UIColor { return BankLabelColor                 }
	class var InfoColor                  : UIColor { return BankInfoColor                  }
  class var ExportBarItemImage         : UIImage { return BankExportBarItemImage         }
  class var ExportBarItemImageSelected : UIImage { return BankExportBarItemImageSelected }
  class var ImportBarItemImage         : UIImage { return BankImportBarItemImage         }
  class var ImportBarItemImageSelected : UIImage { return BankImportBarItemImageSelected }
  class var SearchBarItemImage         : UIImage { return BankSearchBarItemImage         }
  class var SearchBarItemImageSelected : UIImage { return BankSearchBarItemImageSelected }

  /**
  toolbarItemsForController:

  :param: controller BankController

  :returns: [UIBarButtonItem]
  */
  class func toolbarItemsForController(controller: BankController) -> [UIBarButtonItem] {
    let exportBarItem = ToggleBarButtonItem(image: BankExportBarItemImage, toggledImage: BankExportBarItemImageSelected) {
      (toggle:ToggleBarButtonItem) in controller.exportBankObjects()
    }
    let spacer = UIBarButtonItem.fixedSpace(20.0)
    let importBarItem = ToggleBarButtonItem(image: BankImportBarItemImage, toggledImage: BankImportBarItemImageSelected) {
      (toggle:ToggleBarButtonItem) in controller.importBankObjects()
    }
    let flex = UIBarButtonItem.flexibleSpace()
    let searchBarItem = ToggleBarButtonItem(image: BankSearchBarItemImage, toggledImage: BankSearchBarItemImageSelected) {
      (toggle:ToggleBarButtonItem) in controller.searchBankObjects()
    }
    return  [exportBarItem, spacer, importBarItem, flex, searchBarItem]
  }
}
