//
//  IRCode.swift
//  Remote
//
//  Created by Jason Cardwell on 9/30/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(IRCode)
final class IRCode: IndexedEditableModelObject, ModelCategoryItem {
  
  @NSManaged var frequency: Int64
  @NSManaged var offset: Int16
  @NSManaged var onOffPattern: String?
  @NSManaged var prontoHex: String?
  @NSManaged var repeatCount: Int16
  @NSManaged var setsDeviceInput: Bool
  @NSManaged var device: ComponentDevice!
  @NSManaged var sendCommands: NSSet
  @NSManaged var codeSet: IRCodeSet

  var manufacturer: Manufacturer { return codeSet.manufacturer }

  typealias CategoryType = IRCodeSet
  var category: CategoryType? { get { return codeSet } set { if newValue != nil { codeSet = newValue! } } }

  override var index: ModelIndex { return codeSet.index + "\(name)" }

  /**
  modelWithIndex:context:

  :param: index ModelIndex
  :param: context NSManagedObjectContext

  :returns: IRCode?
  */
  override class func modelWithIndex(index: ModelIndex, context: NSManagedObjectContext) -> IRCode? {
    return Manufacturer.itemWithIndex(index, context: context)
  }

  /**
  isValidOnOffPattern:

  :param: pattern String

  :returns: Bool
  */
  class func isValidOnOffPattern(pattern: String) -> Bool { return compressedOnOffPatternFromPattern(pattern) != nil }

  /**
  compressedOnOffPatternFromPattern:

  :param: pattern String

  :returns: String?
  */
  class func compressedOnOffPatternFromPattern(pattern: String) -> String? {

    let max: Int32 = 65635

    var compressed = ""
    let scanner = NSScanner(string: pattern)
    scanner.caseSensitive = true
    scanner.charactersToBeSkipped = NSCharacterSet.whitespaceAndNewlineCharacterSet()

    let availableCompressionCharacters = NSMutableCharacterSet(charactersInString:"")
    let commaCharacterSet = NSCharacterSet(charactersInString:",")
    let compressionCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    var compressionIndex = 0

    while !scanner.atEnd {
      var scannedCompressionCharacters: NSString?
      if scanner.scanCharactersFromSet(availableCompressionCharacters, intoString: &scannedCompressionCharacters) {
        compressed += scannedCompressionCharacters! as String
      } else {
        var on: Int32 = 0, off: Int32 = 0
        if !scanner.scanInt(&on) || on <= 0 || on > max { break }
        if !scanner.scanCharactersFromSet(commaCharacterSet, intoString: nil) { break }
        if !scanner.scanInt(&off) || off <= 0 || off > max { break }

        if compressionIndex < compressionCharacters.length {
          availableCompressionCharacters.addCharactersInString(compressionCharacters[compressionIndex..<compressionIndex + 1])
        }
        if compressed.numberOfMatchesForRegEx("^.*[0-9]$") > 0 { compressed += "," }
        compressed += "\(on),\(off)"
        //TODO: I don't think I actually did any compressing for the output string
      }
    }

    return scanner.atEnd ? compressed : nil
  }

  /**
  updateWithData:

  :param: data [String AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forKey: "category")
    if let frequency = data["frequencey"] as? NSNumber { self.frequency = frequency.longLongValue }
    if let offset = data["offset"] as? NSNumber { self.offset = offset.shortValue }
    if let repeatCount = data["repeatCount"] as? NSNumber { self.repeatCount = repeatCount.shortValue }
    if let onOffPattern = data["on-off-pattern"] as? String { self.onOffPattern = onOffPattern }
  }

}

extension IRCode: MSJSONExport {

  override func JSONDictionary() -> MSDictionary {

    let dictionary = super.JSONDictionary()

    appendValueForKeyPath("device.commentedUUID", forKey: "device", toDictionary: dictionary)
    appendValue(codeSet.index.description, forKey: "code-set.index", ifNotDefault: false, toDictionary: dictionary)
    appendValueForKey("setsDeviceInput", toDictionary: dictionary)
    appendValueForKey("repeatCount", toDictionary: dictionary)

    appendValueForKey("offset", toDictionary: dictionary)
    appendValueForKey("frequency", toDictionary: dictionary)

    appendValue(onOffPattern, forKey: "on-off-pattern", toDictionary: dictionary)
    appendValue(prontoHex,    forKey: "pronto-hex", toDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()

    return dictionary;
  }
}
