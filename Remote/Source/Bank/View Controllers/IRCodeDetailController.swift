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

  var codeSets: [IRCodeSet] = [] { didSet { codeSets.sort{$0.0.name < $0.1.name} } }

  /**
  initWithItem:editing:

  :param: item BankableModelObject
  :param: editing Bool
  */
  required init?(item: BankDisplayItemModel) {
    super.init(item: item)
    precondition(item is IRCode, "we should have been given an ircode")

    codeSets = irCode.manufacturer.codeSets.allObjects as? [IRCodeSet] ?? []

      let section = BankItemDetailSection(sectionNumber: 0, createRows: {

      /// Manufacturer
      ////////////////////////////////////////////////////////////////////////////////

      let manufacturerRow = BankItemDetailRow(identifier: .TextField, isEditable: true, configureCell: {
        (cell: BankItemCell) -> Void in
          cell.name = "Manufacturer"
          cell.info = self.irCode.manufacturer
          cell.pickerNilSelectionTitle = "No Manufacturer"
          cell.changeHandler = {
            (item: NSObject?) -> Void in
            let moc = self.irCode.managedObjectContext!
            moc.performBlock {
              var newManufacturer: Manufacturer?

              if let manufacturer = item as? Manufacturer { newManufacturer = manufacturer }
              else if let manufacturerName = item as? String {
                newManufacturer = self.manufacturers.filter{$0.name == manufacturerName}.first
                if newManufacturer == nil && manufacturerName != "No Manufacturer" {
                    newManufacturer = Manufacturer.manufacturerWithName(manufacturerName, context: moc)
                    self.manufacturers.append(newManufacturer!)
                    sortByName(&(self.manufacturers))
                }
              }
              if self.irCode.manufacturer != newManufacturer { self.irCode.manufacturer = newManufacturer }
            }
          }

          cell.pickerSelectionHandler = {
            self.irCode.manufacturer = $0 as? Manufacturer
            self.updateDisplay()
          }

          cell.pickerData = self.manufacturers
          cell.pickerSelection = self.irCode.manufacturer
      })

      /// Code Set
      ////////////////////////////////////////////////////////////////////////////////

      let codeSetRow = BankItemDetailRow(identifier: .TextField, isEditable: true, configureCell: {
        (cell: BankItemCell) -> Void in
          cell.name = "Code Set"
          cell.info = self.irCode.codeSet ?? "No Code Set"
          cell.validationHandler = {($0 as? NSString)?.length > 0}
          cell.changeHandler = {
            if let codeSet = $0 as? IRCodeSet {
              if self.irCode.codeSet != codeSet {
                self.irCode.codeSet = codeSet
                if self.codeSets ∌ codeSet {
                  self.codeSets.append(codeSet)
                  sortByName(&self.codeSets)
                }
              }
            }
          }
          cell.pickerSelectionHandler = { self.irCode.codeSet = $0 as? IRCodeSet }
          cell.pickerData = self.codeSets
          cell.pickerSelection = self.irCode.codeSet
      })

      /// Frequency
      ////////////////////////////////////////////////////////////////////////////////

      let frequencyRow = BankItemDetailRow(identifier: .TextField, isEditable: true, configureCell: {
        (cell: BankItemCell) -> Void in
          cell.name = "Frequency"
          cell.info = NSNumber(longLong: self.irCode.frequency)
          cell.infoDataType = .LongLongData(15000...500000)
          cell.shouldUseIntegerKeyboard = true
          cell.changeHandler = { if let i = ($0 as? NSNumber)?.longLongValue { self.irCode.frequency = i } }
      })

      /// Repeat
      ////////////////////////////////////////////////////////////////////////////////

      let repeatRow = BankItemDetailRow(identifier: .TextField, isEditable: true, configureCell: {
        (cell: BankItemCell) -> Void in
          cell.name = "Repeat"
          cell.info = NSNumber(short: self.irCode.repeatCount)
          cell.infoDataType = .IntData(1...50)
          cell.shouldUseIntegerKeyboard = true
          cell.changeHandler = { if let i = ($0 as? NSNumber)?.shortValue { self.irCode.repeatCount = i } }
      })

      /// Offset
      ////////////////////////////////////////////////////////////////////////////////

      let offsetRow = BankItemDetailRow(identifier: .Stepper, isEditable: true, configureCell: {
        (cell: BankItemCell) -> Void in
          cell.name = "Offset"
          cell.stepperMinValue = 1
          cell.stepperMaxValue = 383
          cell.stepperStepValue = 2
          cell.infoDataType = .IntData(1...383)
          cell.stepperWraps = false
          cell.info = NSNumber(short: self.irCode.offset)
          cell.changeHandler = { if let i = ($0 as? NSNumber)?.shortValue { self.irCode.offset = i } }
      })

      /// On-Off Pattern
      ////////////////////////////////////////////////////////////////////////////////

      let onOffPatternRow = BankItemDetailRow(identifier: .TextView, isEditable: true, configureCell: {
        (cell: BankItemCell) -> Void in
          cell.name = "On-Off Pattern"
          cell.info = self.irCode.onOffPattern
          cell.validationHandler = {
            if let text = $0 as? NSString {
              let trimmedText = text.stringByTrimmingWhitespace()
              return trimmedText.length == 0 || IRCode.isValidOnOffPattern(trimmedText)
            }
            return true
          }
          cell.changeHandler = {
            if let text = $0 as? String {
              if let compressedText = IRCode.compressedOnOffPatternFromPattern(text.stringByTrimmingWhitespace()) {
                self.irCode.onOffPattern = compressedText
              }
            }
          }
      })

        return [manufacturerRow, codeSetRow, frequencyRow, repeatRow, offsetRow, onOffPatternRow]
    })


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
  override init?(style: UITableViewStyle) { super.init(style: style) }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }


}
