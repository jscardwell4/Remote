//
//  BitArray.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/8/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

/////////////////////////////////////////////////////////////////////////////////
/// Add boolean type support to the builtin bit enum
/////////////////////////////////////////////////////////////////////////////////
extension Bit: BooleanType {
  public var boolValue: Bool { return self.rawValue == 1 }
  static func fromBool(b:Bool) -> Bit { return b ? .One : .Zero }
}

/////////////////////////////////////////////////////////////////////////////////
/// The core bit array implementation
/////////////////////////////////////////////////////////////////////////////////
struct BitArray: CollectionType {

  static var BitLimit = Int(round(log2(Double(UInt64.max))))
  var rawValue: UInt64
  var count = BitArray.BitLimit
  var startIndex: Int { return 0 }
  var endIndex: Int { return count }

  /** Initializers */
  init(storage:Int = 0, count:Int = BitArray.BitLimit) { self.init(storage:UInt64(storage), count:count) }
  init(storage:UInt64 = 0, count:Int = BitArray.BitLimit) { self.rawValue = storage; self.count = count }

  /** Subscripting */
  subscript(i:Int) -> Bit {
    get { return Bit.fromBool(isBitSet(i)) }
    set { (Bool(newValue) ? setBit : unsetBit)(i) }
  }

  /** Toggle an individual bit */
  mutating func toggleBit(i:Int) {
    if i >= count { MSRaiseException(NSRangeException, "i out of bounds", userinfo: nil) }
    (isBitSet(i) ? unsetBit : setBit)(i)
  }

  /** Set an individual bit */
  mutating func setBit(i:Int) {
    if i >= count { MSRaiseException(NSRangeException, "i out of bounds", userinfo: nil) }
    rawValue |= UInt64(1) << UInt64(i)
  }

  /** Unset an individual bit */
  mutating func unsetBit(i:Int) {
    if i >= count { MSRaiseException(NSRangeException, "i out of bounds", userinfo: nil) }
    rawValue &= ~(UInt64(1) << UInt64(i))
  }

  /** unsetting all bits */
  mutating func unsetAllBits() { rawValue = 0 }

  /** Query whether an individual bit is set */
  func isBitSet(i:Int) -> Bool {
    if i >= count { MSRaiseException(NSRangeException, "i out of bounds", userinfo: nil) }
    return Bit(rawValue: Int(rawValue >> UInt64(i) & UInt64(1)))!.boolValue
  }

  /** The index of the most significant bit for currently stored value */
  var mostSignificantBit: Int { var i = 0; for (idx, bit) in enumerate(self) { if bit { i = idx } }; return i }

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - Equatable
////////////////////////////////////////////////////////////////////////////////
func ==(lhs:BitArray, rhs:BitArray) -> Bool { return lhs.rawValue == rhs.rawValue && lhs.count == rhs.count }

/////////////////////////////////////////////////////////////////////////////////
// MARK: - NSNumber conversions
/////////////////////////////////////////////////////////////////////////////////
extension BitArray {
  func toNumber() -> NSNumber { return NSNumber(unsignedLongLong: rawValue) }
  static func fromNumber(number:NSNumber, count:Int = 0) -> BitArray {
    return self(storage:number.unsignedLongLongValue, count:count)
  }
}

/////////////////////////////////////////////////////////////////////////////////
// MARK: - Hashable
/////////////////////////////////////////////////////////////////////////////////
extension BitArray: Hashable { var hashValue: Int { return Int(rawValue) } }

/////////////////////////////////////////////////////////////////////////////////
// MARK: - Printable
/////////////////////////////////////////////////////////////////////////////////
extension BitArray: Printable {
  var description:String {
    var chars = [Character]()
      for (i, bit) in enumerate(self) {
        chars.append(Character("\(bit.rawValue)"))
        if i % 4 == 3 { chars.append(Character(" ")) }
      }
      if chars.last == " " { chars.removeLast() }
      var description = ""
      for char in chars.reverse() { char.writeTo(&description) }
    return description
  }
  func toStringWithLabels(labels: [String], emptyLabel: String = "None") -> String {
    var components: [String] = []
    for (label, bit) in Zip2(labels, self) {
      if bit.boolValue { components += [label] }
    }
    if components.isEmpty { components += [emptyLabel] }
    return "|".join(components)
  }
}

/////////////////////////////////////////////////////////////////////////////////
// MARK: - RawOptionSetType
/////////////////////////////////////////////////////////////////////////////////
extension BitArray: RawOptionSetType {
  static func fromMask(raw: UInt64) -> BitArray  { return self(rawValue: raw) }
}

/////////////////////////////////////////////////////////////////////////////////
// MARK: - BooleanType
/////////////////////////////////////////////////////////////////////////////////
extension BitArray: BooleanType { var boolValue: Bool { return rawValue != 0 } }

/////////////////////////////////////////////////////////////////////////////////
// MARK: - RawRepresentable
/////////////////////////////////////////////////////////////////////////////////
extension BitArray: RawRepresentable {
  init(rawValue: UInt64) {
    self.init(storage: rawValue)
  }
  func toRaw() -> UInt64 { return rawValue }
}

/////////////////////////////////////////////////////////////////////////////////
// MARK: - NilLiteralConvertible
/////////////////////////////////////////////////////////////////////////////////
extension BitArray: NilLiteralConvertible {
  init(nilLiteral: Void) {
    self.init(rawValue: UInt64(0))
  }
  static func convertFromNilLiteral() -> BitArray { return self(storage:0) }
}

/////////////////////////////////////////////////////////////////////////////////
// MARK: - SequenceType
/////////////////////////////////////////////////////////////////////////////////
extension BitArray: SequenceType { func generate() -> BitArrayGenerator { return BitArrayGenerator(self) } }

/////////////////////////////////////////////////////////////////////////////////
// MARK: - BitwiseOperationsType
/////////////////////////////////////////////////////////////////////////////////
extension  BitArray: BitwiseOperationsType { static var allZeros: BitArray { return self(storage:0) } }

func &(lhs: BitArray, rhs: BitArray) -> BitArray {
  return BitArray(storage:lhs.rawValue & rhs.rawValue, count:max(lhs.count, rhs.count))
}
func |(lhs: BitArray, rhs: BitArray) -> BitArray {
  return BitArray(storage:lhs.rawValue | rhs.rawValue, count:max(lhs.count, rhs.count))
}
func ^(lhs: BitArray, rhs: BitArray) -> BitArray {
  return BitArray(storage:lhs.rawValue ^ rhs.rawValue, count:max(lhs.count, rhs.count))
}
prefix func ~(bits: BitArray) -> BitArray { return BitArray(storage:~bits.rawValue, count:bits.count) }

/////////////////////////////////////////////////////////////////////////////////
// MARK: - Generator for enumerating over bits in BitArray
/////////////////////////////////////////////////////////////////////////////////
struct BitArrayGenerator: GeneratorType {
  private let bits: BitArray
  private var bitIndex: Int = 0
  init(_ value:BitArray) { bits = value }
  mutating func next() -> Bit? {
    return (bitIndex < bits.count ? Bit(rawValue: Int((bits.rawValue >> UInt64(bitIndex++)) & UInt64(1))) : nil)
  }
}
