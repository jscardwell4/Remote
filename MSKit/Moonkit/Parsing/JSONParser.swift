//
//  JSONParser.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/16/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

public let JSONParserErrorDomain = "JSONParserErrorDomain"
public enum JSONParserErrorCode: Int {
  case InternalInconsistency
  case InvalidSyntax
}

/*
 @symbolState = '"';

 @start            = array | object;

 object            = openCurly (Empty | keyPath colon value (comma keyPath colon value)*) closeCurly;
 keyPath           = quote key (dot key)* quote;
 key               = Word;

 array             = openBracket (Empty | value (comma value)*) closeBracket;

 value             = (nullLiteral | trueLiteral | falseLiteral | number | string | array | object);

 string            = QuotedString;
 number            = Number;
 nullLiteral       = 'null';
 trueLiteral       = 'true';
 falseLiteral      = 'false';

 openCurly         = '{';
 closeCurly        = '}';
 openBracket       = '[';
 closeBracket      = ']';
 comma             = ',';
 colon             = ':';
 quote             = '"';
 dot               = '.';
 */
@objc(MSJSONParser)
public class JSONParser: NSObject {

  public var string: String { return scanner.string }
  public var idx:    Int    { get { return scanner.scanLocation } set { scanner.scanLocation = newValue } }

  private var tokenStack:   Stack<Token>     = Stack<Token>()
  private var contextStack: Stack<Context>   = Stack<Context>()
  private var objectStack:  Stack<AnyObject> = Stack<AnyObject>()
  private var keyStack:     Stack<String>    = Stack<String>()
  private let scanner:      NSScanner

  /**
  initWithString:

  :param: string String
  */
  public init(string: String) { scanner = NSScanner(string: string); super.init() }


  /**
  setErrorForPointer:code:reason:

  :param: pointer NSErrorPointer
  :param: code JSONParserErrorCode
  :param: reason String?
  */
  private func setErrorForPointer(pointer: NSErrorPointer, _ code: JSONParserErrorCode, _ reason: String?) {
    if pointer != nil {
      var info: [NSObject:AnyObject]?
      if reason != nil { info = [NSLocalizedFailureReasonErrorKey: reason! + " near location \(idx)"] }
      pointer.memory = NSError(domain: JSONParserErrorDomain, code: code.toRaw(), userInfo: info)
    }
  }

  private func logContextStack(message: String, _ file: String, _ function: String, _ line: Int) {
    logDebug("\(message) (\(String.CommaSpace.join(contextStack.map{$0.description})))", file, function, line)
  }

