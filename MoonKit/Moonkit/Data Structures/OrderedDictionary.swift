//
//  OrderedDictionary.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/7/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

/* Should generator be switched to `IndexingGenerator`? */

public struct OrderedDictionary<Key : Hashable, Value> : CollectionType {

  public typealias Index = Int

  private(set) public var dictionary: [Key:Value]
  private(set) var _keys: [Key]
  public var keys: LazyForwardCollection<Array<Key>> { return LazyForwardCollection(_keys) }
  public var printableKeys: Bool { return typeCast(_keys, Array<Printable>.self) != nil }

  public var userInfo: [String:AnyObject]?
  public var count: Int { return _keys.count }
  public var isEmpty: Bool { return _keys.isEmpty }
  public var values: LazyForwardCollection<MapCollectionView<[Key],Value>> {
    return keys.map({self.dictionary[$0]!})
//    return _keys.map { self.dictionary[$0]! }
  }

  public var keyValuePairs: [(Key, Value)] { return Array(SequenceOf({self.generate()})) }

  /**
  Initialize with a minimum capacity

  :param: minimumCapacity Int = 4
  */
  public init(minimumCapacity: Int = 4) {
    dictionary = Dictionary(minimumCapacity: minimumCapacity)
    _keys = []
    _keys.reserveCapacity(minimumCapacity)
  }


  /**
  Initialize with a minimum capacity with `Printable` keys

  :param: minimumCapacity Int = 4
  */
  public init<K,V where K:Printable>(minimumCapacity: Int = 4) {
    dictionary = Dictionary(minimumCapacity: minimumCapacity)
    _keys = []
    _keys.reserveCapacity(minimumCapacity)
  }


  /**
  Initialize with an `NSDictionary`

  :param: dict NSDictionary
  */
  public init(_ dict: NSDictionary) {
    if let kArray = typeCast(dict.allKeys, Array<Key>.self), vArray = typeCast(dict.allValues, Array<Value>.self) {
      self = OrderedDictionary<Key, Value>(keys: kArray, values: vArray)
    } else {
      _keys = []
      dictionary = [:]
    }
  }

  /**
  Initialize with an `MSDictionary`, preserving order

  :param: dict MSDictionary
  */
  public init(_ dict: MSDictionary) {
    self.init(dict as NSDictionary)
    if let kArray = typeCast(dict.allKeys, Array<Key>.self) { _keys = kArray }
  }


  /**
  Initialize with a dictionary

  :param: dict [Key
  */
  public init(_ dict: [Key:Value]) {
    dictionary = dict
    _keys = Array(dict.keys)
  }

  /**
  Initialize with a sequence of keys and a sequence of values

  :param: keys S1
  :param: values S2
  */
  public init<S1:SequenceType, S2:SequenceType where S1.Generator.Element == Key, S2.Generator.Element == Value>(keys: S1, values: S2) {
    self.init(zip(keys, values))
  }

  /**
  Initialize with sequence of (Key, Value) tuples

  :param: elements S
  */
  public init<S:SequenceType where S.Generator.Element == (Key,Value)>(_ elements: S) {
    _keys = []
    dictionary = [:]
    for (k, v) in elements { _keys.append(k); dictionary[k] = v }
  }

  public static func fromMSDictionary(msdict: MSDictionary) -> OrderedDictionary<NSObject, AnyObject> {
    var orderedDict = OrderedDictionary<NSObject,AnyObject>(minimumCapacity: 4)

    let keys = msdict.allKeys as! [NSObject]
    let values = msdict.allValues as [AnyObject]

    for i in 0..<keys.count {
      let k = keys[i]
      let v: AnyObject = values[i]
      orderedDict.setValue(v, forKey: k)
    }

    return orderedDict
  }

  // MARK: - Indexes



  public var startIndex: Index { return 0 }
  public var endIndex: Index { return _keys.count }


  public func indexForKey(key: Key) -> Index? { return find(_keys, key) }

  public func keyForIndex(idx: Index) -> Key { return _keys[idx] }

  /**
  subscript:

  :param: key Key

  :returns: Value?
  */
  public subscript (key: Key) -> Value? {
    get { return dictionary[key] }
    set { setValue(newValue, forKey: key) }
  }

