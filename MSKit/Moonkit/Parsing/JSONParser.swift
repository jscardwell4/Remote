//
//  JSONParser.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/16/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

/**

`JSONParser` is a simple class for parsing a JSON string into an object. The grammar recognized follows:

*note: All whitespace excluding that which appears inside a quoted string is ignored. Additionally, anywhere such
"discardable" whitespace can occur is also a valid location to insert the <comment> production listed below:

comment → single-line-comment | multi-line-comment

single-line-comment → / / ⏎ | / / single-line-comment-items ⏎
single-line-comment-items → single-line-comment-item | single-line-comment-item single-line-comment-items
single-line-comment-item → Any Unicode character except for ⏎

multi-line-comment → / * * / | / * multi-line-comment-items * /
multi-line-comment-items → multi-line-comment-item | multi-line-comment-item multi-line-comment-items
multi-line-comment-item → non-asterisk-character | * non-solidus-character
non-asterisk-character → Any Unicode character except for *
non-solidus-character → Any Unicode character except for /

This is the grammar without flooding the notation with all the possible appearances of the <comment> production:

start → array | object

object → { } | { key-value-list }
key-value-list → key-value | key-value , key-value-list
key-value → string-literal : value

array → [ ] | [ value-list ]
value-list → value | value , value-list

value → null-literal | boolean-literal | number-literal | string-literal | array | object

string-literal → " " | " ­quoted-text­ "
quoted-text → quoted-text-item | quoted-text-item ­quoted-text­
quoted-text-item → escaped-character | Any Unicode character except for ", ⏎, \
escaped-character → \ escaped-character-item
escaped-character-item → " | \ | / | b | f | n | r | t | u hexidecimal-digits
hexidecimal-digits → hexidecimal-digit hexidecimal-digit hexidecimal-digit hexidecimal-digit
hexidecimal-digit → 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | A | B | C | D | E | F


null-literal → null
boolean-literal → true | false

number-literal → decimal-literal | decimal-literal decimal-exponent
decimal-literal → positive-decimal-literal | negative-decimal-literal
negative-decimal-literal → - decimal-digits | - decimal-digits decimal-fraction
positive-decimal-literal → decimal-digits | decimal-digits decimal-fraction
decimal-digits → decimal-digit decimal-digitsœ
decimal-digit → 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
decimal-fraction → . decimal-digits
decimal-exponent →  decimal-exponent-e decimal-digits | decimal-exponent-e sign decimal-digits
decimal-exponent-e → e | E
sign → + | -

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
  public init(string: String) { setLogLevel(LOG_LEVEL_ERROR); scanner = NSScanner(string: string); super.init() }


  /** Parser error domain and error codes */
  public let JSONParserErrorDomain = "JSONParserErrorDomain"
  public enum JSONParserErrorCode: Int { case Internal, InvalidSyntax }


  /**
  setError:code:reason:

  :param: pointer NSErrorPointer
  :param: code JSONParserErrorCode
  :param: reason String?
  */
  private func setError(pointer: NSErrorPointer, _ code: JSONParserErrorCode, _ reason: String?) {
    if pointer != nil {
      var info: [NSObject:AnyObject]?
      if reason != nil { info = [NSLocalizedFailureReasonErrorKey: reason! + " near location \(idx)"] }
      pointer.memory = NSError(domain: JSONParserErrorDomain, code: code.toRaw(), userInfo: info)
    }
  }

  /**
  setInternalError:reason:

  :param: pointer NSErrorPointer
  :param: reason String?
  */
  private func setInternalError(pointer: NSErrorPointer, _ reason: String?) { setError(pointer, .Internal, reason) }

  /**
  setSyntaxError:reason:

  :param: pointer NSErrorPointer
  :param: reason String?
  */
  private func setSyntaxError(pointer: NSErrorPointer, _ reason: String?) { setError(pointer, .InvalidSyntax, reason) }

  /**
  logContextStack:file:function:line:

  :param: message String
  :param: file String
  :param: function String
  :param: line Int
  */
  private func logContextStack(message: String, _ function: String) {
    logDebug("\(message) (\(String.CommaSpace.join(contextStack.map{$0.description})))", function)
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
    logDebug("added \(addedObject.description) to \(containingObject.description)", function)
  }

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
  scanLiteralToken:

  :param: token Token.ValueToken.StaticValueToken

  :returns: Bool
  */
  private func scanLiteralToken(token: Token.ValueToken.StaticValueToken) -> Bool {
    return scanner.scanString(token.toRaw(), intoString: nil)
  }

  /**
  scanToken:

  :param: token Token.PunctuationToken

  :returns: (success: Bool, value: String?)
  */
  private func scanToken(token: Token.PunctuationToken) -> (success: Bool, value: String?) {
    var string: NSString?
    let success = scanner.scanCharactersFromSet(token.characterSet, intoString: &string)
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
  scanQuotedString:

  :param: string AnyObject?

  :returns: Bool
  */
  private func scanQuotedString(inout string:AnyObject?) -> Bool {

    // First get past the first quotation mark
    var (success, _) = scanToken(.Quotation)

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
      if success && result != nil { (success, _) = scanToken(.Quotation); if success { string = result } }

    }

    return success

  }

  /**
  parseObject:

  :param: error NSErrorPointer = nil

  :returns: Bool
  */
  private func parseObject(error: NSErrorPointer = nil) -> Bool {

    var success = false

    // Try to scan the opening punctuation for an object
    if scanToken(Token.PunctuationToken.LeftCurlyBracket).success {

      success = true
      objectStack.push(MSDictionary())   // Push a new dictionary onto the object stack
      contextStack.push(Context.Object)  // Push object context
      contextStack.push(Context.Key)     // Push key context


    }

    // Then try to scan a comma separating another object key value pair
    else if scanToken(Token.PunctuationToken.Comma).success {
      success = true
      contextStack.push(Context.Key)
    }

    // Lastly, try to scan the closing punctuation for an object
    else if scanToken(Token.PunctuationToken.RightCurlyBracket).success {


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
          else { setInternalError(error, "dictionary absent from object stack") }

        }

        // Set error if our context stack is empty
        else { setInternalError(error, "empty context stack") }

      }

      // Set error if we popped a context other than object
      else { setInternalError(error, "incorrect context popped off of stack") }

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

    // Try to scan the opening punctuation for an object
    if scanToken(Token.PunctuationToken.LeftSquareBracket).success {

      success = true
      objectStack.push([AnyObject]())   // Push a new array onto the object stack
      contextStack.push(Context.Array)  // Push the array context
      contextStack.push(Context.Value)  // Push the value context

    }

    // Then try to scan a comma separating another object key value pair
    else if scanToken(Token.PunctuationToken.Comma).success { success = true; contextStack.push(Context.Value) }

    // Lastly, try to scan the closing punctuation for an object
    else if scanToken(Token.PunctuationToken.RightSquareBracket).success {


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
          else if let array = objectStack.pop() as? [AnyObject] { success = addValueToTopObject(array, error) }

          // If we can't get the completed array, set error
          else { setInternalError(error, "array absent from object stack") }

        }

        // Set error if our context stack is empty
        else { setInternalError(error, "empty context stack") }

      }

      // Set error if we popped a context other than array
      else { setInternalError(error, "incorrect context popped off of stack") }

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


    if !(contextStack.pop() == Context.Value) {
      setInternalError(error, "incorrect context popped off of stack")
      return false
    }

    // Try scanning a true literal
    if scanLiteralToken(.True) { value = true; success = true }

    // Try scanning a false literal
    else if scanLiteralToken(.False) { value = false; success = true  }

    // Try scanning a null literal
    else if scanLiteralToken(.Null) { value = NSNull(); success = true  }

    // Try scanning a number
    else if scanNumber(&value) || scanQuotedString(&value) || parseObject(error: error) || parseArray(error: error) {
      success = true
    }

    // Set error
    else { setSyntaxError(error, "failed to parse value") }

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

    if scanQuotedString(&key) {


      // Pop off context, making sure it is of the correct value
      if contextStack.pop() == Context.Key {

        keyStack.push(key! as String)
        logAddedObject(key!, keyStack, __FUNCTION__)

        // Parse the delimiting colon
        if scanToken(.Colon).success {
          contextStack.push(.Value)
          success = true
        }

        // Set error if we could not match the colon
        else { setSyntaxError(error, "missing colon after key") }

      }

      // Set error if we popped a context other than key
      else { setInternalError(error, "incorrect context popped off of stack") }

    }

    // Set error if we failed to match a key
    else { setSyntaxError(error, "missing key for object element") }

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
        if var array = objectStack.pop() as? [AnyObject] {

          array.append(value)
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

    return object

  }

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - Supporting enumerations for the parser
////////////////////////////////////////////////////////////////////////////////


