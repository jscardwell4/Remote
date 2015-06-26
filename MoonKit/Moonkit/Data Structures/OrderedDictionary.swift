//
//  OrderedDictionary.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/7/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

/* Should generator be switched to `IndexingGenerator`? */

public struct OrderedDictionary<Key : Hashable, Value> : KeyValueCollectionType {

  public typealias Index = Int
  typealias SelfType = OrderedDictionary<Key, Value>

  private(set) public var dictionary: [Key:Value]
  private(set) var _keys: [Key]
  public var keys: LazyForwardCollection<Array<Key>> { return LazyForwardCollection(_keys) }
  public var printableKeys: Bool { return typeCast(_keys, Array<CustomStringConvertible>.self) != nil }

  public var userInfo: [String:AnyObject]?
  public var count: Int { return _keys.count }
  public var isEmpty: Bool { return _keys.isEmpty }
  public var values: LazyForwardCollection<MapCollectionView<[Key], Value>> {
    return keys.map({self.dictionary[$0]!})
  }

  public var keyValuePairs: [(Key, Value)] { return Array(zip(_keys, _keys.map({self.dictionary[$0]!}))) }

  /**
  Initialize with a minimum capacity

  - parameter minimumCapacity: Int = 4
  */
  public init(minimumCapacity: Int = 4) {
    dictionary = Dictionary(minimumCapacity: minimumCapacity)
    _keys = []
    _keys.reserveCapacity(minimumCapacity)
  }


  /**
  Initialize with an `NSDictionary`

  - parameter dict: NSDictionary
  */
  public init(_ dict: NSDictionary) {
    if let kArray = typeCast(dict.allKeys, Array<Key>.self), vArray = typeCast(dict.allValues, Array<Value>.self) {
      self = SelfType(keys: kArray, values: vArray)
    } else {
      _keys = []
      dictionary = [:]
    }
  }

  /**
  Initialize with an `MSDictionary`, preserving order

  - parameter dict: MSDictionary
  */
  public init(_ dict: MSDictionary) {
    self.init(dict as NSDictionary)
    if let kArray = typeCast(dict.allKeys, Array<Key>.self) { _keys = kArray }
  }


  /**
  Initialize with a dictionary

  - parameter dict: [Key
  */
  public init(_ dict: [Key:Value]) {
    dictionary = dict
    _keys = Array(dict.keys)
  }

  /**
  Initialize with a sequence of keys and a sequence of values

  - parameter keys: S1
  - parameter values: S2
  */
  public init<S1:SequenceType, S2:SequenceType where S1.Generator.Element == Key, S2.Generator.Element == Value>(keys: S1, values: S2) {
    self.init(zip(keys, values))
  }

  /**
  Initialize with sequence of (Key, Value) tuples

  - parameter elements: S
  */
  public init<S:SequenceType where S.Generator.Element == (Key,Value)>(_ elements: S) {
    _keys = []
    dictionary = [:]
    for (k, v) in elements { _keys.append(k); dictionary[k] = v }
  }

  // MARK: - Indexes

  public var startIndex: Index { return 0 }
  public var endIndex: Index { return _keys.count }


  public func indexForKey(key: Key) -> Index? { return _keys.indexOf(key) }

  public func keyForIndex(idx: Index) -> Key { return _keys[idx] }

  public func valueAtIndex(idx: Index) -> Value? { return dictionary[_keys[idx]] }

  /**
  subscript:

  - parameter key: Key

  - returns: Value?
  */
  public subscript (key: Key) -> Value? {
    get { return dictionary[key] }
    mutating set { setValue(newValue, forKey: key) }
  }

  /**
  subscript:

  - parameter i: Index

  - returns: (Key, Value)
  */
  public subscript(i: Index) -> (Index, Key, Value) {
    get {
      precondition(i < _keys.count)
      return (i, _keys[i], values[i])
    }
    mutating set {
      precondition(i < _keys.count)
      insertValue(newValue.2, atIndex: i, forKey: newValue.1)
    }
  }

