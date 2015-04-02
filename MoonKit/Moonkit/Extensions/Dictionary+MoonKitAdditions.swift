//
//  Dictionary+MoonKitAdditions.swift
//  Remote
//
//  Created by Jason Cardwell on 12/20/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

extension NSDictionary: JSONExport {
  public var JSONString: String { return JSONSerialization.JSONFromObject(JSONObject) ?? "" }
  public var JSONObject: AnyObject { return self }
}

//extension NSDictionary: JSONValueConvertible {
//  public var JSONValue: NSDictionary { return self }
//  public convenience init?(JSONValue: NSDictionary) { self.init(dictionary: JSONValue) }
//}

public protocol KeyValueCollectionTypeGenerator {
  typealias Key
  typealias Value
  mutating func next() -> (Key, Value)?
}

extension DictionaryGenerator: KeyValueCollectionTypeGenerator {}

public protocol KeyValueCollectionType: CollectionType {
  typealias Key: Hashable
  typealias Value
}

extension Dictionary: KeyValueCollectionType {}

/**
keys:

:param: x C

:returns: [C.Key]
*/
public func keys<C: KeyValueCollectionType where C.Generator: KeyValueCollectionTypeGenerator>(x: C) -> [C.Key] {
  var keys: [C.Key] = []
  for entry in x { if let key = reflect(entry)[0].1.value as? C.Key { keys.append(key) } }
  return keys
}

/**
values:

:param: x C

:returns: [C.Value]
*/
public func values<C: KeyValueCollectionType where C.Generator: KeyValueCollectionTypeGenerator>(x: C) -> [C.Value] {
  var values: [C.Value] = []
  for entry in x { if let value = reflect(entry)[1].1.value as? C.Value { values.append(value) } }
  return values
}


/**
formattedDescription:indent:

:param: dictionary C
:param: indent Int = 0

:returns: String
*/
public func formattedDescription<C: KeyValueCollectionType where C.Generator: KeyValueCollectionTypeGenerator>(dictionary: C, indent: Int = 0) -> String {

  var components: [String] = []

  let keyDescriptions = keys(dictionary).map { "\($0)" }
  let maxKeyLength = keyDescriptions.reduce(0) { max($0, count($1)) }
  let indentation = " " * (indent * 4)
  for (key, value) in zip(keyDescriptions, values(dictionary)) {
    let keyLength = key.characterCount
//    var spacer = ""
//    if keyLength != maxKeyLength {
//      let offset = maxKeyLength - keyLength + 1
//      let numberOfTabs = Int(floor(Double(offset) / 4.0)) - 1
//      spacer = "\t" * numberOfTabs
//    }
    let keyString = "\(indentation)\(key): "//\(spacer)"
    var valueString: String
    var valueComponents = split("\(value)") { $0 == "\n" }
    if valueComponents.count > 0 {
      valueString = valueComponents.removeAtIndex(0)
      if valueComponents.count > 0 {
        let spacer = "\t" * (Int(floor(Double((maxKeyLength+1))/4.0)) - 1)
        let subIndentString = "\n\(indentation)\(spacer)"
        valueString += subIndentString + subIndentString.join(valueComponents)
      }
    } else { valueString = "nil" }
    components += ["\(keyString)\(valueString)"]
  }
  return join("\n", components)
}

extension Dictionary {
  /**
  init:Value)]:

  :param: elements [(Key
  :param: Value)]
  */
  init(_ elements: [(Key,Value)]) {
    self = [Key:Value]()
    for (k, v) in elements { self[k] = v }
  }

  var keyValuePairs: [(Key, Value)] { return Array(SequenceOf({self.generate()})) }
}

/**
keyValuePairs:

:param: dict [K V]

:returns: [(K, V)]
*/
public func keyValuePairs<K:Hashable,V>(dict: [K:V]) -> [(K, V)] { return dict.keyValuePairs }

