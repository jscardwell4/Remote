//
//  BankProtocols.swift
//  Remote
//
//  Created by Jason Cardwell on 3/27/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit
import DataModel

// MARK: - Detailable protocol and extensions
@objc protocol Detailable { func detailController() -> UIViewController }

extension ComponentDevice: Detailable {
  func detailController() -> UIViewController { return ComponentDeviceDetailController(model: self) }
}

extension Manufacturer: Detailable {
  func detailController() -> UIViewController { return ManufacturerDetailController(model: self) }
}

extension IRCode: Detailable {
  func detailController() -> UIViewController { return IRCodeDetailController(model: self) }
}

extension Image: Detailable {
  func detailController() -> UIViewController { return ImageDetailController(model: self) }
}

extension ISYDevice: Detailable {
  func detailController() -> UIViewController { return ISYDeviceDetailController(model: self) }
}

extension ITachDevice: Detailable {
  func detailController() -> UIViewController { return ITachDeviceDetailController(model: self) }
}

extension Preset: Detailable {
  func detailController() -> UIViewController {
    switch baseType {
      case .Remote: return RemotePresetDetailController(model: self)
      case .ButtonGroup: return ButtonGroupPresetDetailController(model: self)
      case .Button: return ButtonPresetDetailController(model: self)
      default: return PresetDetailController(model: self)
    }
  }
}

// MARK: - Previewable protocol and extensions
@objc protocol Previewable { var preview: UIImage { get }; var thumbnail: UIImage { get } }

extension Image: Previewable {}
extension Preset: Previewable {}

// MARK: - BankModelCollection protocol and extensions

@objc protocol BankModelCollection: Named {
  optional var items: [NamedModel] { get }
  optional var collections: [ModelCollection] { get }
}

extension Manufacturer: BankModelCollection {}
extension IRCodeSet: BankModelCollection {}
extension ImageCategory: BankModelCollection {}
extension PresetCategory: BankModelCollection {}

// MARK: - View controller related protocols

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