  /**
  subscript:

  :param: i Index

  :returns: (Key, Value)
  */
  public subscript(i: Index) -> (Key, Value) {
    get {
      precondition(i < _keys.count)
      return (_keys[i], values[i])
    }
    set {
      precondition(i < _keys.count)
      insertValue(newValue.1, atIndex: i, forKey: newValue.0)
    }
  }

  /**
  subscript:

  :param: keys [Key]

  :returns: [Value?]
  */
  public subscript(keys: [Key]) -> [Value?] {
    get {
      var values: [Value?] = []
      for key in keys { values.append(self[key]) }
      return values
    }
    set {
      if newValue.count == keys.count {
        for (i, key) in enumerate(keys) { self[key] = newValue[i] }
      }
    }
  }


  // MARK: - Updating and removing values


  /**
  insertValue:atIndex:forKey:

  :param: value Value?
  :param: index Int
  :param: key Key
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
      dictionary[key] = value
    } else {
      if let currentIndex = indexForKey(key) { _keys.removeAtIndex(currentIndex) }
      dictionary[key] = nil
    }
  }


  /**
  setValue:forKey:

  :param: value Value?
  :param: key Key
  */
  public mutating func setValue(value: Value?, forKey key: Key) {
    if let v = value {
      if !contains(_keys, key) { _keys.append(key) }
      dictionary[key] = value
    } else {
      if let idx = indexForKey(key) { _keys.removeAtIndex(idx) }
      dictionary[key] = nil
    }
  }


  /**
  updateValue:forKey:

  :param: value Value
  :param: key Key

  :returns: Value?
  */
  public mutating func updateValue(value: Value, forKey key: Key) -> Value? {
    if !contains(_keys, key) { _keys.append(key) }
    return dictionary.updateValue(value, forKey: key)
  }

  /**
  removeAtIndex:

  :param: index Index

  :returns: Value?
  */
  public mutating func removeAtIndex(index: Index) -> Value? {
    precondition(index < _keys.count)
    return removeValueForKey(_keys[index])
  }


  /**
  removeValueForKey:

  :param: key Key

  :returns: Value?
  */
  public mutating func removeValueForKey(key: Key) -> Value? {
    if let idx = indexForKey(key) { _keys.removeAtIndex(idx) }
    return dictionary.removeValueForKey(key)
  }


  /**
  removeAll:

  :param: keepCapacity Bool = false
  */
  public mutating func removeAll(keepCapacity: Bool = false) {
    _keys.removeAll(keepCapacity: keepCapacity)
    dictionary.removeAll(keepCapacity: keepCapacity)
  }


  /**
  sort:

  :param: isOrderedBefore (Key, Key) -> Bool
  */
  public mutating func sort(isOrderedBefore: (Key, Key) -> Bool) { _keys.sort(isOrderedBefore) }

  public func inflated(expand: (Stack<String>, OrderedDictionary<Key, Value>) -> Value = {
    (var kp: Stack<String>, var leaf: OrderedDictionary<Key, Value>) -> Value  in

    // If there are stops along the way from first to last, recursively embed in dictionaries
    while let k = kp.pop() { leaf = [k as! Key: leaf as! Value] }

    return leaf as! Value
    })
  -> OrderedDictionary<Key, Value>
  {
    var result = self
    result.inflate(expand: expand)
    return result
  }

