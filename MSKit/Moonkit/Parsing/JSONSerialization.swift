//
//  MSJSONSerialization.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/20/13.
//  Copyright (c) 2013 Jason Cardwell. All rights reserved.
//

import Foundation

public class JSONSerialization: NSObject {

  /**
  JSONFromObject:options:

  :param: object AnyObject
  :param: options WriteOptions.Raw

  :returns: String?
  */
  public class func JSONFromObject(object: AnyObject, options: WriteOptions.RawValue) -> String? {
    return JSONFromObject(object, options: WriteOptions.fromMask(options))
  }

	/**
	JSONFromObject:options:

	:param: object AnyObject
	:param: options WriteOptions = .None

	:returns: String
	*/
  class func JSONFromObject(object: AnyObject, options: WriteOptions = .None) -> String? {
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

		if NSJSONSerialization.isValidJSONObject(object) { json = stringFromObject(object, 0) }
		json?.extend("\n")

		return json

	}


	/**
	parseFile:options:error:

	:param: filePath String
	:param: options WriteOptions.Raw
	:param: error NSErrorPointer

	:returns: String?
	*/
	public class func parseFile(filePath: String, options: WriteOptions.RawValue, error: NSErrorPointer) -> String? {
		return parseFile(filePath, options: WriteOptions.fromMask(options), error: error)
	}

	/**
	parseFile:options:error:

	:param: filePath String
	:param: options JSONSerializationWriteOptions = .None
	:param: error NSErrorPointer = nil

	:returns: String?
	*/
	class func parseFile(filePath: String, options: WriteOptions = .None, error: NSErrorPointer = nil) -> String?	{

    var returnString: String?

		// Get the file's contents as a string
    var localError: NSError?
    let string = NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: &localError)

    if localError != nil /*MSHandleError(localError, message: "failed to create string from file")*/ || string == nil {
      if error != nil { error.memory = localError }
    }

    else { returnString = parseString(string! as String, options: options, error: error) }

