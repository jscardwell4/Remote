//
//  JSONValue.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/2/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

public protocol JSONValueType { var value: Any { get } }

public struct JSONBooleanValue: JSONValueType { public var boolValue: Bool                        ; public var value: Any { return boolValue   } }
public struct JSONStringValue:  JSONValueType { public var stringValue: String                    ; public var value: Any { return stringValue } }
public struct JSONNumberValue:  JSONValueType { public var numberValue: NSNumber                  ; public var value: Any { return numberValue } }
public struct JSONNullValue:    JSONValueType { public var nullValue: NSNull { return NSNull() }  ; public var value: Any { return nullValue   } }


public struct JSONArrayValue: JSONValueType, SinkType {
  public var arrayValue: [JSONValueType]
  public var value: Any { return arrayValue }
  public mutating func put(v: JSONValueType) { arrayValue.append(v) }
}

public struct JSONObjectValue: JSONValueType, SinkType {
  public var objectValue: [String:JSONValueType]
  public var value: Any { return objectValue }
  public mutating func put(v: (String, JSONValueType)) { objectValue[v.0] = v.1 }
}