  /**
  subscript:

  - parameter keys: [Key]

  - returns: [Value?]
  */
  public subscript(keys: [Key]) -> [Value?] {
    get {
      var values: [Value?] = []
      for key in keys { values.append(self[key]) }
      return values
    }
    mutating set {
      if newValue.count == keys.count {
        for (i, key) in keys.enumerate() { self[key] = newValue[i] }
      }
    }
  }


  // MARK: - Updating and removing values


  /**
  insertValue:atIndex:forKey:

  - parameter value: Value?
  - parameter index: Int
  - parameter key: Key
  */
  public mutating func insertValue(value: Value?, atIndex index: Int, forKey key: Key) {
    precondition(index < _keys.count)
    if let v = value {
      if let currentIndex = indexForKey(key) {
        if currentIndex != index {
          _keys.removeAtIndex(currentIndex)
          _keys.insert(key, atIndex: index)
        }
      } else {
        _keys.insert(key, atIndex: index)
      }
      dictionary[key] = v
    } else {
      if let currentIndex = indexForKey(key) { _keys.removeAtIndex(currentIndex) }
      dictionary[key] = nil
    }
  }


  /**
  setValue:forKey:

  - parameter value: Value?
  - parameter key: Key
  */
  public mutating func setValue(value: Value?, forKey key: Key) {
    if let v = value {
      if !_keys.contains(key) { _keys.append(key) }
      dictionary[key] = v
    } else {
      if let idx = indexForKey(key) { _keys.removeAtIndex(idx) }
      dictionary[key] = nil
    }
  }


  /**
  updateValue:forKey:

  - parameter value: Value
  - parameter key: Key

  - returns: Value?
  */
  public mutating func updateValue(value: Value, forKey key: Key) -> Value? {
    if !_keys.contains(key) { _keys.append(key) }
    return dictionary.updateValue(value, forKey: key)
  }

  /**
  updateValue:atIndex:

  - parameter value: Value
  - parameter atIndex: idx Index

  - returns: Value?
  */
  public mutating func updateValue(value: Value, atIndex index: Index) -> Value? {
    precondition(index < _keys.count)
    return dictionary.updateValue(value, forKey: _keys[index])
  }

  public mutating func extend<S: SequenceType where S.Generator.Element == (Int, Key, Value)>(s: S) {
    for (_, k, v) in s { self[k] = v }
  }

  /**
  removeAtIndex:

  - parameter index: Index

  - returns: Value?
  */
  public mutating func removeAtIndex(index: Index) -> Value? {
    precondition(index < _keys.count)
    return removeValueForKey(_keys[index])
  }


  /**
  removeValueForKey:

  - parameter key: Key

  - returns: Value?
  */
  public mutating func removeValueForKey(key: Key) -> Value? {
    if let idx = indexForKey(key) { _keys.removeAtIndex(idx) }
    return dictionary.removeValueForKey(key)
  }

  public mutating func removeValuesForKeys<S:SequenceType where S.Generator.Element == Key>(keys: S) {
    keys ➤ {self.removeValueForKey($0)}
  }

  /**
  removeAll:

  - parameter keepCapacity: Bool = false
  */
  public mutating func removeAll(keepCapacity: Bool = false) {
    _keys.removeAll(keepCapacity: keepCapacity)
    dictionary.removeAll(keepCapacity: keepCapacity)
  }


  /**
  sort:

  - parameter isOrderedBefore: (Key, Key) -> Bool
  */
  public mutating func sort(isOrderedBefore: (Key, Key) -> Bool) { _keys.sortInPlace(isOrderedBefore) }

  private static var defaultExpand: (Stack<String>, SelfType) -> Value {
    return {
      (var kp: Stack<String>, var leaf: SelfType) -> Value  in

      // If there are stops along the way from first to last, recursively embed in dictionaries
      while let k = kp.pop() { leaf = [k as! Key: leaf as! Value] }

      return leaf as! Value
    }
  }

  public func inflated(expand: (Stack<String>, SelfType) -> Value = defaultExpand)  -> SelfType {
    var result = self
    result.inflate(expand)
    return result
  }

