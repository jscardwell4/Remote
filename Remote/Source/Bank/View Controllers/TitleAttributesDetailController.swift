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

@objc(TitleAttributesDetailController)
class TitleAttributesDetailController: DetailController {

  var attributesDelegate: TitleAttributesDelegate! { return item as? TitleAttributesDelegate }

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

  :param: attributes TitleAttributesDelegate
  */
  init(attributesDelegate: TitleAttributesDelegate) {
    super.init(item: attributesDelegate)

    let contentSection = DetailSection(section: 0, title: "Content")

    // text
    contentSection.addRow {
      var row = DetailTextFieldRow()
      row.name = "Text"
      row.info = self.attributesDelegate.text
      return row
    }

    // iconName

    let font = UIFont(awesomeFontWithSize: UIFont.labelFontSize())

    // Icon
    contentSection.addRow {
      var row = DetailButtonRow()
      row.name = "Icon"
//      row.infoForPickerSelection = {
//        var info: NSAttributedString?
//        if let iconName = $0 as? String {
//          NSAttributedString(string: UIFont.fontAwesomeIconForName(iconName), attributes: [NSFontAttributeName: font])
//        }
//        return info
//      }
//      row.infoDataType = .AttributedStringData
//      row.pickerNilSelectionTitle = "No Icon"
//      row.pickerData = (UIFont.fontAwesomeIconNames().allObjects as [String]).sorted(<)
//      row.pickerSelection = self.attributesDelegate.iconName
//      row.didSelectItem = { self.attributesDelegate.iconName = $0 as? String }
      return row
    }

    // Icon-Text order
    contentSection.addRow {
      var row = DetailButtonRow()
      row.name = "Order"
//      row.pickerData = TitleAttributes.IconTextOrderSpecification.all.map{$0.JSONValue.capitalizedString}
//      row.pickerSelection = self.attributesDelegate.iconTextOrder.JSONValue.capitalizedString
//      row.didSelectItem = {
//        self.attributesDelegate.iconTextOrder = TitleAttributes.IconTextOrderSpecification(JSONValue: ($0 as String).lowercaseString)
//      }
      return row
    }

    let characterAttributesSection = DetailSection(section: 1, title: "Character Attributes")


    // Font
    characterAttributesSection.addRow {
      var row = DetailLabelRow()
      row.name = "Font"
      row.info = self.attributesDelegate.font?.fontDescriptor().postscriptName
      return row
    }

    // Foreground color
    characterAttributesSection.addRow {
      var row = DetailColorRow()
      row.name = "Foreground Color"
      row.info = self.attributesDelegate.foregroundColor
      row.placeholderColor = UIColor.blackColor()
      row.placeholderText = row.placeholderColor!.rgbaHexString
      row.valueDidChange = { self.attributesDelegate.foregroundColor = $0 as? UIColor }
      return row
    }

    // Background color
    characterAttributesSection.addRow {
      var row = DetailColorRow()
      row.name = "Background Color"
      row.info = self.attributesDelegate.backgroundColor
      row.valueDidChange = { self.attributesDelegate.backgroundColor = $0 as? UIColor }
      return row
    }

    // Ligature
    characterAttributesSection.addRow {
      var row = DetailSwitchRow()
      row.name = "Ligature"
      row.info = Bool(self.attributesDelegate.ligature != nil && self.attributesDelegate.ligature! == 1)
      row.valueDidChange = { self.attributesDelegate.ligature = ($0 as NSNumber).boolValue ? 1 : 0 }
      return row
    }

    // shadow

    // Expansion
    characterAttributesSection.addRow {
      var row = DetailTextFieldRow()
      row.name = "Expansion"
      row.info = self.attributesDelegate.expansion
      row.infoDataType = .FloatData(-Float.infinity...Float.infinity)
      row.shouldUseIntegerKeyboard = true
      row.placeholderText = "No Expansion"
      row.valueDidChange = {
        if let expansion = ($0 as? NSNumber)?.floatValue { self.attributesDelegate.expansion = expansion }
        else { self.attributesDelegate.expansion = nil }
      }
      return row
   }

    // Obliqueness
    characterAttributesSection.addRow {
      var row = DetailTextFieldRow()
      row.name = "Obliqueness"
      row.info = self.attributesDelegate.obliqueness
      row.infoDataType = .FloatData(-Float.infinity...Float.infinity)
      row.shouldUseIntegerKeyboard = true
      row.placeholderText = "No Skew"
      row.valueDidChange = {
        if let obliqueness = ($0 as? NSNumber)?.floatValue { self.attributesDelegate.obliqueness = obliqueness }
        else { self.attributesDelegate.obliqueness = nil }
      }
      return row
   }

    // Strikethrough color
    characterAttributesSection.addRow {
      var row = DetailColorRow()
      row.name = "Strikethrough Color"
      row.info = self.attributesDelegate.strikethroughColor
      row.placeholderColor = self.attributesDelegate.foregroundColor
      row.placeholderText = "Same as Foreground"
      row.valueDidChange = { self.attributesDelegate.strikethroughColor = $0 as? UIColor }
      return row
    }

    // Underline color
    characterAttributesSection.addRow {
      var row = DetailColorRow()
      row.name = "Underline Color"
      row.info = self.attributesDelegate.underlineColor
      row.placeholderColor = self.attributesDelegate.foregroundColor
      row.placeholderText = "Same as Foreground"
      row.valueDidChange = { self.attributesDelegate.underlineColor = $0 as? UIColor }
      return row
    }

    // Baseline offset
    characterAttributesSection.addRow {
      var row = DetailTextFieldRow()
      row.name = "Baseline Offset"
      row.info = self.attributesDelegate.baselineOffset
      row.infoDataType = .FloatData(-Float.infinity...Float.infinity)
      row.shouldUseIntegerKeyboard = true
      row.placeholderText = "0"
      row.valueDidChange = {
        if let baselineOffset = ($0 as? NSNumber)?.floatValue { self.attributesDelegate.baselineOffset = baselineOffset }
        else { self.attributesDelegate.baselineOffset = nil }
      }
      return row
   }

    // Text effect
    characterAttributesSection.addRow {
      var row = DetailSwitchRow()
      row.name = "Letterpress Effect"
      row.info = Bool(self.attributesDelegate.textEffect != nil)
      row.valueDidChange = { self.attributesDelegate.textEffect = ($0 as NSNumber).boolValue ? "letterpress" : nil }
      return row
    }

    // Stroke width - 0 = no change, positive float = stroke width, negative float = stroke and fill text
    characterAttributesSection.addRow {
      var row = DetailTextFieldRow()
      row.name = "Stroke Width"
      row.info = self.attributesDelegate.strokeWidth
      row.infoDataType = .FloatData(-Float.infinity...Float.infinity)
      row.placeholderText = "No Change"
      row.shouldUseIntegerKeyboard = true
      row.valueDidChange = {
        if let strokeWidth = ($0 as? NSNumber)?.floatValue { self.attributesDelegate.strokeWidth = strokeWidth }
        else { self.attributesDelegate.strokeWidth = nil }
      }
      return row
   }

    // Stroke color
    characterAttributesSection.addRow {
      var row = DetailColorRow()
      row.name = "Stroke Color"
      row.info = self.attributesDelegate.strokeColor
      row.placeholderColor = self.attributesDelegate.foregroundColor
      row.placeholderText = "Same as Foreground"
      row.valueDidChange = { self.attributesDelegate.strokeColor = $0 as? UIColor }
      return row
    }

    // underlineStyle
    characterAttributesSection.addRow {
      var row = DetailButtonRow()
      row.name = "Underline Style"
//      row.pickerData = NSUnderlineStyle.all.map{$0.JSONValue.titlecaseString}
//      row.pickerSelection = self.attributesDelegate.underlineStyle?.JSONValue.titlecaseString
//      row.valueDidChange = {
//        if let titlecaseValue = $0 as? String {
//          if let style = NSUnderlineStyle(JSONValue: titlecaseValue.dashcaseString) {
//            self.attributesDelegate.underlineStyle = style
//          }
//        }
//      }
      return row
    }

    // strikethroughStyle
    characterAttributesSection.addRow {
      var row = DetailButtonRow()
      row.name = "Strikethrough Style"
//      row.pickerData = NSUnderlineStyle.all.map{$0.JSONValue.titlecaseString}
//      row.pickerSelection = self.attributesDelegate.strikethroughStyle?.JSONValue.titlecaseString
//      row.valueDidChange = {
//        if let titlecaseValue = $0 as? String {
//          if let style = NSUnderlineStyle(JSONValue: titlecaseValue.dashcaseString) {
//            self.attributesDelegate.strikethroughStyle = style
//          }
//        }
//      }
      return row
    }


    // Kern
    characterAttributesSection.addRow {
      var row = DetailTextFieldRow()
      row.name = "Kern"
      row.info = self.attributesDelegate.kern
      row.infoDataType = .FloatData(-Float.infinity...Float.infinity)
      row.shouldUseIntegerKeyboard = true
      row.placeholderText = "Auto"
      row.valueDidChange = {
        if let kern = ($0 as? NSNumber)?.floatValue { self.attributesDelegate.kern = kern }
        else { self.attributesDelegate.kern = nil }
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
