//
//  Numbers.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/14/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

public func half(x: CGFloat) -> CGFloat { return x * 0.5                 }
public func half(x: Float)   -> Float   { return x * 0.5                 }
public func half(x: Float80) -> Float80 { return x * Float80(0.5)        }
public func half(x: Double)  -> Double  { return x * 0.5                 }
public func half(x: Int)     -> Int     { return    Int(Double(x) * 0.5) }
public func half(x: Int8)    -> Int8    { return   Int8(Double(x) * 0.5) }
public func half(x: Int16)   -> Int16   { return  Int16(Double(x) * 0.5) }
public func half(x: Int32)   -> Int32   { return  Int32(Double(x) * 0.5) }
public func half(x: Int64)   -> Int64   { return  Int64(Double(x) * 0.5) }
public func half(x: UInt)    -> UInt    { return   UInt(Double(x) * 0.5) }
public func half(x: UInt8)   -> UInt8   { return  UInt8(Double(x) * 0.5) }
public func half(x: UInt16)  -> UInt16  { return UInt16(Double(x) * 0.5) }
public func half(x: UInt32)  -> UInt32  { return UInt32(Double(x) * 0.5) }
public func half(x: UInt64)  -> UInt64  { return UInt64(Double(x) * 0.5) }

//public protocol FloatValueConvertible { var floatValue: Float { get }; init(_ floatValue: Float) }
//public protocol CGFloatValueConvertible { var cgfloatValue: CGFloat { get }; init(_ cgfloatValue: CGFloat) }
//public protocol DoubleValueConvertible { var doubleValue: Double { get }; init(_ doubleValue: Double) }
//
//extension Float: FloatValueConvertible { public var floatValue: Float { return self } }
//extension CGFloat: FloatValueConvertible { public var floatValue: Float { return Float(self) } }
//extension Double: FloatValueConvertible { public var floatValue: Float { return Float(self) } }
//extension IntMax: FloatValueConvertible { public var floatValue: Float { return Float(self) } }
//
//extension Float: CGFloatValueConvertible { public var cgfloatValue: CGFloat { return CGFloat(self) } }
//extension Double: CGFloatValueConvertible { public var cgfloatValue: CGFloat { return CGFloat(self) } }
//extension IntMax: CGFloatValueConvertible { public var cgfloatValue: CGFloat { return CGFloat(self) } }
//extension CGFloat: CGFloatValueConvertible {
//  public var cgfloatValue: CGFloat { return self }
//  public init(_ cgfloatValue: CGFloat) { self = cgfloatValue }
//}
//
//extension Float: DoubleValueConvertible { public var doubleValue: Double { return Double(self) } }
//extension CGFloat: DoubleValueConvertible { public var doubleValue: Double { return Double(self) } }
//extension IntMax: DoubleValueConvertible { public var doubleValue: Double { return Double(self) } }
//extension Double: DoubleValueConvertible { public var doubleValue: Double { return self } }
//
//
//public func numericCast<T:FloatValueConvertible>(x: T) -> Float {
//  return x.floatValue
//}
