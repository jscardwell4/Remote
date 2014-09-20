//
//  JSONParser.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/16/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

private var LogLevel: Int32 = LOG_LEVEL_DEBUG

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
@objc(MSJSONParser)
public class JSONParser: NSObject {

  public var string: String { return scanner.string }
  public var idx:    Int    { get { return scanner.scanLocation } set { scanner.scanLocation = newValue } }

  private var contextStack: Stack<Context>   = Stack<Context>()
  private var objectStack:  Stack<AnyObject> = Stack<AnyObject>()
  private var keyStack:     Stack<String>    = Stack<String>()
  private let scanner:      NSScanner

  /**
  initWithString:

  :param: string String
  */
  public init(string: String) { scanner = NSScanner(string: string); super.init() }


  ////////////////////////////////////////////////////////////////////////////////
  /// MARK: - Error handling and debugging
  ////////////////////////////////////////////////////////////////////////////////


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
    if pointer != nil {
      var info = [NSObject:AnyObject]()
      if reason != nil { info[NSLocalizedFailureReasonErrorKey] = reason! + " near location \(idx)" }
      if underlyingError != nil { info[NSUnderlyingErrorKey] = underlyingError! }
      pointer.memory = NSError(domain: JSONParserErrorDomain, code: code.toRaw(), userInfo: info)
    }

