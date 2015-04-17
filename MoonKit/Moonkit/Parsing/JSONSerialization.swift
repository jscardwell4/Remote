//
//  JSONSerializationRedux.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/3/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

public class JSONSerialization {

  /**
  JSONFromObject:options:

  :param: object AnyObject
  :param: options WriteOptions = .None

  :returns: String
  */
/*
  public class func JSONFromObject(object: AnyObject?, options: WriteOptions = .None) -> String? {
    // TODO: Add options support

    var json: String?
    var weakStringFromObject: ((AnyObject, Int) -> String)?

    let stringFromObject: (AnyObject, Int) -> String =
    {(object, depth) in

      let indent = " " * (depth * 4)
      var string = indent

      if let array = object as? NSArray {

        string += "["
        if let comment = array.comment { string += " \(comment)" }

        let objectCount = array.count

        for var i = 0; i < objectCount; i++ {

          var valueString = weakStringFromObject!(array[i], depth + 1).stringByTrimmingTrailingWhitespace()
          string += "\n\(valueString)"

          if i + 1 < objectCount { string += "," }
          if let comment = (array[i] as! NSObject).comment { string += comment }

        }

        if objectCount > 0 { string += "\n\(indent)" }

        string += "]"

      }

      else if let dict = object as? NSDictionary {

        string += "{"


        if let comment = dict.comment { string += comment }

        let keys = dict.allKeys
        let keyCount = keys.count

        for var i = 0; i < keyCount; i++ {

          let key: AnyObject = keys[i]
          let value: AnyObject = dict[key as! NSCopying]!
          let keyString = weakStringFromObject!(key, depth + 1)
          let valueString = weakStringFromObject!(value, depth + 1).stringByTrimmingWhitespace()

          string += "\n\(keyString): \(valueString)"

          if i + 1 < keyCount { string += "," }

          if let comment = (value as! NSObject).comment { string += comment }

        }

        if keyCount > 0 { string += "\n\(indent)" }

        string += "}"

      }

      else if let number = object as? NSNumber {
        if number === kCFBooleanFalse || number === kCFBooleanTrue { string += number.boolValue ? "true" : "false" }
        else { string += "\(number)" }
      }

      else if let nullObject = object as? NSNull { string += "null" }

      else if let stringObject = object as? NSString { string += "\"\(stringObject.stringByEscapingControlCharacters())\"" }

      return string

    }

    weakStringFromObject = stringFromObject

    if let obj: AnyObject = object where NSJSONSerialization.isValidJSONObject(obj) { json = stringFromObject(obj, 0) }
    json?.extend("\n")

    return json

  }
*/

  /**
  objectByParsingString:options:error:

  :param: string String
  :param: options JSONSerializationReadOptions = .None
  :param: error NSErrorPointer = nil

  :returns: AnyObject?
  */
  public class func objectByParsingString(string: String?,
                                  options: ReadOptions = .None,
                                    error: NSErrorPointer = nil) -> JSONValue?
  {
    if string == nil { return nil }
    var object: JSONValue? // Our return object

    // Create the parser with the provided string
    let parser = JSONParser(string: string!)
    object = parser.parse(error: error)

    // Inflate key paths
    if isOptionSet(options, ReadOptions.InflateKeypaths) { object = object?.inflatedValue }

    return object
  }


  /**
  This method calls `objectByParsingString:options:error` with the content of the specified file after attempting to replace
  any '<@include file/to/include.json>' directives with their respective file content.

  :param: filePath String
  :param: options JSONSerializationReadOptions = .None
  :param: error NSErrorPointer = nil

  :returns: JSONValue?
  */
  public class func objectByParsingFile(filePath: String, options: ReadOptions = .None, error: NSErrorPointer = nil) -> JSONValue? {

    var localError: NSError?      // So we can intercept errors before passing them along to caller

    // Create a block for wrapping an underlying error
    let handledError: (Int) -> Bool = {
      if localError == nil { return false }
      if error != nil {
        error.memory = NSError(domain: "MSJSONSerializationErrorDomain",
                               code: $0,
                               underlyingErrors: [localError!])
      }
      return true
    }

    // Get the contents of the file to parse
    if var string = String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: &localError)
      where !handledError(NSFileReadUnknownError)
    {
      // Look for include entries in the file-loaded string
      let directory = filePath.stringByDeletingLastPathComponent
      while parseIncludeDirectives(&string, directory: directory, error: &localError) > 0 { continue }

      return handledError(NSFileReadUnknownError) ? nil : objectByParsingString(string, options: options, error: error)

    }

