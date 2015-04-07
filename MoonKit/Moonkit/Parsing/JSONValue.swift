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
  public typealias ObjectValue = OrderedDictionary<Swift.String, JSONValue>
  public typealias ArrayValue = Swift.Array<JSONValue>

  case Boolean (Bool)
  case String (Swift.String)
  case Array (ArrayValue)
  case Object (ObjectValue)
  case Number (NSNumber)
  case Null

  /** Initialize to `Null` */
  public init() { self = Null }

  /**
  Initialize from a convertible type

  :param: v T:JSONValueConvertible
  */
  public init<T:JSONValueConvertible>(_ v: T) { self = v.jsonValue }

  /**
  Initialize with any object or return nil upon conversion failure

  :param: v AnyObject
  */
  public init?(_ value: Any?) {
    if let v = value {
      if let x = v as? JSONValueConvertible { self = x.jsonValue }
      else if let x = v as? NSNumber { self = Number(x) }
      else if let x = v as? Swift.String { self = String(x) }
      else if let x = v as? BooleanType { self = Boolean(x.boolValue) }
      else if let x = v as? NSNull { self = Null }
      else if let x = v as? NSArray {
        let converted = compressedMap(x, {JSONValue($0)})
        if converted.count == x.count { self = Array(converted) }
        else { return nil }
      }
      else if let x = v as? [Any] {
        let converted = compressedMap(x, {JSONValue($0)})
        if converted.count == x.count { self = Array(converted) }
        else { return nil }
      }
      else if let x = v as? OrderedDictionary<Swift.String, Any> {
        let converted = x.compressedMap({JSONValue($1)})
        if converted.count == x.count { self = Object(converted) }
        else { return nil }
      }
      else if let x = v as? NSDictionary {
        let keys = x.allKeys.map({toString($0)})
        let values = compressedMap(x.allValues, {JSONValue($0)})
        if keys.count == values.count { self = Object(OrderedDictionary(Swift.Array(zip(keys, values)))) }
        else { return nil }
      }
      else { return nil }
    } else { return nil }
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

  /**
  stringValueWithDepth:

  :param: depth Int

  :returns: Swift.String
  */
  private func stringValueWithDepth(depth: Int) -> Swift.String {
    switch self {
      case .Boolean(_),
           .Null(_),
           .Number(_),
           .String(_):
        return stringValue

      case .Array(let a):
        let outerIndent = " " * (depth * 4)
        let innerIndent = outerIndent + " " * 4
        var string = "["
        let elements = a.map({$0.stringValueWithDepth(depth + 1)})
        switch elements.count {
          case 0: string += "]"
          case 1: string += "\n\(innerIndent)" + elements[0] + "\n\(outerIndent)]"
          default: string += "\n\(innerIndent)" + ",\n\(innerIndent)".join(elements) + "\n\(outerIndent)]"
        }
        return string

      case .Object(let o):
        let outerIndent = " " * (depth * 4)
        let innerIndent = outerIndent + " " * 4
        var string = "{"
        let keyValuePairs = o.map({"\"\($0)\": \($1.stringValueWithDepth(depth + 1))"}).values.array
        switch keyValuePairs.count {
          case 0: string += "]"
          case 1: string += "\n\(innerIndent)" + keyValuePairs[0] + "\n\(outerIndent)}"
          default: string += "\n\(innerIndent)" + ",\n\(innerIndent)".join(keyValuePairs) + "\n\(outerIndent)}"
        }
        return string
    }
  }

  /** The formatted JSONValue string representation */
  public var prettyStringValue: Swift.String { return stringValueWithDepth(0) }

  /** An object representation of the value */
  public var objectValue: AnyObject {
    switch self {
      case .Boolean(let b): return b
      case .Null:           return NSNull()
      case .Number(let n):  return n
      case .String(let s):  return s
      case .Array(let a):   return a.map({$0.objectValue})
      case .Object(let o):  return o.map({$1.objectValue}) as MSDictionary //MSDictionary(o.map({$1.objectValue}))
    }
  }

  /** The associated value */
  public var value: Any {
    switch self {
      case .Boolean(let b): return b
      case .Null:           return ()
      case .Number(let n):  return n
      case .String(let s):  return s
      case .Array(let a):   return a
      case .Object(let o):  return o
    }
  }

  /**
  Places the associated value into `v` if possible.

  :param: v T?
  */
  public func getValue<T>(inout v: T?) {
    switch self {
      case .Boolean(let b): v = b as? T
      case .Null:           v = nil
      case .Number(let n):  v = n as? T
      case .String(let s):  v = s as? T
      case .Array(let a):   v = a as? T
      case .Object(let o):  v = typeCast(o, T.self)
    }
  }

  /** The value any dictionary keypaths expanded into deeper levels */
  public var inflatedKeyPaths: JSONValue {
    switch self {

      case .Array(let a):
        return .Array(a.map({$0.inflatedKeyPaths}))

      case .Object(let o):
        let expand = {(var keypath: Stack<Swift.String>, var leaf: ObjectValue) -> JSONValue in

          while let k = keypath.pop() { leaf = [k:.Object(leaf)] }
          return .Object(leaf)
        }
        return .Object(o.inflated(expand: expand).map({$1.inflatedKeyPaths}))

      default:
        return self
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

extension JSONValue: RawRepresentable {
  public var rawValue: Swift.String {
    switch self {
      case .Boolean(let b): return toString(b)
      case .Null:           return "null"
      case .Number(let n):  return toString(n)
      case .String(let s):  return "\"".sandwhich(s)
      case .Array(let a):   return "[" + ",".join(a.map({$0.rawValue})) + "]"
      case .Object(let o):  return "{" + ",".join(o.keyValuePairs.map({"\"\($0)\":\($1.rawValue)"})) + "}"
    }
  }
  public init?(rawValue: Swift.String) {
    let parser = JSONParser(string: rawValue, allowFragment: true)
    var error: NSError?
    if let value = parser.parse(error: &error) where !MSHandleError(error) { self = value }
    else { return nil }
  }
}

extension JSONValue: Equatable {}
public func ==(lhs: JSONValue, rhs: JSONValue) -> Bool {
  return lhs.rawValue == rhs.rawValue
}
infix operator ~== {
  associativity none
  precedence 130
}
public func ~==(lhs: JSONValue, rhs: JSONValue) -> Bool {
  switch (lhs, rhs) {
    case (.Boolean(_), .Boolean(_)),
         (.Number(_), .Number(_)),
         (.String(_), .String(_)),
         (.Null, .Null),
         (.Array(_), .Array(_)),
         (.Object(_), .Object(_)):
      return true

    default:
      return false
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

// MARK: - Wrapper for using `JSONValue` where a class is needed
public class WrappedJSONValue: NSCoding {
  public let jsonValue: JSONValue
  public init(_ jsonValue: JSONValue) { self.jsonValue = jsonValue }
  @objc public func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(jsonValue.rawValue)
  }
  @objc public required init(coder aDecoder: NSCoder) {
    if let rawValue = aDecoder.decodeObject() as? String,
      jsonValue = JSONValue(rawValue: rawValue)
    {
      self.jsonValue = jsonValue
    } else { jsonValue = .Null }
  }
}

// MARK: - Convenience structs that wrap specific enum cases

public struct ObjectJSONValue {
  public let value: JSONValue.ObjectValue
  public init?(_ v: JSONValue?) { switch v ?? .Null { case .Object(let o): value = o; default: return nil } }
  public subscript(key: String) -> JSONValue? { return value[key] }
}
extension ObjectJSONValue: CollectionType {
  public typealias Index = JSONValue.ObjectValue.Index
  public typealias Generator = JSONValue.ObjectValue.Generator
  public var startIndex: Index { return value.startIndex }
  public var endIndex: Index { return value.endIndex }
  public func generate() -> Generator { return value.generate() }
  public subscript(idx: Index) -> Generator.Element { return value[idx] }
}

public struct ArrayJSONValue {
  public let value: [JSONValue]
  public init?(_ v: JSONValue?) { switch v ?? .Null { case .Array(let a): value = a; default: return nil } }
}
extension ArrayJSONValue: CollectionType {
  public typealias Index = JSONValue.ArrayValue.Index
  public typealias Generator = JSONValue.ArrayValue.Generator
  public var startIndex: Index { return value.startIndex }
  public var endIndex: Index { return value.endIndex }
  public func generate() -> Generator { return value.generate() }
  public subscript(idx: Index) -> Generator.Element { return value[idx] }
}


// MARK: - Type extensions

extension Bool: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Boolean(self) }
}

extension Bool: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let b = jsonValue?.value as? Bool { self = b } else { return nil }
  }
}