/**
extended:newElements:V)]:

:param: dict [K V]
:param: newElements [(K
:param: V)]

:returns: [K:V]
*/
public func extended<K:Hashable,V>(dict: [K:V], newElements: [(K,V)]) -> [K:V] {
  return Dictionary(Array(SequenceOf({dict.generate()})) + newElements)
}

/**
extend:newEntries:

:param: x [K:V]
:param: newEntries [K:V]
*/
public func extend<K,V>(inout x: [K:V], newEntries: [K:V]) { for (key, value) in newEntries { x[key] = value } }

/**
map:transform:

:param: dict [K:V]
:param: block (K, V) -> U
:returns: [K:U]
*/
public func map<K,V,U>(dict: [K:V], transform: (K, V) -> U) -> [K:U] {
  var result: [K:U] = [:]
  for (key, value) in dict { result[key] = transform(key, value) }
  return result
}

/**
subscript:rhs:

:param: lhs [K:V]
:param: rhs K

:returns: [K:V]
*/
public func -<K,V>(var lhs: [K:V], rhs: K) -> [K:V] {
  lhs.removeValueForKey(rhs)
  return lhs
}

/**
filter:

:param: dict [K:V]

:returns: [K:V]
*/
public func filter<K:Hashable,V>(dict: [K:V], include: (K, V) -> Bool) -> [K:V] {
  var filteredDict: [K:V] = [:]
  for (key, value) in dict { if include(key, value) { filteredDict[key] = value } }
  return filteredDict
}

/**
compressed:

:param: dict [K:Optional<V>]

:returns: [K:V]
*/
public func compressed<K:Hashable,V>(dict: [K:Optional<V>]) -> [K:V] {
  return Dictionary(dict.keyValuePairs.filter({$1 != nil}).map({($0,$1!)}))
}

/**
compressedMap:transform:

:param: dict [K:V]
:param: block (K, V) -> U?
:returns: [K:U]
*/
public func compressedMap<K:Hashable,V,U>(dict: [K:V], transform: (K, V) -> U?) -> [K:U] {
  return compressed(map(dict, transform))
}

public func inflate(inout dict: [String:AnyObject]) {
  // First gather a list of keys to inflate
  let inflatableKeys = Array(dict.keys.filter({$0 ~= "(?:\\w\\.)+\\w"}))

  // Enumerate the list inflating each key
  for key in inflatableKeys {

    var keypath = MSKeyPath(fromString:key)  // Create a keypath from the inflatable key
    let first = keypath.popFirst()!          // This will become our key
    let last = keypath.popLast()!            // This will become the deepest key in our value



    let value: AnyObject

    // If our value is an array, we embed each value in the array and keep our value as an array
    if let valueArray = dict[key] as? [AnyObject] {

      value = valueArray.map{
        (obj: AnyObject) -> MSDictionary in

        var dict = MSDictionary()  // Create a dictionary within which to embed our value
        var subdict = dict         // This will reference the dictionary to which our value entered

        // If there are stops along the way from first to last, recursively embed in dictionaries
        if !keypath.isEmpty {
          for subkey in keypath {
            subdict[subkey] = MSDictionary()
            var subsubdict = subdict[subkey] as! MSDictionary
            subdict = subsubdict
          }
        }

        subdict[last] = obj
        return dict

        }

    }

      // Otherwise we embed the value
    else {

      var dict = MSDictionary()  // Create a dictionary within which to embed our value
      var subdict = dict         // This will reference the dictionary to which our value entered

      // If there are stops along the way from first to last, recursively embed in dictionaries
      if !keypath.isEmpty {
        for subkey in keypath {
          subdict[subkey] = MSDictionary()
          var subsubdict = subdict[subkey] as! MSDictionary
          subdict = subsubdict
        }
      }

      subdict[last] = dict[key]
      value = dict

    }

    dict[key] = value                              // Remove the compressed key-value entry
  }
}