    if LogLevel == LOG_LEVEL_DEBUG {
      var errorMessage = "Error(\(code))"
      if reason != nil { errorMessage.extend(": \(reason!)") }
      if underlyingError != nil {
        errorMessage.extend("\nunderlying error: \(aggregateErrorMessage(underlyingError!))\n")
      }
      dumpState()
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
  logContextStack:file:function:line:

  :param: message String
  :param: file String
  :param: function String
  :param: line Int
  */
  private func logContextStack(message: String, _ function: String) {
    logVerbose("\(message) (\(String.CommaSpace.join(contextStack.map{$0.description})))", function, level: LogLevel)
  }

  /**
  logAddedObject:containingObject:file:function:line:

  :param: addedObject AnyObject
  :param: containingObject Printable
  :param: file String
  :param: function String
  :param: line Int
  */
  private func logAddedObject(addedObject: AnyObject, _ containingObject: Printable, _ function: String) {
    logVerbose("added \(addedObject.description) to \(containingObject.description)", function, level: LogLevel)
  }

  /**
  dumpState
  */
  private func dumpState() {
    println("scanner.atEnd? \(scanner.atEnd)\nidx: \(idx)")
    println("keyStack[\(keyStack.count)]: \(String.CommaSpace.join(keyStack.map{String.Quote + $0 + String.Quote}))")
    println("contextStack[\(contextStack.count)]: \(String.CommaSpace.join(contextStack.map{$0.description}))")
    println("objectStack[\(objectStack.count)]:\n\(String.Newline.join(objectStack.map{$0.description}))")
  }


  ////////////////////////////////////////////////////////////////////////////////
  /// MARK: - Scanning the string
  ////////////////////////////////////////////////////////////////////////////////


  /**
  scanUpToToken:

  :param: token Token.PunctuationToken

  :returns: (success: Bool, value: String?)
  */
  private func scanUpToToken(token: Token.PunctuationToken) -> (success: Bool, value: String?) {
    var string: NSString?
    let success = scanner.scanUpToCharactersFromSet(token.characterSet, intoString: &string)
    return (success, string)
  }

  /**
  scanComment:

  :param: error NSErrorPointer
  */
  private func scanComment(error: NSErrorPointer) {

    // Try scanning the for solidus characters
    let (success, solidusString) = scanToken(.Solidus, nil)

    // Return if we didn't scan any
    if !success { return }

    // Otherwise check if we scanned two or more
    if solidusString!.hasPrefix("//") {

      // Scan to the end of the line
      scanner.scanUpToCharactersFromSet(NSCharacterSet.newlineCharacterSet(), intoString: nil)

    }

    // Otherwise try scanning an opening asterisk
    else if scanToken(.Asterisk, nil).success {

      // We are inside an open multi-line comment, find the closing asterisk and solidus
      var success = false

      commentLoop: while !scanner.atEnd {

        // Find the closing asterisk
        if scanUpToToken(.Asterisk).success && scanToken(.Asterisk, nil).success {

          // Now check the next character
          if string[idx] == "/" {

            // We have found the end of the multi-line comment, break the loop
            idx++
            success = true
            break commentLoop
          }
        }

        // Make sure we ended any multi-line comment that we found
        if !success { setSyntaxError(error, "multi-line comment without end") }

      }

    }

    // If we get here then we have an illegal solitary solidus
    else {
      setSyntaxError(error, "malformed comment")
    }

  }

  /**
  scanToken:

  :param: token Token.ValueToken.StaticValueToken

  :returns: Bool
  */
  private func scanToken(token: Token.ValueToken.StaticValueToken) -> Bool {
    return scanner.scanString(token.toRaw(), intoString: nil)
  }

  /**
  scanToken:error:

  :param: token Token.PunctuationToken
  :param: error NSErrorPointer

  :returns: (success: Bool, value: String?)
  */
  private func scanToken(token: Token.PunctuationToken, _ error: NSErrorPointer) -> (success: Bool, value: String?) {
    if token.isCommentable { scanComment(error) }
    var string: NSString?
    let success = scanner.scanCharactersFromSet(token.characterSet, intoString: &string)
    if success && token.isCommentable { scanComment(error) }
    return (success, string)
  }

  /**
  scanNumber:

  :param: number AnyObject?

  :returns: Bool
  */
  private func scanNumber(inout number:AnyObject?) -> Bool {
    var num: Double = 0
    let success = scanner.scanDouble(&num)
    if success { number = num }
    return success
  }

  /**
  scanQuotedString:error:

  :param: string AnyObject?
  :param: error NSErrorPointer

  :returns: Bool
  */
  private func scanQuotedString(inout string:AnyObject?, _ error: NSErrorPointer) -> Bool {

    // First get past the first quotation mark
    var (success, quoteString) = scanToken(.Quotation, error)

    // Only proceed if we found a quotation mark
    if success {

      // Now scan up to another quotation mark, accumulating the text in `result`
      var (success, result) = scanUpToToken(.Quotation)

      // Continue scan up to the next quotation mark so long as we are succeeding and the last mark was escaped
      while success && result != nil && result!.hasSuffix("\\") {

        // Scan the text into a temporary `substring`
        var (success, substring) = scanUpToToken(.Quotation)

        // Extend our `result` string with the text from `substring` if non-nil
        if substring != nil { result!.extend(substring!) }
      }

      // If we have been successful, set the `inout string` parameter to our `result` string
      if success && result != nil { (success, _) = scanToken(.Quotation, error); if success { string = result } }

    }

    return success

  }


  ////////////////////////////////////////////////////////////////////////////////
  /// MARK: - Parsing the string
  ////////////////////////////////////////////////////////////////////////////////


  /**
  parseObject:

  :param: error NSErrorPointer = nil

  :returns: Bool
  */
  private func parseObject(error: NSErrorPointer = nil) -> Bool {

    var success = false
    var localError: NSError?

    // Try to scan the opening punctuation for an object
    if scanToken(.LeftCurlyBracket, &localError).success {

      success = true
      objectStack.push(MSDictionary())   // Push a new dictionary onto the object stack
      contextStack.push(Context.Object)  // Push object context
      contextStack.push(Context.Key)     // Push key context


    }

    // Then try to scan a comma separating another object key value pair
    else if scanToken(.Comma, &localError).success {
      success = true
      contextStack.push(Context.Key)
    }

    // Lastly, try to scan the closing punctuation for an object
    else if scanToken(.RightCurlyBracket, &localError).success {


      // Pop context, making sure it is correct
      if contextStack.pop() == Context.Object {

        // Make sure we have another context on the stack
        if let context = contextStack.peek {

          // Replace start context with end context if we have completed the root object
          if context == Context.Start {
            contextStack.pop()
            assert(contextStack.isEmpty)
            contextStack.push(Context.End)
            success = true
          }

          // If not the root object, pop this object off of the stack and add to underlying object
          else if let dict = objectStack.pop() as? MSDictionary { success = addValueToTopObject(dict, error) }

          // If we can't get the completed array, set error
          else { setInternalError(error, "dictionary absent from object stack", underlyingError: localError) }

        }

        // Set error if our context stack is empty
        else { setInternalError(error, "empty context stack", underlyingError: localError) }

      }

      // Set error if we popped a context other than object
      else { setInternalError(error, "incorrect context popped off of stack", underlyingError: localError) }

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

    // Try to scan the opening punctuation for an object
    if scanToken(.LeftSquareBracket, &localError).success {

      success = true
      objectStack.push(NSMutableArray())   // Push a new array onto the object stack
      contextStack.push(Context.Array)  // Push the array context
      contextStack.push(Context.Value)  // Push the value context

    }

    // Then try to scan a comma separating another object key value pair
    else if scanToken(.Comma, &localError).success { success = true; contextStack.push(Context.Value) }

    // Lastly, try to scan the closing punctuation for an object
    else if scanToken(.RightSquareBracket, &localError).success {


      // Pop context, making sure it is correct
      if contextStack.pop() == Context.Array {

        // Make sure we have another context on the stack
        if let context = contextStack.peek {

          // Replace start context with end context if we have completed the root object
          if context == Context.Start {
            contextStack.pop()
            contextStack.push(Context.End)
            success = true
          }

          // If not the root object, pop this object off of the stack and add to underlying object
          else if let array = objectStack.pop() as? NSMutableArray { success = addValueToTopObject(array, error) }

          // If we can't get the completed array, set error
          else { setInternalError(error, "array absent from object stack", underlyingError: localError) }

        }

        // Set error if our context stack is empty
        else { setInternalError(error, "empty context stack", underlyingError: localError) }

      }

      // Set error if we popped a context other than array
      else { setInternalError(error, "incorrect context popped off of stack", underlyingError: localError) }

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
    var value: AnyObject?
    var localError: NSError?

    if !(contextStack.pop() == Context.Value) {
      setInternalError(error, "incorrect context popped off of stack")
      return false
    }

    // Try scanning a true literal
    if scanToken(.True) { value = true; success = true }

    // Try scanning a false literal
    else if scanToken(.False) { value = false; success = true  }

    // Try scanning a null literal
    else if scanToken(.Null) { value = NSNull(); success = true  }

    // Try scanning a number
    else if scanNumber(&value)
      || scanQuotedString(&value, &localError)
      || parseObject(error: &localError)
      || parseArray(error: &localError)
    {
      success = true
    }

    // Set error
    else { setSyntaxError(error, "failed to parse value", underlyingError: localError) }

    if success && value != nil { success = addValueToTopObject(value!, error) }

    return success

  }

  /**
  parseKey:

  :param: error NSErrorPointer = nil

  :returns: Bool
  */
  private func parseKey(error: NSErrorPointer = nil) -> Bool {

    var success = false
    var key: AnyObject?
    var localError: NSError?

    if scanQuotedString(&key, &localError) {


      // Pop off context, making sure it is of the correct value
      if contextStack.pop() == Context.Key {

        keyStack.push(key! as String)
        logAddedObject(key!, keyStack, __FUNCTION__)

        // Parse the delimiting colon
        if scanToken(.Colon, &localError).success {
          contextStack.push(.Value)
          success = true
        }

        // Set error if we could not match the colon
        else { setSyntaxError(error, "missing colon after key", underlyingError: localError) }

      }

      // Set error if we popped a context other than key
      else { setInternalError(error, "incorrect context popped off of stack", underlyingError: localError) }

    }

    // Set error if we failed to match a key
    else { setSyntaxError(error, "missing key for object element", underlyingError: localError) }

    return success

  }


  /**
  addValueToTopObject:error:

  :param: value AnyObject
  :param: error NSErrorPointer = nil

  :returns: Bool
  */
  private func addValueToTopObject(value: AnyObject, _ error: NSErrorPointer = nil) -> Bool {

    var success = false

    if let context = contextStack.peek {

      if context == Context.Object {

        // Try getting the top object as a dictionary
        if let dict = objectStack.peek as? MSDictionary {

          // Set the value for the key obtained from stack
          if let key = keyStack.pop() {
            dict[key] = value
            success = true
          }

            // Set error if we don't have a key
          else { setInternalError(error, "empty key stack") }

        }
        // Otherwise set error
        else { setInternalError(error, "missing object in stack to receive new value") }

      }

      else if context == Context.Array {

        // Then try getting the top object as an array
        if var array = objectStack.pop() as? NSMutableArray {

          array.addObject(value)
          objectStack.push(array)
          success = true

        }

        // Otherwise set error
        else { setInternalError(error, "missing object in stack to receive new value") }

      }

    }

    else { setInternalError(error, "empty context stack") }

    return success

  }

  /**
  parse:

  :param: error NSErrorPointer = nil

  :returns: AnyObject?
  */
  public func parse(error: NSErrorPointer = nil) -> AnyObject? {

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

    var object: AnyObject?  // Variable to hold result to be returned

    // If the root object ends the text we won't hit the `.End` case in our switch statement
    if !objectStack.isEmpty {

      // Make sure we haven't actually set `object` yet if we have objects left in the stack
      if object != nil  || objectStack.count > 1 {
        setInternalError(error, "objects left in stack")
      }

      // If we haven't set object and we have one object in our stack, pop it
      else { object = objectStack.pop() }

    }

    logDebug("parsed object…\n\(object)", __FUNCTION__, level: LogLevel)

    return object

  }

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - Supporting enumerations for the parser
////////////////////////////////////////////////////////////////////////////////


/// Generalized enumeration for all parsable tokens
////////////////////////////////////////////////////////////////////////////////////////////////////
private enum Token {

  /// Enumeration for punctuation tokens used in `Token.Punctation` associations
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  enum PunctuationToken: String {
    case LeftCurlyBracket   = "{"
    case RightCurlyBracket  = "}"
    case LeftSquareBracket  = "["
    case RightSquareBracket = "]"
    case Colon              = ":"
    case Comma              = ","
    case Quotation          = "\""
    case Solidus            = "/"
    case Asterisk           = "*"

    var isCommentable: Bool { switch self { case .Quotation, .Solidus, .Asterisk: return false; default: return true } }

    var characterSet: NSCharacterSet {
      switch self {
        case .LeftCurlyBracket:   return PunctuationToken.LeftCurlyBracketCharacterSet
        case .RightCurlyBracket:  return PunctuationToken.RightCurlyBracketCharacterSet
        case .LeftSquareBracket:  return PunctuationToken.LeftSquareBracketCharacterSet
        case .RightSquareBracket: return PunctuationToken.RightSquareBracketCharacterSet
        case .Colon:              return PunctuationToken.ColonCharacterSet
        case .Comma:              return PunctuationToken.CommaCharacterSet
        case .Quotation:          return PunctuationToken.QuotationCharacterSet
        case .Solidus:            return PunctuationToken.SolidusCharacterSet
        case .Asterisk:           return PunctuationToken.AsteriskCharacterSet
      }
    }

    static var LeftCurlyBracketCharacterSet   = NSCharacterSet(character: "{" )
    static var RightCurlyBracketCharacterSet  = NSCharacterSet(character: "}" )
    static var LeftSquareBracketCharacterSet  = NSCharacterSet(character: "[" )
    static var RightSquareBracketCharacterSet = NSCharacterSet(character: "]" )
    static var ColonCharacterSet              = NSCharacterSet(character: ":" )
    static var CommaCharacterSet              = NSCharacterSet(character: "," )
    static var QuotationCharacterSet          = NSCharacterSet(character: "\"")
    static var SolidusCharacterSet            = NSCharacterSet(character: "/" )
    static var AsteriskCharacterSet           = NSCharacterSet(character: "*" )
  }

  /// Generalized enumeration for value type tokens that are not collections of other tokens
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  enum ValueToken {


    /// Enumeration for value tokens that always have the same representation
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    enum StaticValueToken: String {
      case Null  = "null"
      case True  = "true"
      case False = "false"

      static var NullCharacterSet  = NSCharacterSet(charactersInString: "null")
      static var TrueCharacterSet  = NSCharacterSet(charactersInString: "true")
      static var FalseCharacterSet = NSCharacterSet(charactersInString: "false")

    }

    case QuotedString (String)
    case Number       (NSNumber)
    case Static       (StaticValueToken)

  }

  case Value        (ValueToken)
  case Punctuation  (PunctuationToken)

  var characterSet: NSCharacterSet { return self.0.characterSet }

}

/// Enumeration to represent the current parser state
////////////////////////////////////////////////////////////////////////////////
private enum Context: Printable {
  case Start, Object, Value, Array, Key, End
  var description: String {
    switch self {
      case .Start:  return "start"
      case .Object: return "object"
      case .Value:  return "value"
      case .Array:  return "array"
      case .Key:    return "key"
      case .End:    return "end"
    }
  }
}
