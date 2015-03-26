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
final public class IRCode: EditableModelObject {
  
  @NSManaged public var frequency: Int64
  @NSManaged public var offset: Int16
  @NSManaged public var onOffPattern: String?
  @NSManaged public var prontoHex: String?
  @NSManaged public var repeatCount: Int16
  @NSManaged public var setsDeviceInput: Bool
  @NSManaged public var device: ComponentDevice!
  @NSManaged public var sendCommands: NSSet
  @NSManaged public var codeSet: IRCodeSet

  public var manufacturer: Manufacturer { return codeSet.manufacturer }

//  public typealias CollectionType = IRCodeSet
//  public var collection: CollectionType? { get { return codeSet } set { if newValue != nil { codeSet = newValue! } } }

  /**
  isValidOnOffPattern:

  :param: pattern String

  :returns: Bool
  */
  public class func isValidOnOffPattern(pattern: String) -> Bool { return compressedOnOffPatternFromPattern(pattern) != nil }

  /**
  compressedOnOffPatternFromPattern:

  :param: pattern String

  :returns: String?
  */
  public class func compressedOnOffPatternFromPattern(pattern: String) -> String? {

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
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forKey: "category")
    if let frequency = data["frequencey"] as? NSNumber { self.frequency = frequency.longLongValue }
    if let offset = data["offset"] as? NSNumber { self.offset = offset.shortValue }
    if let repeatCount = data["repeatCount"] as? NSNumber { self.repeatCount = repeatCount.shortValue }
    if let onOffPattern = data["on-off-pattern"] as? String { self.onOffPattern = onOffPattern }
  }

}

extension IRCode: MSJSONExport {

  override public func JSONDictionary() -> MSDictionary {

    let dictionary = super.JSONDictionary()

    appendValueForKeyPath("device.commentedUUID", forKey: "device", toDictionary: dictionary)
    appendValue(codeSet.index.rawValue, forKey: "code-set.index", ifNotDefault: false, toDictionary: dictionary)
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

extension IRCode: PathIndexedModel {
  public var pathIndex: PathModelIndex { return codeSet.pathIndex + "\(name)" }

  /**
  modelWithIndex:context:

  :param: index PathModelIndex
  :param: context NSManagedObjectContext

  :returns: IRCode?
  */
  public static func modelWithIndex(index: PathModelIndex, context: NSManagedObjectContext) -> IRCode? {
    if index.count != 3 { return nil }
    let (manufacturerName, codeSetName, codeName) = disperse3(index.pathComponents)
    if let codeSet = IRCodeSet.modelWithIndex([manufacturerName, codeSetName], context: context) {
      return findFirst(codeSet.codes, {$0.name == codeName})
    } else { return nil }
  }
  
}
