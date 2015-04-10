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
  public typealias MappedObjectValue = OrderedDictionary<Swift.String, Any>
  public typealias MappedArrayValue = Swift.Array<Any>

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
  Initialize to case `Array` using a `JSONValue` sequence

  :param: s S
  */
  public init<S:SequenceType where S.Generator.Element == JSONValue>(s: S) {
    self = Array(Swift.Array(s))
  }

  /**
  Initialize to case `Object` using a key-value collection

  :param: c C
  */
  public init<C:KeyValueCollectionType where C.KeysLazyCollectionType.Generator.Element == Swift.String,
                                             C.ValuesLazyCollectionType.Generator.Element == JSONValue>(c: C)
  {
    self = Object(OrderedDictionary<Swift.String, JSONValue>(keys: c.keys, values: c.values))
  }
  
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
        return rawValue

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
  public var anyObjectValue: AnyObject {
    switch self {
      case .Boolean(let b): return b
      case .Null:           return NSNull()
      case .Number(let n):  return n
      case .String(let s):  return s
      case .Array(let a):   return a.map({$0.anyObjectValue})
      case .Object(let o):  return o.map({$1.anyObjectValue}) as MSDictionary
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

  public var stringValue: Swift.String? { switch self { case .String(let s):  return s; default: return nil } }
  public var boolValue: Bool? { switch self { case .Boolean(let b):  return b; default: return nil } }
  public var numberValue: NSNumber? { switch self { case .Number(let n):  return n; default: return nil } }
  public var intValue: Int? { return numberValue?.longValue }
  public var int8Value: Int8? { return numberValue?.charValue }
  public var int16Value: Int16? { return numberValue?.shortValue }
  public var int32Value: Int32? { return numberValue?.intValue }
  public var int64Value: Int64? { return numberValue?.longLongValue }
  public var uintValue: UInt? { return numberValue?.unsignedLongValue }
  public var uint8Value: UInt8? { return numberValue?.unsignedCharValue }
  public var uint16Value: UInt16? { return numberValue?.unsignedShortValue }
  public var uint32Value: UInt32? { return numberValue?.unsignedIntValue }
  public var uint64Value: UInt64? { return numberValue?.unsignedLongLongValue }
  public var floatValue: Float? { return numberValue?.floatValue }
  public var CGFloatValue: CGFloat? { if let d = doubleValue { return CGFloat(d) } else { return nil } }
  public var doubleValue: Double? { return numberValue?.doubleValue }
  public var CGSizeValue: CGSize? { return CGSize(stringValue) }
  public var UIEdgeInsetsValue: UIEdgeInsets? { return UIEdgeInsets(stringValue) }
  public var CGRectValue: CGRect? { return CGRect(stringValue) }
  public var CGPointValue: CGPoint? { return CGPoint(stringValue) }
  public var CGVectorValue: CGVector? { return CGVector(stringValue) }
  public var UIOffsetValue: UIOffset? { return UIOffset(stringValue) }
  public var CGAffineTransformValue: CGAffineTransform? { return CGAffineTransform(stringValue) }

  public var objectValue: ObjectValue? { switch self { case .Object(let o):  return o; default: return nil } }
  public var mappedObjectValue: MappedObjectValue? {
    return objectValue?.map({$1.mappedObjectValue ?? $1.mappedArrayValue ?? $1.value})
  }

  public var arrayValue: ArrayValue? { switch self { case .Array(let a):  return a; default: return nil } }
  public var mappedArrayValue: MappedArrayValue? {
    return arrayValue?.map({$0.mappedArrayValue ?? $0.mappedObjectValue ?? $0.value})
  }

  /** The value any dictionary keypaths expanded into deeper levels */
  public var inflatedValue: JSONValue {
    switch self {
      case .Array(let a): return .Array(a.map({$0.inflatedValue}))
      case .Object(let o):
        let expand = {(var keypath: Stack<Swift.String>, var leaf: ObjectValue) -> JSONValue in
          while let k = keypath.pop() { leaf = [k:.Object(leaf)] }
          return .Object(leaf)
        }
        return .Object(o.inflated(expand: expand).map({$1.inflatedValue}))
      default: return self
    }
  }

  /**
  Returns the value at the specified index when self is Array or Object and index is valid, nil otherwise

  :param: idx Int

  :returns: JSONValue?
  */
  public subscript(idx: Int) -> JSONValue? {
    switch self {
      case .Array(let a) where a.count > idx: return a[idx]
      case .Object(let o) where o.count > idx: return o[idx].1
    default: return nil
    }
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
public func ==(lhs: JSONValue, rhs: JSONValue) -> Bool { return lhs.rawValue == rhs.rawValue }

extension JSONValue: Hashable {
  public var hashValue: Int { return rawValue.hashValue }
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

// MARK: StringInterpolationConvertible
extension JSONValue: StringInterpolationConvertible {
  public init(stringInterpolation strings: JSONValue...) { self = String(reduce(strings, "", {$0 + ($1.stringValue ?? "")})) }
  public init<T>(stringInterpolationSegment expr: T) { self = String(toString(expr)) }
}

// MARK: Streamable
extension JSONValue: Streamable { public func writeTo<T:OutputStreamType>(inout target: T) { target.write(rawValue) } }

// MARK: Printable
extension JSONValue: Printable { public var description: Swift.String { return rawValue } }

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

public struct ObjectJSONValue: JSONValueConvertible, JSONValueInitializable {
  public var jsonValue: JSONValue { return .Object(value) }
  public let value: JSONValue.ObjectValue
  public init?(_ v: JSONValue?) { switch v ?? .Null { case .Object(let o): value = o; default: return nil } }
  public subscript(key: String) -> JSONValue? { return value[key] }
  public func map<U>(transform: (String, JSONValue) -> U) -> OrderedDictionary<String, U> {
    return value.map(transform)
  }

  public func compressedMap<U>(transform: (String, JSONValue) -> U?) -> OrderedDictionary<String, U> {
    return value.compressedMap(transform)
  }
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
  public init?(_ jsonValue: JSONValue?) { if let b = jsonValue?.boolValue { self = b } else { return nil } }
}

extension String: JSONValueConvertible {
  public var jsonValue: JSONValue { return .String(self) }
}

extension String: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let string = jsonValue?.stringValue { self = string } else { return nil } }
}

extension Int: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(NSNumber(long: self))}
}
extension Int: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.intValue { self = n } else { return nil } }
}

