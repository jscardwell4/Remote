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

    /*********************************************************************************
      Content Section
    *********************************************************************************/

    let contentSection = DetailSection(section: 0, title: "Content")

    // text
    contentSection.addRow {
      var row = DetailTextFieldRow()
      row.name = "Text"
      row.info = attributesDelegate.text
      row.placeholderText = "No Text"
      row.valueDidChange = { attributesDelegate.text = $0 as? String ?? "" }
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

    /*********************************************************************************
      Font Section
    *********************************************************************************/

    let fontSection = DetailSection(section: 1, title: "Font")


    // Font
    // TODO: Make font an editable field
    fontSection.addRow {
      var row = DetailLabelRow()
      row.name = "Font"
      row.info = attributesDelegate.font.fontDescriptor().postscriptName
      return row
    }

    // Foreground color
    fontSection.addRow {
      var row = DetailColorRow()
      row.name = "Foreground Color"
      row.info = attributesDelegate.foregroundColor
      row.valueDidChange = { if let color = $0 as? UIColor { attributesDelegate.foregroundColor = color } }
      return row
    }

    // Background color
    fontSection.addRow {
      var row = DetailColorRow()
      row.name = "Background Color"
      row.info = attributesDelegate.backgroundColor
      row.valueDidChange = { attributesDelegate.backgroundColor = $0 as? UIColor }
      return row
    }

    /*********************************************************************************
      Stroke Section
    *********************************************************************************/

    let strokeSection = DetailSection(section: 2, title: "Stroke")

    // Stroke width - 0 = no change, positive float = stroke width, negative float = stroke and fill text
    strokeSection.addRow {
      var row = DetailTextFieldRow()
      row.name = "Width"
      row.info = abs(attributesDelegate.strokeWidth)
      row.infoDataType = .FloatData(0.0...Float.infinity)
      row.placeholderText = "No Change"
      row.inputType = .FloatingPoint
      row.valueDidChange = {
        if let strokeWidth = ($0 as? NSNumber)?.floatValue {
          attributesDelegate.strokeWidth = attributesDelegate.strokeWidth.isSignMinus == true ? -strokeWidth : strokeWidth
        }
      }
      return row
   }

   strokeSection.addRow {
     var row = DetailSwitchRow()
     row.name = "Fill"
     row.info = attributesDelegate.strokeFill
     row.valueDidChange = { attributesDelegate.strokeFill = ($0 as NSNumber).boolValue }
     return row
   }

    // Stroke color
    strokeSection.addRow {
      var row = DetailColorRow()
      row.name = "Color"
      row.info = attributesDelegate.strokeColor
      row.valueDidChange = { if let color = $0 as? UIColor { attributesDelegate.strokeColor = color } }
      return row
    }


    /*********************************************************************************
       Spacing Section
    *********************************************************************************/

    let spacingSection = DetailSection(section: 3, title: "Spacing")

    // Ligature
    spacingSection.addRow {
      var row = DetailSwitchRow()
      row.name = "Ligature"
      row.info = attributesDelegate.ligature == 1
      row.valueDidChange = { attributesDelegate.ligature = ($0 as NSNumber).boolValue ? 1 : 0 }
      return row
    }

    // Expansion
    spacingSection.addRow {
      var row = DetailTextFieldRow()
      row.name = "Expansion"
      row.info = attributesDelegate.expansion
      row.infoDataType = .FloatData(-Float.infinity...Float.infinity)
      row.inputType = .FloatingPoint
      row.placeholderText = "No Expansion"
      row.valueDidChange = { if let expansion = ($0 as? NSNumber)?.floatValue { attributesDelegate.expansion = expansion } }
      return row
   }

   // Baseline offset
    spacingSection.addRow {
      var row = DetailTextFieldRow()
      row.name = "Baseline Offset"
      row.info = attributesDelegate.baselineOffset
      row.infoDataType = .FloatData(-Float.infinity...Float.infinity)
      row.inputType = .FloatingPoint
      row.placeholderText = "0"
      row.valueDidChange = {
        if let baselineOffset = ($0 as? NSNumber)?.floatValue { attributesDelegate.baselineOffset = baselineOffset }
      }
      return row
   }

    // Kern
    spacingSection.addRow {
      var row = DetailTextFieldRow()
      row.name = "Kern"
      row.info = attributesDelegate.kern
      row.infoDataType = .FloatData(-Float.infinity...Float.infinity)
      row.inputType = .FloatingPoint
      row.placeholderText = "Auto"
      row.valueDidChange = {
        if let kern = ($0 as? NSNumber)?.floatValue { attributesDelegate.kern = kern }
      }
      return row
    }

    /*********************************************************************************
      Style Section
    *********************************************************************************/

    let styleSection = DetailSection(section: 4, title: "Style")

     // Obliqueness
    styleSection.addRow {
      var row = DetailTextFieldRow()
      row.name = "Obliqueness"
      row.info = attributesDelegate.obliqueness
      row.infoDataType = .FloatData(-Float.infinity...Float.infinity)
      row.inputType = .FloatingPoint
      row.placeholderText = "No Skew"
      row.valueDidChange = {
        if let obliqueness = ($0 as? NSNumber)?.floatValue { attributesDelegate.obliqueness = obliqueness }
      }
      return row
   }

    // Text effect
    styleSection.addRow {
      var row = DetailSwitchRow()
      row.name = "Letterpress"
      row.info = attributesDelegate.textEffect != nil
      row.valueDidChange = { attributesDelegate.textEffect = ($0 as NSNumber).boolValue ? "letterpress" : nil }
      return row
    }

    /*********************************************************************************
      Underline Section
    *********************************************************************************/

    let underlineSection = DetailSection(section: 5, title: "Underline")

    // underlineStyle
    underlineSection.addRow {
      var row = DetailButtonRow()
      row.name = "Style"
      row.info = attributesDelegate.underlineStyle.JSONValue.titlecaseString

      var pickerRow = DetailPickerRow()
      pickerRow.data = NSUnderlineStyle.all.map{$0.JSONValue}
      pickerRow.info = attributesDelegate.underlineStyle.JSONValue.titlecaseString
      pickerRow.didSelectItem = { [unowned pickerRow] in
        if !self.didCancel {
          attributesDelegate.underlineStyle = NSUnderlineStyle(JSONValue: $0 as? String ?? "none")
          self.cellDisplayingPicker?.info = attributesDelegate.underlineStyle.JSONValue.titlecaseString
          pickerRow.info = $0
        }
      }

      row.detailPickerRow = pickerRow

      return row
    }

    // Underline color
    underlineSection.addRow {
      var row = DetailColorRow()
      row.name = "Color"
      row.info = attributesDelegate.underlineColor
      row.valueDidChange = { if let color = $0 as? UIColor { attributesDelegate.underlineColor = color } }
      return row
    }

    /*********************************************************************************
      Strikethrough Section
    *********************************************************************************/

    let strikethroughSection = DetailSection(section: 6, title: "Strikethrough")

    // strikethroughStyle
    strikethroughSection.addRow {
      var row = DetailButtonRow()
      row.name = "Style"
      row.info = attributesDelegate.strikethroughStyle.JSONValue.titlecaseString

      var pickerRow = DetailPickerRow()
      pickerRow.data = NSUnderlineStyle.all.map{$0.JSONValue}
      pickerRow.info = attributesDelegate.strikethroughStyle.JSONValue.titlecaseString
      pickerRow.didSelectItem = { [unowned pickerRow] in
        if !self.didCancel {
          attributesDelegate.strikethroughStyle = NSUnderlineStyle(JSONValue: $0 as? String ?? "none")
          self.cellDisplayingPicker?.info = attributesDelegate.strikethroughStyle.JSONValue.titlecaseString
          pickerRow.info = $0
        }
      }

      row.detailPickerRow = pickerRow

      return row
    }

    // Strikethrough color
    strikethroughSection.addRow {
      var row = DetailColorRow()
      row.name = "Color"
      row.info = attributesDelegate.strikethroughColor
      row.valueDidChange = { if let color = $0 as? UIColor { attributesDelegate.strikethroughColor = color } }
      return row
    }

    /********************************************************************************
      Paragraph Style Section
    ********************************************************************************/

    let paragraphStyleSection = DetailSection(section: 7, title: "Paragraph Style")

    // alignment                Button
    paragraphStyleSection.addRow {
      var row = DetailButtonRow()
      row.name = "Alignment"
      row.info = attributesDelegate.alignment.JSONValue.titlecaseString
      return row
    }

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

    sections = ["Content": contentSection,
                "Font": fontSection,
                "Stroke": strokeSection,
                "Spacing": spacingSection,
                "Style": styleSection,
                "Underline": underlineSection,
                "Strikethrough": strikethroughSection,
                "Paragraph Style": paragraphStyleSection]
  }

}
