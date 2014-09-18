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
  public var boolValue: Bool { return self.toRaw() == 1 }
  static func fromBool(b:Bool) -> Bit { return b ? .One : .Zero }
}

/////////////////////////////////////////////////////////////////////////////////
/// The core bit array implementation
/////////////////////////////////////////////////////////////////////////////////
struct BitArray: CollectionType {

  static var BitLimit = Int(round(log2(Double(UInt64.max))))
  var storage: UInt64
  var count = BitArray.BitLimit
  var startIndex: Int { return 0 }
  var endIndex: Int { return count }

  /** Initializers */
  init(storage:Int = 0, count:Int = BitArray.BitLimit) { self.init(storage:UInt64(storage), count:count) }
  init(storage:UInt64 = 0, count:Int = BitArray.BitLimit) { self.storage = storage; self.count = count }

  /** Subscripting */
  subscript(i:Int) -> Bit {
    get { return Bit.fromBool(isBitSet(i)) }
    set { (Bool(newValue) ? setBit : unsetBit)(i) }
  }

  /** Toggle an individual bit */
  mutating func toggleBit(i:Int) {
    if i >= count { raiseException(NSRangeException, "i out of bounds", userinfo: nil) }
    (isBitSet(i) ? unsetBit : setBit)(i)
  }

  /** Set an individual bit */
  mutating func setBit(i:Int) {
    if i >= count { raiseException(NSRangeException, "i out of bounds", userinfo: nil) }
    storage |= UInt64(1) << UInt64(i)
  }

  /** Unset an individual bit */
  mutating func unsetBit(i:Int) {
    if i >= count { raiseException(NSRangeException, "i out of bounds", userinfo: nil) }
    storage &= ~(UInt64(1) << UInt64(i))
  }

  /** unsetting all bits */
  mutating func unsetAllBits() { storage = 0 }

  /** Query whether an individual bit is set */
  func isBitSet(i:Int) -> Bool {
    if i >= count { raiseException(NSRangeException, "i out of bounds", userinfo: nil) }
    return Bit.fromRaw(Int(storage >> UInt64(i) & UInt64(1)))!.boolValue
  }

  /** The index of the most significant bit for currently stored value */
  var mostSignificantBit: Int { var i = 0; for (idx, bit) in enumerate(self) { if bit { i = idx } }; return i }

}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - Equatable
////////////////////////////////////////////////////////////////////////////////
func ==(lhs:BitArray, rhs:BitArray) -> Bool { return lhs.storage == rhs.storage && lhs.count == rhs.count }

/////////////////////////////////////////////////////////////////////////////////
// MARK: - NSNumber conversions
/////////////////////////////////////////////////////////////////////////////////
extension BitArray {
  func toNumber() -> NSNumber { return NSNumber.numberWithUnsignedLongLong(storage) }
  static func fromNumber(number:NSNumber, count:Int = 0) -> BitArray {
    return self(storage:number.unsignedLongLongValue, count:count)
  }
}

/////////////////////////////////////////////////////////////////////////////////
// MARK: - Hashable
/////////////////////////////////////////////////////////////////////////////////
extension BitArray: Hashable { var hashValue: Int { return Int(storage) } }

/////////////////////////////////////////////////////////////////////////////////
// MARK: - Printable
/////////////////////////////////////////////////////////////////////////////////
extension BitArray: Printable {
  var description:String {
    var chars = [Character]()
      for (i, bit) in enumerate(self) {
        chars.append(Character("\(bit.toRaw())"))
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
  static func fromMask(raw: UInt64) -> BitArray  { return self.fromRaw(raw)! }
}

/////////////////////////////////////////////////////////////////////////////////
// MARK: - BooleanType
/////////////////////////////////////////////////////////////////////////////////
extension BitArray: BooleanType { var boolValue: Bool { return storage != 0 } }

/////////////////////////////////////////////////////////////////////////////////
// MARK: - RawRepresentable
/////////////////////////////////////////////////////////////////////////////////
extension BitArray: RawRepresentable {
  static func fromRaw(raw: UInt64) -> BitArray? { return self(storage:raw) }
  func toRaw() -> UInt64 { return storage }
}

/////////////////////////////////////////////////////////////////////////////////
// MARK: - NilLiteralConvertible
/////////////////////////////////////////////////////////////////////////////////
extension BitArray: NilLiteralConvertible {
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
  return BitArray(storage:lhs.storage & rhs.storage, count:max(lhs.count, rhs.count))
}
func |(lhs: BitArray, rhs: BitArray) -> BitArray {
  return BitArray(storage:lhs.storage | rhs.storage, count:max(lhs.count, rhs.count))
}
func ^(lhs: BitArray, rhs: BitArray) -> BitArray {
  return BitArray(storage:lhs.storage ^ rhs.storage, count:max(lhs.count, rhs.count))
}
prefix func ~(bits: BitArray) -> BitArray { return BitArray(storage:~bits.storage, count:bits.count) }

/////////////////////////////////////////////////////////////////////////////////
// MARK: - Generator for enumerating over bits in BitArray
/////////////////////////////////////////////////////////////////////////////////
struct BitArrayGenerator: GeneratorType {
  private let bits: BitArray
  private var bitIndex: Int = 0
  init(_ value:BitArray) { bits = value }
  mutating func next() -> Bit? {
    return (bitIndex < bits.count ? Bit.fromRaw(Int((bits.storage >> UInt64(bitIndex++)) & UInt64(1))) : nil)
  }
}
