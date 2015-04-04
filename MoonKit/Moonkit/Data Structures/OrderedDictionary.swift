//
//  OrderedDictionary.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/7/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

public struct OrderedDictionary<Key : Hashable, Value> : CollectionType {

  public typealias Index = DictionaryIndex<Key, Value>

  private var storage: [Key:Value]
  private var indexKeys: [Key]
  private var printableKeys = false

  public var userInfo: [String:AnyObject]?
  public var count: Int { return indexKeys.count }
  public var isEmpty: Bool { return indexKeys.isEmpty }
  public var keys: [Key] { return indexKeys }
  public var values: [Value] { return indexKeys.map { self.storage[$0]! } }
  public var dictionary: [Key:Value] { return storage }

  public var keyValuePairs: [(Key, Value)] { return Array(SequenceOf({self.generate()})) }

  // MARK: - Initializers

  public init() {
    storage = [Key:Value]()
    indexKeys = [Key]()
  }

  /**
  initWithMinimumCapacity:

  :param: minimumCapacity Int = 4
  */
  public init(minimumCapacity: Int = 4) {
    storage = [Key:Value](minimumCapacity: minimumCapacity)
    indexKeys = [Key]()
    indexKeys.reserveCapacity(minimumCapacity)
  }

  /**
  initWithMinimumCapacity:

  :param: minimumCapacity Int = 4
  */
  public init<K,V where K:Printable>(minimumCapacity: Int = 4) {
    storage = [Key:Value](minimumCapacity: minimumCapacity)
    indexKeys = [Key]()
    indexKeys.reserveCapacity(minimumCapacity)
    printableKeys = true
  }

  /**
  init:

  :param: dict NSDictionary
  */
  public init(_ dict: NSDictionary) { self.init(dict as! [NSObject:AnyObject]) }

  public init(_ dict: MSDictionary) {
    self.init(dict as NSDictionary)
    let keys = dict.allKeys
    if let castKeys = (keys as [Any]) as? [Key] {
      indexKeys = castKeys
    }
  }

  /**
  init:

  :param: dict [Key
  */
  public init(_ dict: [Key:Value]) {
    storage = dict
    indexKeys = Array(dict.keys)
    printableKeys = true
  }

  /**
  initWithKeys:values:

  :param: keys [Key]
  :param: values [Value]
  */
  public init(keys: [Key], values: [Value]) {
    self.init(minimumCapacity: keys.count)
    if keys.count == values.count {
      indexKeys += keys
      for i in 0..<keys.count { let k = keys[i]; let v = values[i]; storage[k] = v }
    }
  }

  /**
  init:Value)]:

  :param: elements [(Key, Value)]
  */
  public init(_ elements: [(Key,Value)]) {
    self.init(minimumCapacity: elements.count)
    for (k, v) in elements { self[k] = v }
  }

  /**
  fromMSDictionary:

  :param: msdict MSDictionary

  :returns: OrderedDictionary<NSObject, AnyObject>
  */
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



  public var startIndex: DictionaryIndex<Key, Value> { return storage.indexForKey(indexKeys[0])! }
  public var endIndex: DictionaryIndex<Key, Value> { return storage.indexForKey(indexKeys.last!)! }

  /**
  indexForKey:

  :param: key Key

  :returns: DictionaryIndex<Key, Value>?
  */
  public func indexForKey(key: Key) -> DictionaryIndex<Key, Value>? { return storage.indexForKey(key) }

  /**
  subscript:

  :param: key Key

  :returns: Value?
  */
  public subscript (key: Key) -> Value? { get { return storage[key] } set { setValue(newValue, forKey: key) } }

  /**
  subscript:Value>:

  :param: i DictionaryIndex<Key
  :param: Value>

  :returns: (Key, Value)
  */
  public subscript (i: DictionaryIndex<Key, Value>) -> (Key, Value) { return storage[i] }

  /**
  subscript:

  :param: i Int

  :returns: Value
  */
  public subscript(i: Int) -> Value {
    get { precondition(i < values.count); return values[i] }
    set { precondition(i < values.count); storage[keys[i]] = newValue }
  }


  // MARK: - Updating and removing values


  /**
  insertValue:atIndex:forKey:

  :param: value Value?
  :param: index Int
  :param: key Key
  */
  public mutating func insertValue(value: Value?, atIndex index: Int, forKey key: Key) {
    precondition(index < keys.count)
    if let v = value {
      if let currentIndex = find(keys, key) {
        if currentIndex != index {
          indexKeys.removeAtIndex(currentIndex)
          indexKeys.insert(key, atIndex: index)
        }
      } else {
        indexKeys.insert(key, atIndex: index)
      }
      storage[key] = value
    } else {
      if let currentIndex = find(indexKeys, key) { indexKeys.removeAtIndex(currentIndex) }
      storage[key] = nil
    }
  }

