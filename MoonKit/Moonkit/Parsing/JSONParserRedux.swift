//
//  JSONParserRedux.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/2/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

/**

`JSONParser` is a simple class for parsing a JSON string into an object. The following grammar is used for parsing.
*note: All whitespace excluding that which appears inside a quoted string is ignored.

start → array | object
object → comment? '{' comment? (key-value (comment? ',' comment? key-value)*)? comment? '}' comment?
key-value → string comment? ':' comment? value
array → comment? '[' comment? (value (comment? ',' comment? value)*)? comment? ']' comment?
value → 'null' | 'true' | 'false' | number | string | array | object
string → " ­character* "
character → Any Unicode character except for ", ⏎, \ | \ ["\/bfnrt] | \ u [0-9A-F]{4}
number →  -? [0-9]+ (. [0-9]+)? ([eE] [+-]? [0-9]+)?
comment → '/' '/' non-return-character* '⏎' | '/' '*' (non-asterisk-character | '*' non-solidus-character)* '*' '/'
non-return-character → Any Unicode character except for ⏎
non-asterisk-character → Any Unicode character except for *
non-solidus-character → Any Unicode character except for /

*/
@objc(MSJSONParserRedux)
public class JSONParserRedux: NSObject {

  public var string: String { return scanner.string }
  public var idx:    Int    { get { return scanner.scanLocation } set { scanner.scanLocation = newValue } }

  private var contextStack: Stack<Context>   = []
  private var objectStack:  Stack<JSONValue> = []
  private var keyStack:     Stack<String>    = []
  private let scanner:      NSScanner

  /**
  initWithString:

  :param: string String
  */
  public init(string: String) { scanner = NSScanner.localizedScannerWithString(string) as! NSScanner; super.init() }


  // MARK: - Error handling and debugging



  /** Parser error domain and error codes */
  public let JSONParserErrorDomain = "JSONParserErrorDomain"
  public enum JSONParserErrorCode: Int { case Internal, InvalidSyntax }

  /**
  setError:code:reason:

  :param: pointer NSErrorPointer
  :param: code JSONParserErrorCode
  :param: reason String?
  */
  private func setError(pointer: NSErrorPointer,
    _ code: JSONParserErrorCode,
    _ reason: String?,
    underlyingError: NSError? = nil)
  {
    // Make sure we have memory in which to put the error object
    if pointer != nil {

      // Create the info dictionary for our new error object
      var info = [NSObject:AnyObject]()

      // Check if we already have an error in the pointer's memory
      if let existingError = pointer.memory {

        info[NSUnderlyingErrorKey] = existingError

      }

      // Check if we have been provided with an underlying error
      if let providedUnderlyingError = underlyingError {

        // Check if we just added an existing error to the dicitonary in the above if clause
        if let existingError = info[NSUnderlyingErrorKey] as? NSError {

          // Add them both as an array
          info[NSUnderlyingErrorKey] = [existingError, providedUnderlyingError]

        }

          // Otherwise just add the underlying error provided
        else {

          info[NSUnderlyingErrorKey] = providedUnderlyingError

        }

      }

      // Check if we are given a reason for the error
      if let failureReason = reason {

        // Add the reason to our dictionary with the current scanner location appended
        info[NSLocalizedFailureReasonErrorKey] = "\(failureReason) near location \(idx)"

      }

      // Finally, set the pointer's memory to a new error object
      pointer.memory = NSError(domain: JSONParserErrorDomain, code: code.rawValue, userInfo: info)

    }

  }

  /**
  setInternalError:reason:underlyingError:

  :param: pointer NSErrorPointer
  :param: reason String?
  :param: underlyingError NSError? = nil
  */
  private func setInternalError(pointer: NSErrorPointer, _ reason: String?, underlyingError: NSError? = nil) {
    setError(pointer, .Internal, reason, underlyingError: underlyingError)
  }

  /**
  setSyntaxError:reason:underlyingError:

  :param: pointer NSErrorPointer
  :param: reason String?
  :param: underlyingError NSError? = nil
  */
  private func setSyntaxError(pointer: NSErrorPointer, _ reason: String?, underlyingError: NSError? = nil) {
    setError(pointer, .InvalidSyntax, reason, underlyingError: underlyingError)
  }

  /**
  dumpState
  */
  private func dumpState() {
    println("scanner.atEnd? \(scanner.atEnd)\nidx: \(idx)")
    println("keyStack[\(keyStack.count)]: " + ", ".join(keyStack.map{"'\($0)'"}))
    println("contextStack[\(contextStack.count)]: " + ", ".join(contextStack.map{toString($0)}))
    println("objectStack[\(objectStack.count)]:\n" + "\n".join(objectStack.map{toString($0)}))
  }