    return nil

  }

  private struct IncludeDirective {
    let fileName: String
    let placeholderValues: [String:String]
    init?(_ string: String) {
      if let capturedString = "<@include\\s+([^>]+)>" /~ (string, 1) {
        var components = ",".split(capturedString)
        if components.count > 0 {
          let f = components.removeAtIndex(0)
          fileName = f.hasSuffix(".json") ? f : f + ".json"
          placeholderValues = Dictionary(components.compressedMap({let kv = "=".split($0); return kv.count == 2 ? disperse2(kv) : nil}))
        } else {
          fileName = ""
          placeholderValues = [:]
          return nil
        }
      } else {
        fileName = ""
        placeholderValues = [:]
        return nil
      }
    }
  }

  private static var includeCache: [String:String] = [:]

  /**
  Look for "<@include FileName.json>" directives in the specified string and attempt to replace with file's content

  :param: string String
  :param: directory String
  :param: error NSErrorPointer

  :returns: Int The number of directives replaced or -1 if a replacement fails
  */
  private static func parseIncludeDirectives(inout string: String, directory: String, error: NSErrorPointer) -> Int {
    let includePattern = ~/"<@include ([^>]+)>"
    var offset = 0 // Holds the over/under from making substitutions in string
    var includeCount = 0

    // Iterate through matches for pattern
    for range in compressed(string.rangesForCapture(0, byMatching: includePattern)) {

      includeCount++

      let adjustedRange = range + offset

      if let directive = IncludeDirective(string[adjustedRange]) {
        var text: String?
        if let t = includeCache[directive.fileName] { text = t }
        else if let t = String(contentsOfFile: "\(directory)/\(directive.fileName)", encoding: NSUTF8StringEncoding, error: error) {
          includeCache[directive.fileName] = t
          text = t
        }

        if text != nil {
          for (placeholder, value) in directive.placeholderValues {
            text = text!.stringByReplacingOccurrencesOfString("<#\(placeholder)#>", withString: value)
          }

          // Replace include directive with the text
          let prefix = string[0..<adjustedRange.startIndex]
          let suffix = string[adjustedRange.endIndex..<string.length]
          string = prefix + text! + suffix
          offset += text!.length - count(range) // Update `offset`

        } else { return -1 }
      } else { return -1 }
    }
    return includeCount
  }

}

// Mark - Read/Write options type definitions
extension JSONSerialization {

  /** Enumeration for read format options */
  public struct ReadOptions: RawOptionSetType {

    public var rawValue: UInt = 0

    public init(rawValue: UInt) { self.rawValue = rawValue }
    public init(nilLiteral: Void) { self = ReadOptions.None }

    public static var None            : ReadOptions = ReadOptions(rawValue: 0b0)
    public static var InflateKeypaths : ReadOptions = ReadOptions(rawValue: 0b1)

    public static var allZeros        : ReadOptions { return None }

  }

  /** Option set for write format options */
  public struct WriteOptions: RawOptionSetType {

    public var rawValue: UInt = 0

    public init(rawValue: UInt) { self.rawValue = rawValue }
    public init(nilLiteral: Void) { self.rawValue = 0 }

    static var None                          : WriteOptions = WriteOptions(rawValue: 0b0000_0000_0000_0000)
    static var PreserveWhitespace            : WriteOptions = WriteOptions(rawValue: 0b0000_0000_0000_0001)
    static var CreateKeypaths                : WriteOptions = WriteOptions(rawValue: 0b0000_0000_0000_0010)
    static var KeepComments                  : WriteOptions = WriteOptions(rawValue: 0b0000_0000_0000_0100)
    static var IndentByDepth                 : WriteOptions = WriteOptions(rawValue: 0b0000_0000_0000_1000)
    static var KeepOneLiners                 : WriteOptions = WriteOptions(rawValue: 0b0000_0000_0001_0000)
    static var ForceOneLiners                : WriteOptions = WriteOptions(rawValue: 0b0000_0000_0010_0000)
    static var BreakAfterLeftSquareBracket   : WriteOptions = WriteOptions(rawValue: 0b0000_0000_0100_0000)
    static var BreakBeforeRightSquareBracket : WriteOptions = WriteOptions(rawValue: 0b0000_0000_1000_0000)
    static var BreakInsideSquareBrackets     : WriteOptions = WriteOptions(rawValue: 0b0000_0000_1100_0000)
    static var BreakAfterLeftCurlyBracket    : WriteOptions = WriteOptions(rawValue: 0b0000_0001_0000_0000)
    static var BreakBeforeRightCurlyBracket  : WriteOptions = WriteOptions(rawValue: 0b0000_0010_0000_0000)
    static var BreakInsideCurlyBrackets      : WriteOptions = WriteOptions(rawValue: 0b0000_0011_0000_0000)
    static var BreakAfterComma               : WriteOptions = WriteOptions(rawValue: 0b0000_0100_0000_0000)
    static var BreakBetweenColonAndArray     : WriteOptions = WriteOptions(rawValue: 0b0000_1000_0000_0000)
    static var BreakBetweenColonAndObject    : WriteOptions = WriteOptions(rawValue: 0b0001_0000_0000_0000)
    
    public static var allZeros               : WriteOptions { return WriteOptions.None }
  }
  
}
