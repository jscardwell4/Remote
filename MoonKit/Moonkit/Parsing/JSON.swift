//
//  JSON.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/1/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

/*
/** Publicly exposed `JSONValueType` */
public protocol JSONValueType {
  var JSONValue: JSON { get }
}

/** Protocol used internally because we can't make generic type extensions public */
protocol _JSONValueType {
  var JSONValue: JSON { get }
}

// MARK: - JSONValueType conformance extensions for base types
extension String: _JSONValueType, JSONValueType {
  public var JSONValue: JSON { return JSON(self)  }
}

extension Bool: _JSONValueType, JSONValueType {
  public var JSONValue: JSON { return JSON(self) }
}

extension NSNumber: _JSONValueType, JSONValueType {
  public var JSONValue: JSON { return JSON(self)  }
}

extension Float: _JSONValueType, JSONValueType {
  public var JSONValue: JSON { return JSON(NSNumber(float: self)) }
}

extension Double: _JSONValueType, JSONValueType {
  public var JSONValue: JSON { return JSON(NSNumber(floatLiteral: self)) }
}

extension Int: _JSONValueType, JSONValueType {
  public var JSONValue: JSON { return JSON(NSNumber(long: self))  }
}

extension UInt: _JSONValueType, JSONValueType {
  public var JSONValue: JSON { return JSON(NSNumber(unsignedLong: self)) }
}

extension Int8: _JSONValueType, JSONValueType {
  public var JSONValue: JSON { return JSON(NSNumber(char: self)) }
}

extension UInt8: _JSONValueType, JSONValueType {
  public var JSONValue: JSON { return JSON(NSNumber(unsignedChar: self)) }
}

extension Int16: _JSONValueType, JSONValueType {
  public var JSONValue: JSON { return JSON(NSNumber(short: self)) }
}

extension UInt16: _JSONValueType, JSONValueType {
  public var JSONValue: JSON { return JSON(NSNumber(unsignedShort: self)) }
}

extension Int32: _JSONValueType, JSONValueType {
  public var JSONValue: JSON { return JSON(NSNumber(int: self)) }
}

extension UInt32: _JSONValueType, JSONValueType {
  public var JSONValue: JSON { return JSON(NSNumber(unsignedInt: self)) }
}

extension Int64: _JSONValueType, JSONValueType {
  public var JSONValue: JSON { return JSON(NSNumber(longLong: self)) }
}

extension UInt64: _JSONValueType, JSONValueType {
  public var JSONValue: JSON { return JSON(NSNumber(unsignedLongLong: self)) }
}

extension NSDictionary: _JSONValueType, JSONValueType {
  public var JSONValue: JSON {
    if let dict = (self as Any) as? [String:_JSONValueType] {
      return dict.JSONValue
    } else { return JSON.Null }
  }
}

extension Dictionary: _JSONValueType {
  var JSONValue: JSON {
    return JSON.Object(Dictionary<String, JSON>( compressed( map(self) {
        if let s = $0 as? String, v = $1 as? _JSONValueType { return (s, v.JSONValue) } else { return nil }
      })))
  }
}

extension NSArray: _JSONValueType, JSONValueType {
  public var JSONValue: JSON {
    if let array = (self as Any) as? [_JSONValueType] {
      return array.JSONValue
    } else { return JSON.Null }
  }
}

extension Array: _JSONValueType {
  var JSONValue: JSON {
    return JSON.Array(compressed(map {($0 as? _JSONValueType)?.JSONValue }))
  }
}

*/
// MARK: -
/** Enumeration of discriminating union to represent a JSON value */
public enum JSON: NilLiteralConvertible {
  case Boolean (Bool)
  case Text (String)
  case Array ([JSON])
  case Object ([String:JSON])
  case Number (NSNumber)
  case Null

  public init(_ b: Bool) { self = Boolean(b) }
  public init(_ s: String) { self = Text(s) }
  public init(_ n: NSNumber) { self = Number(n) }
  public init(nilLiteral: ()) { self = Null }
  public init(_ a: [JSON]) { self = Array(a) }
  public init(_ d: [String:JSON]) { self = Object(d) }

  /** The condensed JSON string representation */
  public var stringValue: String {
    switch self {
      case .Boolean(let b): return toString(b)
      case .Null:           return "null"
      case .Number(let n):  return toString(n)
      case .Text(let s):  return "\"".sandwhich(s)
      case .Array(let a):   return "[" + ",".join(a.map({$0.stringValue})) + "]"
      case .Object(let o):  return "{" + ",".join(o.keyValuePairs.map({"\"\($0)\":\($1.stringValue)"})) + "}"
    }
  }
}

extension JSON: Printable { public var description: String { return stringValue } }