  // MARK: - Scanning the string

  /** Enumeration to represent the current parser state */
  private enum Context { case Start, Object, Value, Array, Key, End }

  /** Enumeration for specifying a type of scan to perform */
  private enum ScanType {
    case CharactersFromSet     (NSCharacterSet)
    case UpToCharactersFromSet (NSCharacterSet)
    case Text                  (String)
    case UpToText              (String)
    case Number
  }

  /**
  scanFor:into:discardingComments:skipping:error:

  :param: type ScanType
  :param: object AnyObject?
  :param: discardingComments Bool = true
  :param: skipCharacters NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
  :param: error NSErrorPointer = nil

  :returns: Bool
  */
  private func scanFor(type: ScanType,
    inout into object: AnyObject?,
    discardingComments: Bool = true,
    skipping skipCharacters: NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet(),
    error: NSErrorPointer = nil) -> Bool
  {

    var success = false

    if discardingComments { scanComment(error) }

    let currentSkipCharacters = scanner.charactersToBeSkipped
    scanner.charactersToBeSkipped = skipCharacters

    switch type {

    case .CharactersFromSet(let set):
      var scannedString: NSString?
      success = scanner.scanCharactersFromSet(set, intoString: &scannedString)
      if success { object = scannedString }

    case .UpToCharactersFromSet(let set):
      var scannedString: NSString?
      success = scanner.scanUpToCharactersFromSet(set, intoString: &scannedString)
      if success { object = scannedString }

    case .Text (let text):
      var scannedString: NSString?
      success = scanner.scanString(text, intoString: &scannedString)
      if success { object = scannedString }

    case .UpToText(let text):
      var scannedString: NSString?
      success = scanner.scanUpToString(text, intoString: &scannedString)
      if success { object = scannedString }

    case .Number:
      var scannedNumber: Double = 0
      success = scanner.scanDouble(&scannedNumber)
      if success { object = scannedNumber }

    }

    scanner.charactersToBeSkipped = currentSkipCharacters
    if discardingComments { scanComment(error) }

    return success

  }

  /**
  scanComment:

  :param: error NSErrorPointer
  */
  private func scanComment(error: NSErrorPointer) {

    var scannedObject: AnyObject?

    // Try scanning the for solidus characters
    if scanFor(.CharactersFromSet(NSCharacterSet(charactersInString: "/" )),
      into: &scannedObject, discardingComments: false) {

        if let scannedString = scannedObject as? String {

          if scannedString.hasPrefix("//") {

            scanFor(.UpToCharactersFromSet(NSCharacterSet.newlineCharacterSet()),
              into: &scannedObject, discardingComments: false, skipping: NSCharacterSet(charactersInString: ""))

          }

          else if scanFor(.CharactersFromSet(NSCharacterSet(charactersInString: "*" )),
            into: &scannedObject, discardingComments: false, skipping: NSCharacterSet(charactersInString: ""))
          {
            if !scanFor(.UpToText("*/"), into: &scannedObject, discardingComments: false) {
              setSyntaxError(error, "open-ended multi-line comment")
            }

            else { scanFor(.Text("*/"), into: &scannedObject, discardingComments: false) }

          }

          else { setSyntaxError(error, "malformed comment detected") }

        }

        else { setInternalError(error, "scan succeeded but scanned object is empty") }

    }

  }

  /**
  scanNumber:

  :param: number AnyObject?

  :returns: Bool
  */
  private func scanNumber(inout number:AnyObject?) -> Bool { return scanFor(.Number, into: &number) }

  /**
  scanQuotedString:error:

  :param: string AnyObject?
  :param: error NSErrorPointer

  :returns: Bool
  */
  private func scanQuotedString(inout string:AnyObject?, _ error: NSErrorPointer) -> Bool {

    var scannedObject: AnyObject?
    var success = false

    if scanFor(.Text("\""), into: &scannedObject) {

      var scannedString = ""

      // Check if we have an empty string
      if scanFor(.Text("\""), into: &scannedObject) { success = true }

      else {

        while !success && scanFor(.UpToCharactersFromSet(NSCharacterSet(charactersInString: "\"")),
          into: &scannedObject, skipping: NSCharacterSet(charactersInString: ""))
        {
          // Make sure we scanned something and that we didn't scan up to an escaped quotation mark
          if let s = scannedObject as? String {

            scannedString += s // Append what we just scanned to accumulating string

            // Set success if our quotation mark was not escaped
            if !s.hasSuffix("\\") { success = true }

          }

        }

        // At this point, to be valid syntax we must have scanned an opening quotation mark,
        // some text, and be sitting on an unescaped quotation mark
        if !(success && scanFor(.Text("\""), into: &scannedObject, skipping: NSCharacterSet(charactersInString: ""))) {

          success = false
          setSyntaxError(error, "unmatched double quote")

        }

      }

      // If we have succeeded, be sure to set the inout parameter to our accumulated string
      if success { string = scannedString }

    }

    return success

  }


