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
final public class IRCode: EditableModelObject, CollectedModel {

  @NSManaged public var frequency: Int64
  @NSManaged public var offset: Int16
  @NSManaged public var onOffPattern: String!
  @NSManaged public var prontoHex: String?
  @NSManaged public var repeatCount: Int16
  @NSManaged public var setsDeviceInput: Bool
  @NSManaged public var device: ComponentDevice?
  @NSManaged public var sendCommands: NSSet

  public var codeSet: IRCodeSet {
    get {
      willAccessValueForKey("codeSet")
      var codeSet = primitiveValueForKey("codeSet") as? IRCodeSet
      didAccessValueForKey("codeSet")
      if codeSet == nil {
        codeSet = IRCodeSet.defaultCollectionInContext(managedObjectContext!)
        setPrimitiveValue(codeSet, forKey: "codeSet")
      }
      return codeSet!
    }
    set {
      willChangeValueForKey("codeSet")
      setPrimitiveValue(newValue, forKey: "codeSet")
      didChangeValueForKey("codeSet")
    }
  }

  public var collection: ModelCollection? { return codeSet }

  public var manufacturer: Manufacturer { return codeSet.manufacturer }

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

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
//    updateRelationshipFromData(data, forAttribute: "codeSet")
    if let frequency = Int64(data["frequency"]) { self.frequency = frequency }
    if let offset = Int16(data["offset"]) { self.offset = offset }
    if let repeatCount = Int16(data["repeatCount"]) { self.repeatCount = repeatCount }
    if let onOffPattern = String(data["onOffPattern"]) { self.onOffPattern = onOffPattern }
  }

  override public var description: String {
    return "\(super.description)\n\t" + "\n\t".join(
      "code set = \(codeSet.index)",
      "device = \(toString(device?.name))",
      "sets device input = \(setsDeviceInput)",
      "frequency = \(frequency)",
      "offset = \(offset)",
      "repeat count = \(repeatCount)",
      "on-off pattern = \(onOffPattern)"
    )
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["device.index"] = device?.index.jsonValue
    obj["codeSet.index"] = codeSet.index.jsonValue
    obj["setsDeviceInput"] = setsDeviceInput.jsonValue
    obj["repeatCount"] = repeatCount.jsonValue
    obj["offset"] = offset.jsonValue
    obj["frequency"] = frequency.jsonValue
    obj["onOffPattern"] = onOffPattern?.jsonValue
    obj["prontoHex"] = prontoHex?.jsonValue
    return obj.jsonValue
  }

  public override var pathIndex: PathIndex { return codeSet.pathIndex + indexedName }

  /**
  modelWithIndex:context:

  :param: index PathIndex
  :param: context NSManagedObjectContext

  :returns: IRCode?
  */
  public override static func modelWithIndex(index: PathIndex, context: NSManagedObjectContext) -> IRCode? {
    if index.count != 3 { return nil }
    if let codeSet = IRCodeSet.modelWithIndex(index[0...1], context: context) {
      return objectMatchingPredicate(∀"codeSet.uuid == '\(codeSet.uuid)' AND name == '\(index[2].pathDecoded)'", context: context)
    } else {
      MSLogVerbose("failed to locate code set for index '\(index[0...1])'")
      return nil
    }
  }

}
