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
class IRCode: BankableModelObject {

  @NSManaged var frequency: Int64
  @NSManaged var offset: Int16
  @NSManaged var onOffPattern: String?
  @NSManaged var prontoHex: String?
  @NSManaged var repeatCount: Int16
  @NSManaged var setsDeviceInput: Bool
  @NSManaged var codeSet: IRCodeSet!
  @NSManaged var device: ComponentDevice!
  @NSManaged var manufacturer: Manufacturer!
  @NSManaged var sendCommands: NSSet

  class func isValidOnOffPattern(pattern: String) -> Bool { return compressedOnOffPatternFromPattern(pattern) != nil }

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
        compressed += scannedCompressionCharacters!
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

  override func updateWithData(data: [NSObject : AnyObject]!) {
    super.updateWithData(data)
    codeSet      = IRCodeSet.importObjectFromData(data["codeset"] as? NSDictionary, context: managedObjectContext) ?? codeSet
    frequency    = (data["frequency"]      as? NSNumber)?.longLongValue ?? frequency
    offset       = (data["offset"]         as? NSNumber)?.shortValue    ?? offset
    repeatCount  = (data["repeat-count"]   as? NSNumber)?.shortValue    ?? repeatCount
    onOffPattern = data["on-off-pattern"]  as? NSString                 ?? onOffPattern
  }

//  override class func categoryType() -> BankDisplayItemCategory.Protocol { return IRCodeSet.self }

  class var rootCategory: Bank.RootCategory {
    return Bank.RootCategory(label: "IR Codes", icon: UIImage(named: "tv-remote")!, categories: [])
  }

  override class func isThumbnailable() -> Bool { return false }
  override class func isPreviewable()   -> Bool { return false }
  override class func isDetailable()    -> Bool { return true }
  override class func isEditable()      -> Bool { return true }

//  override class func detailControllerType() -> BankDetailController.Protocol { return IRCodeDetailController.self }

}

extension IRCode: MSJSONExport {

  override func JSONDictionary() -> MSDictionary! {

    let dictionary = super.JSONDictionary()

    safeSetValueForKeyPath("device.commentedUUID",  forKey: "device",  inDictionary: dictionary)
    safeSetValueForKeyPath("codeSet.commentedUUID", forKey: "codeset", inDictionary: dictionary)

    setIfNotDefault("setsDeviceInput", forKey: "sets-device-input", inDictionary: dictionary)
    setIfNotDefault("repeatCount",     forKey: "repeat-count",      inDictionary: dictionary)

    setIfNotDefault("offset",      inDictionary: dictionary)
    setIfNotDefault("frequency",   inDictionary: dictionary)

    safeSetValue(onOffPattern, forKey: "on-off-pattern", inDictionary: dictionary)
    safeSetValue(prontoHex,    forKey: "pronto-hex",     inDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()

    return dictionary;
  }
}