// MARK: - Public functions to convert something into a `JSON` type
public func toJSONValue(v: Bool) -> JSON { return JSON(v) }
public func toJSONValue<B: BooleanType>(v: B) -> JSON { return toJSONValue(v.boolValue) }
public func toJSONValue(v: String) -> JSON { return JSON(v) }
public func toJSONValue(v: Float) -> JSON { return JSON(NSNumber(float: v)) }
public func toJSONValue(v: Double) -> JSON { return JSON(NSNumber(floatLiteral: v)) }
public func toJSONValue(v: Int) -> JSON { return JSON(NSNumber(long: v)) }
public func toJSONValue(v: UInt) -> JSON { return JSON(NSNumber(unsignedLong: v)) }
public func toJSONValue(v: Int8) -> JSON { return JSON(NSNumber(char: v)) }
public func toJSONValue(v: UInt8) -> JSON { return JSON(NSNumber(unsignedChar: v)) }
public func toJSONValue(v: Int16) -> JSON { return JSON(NSNumber(short: v)) }
public func toJSONValue(v: UInt16) -> JSON { return JSON(NSNumber(unsignedShort: v)) }
public func toJSONValue(v: Int32) -> JSON { return JSON(NSNumber(int: v)) }
public func toJSONValue(v: UInt32) -> JSON { return JSON(NSNumber(unsignedInt: v)) }
public func toJSONValue(v: Int64) -> JSON { return JSON(NSNumber(longLong: v)) }
public func toJSONValue(v: UInt64) -> JSON { return JSON(NSNumber(unsignedLongLong: v)) }
public func toJSONValue(v: NSNumber) -> JSON { return JSON(v) }
public func toJSONValue(v: AnyObject) -> JSON? {
  if let x = v as? [AnyObject] { return toJSONValue(x) }
  if let x = v as? [String:AnyObject] { return toJSONValue(x) }
  if let x = v as? String { return toJSONValue(x) }
  if let x = v as? Float { return toJSONValue(x) }
  if let x = v as? Double { return toJSONValue(x) }
  if let x = v as? Int { return toJSONValue(x) }
  if let x = v as? UInt { return toJSONValue(x) }
  if let x = v as? Int8 { return toJSONValue(x) }
  if let x = v as? UInt8 { return toJSONValue(x) }
  if let x = v as? Int16 { return toJSONValue(x) }
  if let x = v as? UInt16 { return toJSONValue(x) }
  if let x = v as? Int32 { return toJSONValue(x) }
  if let x = v as? UInt32 { return toJSONValue(x) }
  if let x = v as? Int64 { return toJSONValue(x) }
  if let x = v as? UInt64 { return toJSONValue(x) }
  if let x = v as? NSNumber { return toJSONValue(x) }
  return nil
}
public func toJSONValue<T:AnyObject>(v: [T]) -> JSON { return JSON(compressedMap(v, {toJSONValue($0)})) }
public func toJSONValue(v:NSArray) -> JSON { return toJSONValue(v as [AnyObject]) }
public func toJSONValue<T:AnyObject>(v: [String:T]) -> JSON { return JSON(compressedMap(v, {toJSONValue($1)})) }
public func toJSONValue(v: NSDictionary) -> JSON {
  return toJSONValue(NSDictionary(objects: v.allValues, forKeys: v.allKeys.map({toString($0)})) as! [String:AnyObject])
}
public func toJSONValue(v: [String:Bool]) -> JSON { return JSON(compressedMap(v, {toJSONValue($1)})) }
public func toJSONValue<B:BooleanType>(v: [String:B]) -> JSON { return JSON(compressedMap(v, {toJSONValue($1)})) }
public func toJSONValue(v: [String:String]) -> JSON { return JSON(compressedMap(v, {toJSONValue($1)})) }
public func toJSONValue(v: [String:Float]) -> JSON { return JSON(compressedMap(v, {toJSONValue($1)})) }
public func toJSONValue(v: [String:Double]) -> JSON { return JSON(compressedMap(v, {toJSONValue($1)})) }
public func toJSONValue(v: [String:Int]) -> JSON { return JSON(compressedMap(v, {toJSONValue($1)})) }
public func toJSONValue(v: [String:UInt]) -> JSON { return JSON(compressedMap(v, {toJSONValue($1)})) }
public func toJSONValue(v: [String:Int8]) -> JSON { return JSON(compressedMap(v, {toJSONValue($1)})) }
public func toJSONValue(v: [String:UInt8]) -> JSON { return JSON(compressedMap(v, {toJSONValue($1)})) }
public func toJSONValue(v: [String:Int16]) -> JSON { return JSON(compressedMap(v, {toJSONValue($1)})) }
public func toJSONValue(v: [String:UInt16]) -> JSON { return JSON(compressedMap(v, {toJSONValue($1)})) }
public func toJSONValue(v: [String:Int32]) -> JSON { return JSON(compressedMap(v, {toJSONValue($1)})) }
public func toJSONValue(v: [String:UInt32]) -> JSON { return JSON(compressedMap(v, {toJSONValue($1)})) }
public func toJSONValue(v: [String:Int64]) -> JSON { return JSON(compressedMap(v, {toJSONValue($1)})) }
public func toJSONValue(v: [String:UInt64]) -> JSON { return JSON(compressedMap(v, {toJSONValue($1)})) }
public func toJSONValue(v: [String:NSNumber]) -> JSON { return JSON(compressedMap(v, {toJSONValue($1)})) }
public func toJSONValue(v: [String:AnyObject]) -> JSON { return JSON(compressedMap(v, {toJSONValue($1)})) }

