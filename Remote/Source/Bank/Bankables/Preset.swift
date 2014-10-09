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
//    @NSManaged var presetPreview: BankObjectPreview
  override class func isThumbnailable() -> Bool { return true }
  override class func isDetailable()    -> Bool { return true }
  override class func isEditable()      -> Bool { return true }
  override class func isPreviewable()   -> Bool { return true }

//  override class func categoryType() -> BankDisplayItemCategory.Protocol { return PresetCategory.self }
  override func detailController() -> UIViewController { return PresetDetailController(item: self, editing: false)! }
  class var rootCategory: Bank.RootCategory {
    return Bank.RootCategory(label: "Presets",
                             icon: UIImage(named: "1059-sliders")!,
                             detailableItems: true,
                             editableItems: true,
                             previewableItems: true,
                             thumbnailableItems: true)
  }

}