  private func logAddedObject(addedObject: AnyObject, _ containingObject: Printable,
                              _ file: String, _ function: String, _ line: Int)
  {
    logDebug("added \(addedObject.description) to \(containingObject.description)", file, function, line)
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
    var success: Bool
    (success, _) = scanToken(.Quotation)
    if success {
      var s: String?
      (success, s) = scanUpToToken(.Quotation)
      while success && s != nil && s!.hasSuffix("\\") {
        var substring: String?
        (success, substring) = scanUpToToken(.Quotation)
        if substring != nil { s!.extend(substring!) }
        if success { string = s }
      }
      if success && s != nil { (success, _) = scanToken(.Quotation); if success { string = s } }

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
      logAddedObject(objectStack.peek!, objectStack, __FILE__, __FUNCTION__, __LINE__)
      contextStack.push(Context.Object)  // Push object context
      contextStack.push(Context.Key)     // Push key context

      logContextStack("pushed contexts onto stack", __FILE__, __FUNCTION__, __LINE__)

    }

    // Then try to scan a comma separating another object key value pair
    else if scanToken(Token.PunctuationToken.Comma).success {
      success = true
      contextStack.push(Context.Key)
      logContextStack("pushed context onto stack", __FILE__, __FUNCTION__, __LINE__)
    }

    // Lastly, try to scan the closing punctuation for an object
    else if scanToken(Token.PunctuationToken.RightCurlyBracket).success {

      logContextStack("popping context off of stack", __FILE__, __FUNCTION__, __LINE__)

      // Pop context, making sure it is correct
      if contextStack.pop() == Context.Object {

        // Make sure we have another context on the stack
        if let context = contextStack.peek {

          // Replace start context with end context if we have completed the root object
          if context == Context.Start {
            logContextStack("popping context off of stack", __FILE__, __FUNCTION__, __LINE__)
            contextStack.pop()
            assert(contextStack.isEmpty)
            contextStack.push(Context.End)
            logContextStack("pushed context onto stack", __FILE__, __FUNCTION__, __LINE__)
            success = true
          }

          // If not the root object, pop this object off of the stack and add to underlying object
          else if let dict = objectStack.pop() as? MSDictionary { success = addValueToTopObject(dict, error) }

          // If we can't get the completed array, set error
          else { setErrorForPointer(error, .InternalInconsistency, "dictionary absent from object stack") }

        }

        // Set error if our context stack is empty
        else { setErrorForPointer(error, .InternalInconsistency, "empty context stack") }

      }

      // Set error if we popped a context other than object
      else { setErrorForPointer(error, .InternalInconsistency, "incorrect context popped off of stack") }

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
      logAddedObject(objectStack.peek!, objectStack, __FILE__, __FUNCTION__, __LINE__)
      contextStack.push(Context.Array)  // Push the array context
      contextStack.push(Context.Value)  // Push the value context
      logContextStack("pushed contexts onto stack", __FILE__, __FUNCTION__, __LINE__)

    }

    // Then try to scan a comma separating another object key value pair
    else if scanToken(Token.PunctuationToken.Comma).success { success = true; contextStack.push(Context.Value) }

    // Lastly, try to scan the closing punctuation for an object
    else if scanToken(Token.PunctuationToken.RightSquareBracket).success {

      logContextStack("popping context off of stack", __FILE__, __FUNCTION__, __LINE__)

      // Pop context, making sure it is correct
      if contextStack.pop() == Context.Array {

        // Make sure we have another context on the stack
        if let context = contextStack.peek {

          // Replace start context with end context if we have completed the root object
          if context == Context.Start {
            logContextStack("popping context off of stack", __FILE__, __FUNCTION__, __LINE__)
            contextStack.pop()
            contextStack.push(Context.End)
            logContextStack("pushed context onto stack", __FILE__, __FUNCTION__, __LINE__)
            success = true
          }

          // If not the root object, pop this object off of the stack and add to underlying object
          else if let array = objectStack.pop() as? [AnyObject] { success = addValueToTopObject(array, error) }

          // If we can't get the completed array, set error
          else { setErrorForPointer(error, .InternalInconsistency, "array absent from object stack") }

        }

        // Set error if our context stack is empty
        else { setErrorForPointer(error, .InternalInconsistency, "empty context stack") }

      }

      // Set error if we popped a context other than array
      else { setErrorForPointer(error, .InternalInconsistency, "incorrect context popped off of stack") }

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

    logContextStack("popping context off of stack", __FILE__, __FUNCTION__, __LINE__)

    if !(contextStack.pop() == Context.Value) {
      setErrorForPointer(error, .InternalInconsistency, "incorrect context popped off of stack")
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
    else { setErrorForPointer(error, .InvalidSyntax, "failed to parse value") }

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

      logContextStack("popping context off of stack", __FILE__, __FUNCTION__, __LINE__)

      // Pop off context, making sure it is of the correct value
      if contextStack.pop() == Context.Key {

        keyStack.push(key! as String)
        logAddedObject(key!, keyStack, __FILE__, __FUNCTION__, __LINE__)

        // Parse the delimiting colon
        if scanToken(.Colon).success {
          contextStack.push(.Value)
          logContextStack("pushed context onto stack", __FILE__, __FUNCTION__, __LINE__)
          success = true
        }

        // Set error if we could not match the colon
        else { setErrorForPointer(error, .InvalidSyntax, "missing colon after key") }

      }

      // Set error if we popped a context other than key
      else { setErrorForPointer(error, .InternalInconsistency, "incorrect context popped off of stack") }

    }

    // Set error if we failed to match a key
    else { setErrorForPointer(error, .InvalidSyntax, "missing key for object element") }

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
            logAddedObject(value, dict, __FILE__, __FUNCTION__, __LINE__)
            success = true
          }

            // Set error if we don't have a key
          else { setErrorForPointer(error, .InternalInconsistency, "empty key stack") }

        }
        // Otherwise set error
        else { setErrorForPointer(error, .InternalInconsistency, "missing object in stack to receive new value") }

      }


      else if context == Context.Array {

        // Then try getting the top object as an array
        if var array = objectStack.pop() as? [AnyObject] {

          array.append(value)
          objectStack.push(array)
          logAddedObject(value, array, __FILE__, __FUNCTION__, __LINE__)
          success = true

        }

        // Otherwise set error
        else { setErrorForPointer(error, .InternalInconsistency, "missing object in stack to receive new value") }

      }

    }

    else { setErrorForPointer(error, .InternalInconsistency, "empty context stack") }

    return success

  }


  /**
  parse:

  :param: error NSErrorPointer = nil

  :returns: AnyObject?
  */
  public func parse(error: NSErrorPointer = nil) -> AnyObject? {

    contextStack.push(.Start)
    logContextStack("pushed context onto stack", __FILE__, __FUNCTION__, __LINE__)

    var object: AnyObject?  // The root object

    scanLoop: while !scanner.atEnd {

      if let context = contextStack.peek {

        switch context {

          case .Start: // To be valid, we must be able to scan an opening bracked of some kind
            if !(parseObject(error: error) || parseArray(error: error)) {
              // Set error if we fail to match the start of an array or an object and exit loop

              setErrorForPointer(error, .InvalidSyntax, "root must be an object/array")
              break scanLoop
            }

          case .Value: // Try to scan a number, a boolean, null, the start of an object, or the start of an array
            if !parseValue(error: error) {
              break scanLoop
            }


          case .Object: // Try to scan a comma or curly bracket
            if !parseObject(error: error) {
              break scanLoop
            }


          case .Array: // Try to scan a comma or square bracket
            if !parseArray(error: error) {
              break scanLoop
            }

          case .Key: // Try to scan a quoted string for use as a dictionary key
            if !parseKey(error: error) {
              break scanLoop
            }

          case .End: // Pop the root object off of the object stack and set it as our return value
            object = objectStack.pop()
            break scanLoop

        }

      }

    }

    if object == nil && objectStack.count == 1 { object = objectStack.pop() }
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

  enum PunctuationToken: String, Printable {
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

      var description: String { return "wtf" } //self.toRaw() }
  }

  /// Generalized enumeration for value type tokens that are not collections of other tokens
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  enum ValueToken: Printable {


    /// Enumeration for value tokens that always have the same representation
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    enum StaticValueToken: String, Printable {
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

      var description: String { return "wtf" } //self.toRaw() }
    }

    case QuotedString (String)
    case Number       (NSNumber)
    case Static       (StaticValueToken)

    static var NumberCharacterSet = NSCharacterSet.decimalDigitCharacterSet()
    static var QuotedStringCharacterSet = NSCharacterSet.illegalCharacterSet().invertedSet

    var characterSet: NSCharacterSet {
      switch self {
        case .Static:       return self.0.characterSet
        case .Number:       return ValueToken.NumberCharacterSet
        case .QuotedString: return ValueToken.QuotedStringCharacterSet
      }
    }

    var description: String { return "wtf" }//self.0.description }

  }

  case Value        (ValueToken)
  case Punctuation  (PunctuationToken)
  case Array        ([AnyObject])
  case Object       ([String:AnyObject])

  static var LeftCurlyBracket   = Token.Punctuation(.LeftCurlyBracket)
  static var RightCurlyBracket  = Token.Punctuation(.RightCurlyBracket)
  static var LeftSquareBracket  = Token.Punctuation(.LeftSquareBracket)
  static var RightSquareBracket = Token.Punctuation(.RightSquareBracket)
  static var Colon              = Token.Punctuation(.Colon)
  static var Comma              = Token.Punctuation(.Comma)
  static var True               = Token.Value(.Static(.True))
  static var False              = Token.Value(.Static(.False))
  static var Null               = Token.Value(.Static(.Null))


  var characterSet: NSCharacterSet {
    switch self {
      case .Punctuation:    return self.0.characterSet
      case .Value:          return self.0.characterSet
      case .Array, .Object: return NSCharacterSet()
    }
  }

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
      default: return "root wtf"
    }
  }

}

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
