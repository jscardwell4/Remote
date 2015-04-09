//: Playground - noun: a place where people can play

import UIKit
import MoonKit

let expectedJSON = JSONValue(rawValue: "\n".join("{",
                                                   "\"name\": \"Backgrounds\",",
                                                   "\"images\": [",
                                                     "{",
                                                       "\"asset-name\": \"Aged Paper\",",
                                                       "\"name\": \"Aged Paper\"",
                                                     "}",
                                                   "]",
                                                 "}"))!
let expectedJSONObject = ObjectJSONValue(expectedJSON)!

var expectedData = expectedJSONObject.value
//let excluded = ["images.name", "name"]
//let excludedSet = Set(excluded)
//let expectedDataKeys = Set(expectedData.keys)
//let possibleKeypaths = excludedSet.subtract(expectedDataKeys)
//expectedData.removeValuesForKeys(excludedSet.subtract(possibleKeypaths))
//expectedData
//var keypathStacks = map(possibleKeypaths, {$0.keypathStack}).filter({$0.count > 1})
//toString(keypathStacks)
//
//var keypathMap: [String:Stack<String>] = [:]
//while keypathStacks.count > 0 {
//  for i in 0..<keypathStacks.count {
//    if let top = keypathStacks[i].pop() {
//
//    }
//  }
//}
