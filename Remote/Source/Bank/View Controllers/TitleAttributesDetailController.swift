//
//  TitleAttributesDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class TitleAttributesDetailController: DetailController {

  var attributesDelegate: TitleAttributesDelegate! { return item as? TitleAttributesDelegate }

  /** loadSections */
  override func loadSections() {
    super.loadSections()

    precondition(item is TitleAttributesDelegate, "we should have been given a title attributes delegate")

    let attributesDelegate = item as TitleAttributesDelegate

    let contentSection = DetailSection(section: 0, title: "Content")

    // text
    contentSection.addRow {
      var row = DetailTextFieldRow()
      row.name = "Text"
      row.info = attributesDelegate.text
      row.placeholderText = "No Text"
      row.valueDidChange = { attributesDelegate.text = $0 as? String }
      return row
    }

    // iconName
    contentSection.addRow {
      var row = DetailButtonRow()
      row.name = "Icon"
      row.infoDataType = .AttributedStringData
      row.info = UIFont.attributedFontAwesomeIconForName(attributesDelegate.iconName) ?? "No Icon"
      var pickerRow = DetailPickerRow()

      pickerRow.nilItemTitle = "No Icon"
      pickerRow.data = (UIFont.fontAwesomeIconNames().allObjects as [String]).sorted(<)
      pickerRow.info = attributesDelegate.iconName
      pickerRow.didSelectItem = { [unowned pickerRow] in
        if !self.didCancel {
          if let iconName = $0 as? String {
            attributesDelegate.iconName = iconName
            self.cellDisplayingPicker?.info = UIFont.attributedFontAwesomeIconForName(iconName)
          } else {
            attributesDelegate.iconName = nil
            self.cellDisplayingPicker?.info = "No Icon"
          }
          pickerRow.info = $0
        }
      }

      row.detailPickerRow = pickerRow

      return row
    }

    // Icon-Text order
    contentSection.addRow {
      var row = DetailButtonRow()
      row.name = "Order"
      row.info = attributesDelegate.iconTextOrder.JSONValue.capitalizedString

      var pickerRow = DetailPickerRow()
      pickerRow.data = TitleAttributes.IconTextOrderSpecification.all.map{$0.JSONValue}
      pickerRow.info = attributesDelegate.iconTextOrder.JSONValue
      pickerRow.titleForInfo = {($0 as String).capitalizedString}
      pickerRow.didSelectItem = {
        if !self.didCancel {
          attributesDelegate.iconTextOrder = TitleAttributes.IconTextOrderSpecification(JSONValue: ($0 as String))
          self.cellDisplayingPicker?.info = attributesDelegate.iconTextOrder.JSONValue.capitalizedString
          pickerRow.info = attributesDelegate.iconTextOrder.JSONValue
        }
      }

      row.detailPickerRow = pickerRow

      return row
    }

    let characterAttributesSection = DetailSection(section: 1, title: "Character Attributes")


    // Font
    // TODO: Make font an editable field
    characterAttributesSection.addRow {
      var row = DetailLabelRow()
      row.name = "Font"
      row.info = attributesDelegate.font?.fontDescriptor().postscriptName
      return row
    }

    // Foreground color
    characterAttributesSection.addRow {
      var row = DetailColorRow()
      row.name = "Foreground Color"
      row.info = attributesDelegate.foregroundColor
      row.placeholderColor = UIColor.blackColor()
      row.placeholderText = row.placeholderColor!.rgbaHexString
      row.valueDidChange = { attributesDelegate.foregroundColor = $0 as? UIColor }
      return row
    }

    // Background color
    characterAttributesSection.addRow {
      var row = DetailColorRow()
      row.name = "Background Color"
      row.info = attributesDelegate.backgroundColor
      row.valueDidChange = { attributesDelegate.backgroundColor = $0 as? UIColor }
      return row
    }

    // Ligature
    characterAttributesSection.addRow {
      var row = DetailSwitchRow()
      row.name = "Ligature"
      row.info = Bool(attributesDelegate.ligature != nil && attributesDelegate.ligature! == 1)
      row.valueDidChange = { attributesDelegate.ligature = ($0 as NSNumber).boolValue ? 1 : 0 }
      return row
    }

    // shadow

    // Expansion
    characterAttributesSection.addRow {
      var row = DetailTextFieldRow()
      row.name = "Expansion"
      row.info = attributesDelegate.expansion
      row.infoDataType = .FloatData(-Float.infinity...Float.infinity)
      row.inputType = .FloatingPoint
      row.placeholderText = "No Expansion"
      row.valueDidChange = {
        if let expansion = ($0 as? NSNumber)?.floatValue { attributesDelegate.expansion = expansion }
        else { attributesDelegate.expansion = nil }
      }
      return row
   }

    // Obliqueness
    characterAttributesSection.addRow {
      var row = DetailTextFieldRow()
      row.name = "Obliqueness"
      row.info = attributesDelegate.obliqueness
      row.infoDataType = .FloatData(-Float.infinity...Float.infinity)
      row.inputType = .FloatingPoint
      row.placeholderText = "No Skew"
      row.valueDidChange = {
        if let obliqueness = ($0 as? NSNumber)?.floatValue { attributesDelegate.obliqueness = obliqueness }
        else { attributesDelegate.obliqueness = nil }
      }
      return row
   }

    // Strikethrough color
    characterAttributesSection.addRow {
      var row = DetailColorRow()
      row.name = "Strikethrough Color"
      row.info = attributesDelegate.strikethroughColor
      row.placeholderColor = attributesDelegate.foregroundColor
      row.placeholderText = "Same as Foreground"
      row.valueDidChange = { attributesDelegate.strikethroughColor = $0 as? UIColor }
      return row
    }

    // Underline color
    characterAttributesSection.addRow {
      var row = DetailColorRow()
      row.name = "Underline Color"
      row.info = attributesDelegate.underlineColor
      row.placeholderColor = attributesDelegate.foregroundColor
      row.placeholderText = "Same as Foreground"
      row.valueDidChange = { attributesDelegate.underlineColor = $0 as? UIColor }
      return row
    }

    // Baseline offset
    characterAttributesSection.addRow {
      var row = DetailTextFieldRow()
      row.name = "Baseline Offset"
      row.info = attributesDelegate.baselineOffset
      row.infoDataType = .FloatData(-Float.infinity...Float.infinity)
      row.inputType = .FloatingPoint
      row.placeholderText = "0"
      row.valueDidChange = {
        if let baselineOffset = ($0 as? NSNumber)?.floatValue { attributesDelegate.baselineOffset = baselineOffset }
        else { attributesDelegate.baselineOffset = nil }
      }
      return row
   }

    // Text effect
    characterAttributesSection.addRow {
      var row = DetailSwitchRow()
      row.name = "Letterpress Effect"
      row.info = Bool(attributesDelegate.textEffect != nil)
      row.valueDidChange = { attributesDelegate.textEffect = ($0 as NSNumber).boolValue ? "letterpress" : nil }
      return row
    }

    // Stroke width - 0 = no change, positive float = stroke width, negative float = stroke and fill text
    characterAttributesSection.addRow {
      var row = DetailTextFieldRow()
      row.name = "Stroke Width"
      row.info = attributesDelegate.strokeWidth
      row.infoDataType = .FloatData(-Float.infinity...Float.infinity)
      row.placeholderText = "No Change"
      row.inputType = .FloatingPoint
      row.valueDidChange = {
        if let strokeWidth = ($0 as? NSNumber)?.floatValue { attributesDelegate.strokeWidth = strokeWidth }
        else { attributesDelegate.strokeWidth = nil }
      }
      return row
   }

    // Stroke color
    characterAttributesSection.addRow {
      var row = DetailColorRow()
      row.name = "Stroke Color"
      row.info = attributesDelegate.strokeColor
      row.placeholderColor = attributesDelegate.foregroundColor
      row.placeholderText = "Same as Foreground"
      row.valueDidChange = { attributesDelegate.strokeColor = $0 as? UIColor }
      return row
    }

    // underlineStyle
    characterAttributesSection.addRow {
      var row = DetailButtonRow()
      row.name = "Underline Style"
      row.info = attributesDelegate.underlineStyle?.JSONValue.titlecaseString ?? "None"

      var pickerRow = DetailPickerRow()
      pickerRow.data = NSUnderlineStyle.all.map{$0.JSONValue}
      pickerRow.info = attributesDelegate.underlineStyle?.JSONValue.titlecaseString
      pickerRow.didSelectItem = { [unowned pickerRow] in
        if !self.didCancel {
          attributesDelegate.underlineStyle = NSUnderlineStyle(JSONValue: $0 as? String ?? "")
          self.cellDisplayingPicker?.info = attributesDelegate.underlineStyle?.JSONValue ?? "None"
          pickerRow.info = $0
        }
      }

      row.detailPickerRow = pickerRow

      return row
    }

    // strikethroughStyle
    characterAttributesSection.addRow {
      var row = DetailButtonRow()
      row.name = "Strikethrough Style"
      row.info = attributesDelegate.strikethroughStyle?.JSONValue.titlecaseString ?? "None"

      var pickerRow = DetailPickerRow()
      pickerRow.data = NSUnderlineStyle.all.map{$0.JSONValue}
      pickerRow.info = attributesDelegate.strikethroughStyle?.JSONValue.titlecaseString
      pickerRow.didSelectItem = { [unowned pickerRow] in
        if !self.didCancel {
          attributesDelegate.strikethroughStyle = NSUnderlineStyle(JSONValue: $0 as? String ?? "")
          self.cellDisplayingPicker?.info = attributesDelegate.strikethroughStyle?.JSONValue ?? "None"
          pickerRow.info = $0
        }
      }

      row.detailPickerRow = pickerRow

      return row
    }


    // Kern
    characterAttributesSection.addRow {
      var row = DetailTextFieldRow()
      row.name = "Kern"
      row.info = attributesDelegate.kern
      row.infoDataType = .FloatData(-Float.infinity...Float.infinity)
      row.inputType = .FloatingPoint
      row.placeholderText = "Auto"
      row.valueDidChange = {
        if let kern = ($0 as? NSNumber)?.floatValue { attributesDelegate.kern = kern }
        else { attributesDelegate.kern = nil }
      }
      return row
    }

    // paragraphStyle

    // alignment                Button
    // firstLineHeadIndent      TextField
    // headIndent               TextField
    // tailIndent               TextField
    // lineHeightMultiple       TextField
    // maximumLineHeight        TextField
    // minimumLineHeight        TextField
    // lineSpacing              TextField
    // paragraphSpacing         TextField
    // paragraphSpacingBefore   TextField
    // hyphenationFactor        TextField
    // lineBreakMode            Button

    sections = [contentSection, characterAttributesSection]
  }

}