  /** inflate */
  public mutating func inflate(expand: (Stack<String>, SelfType) -> Value = defaultExpand) {
    if let stringKeys = typeCast(_keys, Array<String>.self) {

      // First gather a list of keys to inflate
      let inflatableKeys = Array(stringKeys.filter({$0 ~= "(?:\\w\\.)+\\w"}))

      // Enumerate the list inflating each key
      for key in inflatableKeys {

        let keyComponents = split(key.characters, isSeparator: {$0 == "."}).map { String($0) }
        let firstKey = keyComponents.first!
        let lastKey = keyComponents.last!
        let keypath = Stack(dropLast(dropFirst(keyComponents)))
        let value: Value

        // If our value is an array, we embed each value in the array and keep our value as an array
        if let valueArray = typeCast(self[key as! Key], Array<Value>.self) {
          value = valueArray.map({expand(keypath, [lastKey as! Key:$0])}) as! Value
        }

          // Otherwise we embed the value
        else { value = expand(keypath, [lastKey as! Key: self[key as! Key]!]) }

        insertValue(value, atIndex: _keys.indexOf(key as! Key)!, forKey: firstKey as! Key)
        self[key as! Key] = nil // Remove the compressed key-value entry
      }
    }
  }



  /**
  reverse

  - returns: OrderedDictionary<Key, Value>
  */
  public mutating func reverse() -> SelfType {
    var result = self
    result._keys = Array(result._keys.reverse())
    return result
  }


  /**
  filter

  - parameter includeElement: (Key,Value) -> Bool

  - returns: OrderedDictionary<Key, Value>
  */
  public func filter(includeElement: (Index, Key, Value) -> Bool) -> SelfType {
    var result: SelfType = [:]
    for (i, k, v) in self { if includeElement((i, k, v)) { result.setValue(v, forKey: k) } }
    return result
  }


  /**
  map

  - parameter transform: (Key, Value) -> U

  - returns: OrderedDictionary<Key, U>
  */
  public func map<U>(transform: (Index, Key, Value) -> U) -> OrderedDictionary<Key, U> {
    var result: OrderedDictionary<Key, U> = [:]
    for (i, k, v) in self { result[k] = transform(i, k, v) }
    return result
  }

  /**
  coompressedMap

  - parameter transform: (Key, Value) -> U?

  - returns: OrderedDictionary<Key, U>
  */
  public func compressedMap<U>(transform: (Index, Key, Value) -> U?) -> OrderedDictionary<Key, U> {
    return map(transform).filter({$2 != nil}).map({$2!})
  }

  public func valuesForKeys<S:SequenceType where S.Generator.Element == Key>(keys: S) -> OrderedDictionary<Key, Value?> {
    var result: OrderedDictionary<Key, Value?> = [:]
    keys ➤ {result[$0] = self[$0]}
    return result
  }

  public static func dictionaryWithXMLData(data: NSData) -> OrderedDictionary<String, AnyObject> {
    let dictionary = MSDictionary(byParsingXML: data)
    return OrderedDictionary<String,AnyObject>(dictionary)
//    return MSDictionary(byParsingXML: data) as! OrderedDictionary<String, AnyObject>
  }

}

// MARK: - Printing
extension  OrderedDictionary: CustomStringConvertible, CustomDebugStringConvertible {

  public var description: String {
    var description = "{\n\t"
    description += "\n\t".join(keyValuePairs.map({toString($0) + ": " + toString($1)}))
    description += "\n}"
    return description
  }
  public var debugDescription: String { return "\(self.dynamicType.self): " + description }

}

// MARK: DictionaryLiteralConvertible
extension  OrderedDictionary: DictionaryLiteralConvertible {
  public init(dictionaryLiteral elements: (Key, Value)...) { self = OrderedDictionary(elements) }
}

