//
//  JSONParser.swift
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

object → left-curly-bracket key-value-pairs? right-curly-bracket

key-value-pairs → key-value (comma key-value)*

key-value → string colon value

array → left-square-bracket values? right-square-bracket

values → value (comma value)*

value → 'null'

value → 'true'

value → 'false'

value → number

value → string

value → array

value → object

string → " ­character* "

character → Any Unicode character except for ", ⏎, \

character → \ ["\/bfnrt]

character → \ u [0-9A-F]{4}

number →  -? [0-9]+ (. [0-9]+)? ([eE] [+-]? [0-9]+)?

comment → '/' '/' non-return-character* '⏎'

comment → '/' '*' (non-asterisk-character | '*' non-solidus-character)* '*' '/'

non-return-character → Any Unicode character except for ⏎

non-asterisk-character → Any Unicode character except for *

non-solidus-character → Any Unicode character except for /

comma → comment? ',' comment?

colon → comment? ':' comment?

left-curly-bracket → comment? '{' comment?

right-curly-bracket → comment? '}' comment?

left-square-bracket → comment? '[' comment?

right-square-bracket → comment? ']' comment?


*/
public class JSONParser {

  public var string: String { return scanner.string }
  public let allowFragment: Bool
  public let ignoreExcess: Bool
  public var idx:    Int    { get { return scanner.scanLocation } set { scanner.scanLocation = newValue } }

  private var contextStack: Stack<Context>   = []
  private var objectStack:  Stack<JSONValue> = []
  private var keyStack:     Stack<String>    = []
  private let scanner:      NSScanner

  /**
  initWithString:

  - parameter string: String
  */
  public init(string: String, allowFragment: Bool = false, ignoreExcess: Bool = false) {
    scanner = NSScanner.localizedScannerWithString(string) as! NSScanner
    self.allowFragment = allowFragment
    self.ignoreExcess = ignoreExcess
  }


  // MARK: - Error handling and debugging



  /** Parser error domain and error codes */
  public let JSONParserErrorDomain = "JSONParserErrorDomain"
  public enum JSONParserErrorCode: Int { case Internal, InvalidSyntax }

  /**
  setError:code:reason:

  - parameter pointer: NSErrorPointer
  - parameter code: JSONParserErrorCode
  - parameter reason: String?
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

  - parameter pointer: NSErrorPointer
  - parameter reason: String?
  - parameter underlyingError: NSError? = nil
  */
  private func setInternalError(pointer: NSErrorPointer, _ reason: String?, underlyingError: NSError? = nil) {
    setError(pointer, .Internal, reason, underlyingError: underlyingError)
  }

  /**
  setSyntaxError:reason:underlyingError:

  - parameter pointer: NSErrorPointer
  - parameter reason: String?
  - parameter underlyingError: NSError? = nil
  */
  private func setSyntaxError(pointer: NSErrorPointer, _ reason: String?, underlyingError: NSError? = nil) {
    setError(pointer, .InvalidSyntax, reason, underlyingError: underlyingError)
  }

  /**
  dumpState
  */
  private func dumpState(error: NSError? = nil) {
    print("scanner.atEnd? \(scanner.atEnd)\nidx: \(idx)")
    print("keyStack[\(keyStack.count)]: " + ", ".join(keyStack.map{"'\($0)'"}))
    print("contextStack[\(contextStack.count)]: " + ", ".join(contextStack.map{$0.rawValue}))
    print("objectStack[\(objectStack.count)]:\n" + "\n".join(objectStack.map{toString($0)}))
    if error != nil {
      print("error: \(detailedDescriptionForError(error!, depth: 0))")
    }
  }


  // MARK: - Scanning the string

  /** Enumeration to represent the current parser state */
  private enum Context: String {
    case Start  = "start"
    case Object = "object"
    case Value  = "value"
    case Array  = "array"
    case Key    = "key"
    case End    = "end"
  }

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

  - parameter type: ScanType
  - parameter object: AnyObject?
  - parameter discardingComments: Bool = true
  - parameter skipCharacters: NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
  - parameter error: NSErrorPointer = nil

  - returns: Bool
  */
  private func scanFor(type: ScanType,
            inout into object: AnyObject?,
    discardingComments: Bool = true,
              skipping skipCharacters: NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()) throws
  {
    var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)

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

    if success {
      return
    }
    throw error

  }

  /**
  scanComment:

  - parameter error: NSErrorPointer
  */
  private func scanComment(error: NSErrorPointer) {

    var scannedObject: AnyObject?

    // Try scanning the for solidus characters
    do {
      try scanFor(.CharactersFromSet(NSCharacterSet(charactersInString: "/" )),
            into: &scannedObject, discardingComments: false)

        if let scannedString = scannedObject as? String {

          if scannedString.hasPrefix("//") {

            do {
              try scanFor(.UpToCharactersFromSet(NSCharacterSet.newlineCharacterSet()),
                into: &scannedObject, discardingComments: false, skipping: NSCharacterSet(charactersInString: ""))
            } catch _ {
            }

          }

          else {
            do {
              try scanFor(.CharactersFromSet(NSCharacterSet(charactersInString: "*" )),
                          into: &scannedObject, discardingComments: false, skipping: NSCharacterSet(charactersInString: ""))
              do { try scanFor(.UpToText("*/"), into: &scannedObject, discardingComments: false); do {
                  try scanFor(.Text("*/"), into: &scannedObject, discardingComments: false)
                } catch _ {
                } } catch _ {
                setSyntaxError(error, "open-ended multi-line comment")
              }

            } catch _ { setSyntaxError(error, "malformed comment detected") }
          }

        }

        else { setInternalError(error, "scan succeeded but scanned object is empty") }

    } catch _ {
    }

  }

  /**
  scanNumber:

  - parameter number: AnyObject?

  - returns: Bool
  */
  private func scanNumber(inout number:AnyObject?) -> Bool { do {
      try scanFor(.Number, into: &number)
      return true
    } catch _ {
      return false
    } }

  /**
  scanQuotedString:error:

  - parameter string: AnyObject?
  - parameter error: NSErrorPointer

  - returns: Bool
  */
  private func scanQuotedString(inout string:AnyObject?) throws {
    var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)

    var scannedObject: AnyObject?
    var success = false

    do {
      try scanFor(.Text("\""), into: &scannedObject)

      var scannedString = ""

      // Check if we have an empty string
      do { try scanFor(.Text("\""), into: &scannedObject); success = true } catch _ {

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

    } catch _ {
    }

    if success {
      return
    }
    throw error

  }


  // MARK: - Parsing the string



  /**
  parseObject:

  - parameter error: NSErrorPointer = nil

  - returns: Bool
  */
  private func parseObject() throws {
    var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)

    var success = false
    var localError: NSError?
    var scannedObject: AnyObject?

    // Try to scan the opening punctuation for an object
    do {
      try scanFor(.Text("{"), into: &scannedObject, error: &localError)

      success = true
      objectStack.push(.Object([:])) // Push a new dictionary onto the object stack
      contextStack.push(.Object)     // Push object context
      contextStack.push(.Key)        // Push key context


    } catch _ {
      do {
        try scanFor(.Text(","), into: &scannedObject, error: &localError)
        success = true
        contextStack.push(.Key)
      } catch _ {
        do {
          try scanFor(.Text("}"), into: &scannedObject, error: &localError)

          // Pop context and object stacks
          if let context = contextStack.pop(), object = objectStack.pop() {

            switch (context, object) {

              case (_, _) where contextStack.peek == .Start:
                // Replace start context with end context if we have completed the root object
                contextStack.pop()
                contextStack.push(.End)
                objectStack.push(object)
                success = true

              case (.Object, .Object(_)):
                do {
                  try addValueToTopObject(object)
                  success = true
                } catch var error1 as NSError {
                  error = error1
                  success = false
                }

              case (_, .Object(_)):
                setInternalError(error, "incorrect context popped off of stack", underlyingError: localError)

              case (.Object, _):
                setInternalError(error, "dictionary absent from object stack", underlyingError: localError)

              default:
                assert(false, "shouldn't this be unreachable?")
            }

          }

          else { setInternalError(error, "one or both of context and object stacks is empty", underlyingError: localError) }

        } catch _ {
        }
      }
    }

    if success {
      return
    }
    throw error

  }

  /**
  parseArray:

  - parameter error: NSErrorPointer = nil

  - returns: Bool
  */
  private func parseArray() throws {
    var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)

    var success = false
    var localError: NSError?
    var scannedObject: AnyObject?

    // Try to scan the opening punctuation for an object
    do {
      try scanFor(.Text("["), into: &scannedObject, error: &localError)

      success = true
      objectStack.push(.Array([])) // Push a new array onto the object stack
      contextStack.push(.Array)    // Push the array context
      contextStack.push(.Value)    // Push the value context

    } catch _ {
      do {
        try scanFor(.Text(","), into: &scannedObject, error: &localError)
        success = true
        contextStack.push(.Value)
      } catch _ {
        do {
          try scanFor(.Text("]"), into: &scannedObject, error: &localError)

          // Pop context and object stacks
          if let context = contextStack.pop(), object = objectStack.pop() {

            switch (context, object) {
            case (_, _) where contextStack.peek == .Start:
              // Replace start context with end context if we have completed the root object
              contextStack.pop()
              contextStack.push(.End)
              objectStack.push(object)
              success = true

            case (.Array, .Array(_)):
              do {
                try addValueToTopObject(object)
                success = true
              } catch var error1 as NSError {
                error = error1
                success = false
              }

            case (_, .Array(_)):
              setInternalError(error, "incorrect context popped off of stack", underlyingError: localError)

            case (.Array, _):
              setInternalError(error, "array absent from object stack", underlyingError: localError)

            default:
              assert(false, "shouldn't this be unreachable?")
            }
          }

          else { setInternalError(error, "one or both of context and object stacks is empty", underlyingError: localError) }

        } catch _ {
        }
      }
    }

    if success {
      return
    }
    throw error

  }

  /**
  parseValue:

  - parameter error: NSErrorPointer = nil

  - returns: Bool
  */
  private func parseValue() throws {
    var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)

    var success = false
    var value: JSONValue?
    var scanError: NSError?
    var scannedObject: AnyObject?

    if !(contextStack.pop() == Context.Value) {
      setInternalError(error, "incorrect context popped off of stack")
      throw error
    }

    // Try scanning a true literal
    do {
      try scanFor(.Text("true"), into: &scannedObject, error: &scanError)
      value = true
      success = true
    } catch _ {
      do {
        try scanFor(.Text("false"), into: &scannedObject, error: &scanError)
        value = false
        success = true
      } catch _ {
        do {
          try scanFor(.Text("null"), into: &scannedObject, error: &scanError)
          value = .Null
          success = true
        } catch _ {
          do {
            try scanFor(.Number, into: &scannedObject, error: &scanError)
            value = .Number(scannedObject as! NSNumber)
            success = true
          } catch _ {
            do {
              try scanQuotedString(&scannedObject)
              value = .String(scannedObject as! Swift.String)
              success = true
            } catch var error3 as NSError {
              scanError = error3
              do { try parseObject(); success = true } catch var error2 as NSError {
                scanError = error2
                do { try parseArray(); success = true } catch var error1 as NSError { scanError = error1; setSyntaxError(error, "failed to parse value", underlyingError: scanError) }
              }
            }
          }
        }
      }
    }

    // If we have a value, add it to the top object in our stack
    if let v = value where success {

      var addValueError: NSError?
      do {
        try addValueToTopObject(v)
        success = true
      } catch var error as NSError {
        addValueError = error
        success = false
      }

      // Handle error adding value if not successful
      if addValueError != nil {
        setInternalError(error, "error encountered while adding parsed value", underlyingError: addValueError)
      }

    }

    if success {
      return
    }
    throw error

  }

  /**
  parseKey:

  - parameter error: NSErrorPointer = nil

  - returns: Bool
  */
  private func parseKey() throws {
    var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)

    var success = false
    var localError: NSError?
    var scannedObject: AnyObject?

    // Set error if we can't scan a string
    do {
      try scanQuotedString(&scannedObject)

      // Pop off context, making sure it is of the correct value
      if contextStack.pop() != .Key {
        setInternalError(error, "incorrect context popped off of stack", underlyingError: localError)
      }

        // Otherwise push the key we scanned into the key stack and look for a colon
      else if let key = scannedObject as? String {

        keyStack.push(key)

        // Parse the delimiting colon
        do { try scanFor(.Text(":"), into: &scannedObject, error: &localError); contextStack.push(.Value); success = true } catch _ {
          setSyntaxError(error, "missing colon after key", underlyingError: localError)
        }

      }

    } catch var error1 as NSError {
      localError = error1
      setSyntaxError(error, "missing key for object element", underlyingError: localError)
    }

    if success {
      return
    }
    throw error

  }


  /**
  addValueToTopObject:error:

  - parameter value: AnyObject
  - parameter error: NSErrorPointer = nil

  - returns: Bool
  */
  private func addValueToTopObject(value: JSONValue) throws {
    var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)

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

    } else if allowFragment && objectStack.isEmpty {
      objectStack.push(value)
      success = true
      if contextStack.peek == .Start { contextStack.pop(); contextStack.push(.End) }
    } else if contextStack.isEmpty && objectStack.isEmpty {
      setInternalError(error, "empty stacks")
    } else if contextStack.isEmpty {
      setInternalError(error, "empty context stack")
    } else if objectStack.isEmpty {
      setInternalError(error, "empty object stack")
    } else {
      setInternalError(error, "an unknown internal error has occurred")
    }

    if success {
      return
    }
    throw error

  }

  /**
  parse:

  - parameter error: NSErrorPointer = nil

  - returns: JSONValue?
  */
  public func parse() throws -> JSONValue {
    var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)

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

            // Check if we are allowing the string to be a json fragment
            if allowFragment {
              contextStack.push(.Value)
              do {
                try parseValue()
              } catch var error1 as NSError {
                setSyntaxError(error1, "root is not a valid json fragment")
                throw error1
              }
            }

            // Set error if we fail to match the start of an array or an object and exit loop
            else if !(parseObject() || parseArray()) {
              setSyntaxError(error, "root must be an object/array")
              throw error
            }

          // Try to scan a number, a boolean, null, the start of an object, or the start of an array
          case .Value: do {
              try parseValue()
            } catch var error1 as NSError { error = error1; break scanLoop }

          // Try to scan a comma or curly bracket
          case .Object: do {
              try parseObject()
            } catch var error1 as NSError { error = error1; break scanLoop }

          // Try to scan a comma or square bracket
          case .Array: do {
              try parseArray()
            } catch var error1 as NSError { error = error1; break scanLoop }

          // Try to scan a quoted string for use as a dictionary key
          case .Key: do {
              try parseKey()
            } catch var error1 as NSError { error = error1; break scanLoop }

          // Just break out of scan loop
          case .End:
            if !(scanner.atEnd || ignoreExcess) {
              setSyntaxError(error, "parse completed but scanner is not at end")
              throw error
            }
            break scanLoop

        }

      } // else { contextStack.push(.End) }


    }

    var object: JSONValue?  // Variable to hold result to be returned

    // If the root object ends the text we won't hit the `.End` case in our switch statement
    if !objectStack.isEmpty {

      // Make sure we don't have more than one object left in the stack
      if objectStack.count > 1 { setInternalError(error, "objects left in stack") }

      // Otherwise pop the root object from the stack
      else { object = objectStack.pop() }

    }

    if var value = object {
      return value
    }
    throw error

  }

}
