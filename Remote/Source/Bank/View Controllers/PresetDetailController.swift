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

  private struct SectionKey {
    static let Preview          = "Preview"
    static let CommonAttributes = "Common Attributes"
  }

  private struct RowKey {
    static let Preview              = "Preview"
    static let Category             = "Category"
    static let BaseType             = "Base Type"
    static let Role                 = "Role"
    static let Shape                = "Shape"
    static let Style                = "Style"
    static let BackgroundImage      = "Background Image"
    static let BackgroundImageAlpha = "Background Image Alpha"
    static let BackgroundColor      = "Background Color"
  }

  /** loadSections() */
  override func loadSections() {
    super.loadSections()

    precondition(model is Preset, "we should have been given a preset")

    loadPreviewSection()
    loadCommonAttributesSection()
    // TODO: subelements
    // TODO: constraints

  }


 /** loadPreviewSection */
 private func loadPreviewSection() {

   let previewSection = DetailSection(section: 0)

   previewSection.addRow({
     let row = DetailCustomRow()
     row.generateCustomView = { RemoteElementView.viewWithPreset(self.model as! Preset) ?? UIView() }
     return row
   }, forKey: RowKey.Preview)

   sections[SectionKey.Preview] = previewSection
 }

 /** loadCommonAttributesSection */
 private func loadCommonAttributesSection() {

    let preset = model as! Preset

    let commonAttributesSection = DetailSection(section: 1, title: "Common Attributes")

    commonAttributesSection.addRow({ DetailLabelRow(pushableCategory: preset.presetCategory!, label: "Category") },
                            forKey: RowKey.Category)

    let baseType = preset.baseType

    commonAttributesSection.addRow({ DetailLabelRow(label: "Base Type", value: baseType.JSONValue.titlecaseString) },
                            forKey: RowKey.BaseType)

    var roles: [RemoteElement.Role]

    switch baseType {
      case .Button: roles = RemoteElement.Role.buttonRoles
      case .ButtonGroup: roles = RemoteElement.Role.buttonGroupRoles
      default: roles = [.Undefined]
    }

    commonAttributesSection.addRow({
      let row = DetailButtonRow()
      row.name = "Role"
      row.info = preset.role.JSONValue.titlecaseString

      var pickerRow = DetailPickerRow()
      pickerRow.titleForInfo = {($0 as! String).titlecaseString}
      pickerRow.data = roles.map{$0.JSONValue}
      pickerRow.info = preset.role.JSONValue
      pickerRow.didSelectItem = {
        if !self.didCancel {
          preset.role = RemoteElement.Role(JSONValue: $0 as! String)
          self.cellDisplayingPicker?.info = ($0 as! String).titlecaseString
          pickerRow.info = $0
        }
      }

      row.detailPickerRow = pickerRow

      return row
    }, forKey: RowKey.Role)

    if [.ButtonGroup, .Button] ∋ baseType {

        commonAttributesSection.addRow({
          let row = DetailButtonRow()
          row.name = "Shape"
          row.info = preset.shape.JSONValue.titlecaseString

          var pickerRow = DetailPickerRow()
          pickerRow.didSelectItem = {
            if !self.didCancel {
              preset.shape = RemoteElement.Shape(JSONValue: $0 as! String)
              self.cellDisplayingPicker?.info = ($0 as! String).titlecaseString
              pickerRow.info = $0
            }
          }
          pickerRow.titleForInfo = {($0 as! String).titlecaseString}
          pickerRow.data = RemoteElement.Shape.allShapes.map{$0.JSONValue}
          pickerRow.info = preset.shape.JSONValue

          row.detailPickerRow = pickerRow

          return row
        }, forKey: RowKey.Shape)

        commonAttributesSection.addRow({
          let row = DetailTextFieldRow()
          row.name = "Style"
          row.info = preset.style.JSONValue.capitalizedString
          row.placeholderText = "None"
          row.valueDidChange = { preset.style = RemoteElement.Style(JSONValue: ($0 as! String).lowercaseString) }

          return row
        }, forKey: RowKey.Style)
    }

    commonAttributesSection.addRow({
      let row = DetailLabeledImageRow(label: "Background Image", previewableItem: preset.backgroundImage)
      row.placeholderImage = DrawingKit.imageOfNoImage(frame: CGRect(size: CGSize(square: 32.0)))
      return row
    }, forKey: RowKey.BackgroundImage)

    commonAttributesSection.addRow({
      let row = DetailSliderRow()
      row.name = "Background Image Alpha"
      row.info = preset.backgroundImageAlpha
      row.sliderStyle = .Gradient(.Alpha)
      row.valueDidChange = { preset.backgroundImageAlpha = CGFloat(($0 as! NSNumber).floatValue) }
      return row
    }, forKey: RowKey.BackgroundImageAlpha)

    commonAttributesSection.addRow({
      let row = DetailColorRow()
      row.name = "Background Color"
      row.info = preset.backgroundColor
      row.valueDidChange = { preset.backgroundColor = $0 as? UIColor }
      return row
    }, forKey: RowKey.BackgroundColor)

    sections[SectionKey.CommonAttributes] = commonAttributesSection

  }

}
