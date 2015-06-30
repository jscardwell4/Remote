//
//  IRCode+Bank.swift
//  Remote
//
//  Created by Jason Cardwell on 5/16/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import DataModel
import MoonKit
import CoreData

extension IRCode: DelegateDetailable {
    func sectionIndexForController(controller: BankCollectionDetailController) -> BankModelDetailDelegate.SectionIndex {
      var sections: BankModelDetailDelegate.SectionIndex = [:]

      struct SectionKey {
        static let Details = "Details"
      }

      struct RowKey {
        static let Manufacturer = "Manufacturer"
        static let CodeSet      = "Code Set"
        static let Frequency    = "Frequency"
        static let Repeat       = "Repeat"
        static let Offset       = "Offset"
        static let OnOffPattern = "On-Off Pattern"
      }

      /** loadDetailsSection */
      func loadDetailsSection() {

        let irCode = self
        let manufacturers = Manufacturer.objectsInContext(irCode.managedObjectContext!,
                                                   sortBy: "name") as? [Manufacturer] ?? []
        let codeSets = sortedByName(irCode.manufacturer.codeSets)

        let section = BankCollectionDetailSection(section: 0)

        /// Manufacturer
        ////////////////////////////////////////////////////////////////////////////////

        section.addRow({
          let row = BankCollectionDetailButtonRow()
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

          row.nilItem = .NilItem(title: "No Manufacturer")
    //      row.didSelectItem = {
    //        if !self.didCancel {
    //          irCode.manufacturer = $0 as? Manufacturer
    //          self.updateDisplay()
    //        }
    //      }

          row.data = manufacturers
          row.info = irCode.manufacturer

          return row
        }, forKey: RowKey.Manufacturer)

        /// Code Set
        ////////////////////////////////////////////////////////////////////////////////

        section.addRow({
          let row = BankCollectionDetailButtonRow()
          row.name = "Code Set"
          row.info = irCode.codeSet ?? "No Code Set"
          row.valueDidChange = {
            if let codeSet = $0 as? IRCodeSet {
              if irCode.codeSet != codeSet {
                irCode.codeSet = codeSet
              }
            }
          }

          row.didSelectItem = { if !controller.didCancel { if let codeSet = $0 as? IRCodeSet { irCode.codeSet = codeSet } } }
          row.data = codeSets
          row.info = irCode.codeSet

          return row
        }, forKey: RowKey.CodeSet)

        /// Frequency
        ////////////////////////////////////////////////////////////////////////////////

        section.addRow({
          let row = BankCollectionDetailTextFieldRow()
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
          let row = BankCollectionDetailTextFieldRow()
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
          let row = BankCollectionDetailStepperRow()
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
          let row = BankCollectionDetailTextViewRow()
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

      loadDetailsSection()

      return sections
    }
}

// TODO: Fill out stubs for `FormCreatable`
extension IRCode: FormCreatable {

  /**
  creationForm:

  - parameter #text: NSManagedObjectContext

  - returns: Form
  */
  static func creationForm(context context: NSManagedObjectContext) -> Form {
    return Form(templates: [:])
  }

  /**
  createWithForm:context:

  - parameter form: Form
  - parameter context: NSManagedObjectContext

  - returns: Self?
  */
  static func createWithForm(form: Form, context: NSManagedObjectContext) -> Self? {
    return nil
  }

}