  // MARK: - Parsing the string



  /**
  parseObject:

  :param: error NSErrorPointer = nil

  :returns: Bool
  */
  private func parseObject(error: NSErrorPointer = nil) -> Bool {

    var success = false
    var localError: NSError?
    var scannedObject: AnyObject?

    // Try to scan the opening punctuation for an object
    if scanFor(.Text("{"), into: &scannedObject, error: &localError) {

      success = true
      objectStack.push(.Object([:])) // Push a new dictionary onto the object stack
      contextStack.push(.Object)     // Push object context
      contextStack.push(.Key)        // Push key context


    }

      // Then try to scan a comma separating another object key value pair
    else if scanFor(.Text(","), into: &scannedObject, error: &localError) {
      success = true
      contextStack.push(.Key)
    }

      // Lastly, try to scan the closing punctuation for an object
    else if scanFor(.Text("}"), into: &scannedObject, error: &localError) {

      // Pop context and object stacks
      if let context = contextStack.pop(), object = objectStack.pop() {

        switch (context, object) {
          case (_, _) where contextStack.peek == .Start:
            // Replace start context with end context if we have completed the root object
            contextStack.pop()
            contextStack.push(.End)
            success = true

          case (.Object, .Object(_)):
            success = addValueToTopObject(object, error)

          case (_, .Object(_)):
            setInternalError(error, "incorrect context popped off of stack", underlyingError: localError)

          case (.Object, _):
            setInternalError(error, "dictionary absent from object stack", underlyingError: localError)

          default:
            assert(false, "shouldn't this be unreachable?")
        }
      }

      else { setInternalError(error, "one or both of context and object stacks is empty", underlyingError: localError) }

    }

    return success

  }

  /**
  parseArray:

  :param: error NSErrorPointer = nil

  :returns: Bool
  */
  private func parseArray(error: NSErrorPointer = nil) -> Bool {

    var success = false
    var localError: NSError?
    var scannedObject: AnyObject?

    // Try to scan the opening punctuation for an object
    if scanFor(.Text("["), into: &scannedObject, error: &localError) {

      success = true
      objectStack.push(.Array([])) // Push a new array onto the object stack
      contextStack.push(.Array)    // Push the array context
      contextStack.push(.Value)    // Push the value context

    }

      // Then try to scan a comma separating another object key value pair
    else if scanFor(.Text(","), into: &scannedObject, error: &localError) {
      success = true
      contextStack.push(.Value)
    }

      // Lastly, try to scan the closing punctuation for an object
    else if scanFor(.Text("]"), into: &scannedObject, error: &localError) {

      // Pop context and object stacks
      if let context = contextStack.pop(), object = objectStack.pop() {

        switch (context, object) {
        case (_, _) where contextStack.peek == .Start:
          // Replace start context with end context if we have completed the root object
          contextStack.pop()
          contextStack.push(.End)
          success = true

        case (.Array, .Array(_)):
          success = addValueToTopObject(object, error)

        case (_, .Array(_)):
          setInternalError(error, "incorrect context popped off of stack", underlyingError: localError)

        case (.Array, _):
          setInternalError(error, "array absent from object stack", underlyingError: localError)

        default:
          assert(false, "shouldn't this be unreachable?")
        }
      }

      else { setInternalError(error, "one or both of context and object stacks is empty", underlyingError: localError) }

    }

    return success

  }

  /**
  parseValue:

  :param: error NSErrorPointer = nil

  :returns: Bool
  */
  private func parseValue(error: NSErrorPointer = nil) -> Bool {

    var success = false
    var value: JSONValue?
    var scanError: NSError?
    var scannedObject: AnyObject?

    if !(contextStack.pop() == Context.Value) {
      setInternalError(error, "incorrect context popped off of stack")
      return false
    }

    // Try scanning a true literal
    if scanFor(.Text("true"), into: &scannedObject, error: &scanError) {
      value = true
      success = true
    }

      // Try scanning a false literal
    else if scanFor(.Text("false"), into: &scannedObject, error: &scanError) {
      value = false
      success = true
    }

      // Try scanning a null literal
    else if scanFor(.Text("null"), into: &scannedObject, error: &scanError) {
      value = nil
      success = true
    }

      // Try scanning a number
    else if scanFor(.Number, into: &scannedObject, error: &scanError) {
      value = .Number(scannedObject as! NSNumber)
      success = true
    }

      // Try scanning a string
    else if scanQuotedString(&scannedObject, &scanError) {
      value = .String(scannedObject as! Swift.String)
      success = true
    }

      // Try scanning an object
    else if parseObject(error: &scanError) { success = true }

      // Try scanning an array
    else if parseArray(error: &scanError) { success = true }

      // Set error if we failed to scan anything
    else { setSyntaxError(error, "failed to parse value", underlyingError: scanError) }

    // If we have a value, add it to the top object in our stack
    if let v = value where success {

      var addValueError: NSError?
      success = addValueToTopObject(v, &addValueError)

      // Handle error adding value if not successful
      if addValueError != nil {
        setInternalError(error, "error encountered while adding parsed value", underlyingError: addValueError)
      }

    }

    return success

  }