extension Int8: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(NSNumber(char: self))}
}
extension Int8: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.int8Value { self = n } else { return nil } }
}

extension Int16: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(NSNumber(short: self))}
}
extension Int16: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.int16Value { self = n } else { return nil } }
}

extension Int32: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(NSNumber(int:self))}
}
extension Int32: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.int32Value { self = n } else { return nil } }
}

extension Int64: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(NSNumber(longLong: self))}
}
extension Int64: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.int64Value { self = n } else { return nil } }
}

extension UInt: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(NSNumber(unsignedLong: self))}
}
extension UInt: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.uintValue { self = n } else { return nil } }
}

extension UInt8: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(NSNumber(unsignedChar: self))}
}
extension UInt8: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.uint8Value { self = n } else { return nil } }
}

extension UInt16: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(NSNumber(unsignedShort: self))}
}
extension UInt16: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.uint16Value { self = n } else { return nil } }
}

extension UInt32: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(NSNumber(unsignedInt: self))}
}
extension UInt32: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.uint32Value { self = n } else { return nil } }
}

extension UInt64: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(NSNumber(unsignedLongLong: self))}
}
extension UInt64: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.uint64Value { self = n } else { return nil } }
}

extension Float: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(self)}
}
extension Float: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.floatValue { self = n } else { return nil } }
}
extension CGFloat: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(self)}
}
extension CGFloat: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.CGFloatValue { self = n } else { return nil } }
}

extension Double: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(self)}
}
extension Double: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.doubleValue { self = n } else { return nil } }
}

extension CGSize: JSONValueConvertible {
  public var jsonValue: JSONValue { return .String(NSStringFromCGSize(self)) }
}
extension CGSize: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let s = jsonValue?.CGSizeValue { self = s } else { return nil } }
}

extension CGRect: JSONValueConvertible {
  public var jsonValue: JSONValue { return .String(NSStringFromCGRect(self)) }
}
extension CGRect: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let s = jsonValue?.CGRectValue { self = s } else { return nil } }
}

extension CGPoint: JSONValueConvertible {
  public var jsonValue: JSONValue { return .String(NSStringFromCGPoint(self)) }
}
extension CGPoint: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let s = jsonValue?.CGPointValue { self = s } else { return nil } }
}

extension CGVector: JSONValueConvertible {
  public var jsonValue: JSONValue { return .String(NSStringFromCGVector(self)) }
}
extension CGVector: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let s = jsonValue?.CGVectorValue { self = s } else { return nil } }
}

extension UIOffset: JSONValueConvertible {
  public var jsonValue: JSONValue { return .String(NSStringFromUIOffset(self)) }
}
extension UIOffset: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let s = jsonValue?.UIOffsetValue { self = s } else { return nil } }
}

extension CGAffineTransform: JSONValueConvertible {
  public var jsonValue: JSONValue { return .String(NSStringFromCGAffineTransform(self)) }
}
extension CGAffineTransform: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let s = jsonValue?.CGAffineTransformValue { self = s } else { return nil } }
}

extension UIEdgeInsets: JSONValueConvertible {
  public var jsonValue: JSONValue { return .String(NSStringFromUIEdgeInsets(self)) }
}
extension UIEdgeInsets: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let u = jsonValue?.UIEdgeInsetsValue { self = u } else { return nil } }
}