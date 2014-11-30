//
//  TitleAttributesDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import UIKit

@objc(TitleAttributesDetailController)
class TitleAttributesDetailController: DetailController {

  var attributes: TitleAttributes! { return item as? TitleAttributes }

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
  initWithCoder:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /**
  initWithAttributes:

  :param: attributes TitleAttributes
  */
  init(attributes: TitleAttributes) {
    super.init(item: attributes)

    let contentSection = DetailSection(sectionNumber: 0, title: "Content")

    // text
    contentSection.addRow {
      let row = DetailTextFieldRow()
      row.name = "Text"
      row.info = attributes.text
      return row
    }

    // iconName

    // Icon
    contentSection.addRow {
      let row = DetailTextFieldRow()
      row.name = "Icon"
      row.info = attributes.iconString
      row.infoDataType = .AttributedStringData
      return row
    }

    // Icon-Text order
    contentSection.addRow {
      let row = DetailLabelRow()
      row.name = "Order"
      row.info = attributes.iconTextOrder.JSONValue.capitalizedString
      return row
    }

    let characterAttributesSection = DetailSection(sectionNumber: 1, title: "Character Attributes")


    // Font
    characterAttributesSection.addRow {
      let row = DetailLabelRow()
      row.name = "Font"
      row.info = attributes.font?.fontDescriptor().postscriptName
      return row
    }

    // Foreground color
    characterAttributesSection.addRow {
      let row = DetailColorRow(label: "Foreground Color", color: attributes.foregroundColor)
      row.valueDidChange = { attributes.foregroundColor = $0 as? UIColor }
      return row
    }

    // Background color
    characterAttributesSection.addRow {
      let row = DetailColorRow(label: "Background Color", color: attributes.backgroundColor)
      row.valueDidChange = { attributes.backgroundColor = $0 as? UIColor }
      return row
    }

    // Ligature
    characterAttributesSection.addRow {
      let row = DetailSwitchRow()
      row.name = "Ligature"
      row.info = Bool(attributes.ligature != nil && attributes.ligature! == 1)
      row.valueDidChange = { attributes.ligature = ($0 as NSNumber).boolValue ? 1 : 0 }
      return row
    }

    // shadow

    // Expansion
    characterAttributesSection.addRow {
      let row = DetailTextFieldRow()
      row.name = "Expansion"
      row.info = attributes.expansion
      row.infoDataType = .FloatData(-Float.infinity...Float.infinity)
      row.shouldUseIntegerKeyboard = true
      row.valueDidChange = {
        if let expansion = ($0 as? NSNumber)?.floatValue { attributes.expansion = expansion } else { attributes.expansion = nil }
      }
      return row
   }

    // Obliqueness
    characterAttributesSection.addRow {
      let row = DetailTextFieldRow()
      row.name = "Obliqueness"
      row.info = attributes.obliqueness
      row.infoDataType = .FloatData(-Float.infinity...Float.infinity)
      row.shouldUseIntegerKeyboard = true
      row.valueDidChange = {
        if let obliqueness = ($0 as? NSNumber)?.floatValue { attributes.obliqueness = obliqueness }
        else { attributes.obliqueness = nil }
      }
      return row
   }

    // Strikethrough color
    characterAttributesSection.addRow {
      let row = DetailColorRow(label: "Strikethrough Color", color: attributes.strikethroughColor)
      row.valueDidChange = { attributes.strikethroughColor = $0 as? UIColor }
      return row
    }

    // Underline color
    characterAttributesSection.addRow {
      let row = DetailColorRow(label: "Underline Color", color: attributes.underlineColor)
      row.valueDidChange = { attributes.underlineColor = $0 as? UIColor }
      return row
    }

    // Baseline offset
    characterAttributesSection.addRow {
      let row = DetailTextFieldRow()
      row.name = "Baseline Offset"
      row.info = attributes.baselineOffset
      row.infoDataType = .FloatData(-Float.infinity...Float.infinity)
      row.shouldUseIntegerKeyboard = true
      row.valueDidChange = {
        if let baselineOffset = ($0 as? NSNumber)?.floatValue { attributes.baselineOffset = baselineOffset }
        else { attributes.baselineOffset = nil }
      }
      return row
   }

    // Text effect
    characterAttributesSection.addRow {
      let row = DetailSwitchRow()
      row.name = "Letterpress Effect"
      row.info = Bool(attributes.textEffect != nil)
      row.valueDidChange = { attributes.textEffect = ($0 as NSNumber).boolValue ? "letterpress" : nil }
      return row
    }

    // Stroke width - 0 = no change, positive float = stroke width, negative float = stroke and fill text
    characterAttributesSection.addRow {
      let row = DetailTextFieldRow()
      row.name = "Stroke Width"
      row.info = attributes.strokeWidth
      row.infoDataType = .FloatData(-Float.infinity...Float.infinity)
      row.shouldUseIntegerKeyboard = true
      row.valueDidChange = {
        if let strokeWidth = ($0 as? NSNumber)?.floatValue { attributes.strokeWidth = strokeWidth }
        else { attributes.strokeWidth = nil }
      }
      return row
   }

    // Stroke color
    characterAttributesSection.addRow {
      let row = DetailColorRow(label: "Stroke Color", color: attributes.strokeColor)
      row.valueDidChange = { attributes.strokeColor = $0 as? UIColor }
      return row
    }

    // underlineStyle
    characterAttributesSection.addRow {
      let row = DetailButtonRow()
      row.name = "Underline Style"
      row.info = attributes.underlineStyle?.JSONValue.titlecaseString
      row.pickerData = NSUnderlineStyle.all.map{$0.JSONValue.titlecaseString}
      row.pickerSelection = row.info as? NSObject
      row.valueDidChange = {
        if let titlecaseValue = $0 as? String {
          if let style = NSUnderlineStyle(JSONValue: titlecaseValue.dashcaseString) {
            attributes.underlineStyle = style
          }
        }
      }
      return row
    }

    // strikethroughStyle
    characterAttributesSection.addRow {
      let row = DetailButtonRow()
      row.name = "Strikethrough Style"
      row.info = attributes.strikethroughStyle?.JSONValue.titlecaseString
      row.pickerData = NSUnderlineStyle.all.map{$0.JSONValue.titlecaseString}
      row.pickerSelection = row.info as? NSObject
      row.valueDidChange = {
        if let titlecaseValue = $0 as? String {
          if let style = NSUnderlineStyle(JSONValue: titlecaseValue.dashcaseString) {
            attributes.strikethroughStyle = style
          }
        }
      }
      return row
    }


    // Kern
    characterAttributesSection.addRow {
      let row = DetailTextFieldRow()
      row.name = "Kern"
      row.info = attributes.kern
      row.infoDataType = .FloatData(-Float.infinity...Float.infinity)
      row.shouldUseIntegerKeyboard = true
      row.valueDidChange = {
        if let kern = ($0 as? NSNumber)?.floatValue { attributes.kern = kern } else { attributes.kern = nil }
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
