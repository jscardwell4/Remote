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
      let detailsSection = DetailSection(sectionNumber: 0, title: "Common Attributes")

      detailsSection.addRow { DetailLabelRow(pushableCategory: preset.presetCategory!, label: "Category") }

      detailsSection.addRow {
        DetailLabelRow(label: "Base Type", value: preset.attributes.baseType.JSONValue.titlecaseString)
      }

      let baseType = preset.attributes.baseType

      if [.ButtonGroup, .Button] ∋ baseType {
        detailsSection.addRow {
          let row = DetailButtonRow()
          row.name = "Role"
          row.info = preset.attributes.role.JSONValue.titlecaseString
          row.didSelectItem = {
            if !self.didCancel {
              var attributes = preset.attributes
              attributes.role = RemoteElement.Role(JSONValue: ($0 as String).dashcaseString)
              preset.attributes = attributes
            }
          }
          let roles = baseType == .ButtonGroup ? RemoteElement.Role.buttonGroupRoles : RemoteElement.Role.buttonRoles
          row.pickerData = roles.map{$0.JSONValue.titlecaseString}
          row.pickerSelection = preset.attributes.role.JSONValue.titlecaseString

          return row
        }

        detailsSection.addRow {
          let row = DetailButtonRow()
          row.name = "Shape"
          row.info = preset.attributes.shape.JSONValue.titlecaseString
          row.didSelectItem = {
            if !self.didCancel {
              var attributes = preset.attributes
              attributes.shape = RemoteElement.Shape(JSONValue: ($0 as String).dashcaseString)
              preset.attributes = attributes
            }
          }
          row.pickerData = RemoteElement.Shape.allShapes.map{$0.JSONValue.titlecaseString}
          row.pickerSelection = preset.attributes.shape.JSONValue.titlecaseString

          return row
        }

        detailsSection.addRow {
          let row = DetailTextFieldRow()
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
        let row = DetailSliderRow()
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
        let row = DetailColorRow(label: "Background Color", color: preset.attributes.backgroundColor)
        row.valueDidChange = {
          var attributes = preset.attributes
          attributes.backgroundColor = $0 as? UIColor
          preset.attributes = attributes
        }
        return row
      }

      // TODO: subelements
      // TODO: constraints


      let previewSection = DetailSection(sectionNumber: 1)
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

  func generateRowsForTitleAttributes(titleAttributes: TitleAttributes, indentationLevel: Int = 0) -> [DetailRow] {
    var rows: [DetailRow] = []
    TitleAttributes.PropertyKey.enumerateAttributePropertyKeys {
      switch $0 {
        case .Font:
          let row = DetailLabelRow(label: "Font", value: "") //Font(titleAttributes.font)?.JSONValue)
          row.indentationLevel = indentationLevel
          rows.append(row)
        case .ForegroundColor:
          let row = DetailColorRow(label: "Foreground Color", color: titleAttributes.foregroundColor)
          row.indentationLevel = indentationLevel
          // row.valueDidChange = {
          //   titleAttributes.foregroundColor = $0 as? UIColor
            // storage.dictionary = titleAttributes.dictionaryValue
          // }
          rows.append(row)
        case .BackgroundColor:
          let row = DetailColorRow(label: "Background Color", color: titleAttributes.backgroundColor)
          row.indentationLevel = indentationLevel
          // row.valueDidChange = {
          //   titleAttributes.backgroundColor = $0 as? UIColor
            // storage.dictionary = titleAttributes.dictionaryValue
          // }
          rows.append(row)
        case .Ligature:
          let row = DetailLabelRow(label: "Ligature", value: "\(titleAttributes.ligature ?? 0)")
          row.indentationLevel = indentationLevel
          rows.append(row)
        case .Shadow:
          break
        case .Expansion:
          let row = DetailLabelRow(label: "Expansion", value: "\(titleAttributes.expansion ?? 0)")
          row.indentationLevel = indentationLevel
          rows.append(row)
        case .Obliqueness:
          let row = DetailLabelRow(label: "Obliqueness", value: "\(titleAttributes.obliqueness ?? 0)")
          row.indentationLevel = indentationLevel
          rows.append(row)
        case .StrikethroughColor:
          let row = DetailColorRow(label: "Strikethrough Color", color: titleAttributes.strikethroughColor)
          row.indentationLevel = indentationLevel
          // row.valueDidChange = {
          //   titleAttributes.strikethroughColor = $0 as? UIColor
            // storage.dictionary = titleAttributes.dictionaryValue
          // }
          rows.append(row)
        case .UnderlineColor:
          let row = DetailColorRow(label: "Underline Color", color: titleAttributes.underlineColor)
          row.indentationLevel = indentationLevel
          // row.valueDidChange = {
          //   titleAttributes.underlineColor = $0 as? UIColor
            // storage.dictionary = titleAttributes.dictionaryValue
          // }
          rows.append(row)
        case .BaselineOffset:
          let row = DetailLabelRow(label: "BaselineOffset", value: "\(titleAttributes.baselineOffset ?? 0)")
          row.indentationLevel = indentationLevel
          rows.append(row)
        case .TextEffect:
          let row = DetailLabelRow(label: "TextEffect", value: titleAttributes.textEffect == nil ? "" : "Letterpress")
          row.indentationLevel = indentationLevel
          rows.append(row)
        case .StrokeWidth:
          let row = DetailLabelRow(label: "StrokeWidth", value: "\(titleAttributes.strokeWidth ?? 0)")
          row.indentationLevel = indentationLevel
          rows.append(row)
        case .StrokeColor:
          let row = DetailColorRow(label: "Stroke Color", color: titleAttributes.strokeColor)
          row.indentationLevel = indentationLevel
          // row.valueDidChange = {
          //   titleAttributes.strokeColor = $0 as? UIColor
            // storage.dictionary = titleAttributes.dictionaryValue
          // }
          rows.append(row)
        case .UnderlineStyle:
          let row = DetailLabelRow(label: "Underline Style",
                                     value: titleAttributes.underlineStyle?.JSONValue.titlecaseString)
          row.indentationLevel = indentationLevel
          rows.append(row)
        case .StrikethroughStyle:
          let row = DetailLabelRow(label: "Strikethrough Style",
                                     value: titleAttributes.strikethroughStyle?.JSONValue.titlecaseString)
          row.indentationLevel = indentationLevel
          rows.append(row)
        case .Kern:
          let row = DetailLabelRow(label: "Kern", value: "\(titleAttributes.kern ?? 0)")
          row.indentationLevel = indentationLevel
          rows.append(row)
        default:
          break
      }
    }
    return rows
  }

}