  /**
  setValue:forKey:

  :param: value Value
  :param: key Key
  */
  public mutating func setValue(value: Value?, forKey key: Key) {
    if let v = value {
      if !contains(indexKeys, key) { indexKeys.append(key) }
      storage[key] = value
    } else {
      if let idx = find(indexKeys, key) { indexKeys.removeAtIndex(idx) }
      storage[key] = nil
    }
  }

  /**
  updateValue:forKey:

  :param: value Value
  :param: key Key

  :returns: Value?
  */
  public mutating func updateValue(value: Value, forKey key: Key) -> Value? {
    let currentValue: Value? = contains(indexKeys, key) ? storage[key] : nil
    if !contains(indexKeys, key) { indexKeys.append(key) }
    storage[key] = value
    return currentValue
  }

  /**
  removeAtIndex:

  :param: index DictionaryIndex<Key
  :param: Value>
  */
  public mutating func removeAtIndex(index: DictionaryIndex<Key, Value>) {
    let (k, _) = self[index]
    indexKeys.removeAtIndex(find(indexKeys, k)!)
    storage.removeAtIndex(index)
  }

  /**
  removeAtIndex::

  :param: index Int
  */
  public mutating func removeAtIndex(index: Int) {
    precondition(index < keys.count)
    storage[keys[index]] = nil
    indexKeys.removeAtIndex(index)
  }

  /**
  removeValueForKey:

  :param: key Key

  :returns: Value?
  */
  public mutating func removeValueForKey(key: Key) -> Value? {
    if let idx = find(indexKeys, key) {
      indexKeys.removeAtIndex(idx)
      return storage.removeValueForKey(key)
    } else {
      return nil
    }
  }

  /**
  removeAll:

  :param: keepCapacity Bool = false
  */
  public mutating func removeAll(keepCapacity: Bool = false) {
    indexKeys.removeAll(keepCapacity: keepCapacity)
    storage.removeAll(keepCapacity: keepCapacity)
  }

  /**
  sort:

  :param: isOrderedBefore (Key, Key) -> Bool
  */
  public mutating func sort(isOrderedBefore: (Key, Key) -> Bool) { indexKeys.sort(isOrderedBefore) }

  public var inflated: OrderedDictionary<Key, Value> { var dict = self; dict.inflate(); return dict }

