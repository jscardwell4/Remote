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

@objc(IRCodeDetailController)
class IRCodeDetailController: BankItemDetailController {

  var irCode: IRCode { return item as IRCode }

  lazy var manufacturers: [Manufacturer] = {
    var manufacturers: [Manufacturer] = []
    if let fetchedManufacturers = Manufacturer.findAllSortedBy("name", ascending: true) as? [Manufacturer] {
      manufacturers += fetchedManufacturers
    }
    return manufacturers
    }()

  var codesets: [IRCodeSet] = [] { didSet { codesets.sort{$0.0.name < $0.1.name} } }

  /**
  initWithItem:editing:

  :param: item BankableModelObject
  :param: editing Bool
  */
  required init(item: BankableModelObject, editing: Bool) {
    super.init(item: item, editing: editing)
    precondition(item is IRCode, "we should have been given an ircode")

    codesets = irCode.manufacturer.codeSets.allObjects as? [IRCodeSet] ?? []

    // section 0 - row 0: manufacturer
    let manufacturerRow = Row(identifier: .TextField, isEditable: true) {[unowned self] in
      $0.name = "Manufacturer"
      $0.info = self.irCode.manufacturer ?? "No Manufacturer"
      $0.validationHandler = {($0.info as NSString).length > 0}
      $0.changeHandler = {[unowned self] c in

        var newManufacturer: Manufacturer?

        if let manufacturer = c.info as? Manufacturer { newManufacturer = manufacturer }
        else if let manufacturerName = c.info as? String {
          newManufacturer = self.manufacturers.filter{$0.name == manufacturerName}.first
          if newManufacturer == nil &&  manufacturerName != "No Manufacturer" {
              newManufacturer = Manufacturer.manufacturerWithName(manufacturerName, context: self.irCode.managedObjectContext)
              self.manufacturers.append(newManufacturer!)
              self.manufacturers.sort{$0.0.name < $0.1.name}
          }
        }
        if self.irCode.manufacturer != newManufacturer { self.irCode.manufacturer = newManufacturer }
      }

      $0.pickerSelectionHandler = {[unowned self] c in
        if let selection = c.pickerSelection as? Manufacturer {
          if self.irCode.manufacturer != selection {
            self.irCode.manufacturer = selection
            self.updateDisplay()
          }
        } else {
          self.irCode.manufacturer = nil
          self.updateDisplay()
        }
      }

      $0.pickerData = self.manufacturers
      $0.pickerSelection = self.irCode.manufacturer
    }

    // section 0 - row 1: codeset
    let codesetRow = Row(identifier: .TextField, isEditable: true) {[unowned self] in
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
      $0.pickerSelectionHandler = {[unowned self] c in
        if let selection = c.pickerSelection as? IRCodeSet {
          self.irCode.codeSet = selection
        }
      }
      $0.pickerData = self.codesets
      $0.pickerSelection = self.irCode.codeSet
    }

    // section 0 - row 2: frequency
    let frequencyRow = Row(identifier: .TextField, isEditable: true) {[unowned self] in
      $0.name = "Frequency"
      $0.info = NSNumber(longLong: self.irCode.frequency)
      $0.shouldUseIntegerKeyboard = true
      $0.changeHandler = {[unowned self] c in self.irCode.frequency = (c.info as NSNumber).longLongValue}
    }

    // section 0 - row 3: repeat
    let repeatRow = Row(identifier: .TextField, isEditable: true) {[unowned self] in
      $0.name = "Repeat"
      $0.info = NSNumber(short: self.irCode.repeatCount)
      $0.shouldUseIntegerKeyboard = true
      $0.changeHandler = {[unowned self] c in self.irCode.repeatCount = (c.info as NSNumber).shortValue}
    }

    // section 0 - row 4: offset
    let offsetRow = Row(identifier: .Stepper, isEditable: true) {[unowned self] in
      $0.name = "Offset"
      $0.stepperMinValue = 0
      $0.stepperMaxValue = 127
      $0.stepperWraps = false
      $0.info = NSNumber(short: self.irCode.offset)
      $0.changeHandler = {[unowned self] c in self.irCode.offset = (c.info as NSNumber).shortValue}
    }

    // section 0 - row 5: on-off pattern
    let onOffPatternRow = Row(identifier: .TextView, isEditable: true) {[unowned self] in
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
    }

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
  override init(style: UITableViewStyle) { super.init(style: style) }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }


}
