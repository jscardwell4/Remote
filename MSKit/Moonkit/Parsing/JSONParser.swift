//
//  JSONParser.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/16/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

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

  public var string: String { return scanner.string }
  private var idx: Int { get { return scanner.scanLocation } set { scanner.scanLocation = newValue } }
  private var tokenStack: Stack<Token> = Stack<Token>()
  private var contextStack: Stack<Context> = Stack<Context>()
  private let scanner: NSScanner

  public init(string: String) { scanner = NSScanner(string: string); super.init() }


  /**
  scanUpToToken:

  :param: token Token.PunctuationToken

  :returns:
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

  :returns:
  */
  private func scanToken(token: Token.PunctuationToken) -> (success: Bool, value: String?) {

    var string: NSString?
    let success = scanner.scanCharactersFromSet(token.characterSet, intoString: &string)
    return (success, string)
  }

  /**
  scanNumber

  :returns:
  */
  private func scanNumber() -> (success: Bool, value: Double) {

    var number = Double(CGFloat.max)
    let success = scanner.scanDouble(&number)
    return (success, number)
  }

  /**
  scanQuotedString

  :returns:
  */
  private func scanQuotedString() -> (success: Bool, value: String?) {

    var success: Bool
    var string: String?
    (success, _) = scanToken(.Quotation)
    if success {
      (success, string) = scanUpToToken(.Quotation)
      while success && string != nil && string!.hasSuffix("\\") {
        var substring: String?
        (success, substring) = scanUpToToken(.Quotation)
        if substring != nil { string!.extend(substring!) }
      }
      if success && string != nil {
        (success, _) = scanToken(.Quotation)
      }
    }
    return (success, string)
  }

  /**
  parse

  */
  public func parse() {

    contextStack.push(.Start)

    scanLoop: while !scanner.atEnd {

      if let context = contextStack.peek {

        switch context {

        case .Start:
          // To be valid, we must be able to scan an opening bracked of some kind

          if scanToken(.LeftCurlyBracket).success {
            // Starting an object, push object and string contexts to look for the first key

            contextStack.push([.Object, .Key])
            tokenStack.push(.LeftCurlyBracket)

          }

          else if scanToken(.LeftSquareBracket).success {
            // Starting an array, push array and value contexts to look for the first value

            contextStack.push([.Array, .Value])
            tokenStack.push(.LeftSquareBracket)

          }

          else {
            // Failure to find an opening bracket means this json string is invalid

            println("parse failed at location \(idx)")
            break scanLoop

          }

        case .Value:
          // We are looking for one of the following:
          //   a number, a boolean, null, the start of an object, or the start of an array

          if scanLiteralToken(.True) {
            // Found true literal, push token and pop context

            contextStack.pop()
            tokenStack.push(Token.True)

          } else if scanLiteralToken(.False) {
            // Found false literal, push token and pop context

            contextStack.pop()
            tokenStack.push(.False)

          } else if scanLiteralToken(.Null) {
            // Found null literal, push token and pop context

            contextStack.pop()
            tokenStack.push(.Null)

          } else if scanToken(.LeftCurlyBracket).success {
            // Found the start of an object, update context

            contextStack.pop()
            contextStack.push([.Object, .Key])

          } else if scanToken(.LeftSquareBracket).success {
            // Found the start of an array, update context

            contextStack.pop()
            contextStack.push([.Array, .Value])

          } else {

            let result = scanNumber()
            if result.success {
              // Found a number, push token and pop context

              contextStack.pop()
              tokenStack.push(.Value(.Number(result.value)))

            } else {

              let result = scanQuotedString()
              if result.success && result.value != nil {
                // Found a number, push token and pop context

                contextStack.pop()
                tokenStack.push(.Value(.QuotedString(result.value!)))

              }

              else {
                // Failed to parse a value

                println("parse failed looking for value near location \(idx)")
                break scanLoop

              }

            }

          }

        case .Object:
          // Try to scan a comma or closing bracket

          if scanner.scanCharacter(",") {
            // Push string context to parse key of the entry to follow the comma

            contextStack.push(.Key)
            tokenStack.push(.Comma)

          }

          else if scanner.scanCharacter("}") {
            // The object has been parsed. Clean up context stack

            contextStack.pop() // Pop off object context

            if contextStack.peek! == .Start {
              // We have finished parsing, pop start out of stack and push end into stack

              contextStack.pop()
              contextStack.push(.End)

            }

            tokenStack.push(.RightCurlyBracket)

          }


        case .Array:
          // Try to scan a comma or closing bracket

          if scanner.scanCharacter(",") {
            // Push value context to parse value that follows the comma

            contextStack.push(.Value)
            tokenStack.push(.Comma)

          }

          else if scanner.scanCharacter("]") {
            // The array has been parsed. Clean up context stack

            contextStack.pop() // Pop off array context

            if contextStack.peek! == .Start {
              // We have finished parsing, pop start out of stack and push end into stack

              contextStack.pop()
              contextStack.push(.End)

            }

            tokenStack.push(.RightSquareBracket)

          }


        case .Key:
          // We are beginning or continuing the parsing of a string

          let result = scanQuotedString()
          if result.success && result.value != nil {
            // Found the key

            contextStack.pop()
            tokenStack.push(.Value(.QuotedString(result.value!)))

            if scanToken(.Colon).success {
              // Found the colon, push value context

              contextStack.push(.Value)

            }

            else {
              // Failed to find colon

              println("parse failed looking for colon near location \(idx)")
              break scanLoop

            }

          }

          else {
            // Failed to find key

            println("parse failed looking for key near location \(idx)")
            break scanLoop

          }

        case .End:
          println("parse complete")
          break scanLoop

        }
      }

    }

    println("parse complete…\ncontext stack: \(contextStack)\ntoken stack: \(tokenStack)")

  }

}
