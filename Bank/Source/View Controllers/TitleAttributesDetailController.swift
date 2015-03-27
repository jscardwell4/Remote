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
import DataModel

class TitleAttributesDetailController: DetailController {

  private struct SectionKey {
    static let Content        = "Content"
    static let Font           = "Font"
    static let Stroke         = "Stroke"
    static let Style          = "Style"
    static let Underline      = "Underline"
    static let Strikethrough  = "Strikethrough"
    static let ParagraphStyle = "Paragraph Style"
  }

  private struct RowKey {
    static let Text               = "Text"
    static let Icon               = "Icon"
    static let Order              = "Order"
    static let Font               = "Font"
    static let ForegroundColor    = "Foreground Color"
    static let BackgroundColor    = "Background Color"
    static let Width              = "Width"
    static let Fill               = "Fill"
    static let StrokeColor        = "Stroke Color"
    static let Obliqueness        = "Obliqueness"
    static let Letterpress        = "Letterpress"
    static let UnderlineStyle     = "Underline Style"
    static let UnderlineColor     = "Underline Color"
    static let StrikethroughStyle = "Strikethrough Style"
    static let StrikethroughColor = "Strikethrough Color"
    static let Alignment          = "Alignment"
  }

  var attributesDelegate: TitleAttributesDelegate! { return item as? TitleAttributesDelegate }

  /** loadSections */
  override func loadSections() {
    super.loadSections()

    precondition(item is TitleAttributesDelegate, "we should have been given a title attributes delegate")

    loadContentSection()
    loadFontSection()
    loadStrokeSection()
    loadStyleSection()
    loadUnderlineSection()
    loadStrikethroughSection()
    loadParagraphStyleSection()

  }

  /** loadContentSection */
  private func loadContentSection() {

    let attributesDelegate = item as! TitleAttributesDelegate

    /*********************************************************************************
      Content Section
    *********************************************************************************/

    let contentSection = DetailSection(section: 0, title: "Content")

    // text
    contentSection.addRow({
      var row = DetailTextFieldRow()
      row.name = "Text"
      row.info = attributesDelegate.text
      row.placeholderText = "No Text"
      row.valueDidChange = { attributesDelegate.text = $0 as? String ?? "" }
      return row
    }, forKey: RowKey.Text)

    // iconName
    contentSection.addRow({
      var row = DetailButtonRow()
      row.name = "Icon"
      row.infoDataType = .AttributedStringData
      row.info = UIFont.attributedFontAwesomeIconForName(attributesDelegate.iconName) ?? "No Icon"
      var pickerRow = DetailPickerRow()

      pickerRow.nilItemTitle = "No Icon"
      pickerRow.data = ((UIFont.fontAwesomeIconNames() as NSSet).allObjects as! [String]).sorted(<)
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
    }, forKey: RowKey.Icon)

    // Icon-Text order
    contentSection.addRow({
      var row = DetailButtonRow()
      row.name = "Order"
      row.info = attributesDelegate.iconTextOrder.JSONValue.capitalizedString

      var pickerRow = DetailPickerRow()
      pickerRow.data = TitleAttributes.IconTextOrderSpecification.all.map{$0.JSONValue}
      pickerRow.info = attributesDelegate.iconTextOrder.JSONValue
      pickerRow.titleForInfo = {($0 as! String).capitalizedString}
      pickerRow.didSelectItem = {
        if !self.didCancel {
          attributesDelegate.iconTextOrder = TitleAttributes.IconTextOrderSpecification(JSONValue: ($0 as! String))
          self.cellDisplayingPicker?.info = attributesDelegate.iconTextOrder.JSONValue.capitalizedString
          pickerRow.info = attributesDelegate.iconTextOrder.JSONValue
        }
      }

      row.detailPickerRow = pickerRow

      return row
    }, forKey: RowKey.Order)

    sections[SectionKey.Content] = contentSection

  }

  /** loadFontSection */
  private func loadFontSection() {

    let attributesDelegate = item as! TitleAttributesDelegate

    /*********************************************************************************
      Font Section
    *********************************************************************************/

    let fontSection = DetailSection(section: 1, title: "Font")


    // Font
    // TODO: Make font an editable field
    fontSection.addRow({
      var row = DetailLabelRow()
      row.name = "Font"
      row.info = attributesDelegate.font.fontDescriptor().postscriptName
      return row
    }, forKey: RowKey.Font)

    // Foreground color
    fontSection.addRow({
      var row = DetailColorRow()
      row.name = "Foreground Color"
      row.info = attributesDelegate.foregroundColor
      row.valueDidChange = { if let color = $0 as? UIColor { attributesDelegate.foregroundColor = color } }
      return row
    }, forKey: RowKey.ForegroundColor)

    // Background color
    fontSection.addRow({
      var row = DetailColorRow()
      row.name = "Background Color"
      row.info = attributesDelegate.backgroundColor
      row.valueDidChange = { attributesDelegate.backgroundColor = $0 as? UIColor }
      return row
    }, forKey: RowKey.BackgroundColor)

    sections[SectionKey.Font] = fontSection

  }

