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
@objc(IRCodeDetailController)
class IRCodeDetailController: BankItemDetailController {

  var irCode: IRCode { return model as IRCode }

  lazy var manufacturers: [Manufacturer] = Manufacturer.findAllSortedBy("name", ascending: true) as? [Manufacturer] ?? []

  var codeSets: [IRCodeSet] = [] { didSet { codeSets.sort{$0.0.name < $0.1.name} } }

  /**
  initWithItem:editing:

  :param: model BankableModelObject
  :param: editing Bool
  */
  override init(model: BankableModelObject) {
    super.init(model: model)
    precondition(model is IRCode, "we should have been given an ircode")

    codeSets = irCode.manufacturer.codeSets?.allObjects as? [IRCodeSet] ?? []

    var section = DetailSection(section: 0)

    /// Manufacturer
    ////////////////////////////////////////////////////////////////////////////////

    section.addRow {
      var row = DetailButtonRow()
      row.name = "Manufacturer"
      row.info = self.irCode.manufacturer
      // row.pickerNilSelectionTitle = "No Manufacturer"
      // row.valueDidChange = {
      //   (item: AnyObject?) -> Void in
      //   let moc = self.irCode.managedObjectContext!
      //   moc.performBlock {
      //     var newManufacturer: Manufacturer?

      //     if let manufacturer = item as? Manufacturer { newManufacturer = manufacturer }
      //     else if let manufacturerName = item as? String {
      //       newManufacturer = self.manufacturers.filter{$0.name == manufacturerName}.first
      //       if newManufacturer == nil && manufacturerName != "No Manufacturer" {
      //           newManufacturer = Manufacturer.manufacturerWithName(manufacturerName, context: moc)
      //           self.manufacturers.append(newManufacturer!)
      //           sortByName(&(self.manufacturers))
      //       }
      //     }
      //     if self.irCode.manufacturer != newManufacturer { self.irCode.manufacturer = newManufacturer }
      //   }
      // }

      // row.didSelectItem = {
      //   if !self.didCancel {
      //     self.irCode.manufacturer = $0 as? Manufacturer
      //     self.updateDisplay()
      //   }
      // }

      // row.pickerData = self.manufacturers
      // row.pickerSelection = self.irCode.manufacturer

      return row
    }

    /// Code Set
    ////////////////////////////////////////////////////////////////////////////////

    section.addRow {
      var row = DetailButtonRow()
      row.name = "Code Set"
      row.info = self.irCode.codeSet ?? "No Code Set"
      // row.valueIsValid = {($0 as? NSString)?.length > 0}
      // row.valueDidChange = {
      //   if let codeSet = $0 as? IRCodeSet {
      //     if self.irCode.codeSet != codeSet {
      //       self.irCode.codeSet = codeSet
      //       if self.codeSets ∌ codeSet {
      //         self.codeSets.append(codeSet)
      //         sortByName(&self.codeSets)
      //       }
      //     }
      //   }
      // }
      // row.didSelectItem = { if !self.didCancel { self.irCode.codeSet = $0 as? IRCodeSet } }
      // row.pickerData = self.codeSets
      // row.pickerSelection = self.irCode.codeSet

      return row
    }

    /// Frequency
    ////////////////////////////////////////////////////////////////////////////////

    section.addRow {
      var row = DetailTextFieldRow()
      row.name = "Frequency"
      row.info = NSNumber(longLong: self.irCode.frequency)
      row.infoDataType = .LongLongData(15000...500000)
      row.shouldUseIntegerKeyboard = true
      row.valueDidChange = { if let i = ($0 as? NSNumber)?.longLongValue { self.irCode.frequency = i } }
      return row
    }

    /// Repeat
    ////////////////////////////////////////////////////////////////////////////////

    section.addRow {
      var row = DetailTextFieldRow()
      row.name = "Repeat"
      row.info = NSNumber(longLong: self.irCode.frequency)
      row.infoDataType = .IntData(1...50)
      row.shouldUseIntegerKeyboard = true
      row.valueDidChange = { if let i = ($0 as? NSNumber)?.shortValue { self.irCode.repeatCount = i } }
      return row
    }

    /// Offset
    ////////////////////////////////////////////////////////////////////////////////

    section.addRow {
      var row = DetailStepperRow()
      row.name = "Offset"
      row.stepperMinValue = 1
      row.stepperMaxValue = 383
      row.stepperStepValue = 2
      row.infoDataType = .IntData(1...383)
      row.stepperWraps = false
      row.info = NSNumber(short: self.irCode.offset)
      row.valueDidChange = { if let i = ($0 as? NSNumber)?.shortValue { self.irCode.offset = i } }

      return row
    }

    /// On-Off Pattern
    ////////////////////////////////////////////////////////////////////////////////

    section.addRow {
      var row = DetailTextViewRow()
      row.name = "On-Off Pattern"
      row.info = self.irCode.onOffPattern
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
            self.irCode.onOffPattern = compressedText
          }
        }
      }
      return row
    }

    sections = [section]
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