  /**
  parseKey:

  :param: error NSErrorPointer = nil

  :returns: Bool
  */
  private func parseKey(error: NSErrorPointer = nil) -> Bool {

    var success = false
    var localError: NSError?
    var scannedObject: AnyObject?

    // Set error if we can't scan a string
    if !scanQuotedString(&scannedObject, &localError) { setSyntaxError(error, "missing key for object element",
      underlyingError: localError) }
      // Otherwise process what we have scanned
    else {

      // Pop off context, making sure it is of the correct value
      if contextStack.pop() != Context.Key { setInternalError(error, "incorrect context popped off of stack",
        underlyingError: localError) }

        // Otherwise push the key we scanned into the key stack and look for a colon
      else if let key = scannedObject as? String {

        keyStack.push(key)

        // Parse the delimiting colon
        if !scanFor(.Text(":"), into: &scannedObject, error: &localError) { setSyntaxError(error, "missing colon after key",
          underlyingError: localError) }
          // Push value context and set success if we found the colon
        else { contextStack.push(.Value); success = true }

      }

    }

    return success

  }


  /**
  addValueToTopObject:error:

  :param: value AnyObject
  :param: error NSErrorPointer = nil

  :returns: Bool
  */
  private func addValueToTopObject(value: JSONValue, _ error: NSErrorPointer = nil) -> Bool {

    var success = false

    if let context = contextStack.peek, object = objectStack.pop() {

      switch (context, object) {
        case (.Object, .Object(var d)):
          if let k = keyStack.pop() {
            d[k] = value
            objectStack.push(.Object(d))
            success = true
          } else { setInternalError(error, "empty key stack") }

        case (.Array, .Array(var a)):
          a.append(value)
          objectStack.push(.Array(a))
          success = true

        case (_, .Object(_)),
             (_, .Array(_)):
          setInternalError(error, "invalid context-object pairing: \(context)-\(object)")

        case (.Object, _),
             (.Array, _):
          setInternalError(error, "missing object in stack to receive new value")

        default:
          assert(false, "should be unreachable?")
      }

    } else { setInternalError(error, "empty context stack") }

    return success

  }

  /**
  parse:

  :param: error NSErrorPointer = nil

  :returns: JSONValue?
  */
  public func parse(error: NSErrorPointer = nil) -> JSONValue? {

    // Start in a known context
    contextStack.push(.Start)

    // Scan while we have input, completing the root object will exit the loop even if text remains
    scanLoop: while !scanner.atEnd {

      // We must have a context on top of the context stack
      if let context = contextStack.peek {

        // Perform a context-appropriate action
        switch context {

          // To be valid, we must be able to scan an opening bracked of some kind
        case .Start:

          // Set error if we fail to match the start of an array or an object and exit loop
          if !(parseObject(error: error) || parseArray(error: error)) {
            setSyntaxError(error, "root must be an object/array")
            break scanLoop
          }

          // Try to scan a number, a boolean, null, the start of an object, or the start of an array
        case .Value: if !parseValue(error: error) { break scanLoop }

          // Try to scan a comma or curly bracket
        case .Object: if !parseObject(error: error) { break scanLoop }

          // Try to scan a comma or square bracket
        case .Array: if !parseArray(error: error) { break scanLoop }

          // Try to scan a quoted string for use as a dictionary key
        case .Key: if !parseKey(error: error) { break scanLoop }

          // Just break out of scan loop
        case .End: break scanLoop

        }

      }

    }

    var object: JSONValue?  // Variable to hold result to be returned

    // If the root object ends the text we won't hit the `.End` case in our switch statement
    if !objectStack.isEmpty {

      // Make sure we don't have more than one object left in the stack
      if objectStack.count > 1 { setInternalError(error, "objects left in stack") }

      // Otherwise pop the root object from the stack
      else { object = objectStack.pop() }

    }

    return object

  }

}
