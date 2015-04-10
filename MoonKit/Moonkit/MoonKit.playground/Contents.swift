//: Playground - noun: a place where people can play

import UIKit
import MoonKit

let backgroundsString = "Backgrounds"
let agedPaperString = "Aged Paper"
let imageObjectValue: OrderedDictionary<String, JSONValue> = [
  "name": agedPaperString.jsonValue,
  "asset-name": agedPaperString.jsonValue
]
let imagesArrayValue = [JSONValue.Object(imageObjectValue)]

let rootObjectValue: OrderedDictionary<String, JSONValue> = [
  "name": backgroundsString.jsonValue,
  "images": .Array(imagesArrayValue)
]

let rootJSON = JSONValue.Object(rootObjectValue)
println(rootJSON.prettyRawValue)
println(rootJSON.debugDescription)

let equalStrings = backgroundsString.jsonValue == rootObjectValue["name"]

let equalArrays = JSONValue.Array(imagesArrayValue) == rootObjectValue["images"]

let equalObjects = JSONValue.Object(imageObjectValue) == ArrayJSONValue(rootObjectValue["images"])![0]

let equalRoots = JSONValue.Object(rootObjectValue) == rootJSON


let array1 = ["one".jsonValue, "two".jsonValue, "three".jsonValue]
let array2 = ["two".jsonValue, "three".jsonValue]

var does1Contain2 = ArrayJSONValue(array1).contains(ArrayJSONValue(array2))
var does2Contain1 = ArrayJSONValue(array2).contains(ArrayJSONValue(array1))

let object1: JSONValue.ObjectValue = ["one": 1.jsonValue, "two": 2.jsonValue, "three": 3.jsonValue]
let object2: JSONValue.ObjectValue = ["two": 2.jsonValue, "three": 3.jsonValue]

does1Contain2 = ObjectJSONValue(object1).contains(ObjectJSONValue(object2))
does2Contain1 = ObjectJSONValue(object2).contains(ObjectJSONValue(object1))

println(toDebugString(ObjectJSONValue(object1)))