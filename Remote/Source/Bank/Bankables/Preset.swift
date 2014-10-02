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

}

extension Preset: BankDisplayItem {

  class var label: String   { return "Presets"                      }
  class var icon:  UIImage? { return UIImage(named: "1059-sliders") }

  class var isThumbnailable: Bool { return true }
  class var isDetailable:    Bool { return true }
  class var isEditable:      Bool { return true }
  class var isPreviewable:   Bool { return true }

}

extension Preset: BankDisplayItemModel {

  var detailController: BankDetailController { return PresetDetailController(item: self, editing: false) }

}