extension String: JSONValueConvertible {
  public var jsonValue: JSONValue { return .String(self) }
}

extension String: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let string = jsonValue?.value as? String { self = string } else { return nil }
  }
}

extension Int: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(NSNumber(long: self))}
}
extension Int: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let n = jsonValue?.value as? NSNumber { self = n.longValue } else { return nil }
  }
}

extension Int8: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(NSNumber(char: self))}
}
extension Int8: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let n = jsonValue?.value as? NSNumber { self = n.charValue } else { return nil }
  }
}

extension Int16: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(NSNumber(short: self))}
}
extension Int16: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let n = jsonValue?.value as? NSNumber { self = n.shortValue } else { return nil }
  }
}

extension Int32: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(NSNumber(int:self))}
}
extension Int32: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let n = jsonValue?.value as? NSNumber { self = n.intValue } else { return nil }
  }
}

extension Int64: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(NSNumber(longLong: self))}
}
extension Int64: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let n = jsonValue?.value as? NSNumber { self = n.longLongValue } else { return nil }
  }
}

extension UInt: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(NSNumber(unsignedLong: self))}
}
extension UInt: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let n = jsonValue?.value as? NSNumber { self = n.unsignedLongValue } else { return nil }
  }
}

extension UInt8: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(NSNumber(unsignedChar: self))}
}
extension UInt8: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let n = jsonValue?.value as? NSNumber { self = n.unsignedCharValue } else { return nil }
  }
}

extension UInt16: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(NSNumber(unsignedShort: self))}
}
extension UInt16: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let n = jsonValue?.value as? NSNumber { self = n.unsignedShortValue } else { return nil }
  }
}

extension UInt32: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(NSNumber(unsignedInt: self))}
}
extension UInt32: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let n = jsonValue?.value as? NSNumber { self = n.unsignedIntValue } else { return nil }
  }
}

extension UInt64: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(NSNumber(unsignedLongLong: self))}
}
extension UInt64: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let n = jsonValue?.value as? NSNumber { self = n.unsignedLongLongValue } else { return nil }
  }
}

extension Float: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(self)}
}
extension Float: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let n = jsonValue?.value as? NSNumber { self = n.floatValue } else { return nil }
  }
}
extension CGFloat: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(self)}
}
extension CGFloat: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let n = jsonValue?.value as? NSNumber { self = CGFloat(n.doubleValue) } else { return nil }
  }
}

extension Double: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(self)}
}
extension Double: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let n = jsonValue?.value as? NSNumber { self = n.doubleValue } else { return nil }
  }
}

extension CGSize: JSONValueConvertible {
  public var jsonValue: JSONValue { return .String(NSStringFromCGSize(self)) }
}
extension CGSize: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let string = String(jsonValue) { self = CGSizeFromString(string) } else { return nil }
  }
}