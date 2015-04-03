//
//  JSONValue.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/1/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//
import Foundation

// MARK: - JSONValue
/** Enumeration of discriminating union to represent a JSON value */
public enum JSONValue {
  case Boolean (Bool)
  case String (Swift.String)
  case Array ([JSONValue])
  case Object ([Swift.String:JSONValue])
  case Number (NSNumber)
  case Null

  /**
  Initialize with bool

  :param: boolean Bool
  */
  public init(_ boolean: Bool) { self = Boolean(boolean) }

  /**
  Initialize with String

  :param: string Swift.String
  */
  public init(_ string: Swift.String) { self = String(string) }

  /**
  Initialize with number

  :param: number NSNumber
  */
  public init(_ number: NSNumber) { self = Number(number) }

  /** Initialize to `Null` */
  public init() { self = Null }

  /**
  Initialize with any object or return nil upon conversion failure

  :param: v AnyObject
  */
  public init?(_ v: AnyObject) {
    if let x = v as? BooleanType { self = Boolean(x.boolValue) }
    else if let x = v as? NSNumber { self = Number(x) }
    else if let x = v as? Swift.String { self = String(x) }
    else if let x = v as? NSNull { self = Null }
    else if let x = v as? NSArray {
      let converted = compressedMap(x, {JSONValue($0)})
      if converted.count == x.count { self = Array(converted) }
      else { return nil }
    }
    else if let x = v as? NSDictionary {
      let keys = x.allKeys.map({toString($0)})
      let values = compressedMap(x.allValues, {JSONValue($0)})
      if keys.count == values.count { self = Object(Dictionary(Swift.Array(zip(keys, values)))) }
      else { return nil }
    }
    else { return nil }
  }

  /** The condensed JSONValue string representation */
  public var stringValue: Swift.String {
    switch self {
      case .Boolean(let b): return toString(b)
      case .Null:           return "null"
      case .Number(let n):  return toString(n)
      case .String(let s):  return "\"".sandwhich(s)
      case .Array(let a):   return "[" + ",".join(a.map({$0.stringValue})) + "]"
      case .Object(let o):  return "{" + ",".join(o.keyValuePairs.map({"\"\($0)\":\($1.stringValue)"})) + "}"
    }
  }

  /** An object representation of the value */
  public var objectValue: AnyObject {
    switch self {
      case .Boolean(let b): return b
      case .Null:           return NSNull()
      case .Number(let n):  return n
      case .String(let s):  return s
      case .Array(let a):   return a.map({$0.objectValue})
      case .Object(let o):  return map(o, {$1.objectValue})
    }
  }

  /**
  Returns the value at the specified index when self is Array and index is valid, nil otherwise

  :param: idx Int

  :returns: JSONValue?
  */
  public subscript(idx: Int) -> JSONValue? {
    switch self { case .Array(let a) where a.count > idx: return a[idx]; default: return nil }
  }

  /**
  Returns the value for the specified key when self is Object and nil otherwise

  :param: key Swift.String

  :returns: JSONValue?
  */
  public subscript(key: Swift.String) -> JSONValue? {
    switch self { case .Object(let o): return o[key]; default: return nil }
  }
}

// MARK: BooleanLiteralConvertible
extension JSONValue: BooleanLiteralConvertible { public init(booleanLiteral b: Bool) { self = Boolean(b) } }

// MARK: NilLiteralConvertible
extension JSONValue: NilLiteralConvertible { public init(nilLiteral: ()) { self = Null } }

// MARK: IntegerLiteralConvertible
extension JSONValue: IntegerLiteralConvertible { public init(integerLiteral value: Int) { self = Number(value) } }

// MARK: FloatLiteralConvertible
extension JSONValue: FloatLiteralConvertible { public init(floatLiteral value: Double) { self = Number(value) } }

// MARK: ArrayLiteralConvertible
extension JSONValue: ArrayLiteralConvertible { public init(arrayLiteral elements: JSONValue...) { self = Array(elements) } }

// MARK: StringLiteralConvertible
extension JSONValue: StringLiteralConvertible {
  public init(stringLiteral s: Swift.String) { self = String(s) }
  public init(extendedGraphemeClusterLiteral s: Swift.String) { self = String(s) }
  public init(unicodeScalarLiteral s: Swift.String) { self = String(s) }
}

// MARK: Streamable
extension JSONValue: Streamable { public func writeTo<T:OutputStreamType>(inout target: T) { target.write(stringValue) } }

// MARK: Printable
extension JSONValue: Printable { public var description: Swift.String { return stringValue } }

// MARK: DebugPrintable
extension JSONValue: DebugPrintable {
  public var debugDescription: Swift.String {
    var description: Swift.String
    switch self {
      case .Boolean(let b): description = "JSONValue.Boolean(\(b))"
      case .Null:           description = "JSONValue.Null"
      case .Number(let n):  description = "JSONValue.Number(\(n))"
      case .String(let s):   description = "JSONValue.String(\(s))"
      case .Array(let a):   description = "JSONValue.Array(\(a.count) items)"
      case .Object(let o):  description = "JSONValue.Object(\(o.count) entries)"
    }
    description += " - \(stringValue)"
    return description
  }
}
