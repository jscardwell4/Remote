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

  var irCode: IRCode { return item as IRCode }

  lazy var manufacturers: [Manufacturer] = Manufacturer.findAllSortedBy("name", ascending: true) as? [Manufacturer] ?? []

  var codesets: [IRCodeSet] = [] { didSet { codesets.sort{$0.0.name < $0.1.name} } }

  /**
  initWithItem:editing:

  :param: item BankableModelObject
  :param: editing Bool
  */
  required init?(item: BankDisplayItemModel, editing: Bool) {
    super.init(item: item, editing: editing)
    precondition(item is IRCode, "we should have been given an ircode")

    codesets = irCode.manufacturer.codeSets.allObjects as? [IRCodeSet] ?? []

    // section 0 - row 0: manufacturer
    let manufacturerRow = Row(identifier: .TextField, isEditable: true, configureCell: {
      $0.name = "Manufacturer"
      $0.info = self.irCode.manufacturer
      $0.pickerNilSelectionTitle = "No Manufacturer"
      $0.validationHandler = {($0.info as NSString).length > 0}
      $0.changeHandler = {[unowned self] c in

        var newManufacturer: Manufacturer?

        if let manufacturer = c.info as? Manufacturer { newManufacturer = manufacturer }
        else if let manufacturerName = c.info as? String {
          newManufacturer = self.manufacturers.filter{$0.name == manufacturerName}.first
          if newManufacturer == nil && manufacturerName != "No Manufacturer" {
              newManufacturer = Manufacturer.manufacturerWithName(manufacturerName, context: self.irCode.managedObjectContext!)
              self.manufacturers.append(newManufacturer!)
              self.manufacturers.sort{$0.0.name < $0.1.name}
          }
        }
        if self.irCode.manufacturer != newManufacturer { self.irCode.manufacturer = newManufacturer }
      }

      $0.pickerSelectionHandler = {
        self.irCode.manufacturer = $0 as? Manufacturer
        self.updateDisplay()
      }

      $0.pickerData = self.manufacturers
      $0.pickerSelection = self.irCode.manufacturer
    })

    // section 0 - row 1: codeset
    let codesetRow = Row(identifier: .TextField, isEditable: true, configureCell: {
      $0.name = "Code Set"
      $0.info = self.irCode.codeSet ?? "No Code Set"
      $0.validationHandler = {($0.info as NSString).length > 0}
      $0.changeHandler = {[unowned self] c in
        if let codeSet = c.info as? IRCodeSet {
          if self.irCode.codeSet != codeSet {
            self.irCode.codeSet = codeSet
            if self.codesets ∌ codeSet {
              self.codesets.append(codeSet)
              self.codesets.sort{$0.0.name < $0.1.name}
            }
          }
        }
      }
      $0.pickerSelectionHandler = {[unowned self] pickerSelection in
        self.irCode.codeSet = pickerSelection as? IRCodeSet
      }
      $0.pickerData = self.codesets
      $0.pickerSelection = self.irCode.codeSet
    })

    // section 0 - row 2: frequency
    let frequencyRow = Row(identifier: .TextField, isEditable: true, configureCell: {
      $0.name = "Frequency"
      $0.info = NSNumber(longLong: self.irCode.frequency)
      $0.infoDataType = .LongLongData(15000...500000)
      $0.shouldUseIntegerKeyboard = true
      $0.changeHandler = {[unowned self] c in if let i = (c.info as? NSNumber)?.longLongValue { self.irCode.frequency = i } }
    })

    // section 0 - row 3: repeat
    let repeatRow = Row(identifier: .TextField, isEditable: true, configureCell: {
      $0.name = "Repeat"
      $0.info = NSNumber(short: self.irCode.repeatCount)
      $0.infoDataType = .IntData(1...50)
      $0.shouldUseIntegerKeyboard = true
      $0.changeHandler = {[unowned self] c in if let i = (c.info as? NSNumber)?.shortValue { self.irCode.repeatCount = i } }
    })

    // section 0 - row 4: offset
    let offsetRow = Row(identifier: .Stepper, isEditable: true, configureCell: {
      $0.name = "Offset"
      $0.stepperMinValue = 1
      $0.stepperMaxValue = 383
      $0.stepperStepValue = 2
      $0.infoDataType = .IntData(1...383)
      $0.stepperWraps = false
      $0.info = NSNumber(short: self.irCode.offset)
      $0.changeHandler = {[unowned self] c in if let i = (c.info as? NSNumber)?.shortValue { self.irCode.offset = i } }
    })

    // section 0 - row 5: on-off pattern
    let onOffPatternRow = Row(identifier: .TextView, isEditable: true, configureCell: {
      $0.name = "On-Off Pattern"
      $0.info = self.irCode.onOffPattern
      $0.validationHandler = { (c) -> Bool in
        if let text = c.info as? NSString {
          let trimmedText = text.stringByTrimmingWhitespace()
          return trimmedText.length == 0 || IRCode.isValidOnOffPattern(trimmedText)
        }
        return true
      }
      $0.changeHandler = {[unowned self] c in
        if let text = c.info as? String {
          if let compressedText = IRCode.compressedOnOffPatternFromPattern(text.stringByTrimmingWhitespace()) {
            self.irCode.onOffPattern = compressedText
          }
        }
      }
    })

    sections = [Section(title: nil, rows: [manufacturerRow, codesetRow, frequencyRow, repeatRow, offsetRow, onOffPatternRow])]
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
  override init?(style: UITableViewStyle) { super.init(style: style) }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }


}
