//
//  JSON.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/1/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

public protocol JSONValueType { var JSONValue: JSON { get } }
protocol _JSONValueType { var JSONValue: JSON { get } }

extension String: _JSONValueType, JSONValueType   { public var JSONValue: JSON { return JSON.String(self)  } }
extension Bool: _JSONValueType, JSONValueType     { public var JSONValue: JSON { return JSON.Boolean(self) } }
extension NSNumber: _JSONValueType, JSONValueType { public var JSONValue: JSON { return JSON.Number(self)  } }

extension Dictionary: _JSONValueType {
  var JSONValue: JSON {
    return JSON.Object(Dictionary<String, JSON>( compressed( map(self) {
        if let s = $0 as? String, v = $1 as? _JSONValueType { return (s, v.JSONValue) } else { return nil }
      })))
  }
}
extension Array: _JSONValueType {
  var JSONValue: JSON { return JSON.Array(compressed(map {($0 as? _JSONValueType)?.JSONValue })) }
}

public enum JSON {
  case Boolean (Bool)
  case String (Swift.String)
  case Array ([JSON])
  case Object ([Swift.String:JSON])
  case Number (NSNumber)
  case Null

  init<T:BooleanType>(_ b: T) { self = Boolean(b.boolValue) }
  init(_ s: Swift.String) { self = String(s) }
  init(_ n: NSNumber) { self = Number(n) }
  init() { self = Null }
  init<T:_JSONValueType>(_ a: [T]) { self = Array(a.map({$0.JSONValue})) }
  init(_ d: [Swift.String:_JSONValueType]) { self = Object(Dictionary(d.keyValuePairs.map({($0, $1.JSONValue)}))) }
}

