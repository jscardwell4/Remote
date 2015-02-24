// Playground - noun: a place where people can play

import Foundation
import UIKit
import MoonKit
import CoreData

public protocol KeyValueCollectionTypeGenerator {
  typealias Key
  typealias Value
  mutating func next() -> (Key, Value)?
}

extension DictionaryGenerator: KeyValueCollectionTypeGenerator {}

public protocol KeyValueCollectionType: CollectionType {
  typealias Key: Hashable
  typealias Value
  typealias Generator: KeyValueCollectionTypeGenerator
}

extension Dictionary: KeyValueCollectionType {}

public func keys<C: KeyValueCollectionType where C.Generator: KeyValueCollectionTypeGenerator>(x: C) -> [C.Key] {
  var keys: [C.Key] = []
  for entry in x { if let key = reflect(entry)[0].1.value as? C.Key { keys.append(key) } }
  return keys
}

public func values<C: KeyValueCollectionType where C.Generator: KeyValueCollectionTypeGenerator>(x: C) -> [C.Value] {
  var values: [C.Value] = []
  for entry in x { if let value = reflect(entry)[1].1.value as? C.Value { values.append(value) } }
  return values
}


public func formattedDescription<C: KeyValueCollectionType>(dictionary: C, indent:Int = 0) -> String {
  var components: [String] = []

  let entryKeys = keys(dictionary)
  let keyDescriptions = entryKeys.map { "\($0)" }
  keyDescriptions
  let maxKeyLength = keyDescriptions.reduce(0) { max($0, countElements($1)) }
  String(maxKeyLength)
  let space = Character(" ")
  let indentString = String(count:indent*4, repeatedValue:space)
  let entryValues = values(dictionary)
  for (key, value) in Zip2(keyDescriptions, entryValues) {
    let keyLength = key.characterCount
    String(keyLength)
    var spacer = ""
    if keyLength != maxKeyLength {

      let offset = maxKeyLength - keyLength + 1
      let numberOfTabs = floor(Double(offset) / 4.0) - 1
      spacer = String(count:Int(numberOfTabs), repeatedValue:Character("\t"))
    }
    String(spacer.characterCount)
    let keyString = "\(indentString)\(key): \(spacer)"
    var valueString: String
    var valueComponents = split("\(value)") { $0 == "\n" }
    if valueComponents.count > 0 {
      valueString = valueComponents.removeAtIndex(0)
      if valueComponents.count > 0 {
        let subIndentString = "\n\(indentString)" + String(count:Int(floor(Double((maxKeyLength+1))/4.0)) - 1, repeatedValue:Character("\t"))
        valueString += subIndentString + join(subIndentString, valueComponents)
      }
    } else { valueString = "nil" }
    components += ["\(keyString)\(valueString)"]
  }
  return join("\n", components)
}

let dict = ["wtf": "Seriously wtf?", "heyNow": 64, "lithuaniamuthafuckaaaaaa1!": "huh\nwhat kinda\nbullshit is this"]
dict

keys(dict)
values(dict)
"lithuaniamuthafuckaaaaaa1!: ".characterCount
"wtf:                            ".characterCount
formattedDescription(dict, indent: 0)
//formattedDescription(dict, indent: 4)