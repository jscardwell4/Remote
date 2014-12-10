//
//  RemotePresetDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 11/27/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class RemotePresetDetailController: PresetDetailController {

  /** loadSections() */
  override func loadSections() {
    super.loadSections()

    precondition(model is Preset, "we should have been given a preset")

    let preset = model as Preset


    if let detailsSection = sections.first {

      detailsSection.addRow {
        var row = DetailSwitchRow()
        row.name = "Top Bar Hidden"
        row.info = NSNumber(bool: preset.topBarHidden ?? false)
        row.valueDidChange = { preset.topBarHidden = ($0 as? NSNumber)?.boolValue }

        return row
      }

    }
  }

}
