//
//  PresetDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 9/26/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

// TODO: Cancel needs to reset any changed color values

class PresetDetailController: BankItemDetailController {

  /** loadSections() */
  override func loadSections() {
    super.loadSections()

    precondition(model is Preset, "we should have been given a preset")

    let preset = model as Preset

    var detailsSection = DetailSection(section: 0, title: "Common Attributes")

    detailsSection.addRow { DetailLabelRow(pushableCategory: preset.presetCategory!, label: "Category") }

    let baseType = preset.baseType

    detailsSection.addRow { DetailLabelRow(label: "Base Type", value: baseType.JSONValue.titlecaseString) }

    var roles: [RemoteElement.Role]

    switch baseType {
      case .Button: roles = RemoteElement.Role.buttonRoles
      case .ButtonGroup: roles = RemoteElement.Role.buttonGroupRoles
      default: roles = [.Undefined]
    }

    detailsSection.addRow {
      var row = DetailButtonRow()
      row.name = "Role"
      row.info = preset.role.JSONValue.titlecaseString

      var pickerRow = DetailPickerRow()
      pickerRow.titleForInfo = {($0 as String).titlecaseString}
      pickerRow.data = roles.map{$0.JSONValue}
      pickerRow.info = preset.role.JSONValue
      pickerRow.didSelectItem = {
        if !self.didCancel {
          preset.role = RemoteElement.Role(JSONValue: $0 as String)
          self.cellDisplayingPicker?.info = ($0 as String).titlecaseString
          pickerRow.info = $0
        }
      }

      row.detailPickerRow = pickerRow

      return row
    }

    if [.ButtonGroup, .Button] ∋ baseType {

        detailsSection.addRow {
          var row = DetailButtonRow()
          row.name = "Shape"
          row.info = preset.shape.JSONValue.titlecaseString

          var pickerRow = DetailPickerRow()
          pickerRow.didSelectItem = {
            if !self.didCancel {
              preset.shape = RemoteElement.Shape(JSONValue: $0 as String)
              self.cellDisplayingPicker?.info = ($0 as String).titlecaseString
              pickerRow.info = $0
            }
          }
          pickerRow.titleForInfo = {($0 as String).titlecaseString}
          pickerRow.data = RemoteElement.Shape.allShapes.map{$0.JSONValue}
          pickerRow.info = preset.shape.JSONValue

          row.detailPickerRow = pickerRow

          return row
        }

        detailsSection.addRow {
          var row = DetailTextFieldRow()
          row.name = "Style"
          row.info = preset.style.JSONValue.capitalizedString
          row.placeholderText = "None"
          row.valueDidChange = { preset.style = RemoteElement.Style(JSONValue: ($0 as String).lowercaseString) }

          return row
        }
    }

    detailsSection.addRow {
      var row = DetailLabeledImageRow(label: "Background Image", previewableItem: preset.backgroundImage)
      row.placeholderImage = DrawingKit.imageOfNoImage(frame: CGRect(size: CGSize(square: 32.0)),
                                                           color: UIColor.lightGrayColor())
      return row
    }

    detailsSection.addRow {
      var row = DetailSliderRow()
      row.name = "Background Image Alpha"
      row.info = preset.backgroundImageAlpha
      row.sliderStyle = .Gradient(.Alpha)
      row.valueDidChange = { preset.backgroundImageAlpha = CGFloat(($0 as NSNumber).floatValue) }
      return row
    }

    detailsSection.addRow {
      var row = DetailColorRow()
      row.name = "Background Color"
      row.info = preset.backgroundColor
      row.valueDidChange = { preset.backgroundColor = $0 as? UIColor }
      return row
    }

    // TODO: subelements
    // TODO: constraints


    var previewSection = DetailSection(section: 1)
    previewSection.addRow { DetailImageRow(previewableItem: preset) }

    sections = ["Detail": detailsSection]

  }

}