/// Generalized enumeration for all parsable tokens
////////////////////////////////////////////////////////////////////////////////////////////////////
private enum Token: Printable {

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

    var characterSet: NSCharacterSet {
      switch self {
        case .LeftCurlyBracket:   return PunctuationToken.LeftCurlyBracketCharacterSet
        case .RightCurlyBracket:  return PunctuationToken.RightCurlyBracketCharacterSet
        case .LeftSquareBracket:  return PunctuationToken.LeftSquareBracketCharacterSet
        case .RightSquareBracket: return PunctuationToken.RightSquareBracketCharacterSet
        case .Colon:              return PunctuationToken.ColonCharacterSet
        case .Comma:              return PunctuationToken.CommaCharacterSet
        case .Quotation:          return PunctuationToken.QuotationCharacterSet
      }
    }

    static var LeftCurlyBracketCharacterSet   = NSCharacterSet(character: "{")
    static var RightCurlyBracketCharacterSet  = NSCharacterSet(character: "}")
    static var LeftSquareBracketCharacterSet  = NSCharacterSet(character: "[")
    static var RightSquareBracketCharacterSet = NSCharacterSet(character: "]")
    static var ColonCharacterSet              = NSCharacterSet(character: ":")
    static var CommaCharacterSet              = NSCharacterSet(character: ",")
    static var QuotationCharacterSet          = NSCharacterSet(character: "\"")
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

