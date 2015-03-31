//
//  Dictionary+MoonKitAdditions.swift
//  Remote
//
//  Created by Jason Cardwell on 12/20/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

extension NSDictionary: JSONExport {}

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

/**
extend:newEntries:

:param: x [K:V]
:param: newEntries [K:V]
*/
public func extend<K,V>(inout x: [K:V], newEntries: [K:V]) { for (key, value) in newEntries { x[key] = value } }

/**
map:block:

:param: dict [K:V]
:param: block (K, V) -> U
:returns: [K:U]
*/
public func map<K,V,U>(dict: [K:V], block: (K, V) -> U) -> [K:U] {
  var result: [K:U] = [:]
  for (key, value) in dict { result[key] = block(key, value) }
  return result
}

/**
subscript:rhs:

:param: lhs [K
:param: rhs K

:returns: [K:V]
*/
public func -<K,V>(var lhs: [K:V], rhs: K) -> [K:V] {
  lhs.removeValueForKey(rhs)
  return lhs
}

/**
filter:

:param: dict [K V]

:returns: [K:V]
*/
public func filter<K:Hashable,V>(dict: [K:V], include: (K, V) -> Bool) -> [K:V] {
  var filteredDict: [K:V] = [:]
  for (key, value) in dict { if include(key, value) { filteredDict[key] = value } }
  return filteredDict
}