//
//  ButtonGroupPresetDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 11/27/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class ButtonGroupPresetDetailController: PresetDetailController {

  /** loadSections() */
  override func loadSections() {
    super.loadSections()

    precondition(model is Preset, "we should have been given a preset")

    let preset = model as Preset


    let buttonGroupAttributesSection = DetailSection(section: 1, title: "Button Group Attributes")

    buttonGroupAttributesSection.addRow {
      var row = DetailSwitchRow()
      row.name = "Autohide"
      row.info = NSNumber(bool: preset.attributes.autohide ?? false)
      row.valueDidChange = { preset.attributes.autohide = ($0 as? NSNumber)?.boolValue }

      return row
    }

    // buttonGroupAttributesSection.addRow {
    //   let row = DetailTextFieldRow()
    //   row.name = "Label"
    //   row.info =  self.preset.attributes.label?.string
    //   row.valueDidChange = { if let s = $0 as? String { self.preset.attributes.label = NSAttributedString(string: s) } }

    //   return row
    // }

    // TODO: labelAttributes
    // TODO: labelConstraints
    // TODO: panelAssignment

    sections.append(buttonGroupAttributesSection)
  }

}
