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
  public class func JSONFromObject(object: AnyObject, options: WriteOptions.Raw) -> String? {
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
					if let comment = (array[i] as NSObject).comment { string += comment }

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
          let value: AnyObject = dict[key as NSCopying]!
					let keyString = weakStringFromObject!(key, depth + 1)
          let valueString = weakStringFromObject!(value, depth + 1).stringByTrimmingWhitespace()

          string += "\n\(keyString): \(valueString)"

          if i + 1 < keyCount { string += "," }

          if let comment = (value as NSObject).comment { string += comment }

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
	public class func parseFile(filePath: String, options: WriteOptions.Raw, error: NSErrorPointer) -> String? {
		return parseFile(filePath, options: WriteOptions.fromMask(options), error: error)
	}

	/**
	parseFile:options:error:

	:param: filePath String
	:param: options JSONSerializationWriteOptions = .None
	:param: error NSErrorPointer = nil

	:returns: String?
	*/
	class func parseFile(filePath: String, options: WriteOptions = .None, error: NSErrorPointer = nil) -> String?
	{
    var localError: NSError?
    let string = NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: &localError)
    var returnString: String?

    if localError != nil {
      let message = aggregateErrorMessage(localError!, message: "failed to create string from file")
      logError(message, __FUNCTION__, level: LOG_LEVEL_ERROR)
      if error != nil { error.memory = localError }
    }

    else { returnString = parseString(string, options: options, error: error) }

    return returnString
	}

	/**
	parseString:options:error:

	:param: string String
	:param: options WriteOptions.Raw
	:param: error NSErrorPointer

	:returns: String?
	*/
	public class func parseString(string: String, options: WriteOptions.Raw, error: NSErrorPointer) -> String? {
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
	public class func objectByParsingString(string: String, options: ReadOptions.Raw, error: NSErrorPointer) -> AnyObject? {
		return objectByParsingString(string, options:(ReadOptions.fromRaw(options) ?? .None), error: error)
	}

	/**
	objectByParsingString:options:error:

	:param: string String
	:param: options JSONSerializationReadOptions = .None
	:param: error NSErrorPointer = nil

	:returns: AnyObject?
	*/
	class func objectByParsingString(string: String, options: ReadOptions = .None, error: NSErrorPointer = nil) -> AnyObject? {

    var object: AnyObject?

    let parser = JSONParser(string: string)
    object = parser.parse(error: error)

    if options == .InflateKeypaths {
      if let container = object as? MSObjectContaining {
        if let dict = container as? MSDictionary {
          dict.inflate()
        }
        if let dicts = container.allObjectsOfKind(MSDictionary.self) as? [MSDictionary] {
          dicts.perform{$0.inflate()}
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
	public class func objectByParsingFile(filePath: String, options: ReadOptions.Raw, error: NSErrorPointer) -> AnyObject? {
		return objectByParsingFile(filePath, options: (ReadOptions.fromRaw(options) ?? .None), error: error)
	}

	/**
	objectByParsingFile:options:error:

	:param: filePath String
	:param: options JSONSerializationReadOptions = .None
	:param: error NSErrorPointer = nil

	:returns: AnyObject?
	*/
	class func objectByParsingFile(filePath: String, options: ReadOptions = .None, error: NSErrorPointer = nil) -> AnyObject? {

    var localError: NSError?
    let string = NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: &localError)
    var returnObject: AnyObject?

    if localError != nil {
      let message = aggregateErrorMessage(localError!, message: "failed to create string from file")
      logError(message, __FUNCTION__, level: LOG_LEVEL_ERROR)
      if error != nil { error.memory = localError }
    }

    else { returnObject = objectByParsingString(string, options: options, error: error) }

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

    private var value: UInt = 0

    var boolValue: Bool { return value != 0 }

    static var allZeros: WriteOptions { return WriteOptions.None }

    func toRaw() -> UInt { return value }

    init(_ value: UInt) { self.value = value }

    static func fromRaw(raw: UInt)      -> WriteOptions? { return self(raw) }
    static func fromMask(raw: UInt)     -> WriteOptions  { return self(raw) }
    static func convertFromNilLiteral() -> WriteOptions  { return self(0)   }

    static var None                          : WriteOptions = WriteOptions(0b0000_0000_0000_0000)
    static var PreserveWhitespace            : WriteOptions = WriteOptions(0b0000_0000_0000_0001)
    static var CreateKeypaths                : WriteOptions = WriteOptions(0b0000_0000_0000_0010)
    static var KeepComments                  : WriteOptions = WriteOptions(0b0000_0000_0000_0100)
    static var IndentByDepth                 : WriteOptions = WriteOptions(0b0000_0000_0000_1000)
    static var KeepOneLiners                 : WriteOptions = WriteOptions(0b0000_0000_0001_0000)
    static var ForceOneLiners                : WriteOptions = WriteOptions(0b0000_0000_0010_0000)
    static var BreakAfterLeftSquareBracket   : WriteOptions = WriteOptions(0b0000_0000_0100_0000)
    static var BreakBeforeRightSquareBracket : WriteOptions = WriteOptions(0b0000_0000_1000_0000)
    static var BreakInsideSquareBrackets     : WriteOptions = WriteOptions(0b0000_0000_1100_0000)
    static var BreakAfterLeftCurlyBracket    : WriteOptions = WriteOptions(0b0000_0001_0000_0000)
    static var BreakBeforeRightCurlyBracket  : WriteOptions = WriteOptions(0b0000_0010_0000_0000)
    static var BreakInsideCurlyBrackets      : WriteOptions = WriteOptions(0b0000_0011_0000_0000)
    static var BreakAfterComma               : WriteOptions = WriteOptions(0b0000_0100_0000_0000)
    static var BreakBetweenColonAndArray     : WriteOptions = WriteOptions(0b0000_1000_0000_0000)
    static var BreakBetweenColonAndObject    : WriteOptions = WriteOptions(0b0001_0000_0000_0000)

  }

}

func ==(lhs:JSONSerialization.WriteOptions, rhs:JSONSerialization.WriteOptions) -> Bool { return lhs.value == rhs.value }

func &(lhs:JSONSerialization.WriteOptions, rhs:JSONSerialization.WriteOptions) -> JSONSerialization.WriteOptions {
  return JSONSerialization.WriteOptions.fromMask(lhs.value & rhs.value)
}

func |(lhs:JSONSerialization.WriteOptions, rhs:JSONSerialization.WriteOptions) -> JSONSerialization.WriteOptions {
  return JSONSerialization.WriteOptions.fromMask(lhs.value | rhs.value)
}

func ^(lhs:JSONSerialization.WriteOptions, rhs:JSONSerialization.WriteOptions) -> JSONSerialization.WriteOptions {
  return JSONSerialization.WriteOptions.fromMask(lhs.value ^ rhs.value)
}

prefix func ~(value:JSONSerialization.WriteOptions) -> JSONSerialization.WriteOptions {
  return JSONSerialization.WriteOptions.fromMask(~value.value)
}


