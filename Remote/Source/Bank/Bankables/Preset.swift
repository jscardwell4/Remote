//
//  Preset.swift
//  Remote
//
//  Created by Jason Cardwell on 9/30/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(Preset)
class Preset: BankableModelObject {

    @NSManaged var presetCategory: PresetCategory
    @NSManaged var element: RemoteElement
    @NSManaged var presetPreview: BankObjectPreview

  override class func categoryType() -> BankDisplayItemCategory.Protocol { return PresetCategory.self }
}

extension Preset: BankDisplayItem {

  override class func label() -> String   { return "Presets"                      }
  override class func icon()  -> UIImage? { return UIImage(named: "1059-sliders") }

  override class func isThumbnailable() -> Bool { return true }
  override class func isDetailable()    -> Bool { return true }
  override class func isEditable()      -> Bool { return true }
  override class func isPreviewable()   -> Bool { return true }

}

extension Preset: BankDisplayItemModel {

//  override class func categoryType() -> BankDisplayItemCategory.Protocol { return PresetCategory.self }

  override var detailController: DetailControllerType? { return PresetDetailController(item: self, editing: false) }
  override var editingController: DetailControllerType? { return PresetDetailController(item: self, editing: true) }

}