  /** loadStrokeSection */
  private func loadStrokeSection() {

    let attributesDelegate = item as! TitleAttributesDelegate

    /*********************************************************************************
      Stroke Section
    *********************************************************************************/

    let strokeSection = DetailSection(section: 2, title: "Stroke")

    // Stroke width - 0 = no change, positive float = stroke width, negative float = stroke and fill text
    strokeSection.addRow({
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
   }, forKey: RowKey.Width)

   strokeSection.addRow({
     var row = DetailSwitchRow()
     row.name = "Fill"
     row.info = attributesDelegate.strokeFill
     row.valueDidChange = { attributesDelegate.strokeFill = ($0 as! NSNumber).boolValue }
     return row
   }, forKey: RowKey.Fill)

    // Stroke color
    strokeSection.addRow({
      var row = DetailColorRow()
      row.name = "Color"
      row.info = attributesDelegate.strokeColor
      row.valueDidChange = { if let color = $0 as? UIColor { attributesDelegate.strokeColor = color } }
      return row
    }, forKey: RowKey.StrokeColor)

    sections[SectionKey.Stroke] = strokeSection

  }

  /** loadStyleSection */
  private func loadStyleSection() {

    let attributesDelegate = item as! TitleAttributesDelegate


    /*********************************************************************************
      Style Section
    *********************************************************************************/

    let styleSection = DetailSection(section: 4, title: "Style")

     // Obliqueness
    styleSection.addRow({
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
   }, forKey: RowKey.Obliqueness)

    // Text effect
    styleSection.addRow({
      var row = DetailSwitchRow()
      row.name = "Letterpress"
      row.info = attributesDelegate.textEffect != nil
      row.valueDidChange = { attributesDelegate.textEffect = ($0 as! NSNumber).boolValue ? "letterpress" : nil }
      return row
    }, forKey: RowKey.Letterpress)

    sections[SectionKey.Style] = styleSection

  }

  /** loadUnderlineSection */
  private func loadUnderlineSection() {

    let attributesDelegate = item as! TitleAttributesDelegate


    /*********************************************************************************
      Underline Section
    *********************************************************************************/

    let underlineSection = DetailSection(section: 5, title: "Underline")

    // underlineStyle
    underlineSection.addRow({
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
    }, forKey: RowKey.UnderlineStyle)

    // Underline color
    underlineSection.addRow({
      var row = DetailColorRow()
      row.name = "Color"
      row.info = attributesDelegate.underlineColor
      row.valueDidChange = { if let color = $0 as? UIColor { attributesDelegate.underlineColor = color } }
      return row
    }, forKey: RowKey.UnderlineColor)

    sections[SectionKey.Underline] = underlineSection

  }

  /** loadStrikethroughSection */
  private func loadStrikethroughSection() {

    let attributesDelegate = item as! TitleAttributesDelegate


    /*********************************************************************************
      Strikethrough Section
    *********************************************************************************/

    let strikethroughSection = DetailSection(section: 6, title: "Strikethrough")

    // Strikethrough style
    strikethroughSection.addRow({
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
    }, forKey: RowKey.StrikethroughStyle)

    // Strikethrough color
    strikethroughSection.addRow({
      var row = DetailColorRow()
      row.name = "Color"
      row.info = attributesDelegate.strikethroughColor
      row.valueDidChange = { if let color = $0 as? UIColor { attributesDelegate.strikethroughColor = color } }
      return row
    }, forKey: RowKey.StrikethroughColor)

    sections[SectionKey.Strikethrough] = strikethroughSection

  }

  /** loadParagraphStyleSection */
  private func loadParagraphStyleSection() {

    let attributesDelegate = item as! TitleAttributesDelegate

    /********************************************************************************
      Paragraph Style Section
    ********************************************************************************/

    let paragraphStyleSection = DetailSection(section: 7, title: "Paragraph Style")

    // Alignment
    paragraphStyleSection.addRow({
      var row = DetailButtonRow()
      row.name = "Alignment"
      row.info = attributesDelegate.alignment.JSONValue.titlecaseString

      var pickerRow = DetailPickerRow()
      pickerRow.data = NSTextAlignment.all.map{$0.JSONValue}
      pickerRow.info = attributesDelegate.alignment.JSONValue.titlecaseString
      pickerRow.didSelectItem = { [unowned pickerRow] in
        if !self.didCancel {
          attributesDelegate.alignment = NSTextAlignment(JSONValue: $0 as? String ?? "natural")
          self.cellDisplayingPicker?.info = attributesDelegate.alignment.JSONValue.titlecaseString
          pickerRow.info = $0
        }
      }

      row.detailPickerRow = pickerRow

      return row
    }, forKey: RowKey.Alignment)

    sections[SectionKey.ParagraphStyle] = paragraphStyleSection

  }

}