  /** inflate */
  public mutating func inflate(expand: (Stack<String>, OrderedDictionary<Key, Value>) -> Value = {
    (var kp: Stack<String>, var leaf: OrderedDictionary<Key, Value>) -> Value  in

      // If there are stops along the way from first to last, recursively embed in dictionaries
      while let k = kp.pop() { leaf = [k as! Key: leaf as! Value] }

      return leaf as! Value
    })
  {
    if let stringKeys = typeCast(_keys, Array<String>.self) {

      // First gather a list of keys to inflate
      let inflatableKeys = Array(stringKeys.filter({$0 ~= "(?:\\w\\.)+\\w"}))

      // Enumerate the list inflating each key
      for key in inflatableKeys {

        var keyComponents = split(key, isSeparator: {$0 == "."})
        let firstKey = keyComponents.first!
        let lastKey = keyComponents.last!
        var keypath = Stack(dropLast(dropFirst(keyComponents)))
        let value: Value

//        func inflatedValue(obj: Value) -> OrderedDictionary<Key, Value> {
//          var kp = keypath
//          var d: OrderedDictionary<Key, Value> = [lastKey as! Key:obj]
//
//          // If there are stops along the way from first to last, recursively embed in dictionaries
//          while let k = kp.pop() { d = [k as! Key: d as! Value] }
//
//          return d
//        }

        // If our value is an array, we embed each value in the array and keep our value as an array
        if let valueArray = typeCast(self[key as! Key], Array<Value>.self) {
          value = valueArray.map({expand(keypath, [lastKey as! Key:$0])}) as! Value
        }

          // Otherwise we embed the value
        else { value = expand(keypath, [lastKey as! Key: self[key as! Key]!]) }

        insertValue(value, atIndex: find(_keys, key as! Key)!, forKey: firstKey as! Key)
        self[key as! Key] = nil                              // Remove the compressed key-value entry
      }
    }
  }



  /**
  reverse

  :returns: OrderedDictionary<Key, Value>
  */
  public mutating func reverse() -> OrderedDictionary<Key, Value> {
    var result = self
    result._keys = result._keys.reverse()
    return result
  }


  /**
  filter

  :param: includeElement (Key,Value) -> Bool

  :returns: OrderedDictionary<Key, Value>
  */
  public func filter(includeElement: (Key, Value) -> Bool) -> OrderedDictionary<Key, Value> {
    var result: OrderedDictionary<Key, Value> = [:]
    for (k, v) in self { if includeElement((k, v)) { result.setValue(v, forKey: k) } }
    return result
  }


  /**
  map

  :param: transform (Key, Value) -> U

  :returns: OrderedDictionary<Key, U>
  */
  public func map<U>(transform: (Key, Value) -> U) -> OrderedDictionary<Key, U> {
    var result: OrderedDictionary<Key, U> = [:]
    for (k, v) in self { result[k] = transform(k, v) }
    return result
  }

  /**
  coompressedMap

  :param: transform (Key, Value) -> U?

  :returns: OrderedDictionary<Key, U>
  */
  public func compressedMap<U>(transform: (Key, Value) -> U?) -> OrderedDictionary<Key, U> {
    return map(transform).filter({$1 != nil}).map({$1!})
  }

}

// MARK: - Printing
extension  OrderedDictionary: Printable, DebugPrintable {

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

// MARK: _ObjectiveBridgeable ???
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
    return OrderedDictionaryGenerator(value: self)
  }
}

public struct OrderedDictionaryGenerator<Key : Hashable, Value> : GeneratorType {

  let keys: [Key]
  let values: [Value]
  var keyIndex = 0


  init(value:OrderedDictionary<Key,Value>) {
    keys = Array(value.keys); values = Array(value.values)
  }


  public mutating func next() -> (Key, Value)? {
    if keyIndex < keys.count {
      let keyValue = (keys[keyIndex], values[keyIndex])
      keyIndex++
      return keyValue
    } else { return nil }
  }

}

// MARK: - Operations

public func +<K, V>(lhs: OrderedDictionary<K, V>, rhs: OrderedDictionary<K,V>) -> OrderedDictionary<K, V> {
  let keys: [K] = lhs._keys + rhs._keys
  let values: [V] = Array(lhs.values) + Array(rhs.values)
  return OrderedDictionary<K,V>(keys: keys, values: values)
}

public func +=<K, V>(inout lhs: OrderedDictionary<K, V>, rhs: OrderedDictionary<K, V>) {
  lhs = lhs + rhs
}

public func -<K, V>(var lhs: OrderedDictionary<K, V>, rhs: K) -> OrderedDictionary<K, V> {
  lhs.removeValueForKey(rhs)
  return lhs
}

public func -=<K, V>(inout lhs: OrderedDictionary<K, V>, rhs: K) {
  lhs.removeValueForKey(rhs)
}