    return returnString
	}

	/**
	parseString:options:error:

	:param: string String
	:param: options WriteOptions.Raw
	:param: error NSErrorPointer

	:returns: String?
	*/
	public class func parseString(string: String, options: WriteOptions.RawValue, error: NSErrorPointer) -> String? {
		return parseString(string, options: WriteOptions.fromMask(options), error: error)
	}


	/**
	parseString:options:error:

	:param: string String
	:param: options JSONSerializationWriteOptions = .None
	:param: error NSErrorPointer = nil

	:returns: String?
	*/
	class func parseString(string: String, options: WriteOptions = .None, error: NSErrorPointer = nil) -> String? {
    var json: String?
    if let object: AnyObject = objectByParsingString(string, error: error) { json = JSONFromObject(object, options: options) }
    return json
	}

	/**
	objectByParsingString:options:error:

	:param: string String
	:param: options ReadOptions.Raw
	:param: error NSErrorPointer

	:returns: AnyObject?
	*/
	public class func objectByParsingString(string: String, options: ReadOptions.RawValue, error: NSErrorPointer) -> AnyObject? {
		return objectByParsingString(string, options:(ReadOptions(rawValue: options) ?? .None), error: error)
	}

	/**
	objectByParsingString:options:error:

	:param: string String
	:param: options JSONSerializationReadOptions = .None
	:param: error NSErrorPointer = nil

	:returns: AnyObject?
	*/
	class func objectByParsingString(string: String, options: ReadOptions = .None, error: NSErrorPointer = nil) -> AnyObject? {

    var object: AnyObject? // Our return object

    // Create the parser with the provided string
    let parser = JSONParser(string: string)
    object = parser.parse(error: error)

    if options == .InflateKeypaths {
      if let container = object as? MSObjectContaining {
        if let dict = container as? MSDictionary {
          dict.inflate()
        }
        if var dicts = container.allObjectsOfKind(MSDictionary.self) as? [MSDictionary] {
          for dict in dicts { dict.inflate() }
//          dicts.apply{$0.inflate()}
        }
      }
    }

		return object
	}


	/**
	objectByParsingFile:options:error:

	:param: filePath String
	:param: options ReadOptions.Raw
	:param: error NSErrorPointer

	:returns: AnyObject?
	*/
	public class func objectByParsingFile(filePath: String, options: ReadOptions.RawValue, error: NSErrorPointer) -> AnyObject? {
    return objectByParsingFile(filePath, options: (ReadOptions(rawValue: options) ?? .None), error: error)
	}

	/**
	objectByParsingFile:options:error:

	:param: filePath String
	:param: options JSONSerializationReadOptions = .None
	:param: error NSErrorPointer = nil

	:returns: AnyObject?
	*/
	class func objectByParsingFile(filePath: String, options: ReadOptions = .None, error: NSErrorPointer = nil) -> AnyObject? {

    var returnObject: AnyObject?  // The object we will be passing back to the caller
    var localError: NSError?      // So we can intercept errors before passing them along to caller

    // Create a block for logging local errors and setting error pointer
    let handleError: (String) -> Bool = { s in
      if localError != nil /*MSHandleError(localError, message: $0)*/ {
        if error != nil { error.memory = localError }
        return true
      } else { return false }
    }

    // Get the contents of the file to parse
    if var string = NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: &localError) as? String {

      // If no error than we look for any "@include" statements
      if !handleError("failed to get file content for '\(filePath)") {

        // Look for include entries in the file-loaded string
        let pattern = ~/"<@include ([^>]+)>"

        // Get the path to the provided file's directory so we can use it when looking for include files
        let directory = filePath.stringByDeletingLastPathComponent

        var offset = 0 // Holds the over/under from making substitutions in string

        // Iterate through matches for pattern
        for match in pattern /…≈ string {

          // Make sure we have a valid range
          if var range = match {

            // Advance our range by the offset
            let 𝘥 = distance(range.startIndex, range.endIndex)
            let end = advance(range.startIndex, offset + 𝘥)
            let start = advance(range.startIndex, offset)

            range.endIndex = end
            range.startIndex = start
            let s = String.Space
            let r = NSRange(location: range.startIndex, length: distance(range.startIndex, range.endIndex))

            // Get the name of the file to include
            let substring = (string as NSString).substringWithRange(r)
            if let includeFile = pattern /~ (substring, 1) {

              // Create the file path by combining the directory with the name
              let includePath = "\(directory)/\(includeFile)"
              let includeText = NSString(contentsOfFile: includePath, encoding: NSUTF8StringEncoding, error: &localError) as? String

              // Move on to next if error
              if handleError("failed to get file content for include directive '\(includePath)'") || includeText == nil { continue }

              // Replace include directive with the text
              string.replaceRange(string.indexRangeFromIntRange(range), with: includeText!)

              // Update `offset`
              offset += includeText!.length - count(range)

            }

          }

        }

      }
      
      returnObject = objectByParsingString(string, options: options, error: error)

    }

    return returnObject

	}

  ////////////////////////////////////////////////////////////////////////////////
  /// MARK: - Enumeration for read format options
  ////////////////////////////////////////////////////////////////////////////////

  enum ReadOptions: Int { case None, InflateKeypaths }

  ////////////////////////////////////////////////////////////////////////////////
  /// MARK: - Enumeration for write format options
  ////////////////////////////////////////////////////////////////////////////////

  struct WriteOptions: RawOptionSetType {

    var rawValue: UInt = 0

    var boolValue: Bool { return rawValue != 0 }

    static var allZeros: WriteOptions { return WriteOptions.None }

    init(rawValue: UInt) { self.rawValue = rawValue }
    init(nilLiteral: Void) { self.rawValue = 0 }
    static func fromRaw(raw: UInt)      -> WriteOptions? { return self(rawValue: raw) }
    static func fromMask(raw: UInt)     -> WriteOptions  { return self(rawValue: raw) }
    static func convertFromNilLiteral() -> WriteOptions  { return self(rawValue: 0)   }

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

  }

}

func ==(lhs:JSONSerialization.WriteOptions, rhs:JSONSerialization.WriteOptions) -> Bool { return lhs.rawValue == rhs.rawValue }

func &(lhs:JSONSerialization.WriteOptions, rhs:JSONSerialization.WriteOptions) -> JSONSerialization.WriteOptions {
  return JSONSerialization.WriteOptions.fromMask(lhs.rawValue & rhs.rawValue)
}

func |(lhs:JSONSerialization.WriteOptions, rhs:JSONSerialization.WriteOptions) -> JSONSerialization.WriteOptions {
  return JSONSerialization.WriteOptions.fromMask(lhs.rawValue | rhs.rawValue)
}

func ^(lhs:JSONSerialization.WriteOptions, rhs:JSONSerialization.WriteOptions) -> JSONSerialization.WriteOptions {
  return JSONSerialization.WriteOptions.fromMask(lhs.rawValue ^ rhs.rawValue)
}

prefix func ~(value:JSONSerialization.WriteOptions) -> JSONSerialization.WriteOptions {
  return JSONSerialization.WriteOptions.fromMask(~value.rawValue)
}


