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

@objc(PresetDetailController)
class PresetDetailController: BankItemDetailController {

  var preset: Preset { return model as Preset }
  let element: RemoteElement!

  /**
  initWithItem:editing:

  :param: model BankableModelObject
  :param: editing Bool
  */
  override init(model: BankableModelObject) {
    super.init(model: model)

    assert(model is Preset)
    let preset = self.preset

    if let element = preset.generateElement() {
      self.element = element
      var detailsSection = DetailSection(section: 0, title: "Common Attributes")

      detailsSection.addRow { DetailLabelRow(pushableCategory: preset.presetCategory!, label: "Category") }

      detailsSection.addRow {
        var row = DetailLabelRow()
        row.name = "Base Type"
        row.info = preset.attributes.baseType.JSONValue.titlecaseString
        return row
      }

      let baseType = preset.attributes.baseType

      if [.ButtonGroup, .Button] ∋ baseType {
        detailsSection.addRow {
          var row = DetailButtonRow()
          row.name = "Role"
          row.info = preset.attributes.role.JSONValue.titlecaseString

          let roles = baseType == .ButtonGroup ? RemoteElement.Role.buttonGroupRoles : RemoteElement.Role.buttonRoles
          var pickerRow = DetailPickerRow()
          pickerRow.titleForInfo =  {($0 as String).titlecaseString}
          pickerRow.data = roles.map{$0.JSONValue}
          pickerRow.info = preset.attributes.role.JSONValue
          pickerRow.didSelectItem = {
            if !self.didCancel {
              var attributes = preset.attributes
              attributes.role = RemoteElement.Role(JSONValue: $0 as String)
              preset.attributes = attributes
              self.cellDisplayingPicker?.info = ($0 as String).titlecaseString
              pickerRow.info = $0
            }
          }

          row.detailPickerRow = pickerRow

          return row
        }

        detailsSection.addRow {
          var row = DetailButtonRow()
          row.name = "Shape"
          row.info = preset.attributes.shape.JSONValue.titlecaseString

          var pickerRow = DetailPickerRow()
          pickerRow.didSelectItem = {
            if !self.didCancel {
              var attributes = preset.attributes
              attributes.shape = RemoteElement.Shape(JSONValue: $0 as String)
              preset.attributes = attributes
              self.cellDisplayingPicker?.info = ($0 as String).titlecaseString
              pickerRow.info = $0
            }
          }
          pickerRow.titleForInfo = {($0 as String).titlecaseString}
          pickerRow.data = RemoteElement.Shape.allShapes.map{$0.JSONValue}
          pickerRow.info = preset.attributes.shape.JSONValue

          row.detailPickerRow = pickerRow

          return row
        }

        detailsSection.addRow {
          var row = DetailTextFieldRow()
          row.name = "Style"
          row.info = preset.attributes.style.JSONValue.capitalizedString
          row.valueDidChange = {
            var attributes = preset.attributes
            attributes.style = RemoteElement.Style(JSONValue: ($0 as String).lowercaseString)
            preset.attributes = attributes
          }

          return row
        }
      }

      detailsSection.addRow {
        return DetailLabeledImageRow(label: "Background Image",
                                             previewableItem: preset.attributes.backgroundImage)
      }

      detailsSection.addRow {
        var row = DetailSliderRow()
        row.name = "Background Image Alpha"
        row.info = preset.attributes.backgroundImageAlpha
        row.valueDidChange = {
          var attributes = preset.attributes
          attributes.backgroundImageAlpha = CGFloat(($0 as NSNumber).floatValue)
          preset.attributes = attributes
        }
        return row
      }

      detailsSection.addRow {
        var row = DetailColorRow()
        row.name = "Background Color"
        row.info = preset.attributes.backgroundColor
        row.valueDidChange = {
          var attributes = preset.attributes
          attributes.backgroundColor = $0 as? UIColor
          preset.attributes = attributes
        }
        return row
      }

      // TODO: subelements
      // TODO: constraints


      var previewSection = DetailSection(section: 1)
      previewSection.addRow { return DetailImageRow(previewableItem: preset) }

      sections = [detailsSection, previewSection]

    }

  }

  /**
  init:bundle:

  :param: nibNameOrNil String?
  :param: nibBundleOrNil NSBundle?
  */
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  /**
  initWithStyle:

  :param: style UITableViewStyle
  */
  override init(style: UITableViewStyle) { super.init(style: style) }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

}
