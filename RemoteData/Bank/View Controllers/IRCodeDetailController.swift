//
//  IRCodeDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 9/26/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
import Foundation
import UIKit
import MoonKit

/**
The `IRCodeDetailController` is the view controller responsible for viewing and editing
the details for an `IRCode` model object. A valid `IRCode` conforms to the following
pieces of an iTach "sendir" command:

  …<frequency>,<repeat>,<offset>,<on1>,<off1>,<on2>,<off2>,…,<onN>,<offN>…

where…

-  N is less than 260 or a total of 520 numbers
-  <frequency> is |15000|15001|....|500000|
-  <repeat> is |1|2|....|50|
-  <offset> is |1|3|5|....|383|
-  <on1> is |1|2|...|65635|
-  <off1> is |1|2|...|65635|
*/
class IRCodeDetailController: BankItemDetailController {

  private struct SectionKey {
    static let Details = "Details"
  }

  private struct RowKey {
    static let Manufacturer = "Manufacturer"
    static let CodeSet      = "Code Set"
    static let Frequency    = "Frequency"
    static let Repeat       = "Repeat"
    static let Offset       = "Offset"
    static let OnOffPattern = "On-Off Pattern"
  }

  /** loadSections */
  override func loadSections() {
    super.loadSections()

    precondition(model is IRCode, "we should have been given an ircode")

    loadDetailsSection()

  }


  /** loadDetailsSection */
  private func loadDetailsSection() {

    let irCode = model as! IRCode
    let manufacturers = Manufacturer.findAllSortedBy("name",
                                           ascending: true,
                                             context: irCode.managedObjectContext!) as? [Manufacturer] ?? []
    let codeSets = sortedByName(irCode.manufacturer.codeSets)

    var section = DetailSection(section: 0)

    /// Manufacturer
    ////////////////////////////////////////////////////////////////////////////////

    section.addRow({
      var row = DetailButtonRow()
      row.name = "Manufacturer"
      row.info = irCode.manufacturer
//      row.valueDidChange = {
//        (item: AnyObject?) -> Void in
//        let moc = irCode.managedObjectContext!
//        moc.performBlock {
//          var manufacturer = item as? Manufacturer
//          if irCode.manufacturer != manufacturer { irCode.manufacturer = manufacturer }
//        }
//      }

      var pickerRow = DetailPickerRow()
      pickerRow.nilItemTitle = "No Manufacturer"
//      pickerRow.didSelectItem = {
//        if !self.didCancel {
//          irCode.manufacturer = $0 as? Manufacturer
//          self.updateDisplay()
//        }
//      }

      pickerRow.data = manufacturers
      pickerRow.info = irCode.manufacturer

      row.detailPickerRow = pickerRow

      return row
    }, forKey: RowKey.Manufacturer)

    /// Code Set
    ////////////////////////////////////////////////////////////////////////////////

    section.addRow({
      var row = DetailButtonRow()
      row.name = "Code Set"
      row.info = irCode.codeSet ?? "No Code Set"
      row.valueDidChange = {
        if let codeSet = $0 as? IRCodeSet {
          if irCode.codeSet != codeSet {
            irCode.codeSet = codeSet
          }
        }
      }

      var pickerRow = DetailPickerRow()
      pickerRow.didSelectItem = { if !self.didCancel { if let codeSet = $0 as? IRCodeSet { irCode.codeSet = codeSet } } }
      pickerRow.data = codeSets
      pickerRow.info = irCode.codeSet

      row.detailPickerRow = pickerRow

      return row
    }, forKey: RowKey.CodeSet)

    /// Frequency
    ////////////////////////////////////////////////////////////////////////////////

    section.addRow({
      var row = DetailTextFieldRow()
      row.name = "Frequency"
      row.info = NSNumber(longLong: irCode.frequency)
      row.infoDataType = .LongLongData(15000...500000)
      row.inputType = .Integer
      row.valueDidChange = { if let i = ($0 as? NSNumber)?.longLongValue { irCode.frequency = i } }
      return row
    }, forKey: RowKey.Frequency)

    /// Repeat
    ////////////////////////////////////////////////////////////////////////////////

    section.addRow({
      var row = DetailTextFieldRow()
      row.name = "Repeat"
      row.info = NSNumber(longLong: irCode.frequency)
      row.infoDataType = .IntData(1...50)
      row.inputType = .Integer
      row.valueDidChange = { if let i = ($0 as? NSNumber)?.shortValue { irCode.repeatCount = i } }
      return row
    }, forKey: RowKey.Repeat)

    /// Offset
    ////////////////////////////////////////////////////////////////////////////////

    section.addRow({
      var row = DetailStepperRow()
      row.name = "Offset"
      row.stepperMinValue = 1
      row.stepperMaxValue = 383
      row.stepperStepValue = 2
      row.infoDataType = .IntData(1...383)
      row.stepperWraps = false
      row.info = NSNumber(short: irCode.offset)
      row.valueDidChange = { if let i = ($0 as? NSNumber)?.shortValue { irCode.offset = i } }

      return row
    }, forKey: RowKey.Offset)

    /// On-Off Pattern
    ////////////////////////////////////////////////////////////////////////////////

    section.addRow({
      var row = DetailTextViewRow()
      row.name = "On-Off Pattern"
      row.info = irCode.onOffPattern
      row.valueIsValid = {
        if let text = $0 as? NSString {
          let trimmedText = text.stringByTrimmingWhitespace()
          return trimmedText.length == 0 || IRCode.isValidOnOffPattern(trimmedText)
        }
        return true
      }
      row.valueDidChange = {
        if let text = $0 as? String {
          if let compressedText = IRCode.compressedOnOffPatternFromPattern(text.stringByTrimmingWhitespace()) {
            irCode.onOffPattern = compressedText
          }
        }
      }
      return row
    }, forKey: RowKey.OnOffPattern)

    sections[SectionKey.Details] = section
  }

}
