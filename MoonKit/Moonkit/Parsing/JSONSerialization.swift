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
  objectByParsingDirectivesForFile:options:error:

  :param: filePath String
  :param: options ReadOptions = .None
  :param: error NSErrorPointer = nil

  :returns: JSONValue?
  */
  public class func stringByParsingDirectivesForFile(filePath: String,
                                             options: ReadOptions = .None,
                                               error: NSErrorPointer = nil) -> String?
  {
    var localError: NSError?      // So we can intercept errors before passing them along to caller

    // Get the contents of the file to parse
    if var string = String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: &localError)
      where !handledError(localError, errorCode: NSFileReadUnknownError, error: error)
    {
      // Look for include entries in the file-loaded string
      let directory = filePath.stringByDeletingLastPathComponent
      let result = JSONIncludeDirective.stringByParsingDirectivesInString(string, directory: directory)
      if JSONIncludeDirective.cacheSize > 100 { JSONIncludeDirective.emptyCache() }
      return result
    }

    return nil
  }


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
  handledError:errorCode:error:

  :param: localError NSError?
  :param: errorCode Int
  :param: error NSErrorPointer

  :returns: Bool
  */
  private class func handledError(localError: NSError?, errorCode: Int, error: NSErrorPointer) -> Bool {
    if localError == nil { return false }
    if error != nil {
      error.memory = NSError(domain: "MSJSONSerializationErrorDomain",
        code: errorCode,
        underlyingErrors: [localError!])
    }
    return true
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

    if let string = stringByParsingDirectivesForFile(filePath, options: options, error: error)
      where !handledError(localError, errorCode: NSFileReadUnknownError, error: error)
    {
      return objectByParsingString(string, options: options, error: error)
    } else { return nil }
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