  public mutating func inflate() {
    if let stringKeys = typeCast(keys, Array<String>.self) {

    // First gather a list of keys to inflate
      let inflatableKeys = Array(stringKeys.filter({$0 ~= "(?:\\w\\.)+\\w"}))

      // Enumerate the list inflating each key
      for key in inflatableKeys {

        var keyComponents = ".".split(key)
        let firstKey = keyComponents.first!
        let lastKey = keyComponents.last!
        var keypath = Stack(dropLast(dropFirst(keyComponents)))
        let value: Value

        func inflatedValue(obj: Value) -> OrderedDictionary<Key, Value> {
          var kp = keypath
          var d: OrderedDictionary<Key, Value> = [lastKey as! Key:obj]

          // If there are stops along the way from first to last, recursively embed in dictionaries
          while let k = kp.pop() { d = [k as! Key: d as! Value] }

          return d
        }

        // If our value is an array, we embed each value in the array and keep our value as an array
        if let valueArray = typeCast(self[key as! Key], Array<Value>.self) { value = valueArray.map(inflatedValue) as! Value }

          // Otherwise we embed the value
        else { value = inflatedValue(self[key as! Key]!) as! Value }

        insertValue(value, atIndex: find(keys, key as! Key)!, forKey: firstKey as! Key)
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
    result.indexKeys = result.indexKeys.reverse()
    return result
  }

  /**
  filter:

  :param: includeElement (Key, Value) -> Bool

  :returns: OrderedDictionary<Key, Value>
  */
  public func filter(includeElement: (Key, Value) -> Bool) -> OrderedDictionary<Key, Value> {
    var result: OrderedDictionary<Key, Value> = [:]
    for (k, v) in self { if includeElement((k, v)) { result.setValue(v, forKey: k) } }
    return result
  }

  /**
  map:

  :param: transform (Key, Value) -> U

  :returns: OrderedDictionary<Key, U>
  */
  public func map<U>(transform: (Key, Value) -> U) -> OrderedDictionary<Key, U> {
    var result: OrderedDictionary<Key, U> = [:]
    for (k, v) in self { result[k] = transform(k, v) }
    return result
  }

  public func compressedMap<U>(transform: (Key, Value) -> U?) -> OrderedDictionary<Key, U> {
    return map(transform).filter({$1 != nil}).map({$1!})
  }

}


// MARK: - Descriptions


public enum ColonFormatOption {
  case Follow (leftPadding: Int, rightPadding: Int)
  case Align (leftPadding: Int, rightPadding: Int)
  var leftPadding: Int {
    switch self {
      case .Follow(let l, _): return l
      case .Align(let l, _): return l
    }
  }
  var rightPadding: Int {
    switch self {
      case .Follow( _, let r): return r
      case .Align(_, let r): return r
    }
  }
}


extension  OrderedDictionary: Printable, DebugPrintable {

  public var description: String { return storage.description }
  public var debugDescription: String { return storage.debugDescription }

  /**
  formattedDescription:colonFormat:

  i.e. with dictionary ["one": 1, "two": 2, "three": 3] and default values will output:
    one    :  1
    two    :  2
    three  :  3

  :param: indent Int = 0
  :param: colonFormat ColonFormatOption? = nil

  :returns: String
  */
  public func formattedDescription(indent:Int = 0, colonFormat:ColonFormatOption? = nil) -> String {
    var descriptionComponents = [String]()
    let keyDescriptions = indexKeys.map { "\($0)" }
    let maxKeyLength = keyDescriptions.reduce(0) { max($0, Swift.count($1)) }
    let space = Character(" ")
    let indentString = String(count:indent*4, repeatedValue:space)
    for (key, value) in Zip2(keyDescriptions, values) {
      let spacer = String(count:maxKeyLength-Swift.count(key)+1, repeatedValue:space)
      var keyString = indentString + key
      if let opt = colonFormat {
        switch opt {
        case let .Follow(l, r):
          keyString += String(count:l, repeatedValue:space) + ":" + String(count:r, repeatedValue:space) + spacer
        case let .Align(l, r):
          keyString += spacer + String(count:l, repeatedValue:space) + ":" + String(count:r, repeatedValue:space)
        }
      } else {
        keyString += spacer + " :  "
      }
      var valueString: String
      var valueComponents = split("\(value)") { $0 == "\n" }
      if valueComponents.count > 0 {
        valueString = valueComponents.removeAtIndex(0)
        if valueComponents.count > 0 {
          let subIndentString = "\n\(indentString)" + String(count:maxKeyLength+3, repeatedValue:Character(" "))
          valueString += subIndentString + join(subIndentString, valueComponents)
        }
      } else { valueString = "nil" }
      descriptionComponents += ["\(keyString)\(valueString)"]
    }
    return join("\n", descriptionComponents)
  }

}


// MARK: - DictionaryLiteralConvertible



extension  OrderedDictionary: DictionaryLiteralConvertible {

  /**
  init:Value)...:

  :param: elements (Key
  :param: Value)...
  */
  public init(dictionaryLiteral elements: (Key, Value)...) {
    var orderedDict = OrderedDictionary(minimumCapacity: elements.count)
    for (key, value) in elements {
      orderedDict.indexKeys.append(key)
      orderedDict.storage[key] = value
    }
    self = orderedDict
  }

}


// MARK: - Generator



extension  OrderedDictionary: SequenceType  {


  /**
  generate

  :returns: OrderedDictionaryGenerator<Key, Value>
  */
  public func generate() -> OrderedDictionaryGenerator<Key, Value> {
    return OrderedDictionaryGenerator(value: self)
  }

}

public struct OrderedDictionaryGenerator<Key : Hashable, Value> : GeneratorType {

  let keys: [Key]
  let values: [Value]
  var keyIndex = 0

  /**
  initWithValue:Value>:

  :param: value OrderedDictionary<Key
  :param: Value>
  */
  init(value:OrderedDictionary<Key,Value>) { keys = value.keys; values = value.values }

  /**
  next

  :returns: (Key, Value)?
  */
  public mutating func next() -> (Key, Value)? {
    if keyIndex < keys.count {
      let keyValue = (keys[keyIndex], values[keyIndex])
      keyIndex++
      return keyValue
    } else { return nil }
  }

}

// MARK: - Operations


/**
Function for creating an `OrderedDictionary` by appending rhs to lhs

:param: lhs OrderedDictionary<K,V>
:param: rhs OrderedDictionary<K,V>

:returns: OrderedDictionary<K,V>
*/
public func +<K,V>(lhs: OrderedDictionary<K,V>, rhs: OrderedDictionary<K,V>) -> OrderedDictionary<K,V> {
  let keys: [K] = lhs.keys + rhs.keys
  let values: [V] = lhs.values + rhs.values
  return OrderedDictionary<K,V>(keys: keys, values: values)
}