        var characterSet: NSCharacterSet {
          switch self {
            case .Null:  return StaticValueToken.NullCharacterSet
            case .True:  return StaticValueToken.TrueCharacterSet
            case .False: return StaticValueToken.FalseCharacterSet
          }
      }
    }

    case QuotedString (String)
    case Number       (NSNumber)
    case Static       (StaticValueToken)

    static var NumberCharacterSet       = NSCharacterSet.decimalDigitCharacterSet()
    static var QuotedStringCharacterSet = NSCharacterSet.illegalCharacterSet().invertedSet

    var characterSet: NSCharacterSet {
      switch self {
        case .Static:       return self.0.characterSet
        case .Number:       return ValueToken.NumberCharacterSet
        case .QuotedString: return ValueToken.QuotedStringCharacterSet
      }
    }

  }

  case Value        (ValueToken)
  case Punctuation  (PunctuationToken)

  static var LeftCurlyBracket   = Token.Punctuation(.LeftCurlyBracket)
  static var RightCurlyBracket  = Token.Punctuation(.RightCurlyBracket)
  static var LeftSquareBracket  = Token.Punctuation(.LeftSquareBracket)
  static var RightSquareBracket = Token.Punctuation(.RightSquareBracket)
  static var Colon              = Token.Punctuation(.Colon)
  static var Comma              = Token.Punctuation(.Comma)
  static var True               = Token.Value(.Static(.True))
  static var False              = Token.Value(.Static(.False))
  static var Null               = Token.Value(.Static(.Null))


  var characterSet: NSCharacterSet { return self.0.characterSet }

  var description: String {
    switch self {
      case .Punctuation(let p):
        switch p {
          case .LeftCurlyBracket:   return "{"
          case .RightCurlyBracket:  return "}"
          case .LeftSquareBracket:  return "["
          case .RightSquareBracket: return "]"
          case .Colon:              return ":"
          case .Comma:              return ","
          case .Quotation:          return "\""
        }

      case .Value(let v):
        switch v {
          case .Static(let s):
            switch s {
              case .True:  return "true"
              case .False: return "false"
              case .Null:  return "null"
            }
          case .QuotedString(let s): return s
          case .Number(let n):       return "\(n)"
        }
    }
  }

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
      case .End:    return "key"
    }
  }
}