// MARK: _ObjectiveBridgeable
extension OrderedDictionary: _ObjectiveCBridgeable {
  static public func _isBridgedToObjectiveC() -> Bool {
    return true
  }
  public typealias _ObjectiveCType = MSDictionary
  static public func _getObjectiveCType() -> Any.Type { return _ObjectiveCType.self }
  public func _bridgeToObjectiveC() -> _ObjectiveCType {
    var keys: [AnyObject] = []
    var values: [AnyObject] = []
    for key in self.keys {
      if key is AnyObject {
        keys.append(key as! AnyObject)
      }
    }
    for value in self.values {
      if value is AnyObject {
        values.append(value as! AnyObject)
      }
    }
    if keys.count == values.count && keys.count == self.count {
      return MSDictionary(values: values, forKeys: keys)
    } else {
      return MSDictionary()
    }
  }

  static public func _forceBridgeFromObjectiveC(source: MSDictionary, inout result: OrderedDictionary?) {
    var d = OrderedDictionary(minimumCapacity: source.count)
    for (k, v) in zip(source.allKeys, source.allValues) {
      if let key = typeCast(k, Key.self), value = typeCast(v, Value.self) {
        d[key] = value
      }
    }
    if d.count == source.count {
      result = d
    }
  }
  static public func _conditionallyBridgeFromObjectiveC(source: MSDictionary, inout result: OrderedDictionary?) -> Bool {
    var d = OrderedDictionary(minimumCapacity: source.count)
    for (k, v) in zip(source.allKeys, source.allValues) {
      if let key = typeCast(k, Key.self), value = typeCast(v, Value.self) {
        d[key] = value
      }
    }
    if d.count == source.count {
      result = d
      return true
    }
    return false
  }
}

// MARK: - Generator

extension  OrderedDictionary: SequenceType  {
  public func generate() -> OrderedDictionaryGenerator<Key, Value> {
    return OrderedDictionaryGenerator(self)
  }
}

public struct OrderedDictionaryGenerator<Key:Hashable, Value> : GeneratorType {

  public typealias Index = OrderedDictionary<Key, Value>.Index
  let dictionary: OrderedDictionary<Key, Value>
  var index: Index


  init(_ value: OrderedDictionary<Key,Value>) {
    dictionary = value; index = dictionary.startIndex
  }

  public mutating func next() -> (Index, Key, Value)? {
    if index < dictionary.endIndex {
      let key: Key = dictionary._keys[index]
      let value: Value = dictionary.dictionary[key]!
      let element = (index, key, value)
      index++
      return element
    } else { return nil }
  }

}

// MARK: - Operations

//public func +<K, V>(lhs: OrderedDictionary<K, V>, rhs: OrderedDictionary<K,V>) -> OrderedDictionary<K, V> {
//  let keys: [K] = lhs._keys + rhs._keys
//  let values: [V] = Array(lhs.values) + Array(rhs.values)
//  return OrderedDictionary<K,V>(keys: keys, values: values)
//}

public func +<K, V, S:SequenceType where S.Generator.Element == (Int, K, V)>(var lhs: OrderedDictionary<K, V>, rhs: S) -> OrderedDictionary<K,V> {
  for (_, k, v) in rhs { lhs[k] = v }
  return lhs
}

public func +=<K, V, S:SequenceType where S.Generator.Element == (Int, K, V)>(inout lhs: OrderedDictionary<K, V>, rhs: S) {
  lhs = lhs + rhs
}

public func -<K, V>(var lhs: OrderedDictionary<K, V>, rhs: K) -> OrderedDictionary<K, V> {
  lhs.removeValueForKey(rhs)
  return lhs
}

public func -<K, V>(var lhs: OrderedDictionary<K, V>, rhs: [K]) -> OrderedDictionary<K, V> {
  lhs.removeValuesForKeys(rhs)
  return lhs
}

public func -=<K, V>(inout lhs: OrderedDictionary<K, V>, rhs: K) {
  lhs.removeValueForKey(rhs)
}

public func -=<K, V>(inout lhs: OrderedDictionary<K, V>, rhs: [K]) {
  lhs.removeValuesForKeys(rhs)
}
