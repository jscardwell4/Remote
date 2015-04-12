//: Playground - noun: a place where people can play

import UIKit
import MoonKit

func takesAnInt(i: Int) {
  println("takesAnInt(i = \(i))")
}

func takesAndReturnsAnInt(i: Int) -> Int? {
  println("takesAndReturnsAnInt(i = \(i))")
  return i
}

var anI: Int? = 4

flatMap(anI, takesAndReturnsAnInt)
anI <?> takesAndReturnsAnInt
anI ?> takesAnInt
anI = nil

flatMap(anI, takesAndReturnsAnInt)
anI <?> takesAndReturnsAnInt
anI ?> takesAnInt

typealias T = Int
typealias U = Int
anI = 6
let curriedFlatMap: T? -> (T -> U?) -> U? = curry(flatMap)
curriedFlatMap(anI)(takesAndReturnsAnInt)

let actualRaw = "{ \"uuid\": \"FFD22B3B-55F5-4E69-BD11-F7E52F0A56A1\", \"name\": \"20.12.40.1\", \"flag\": 128, \"address\": \"20 12 40 1\", \"type\": \"1.58.193.0\", \"enabled\": true, \"pnode\": \"20 12 40 1\", \"propertyFormatted\": \"On\", \"propertyID\": \"ST\", \"propertyUOM\": \"%/on/off\", \"propertyValue\": 255 }"

let expectedRaw = "{ \"name\": \"20.12.40.1\", \"flag\": 128, \"address\": \"20 12 40 1\", \"type\": \"1.58.193.0\", \"enabled\": true, \"pnode\": \"20 12 40 1\", \"propertyID\": \"ST\", \"propertyValue\": 255, \"propertyUOM\": \"%/on/off\", \"propertyFormatted\": \"On\", \"device.uuid\": \"6BAD3045-DC09-4D29-AEF3-4063D3590BDD\", \"groups\": [ \"CD2361AC-84C2-48D6-A0B4-9A0CB7B3A8D0\" ] }"

let actualJSON = JSONValue(rawValue: actualRaw)
let expectedJSON = JSONValue(rawValue: expectedRaw)
let actualData = ObjectJSONValue(actualJSON)
let expectedData = ObjectJSONValue(expectedJSON?.inflatedValue)?.filter({(k, _) in ["device", "groups"] ∌ k})

actualData?.contains(expectedData!)

let x: Int? = 4
var a = [1, 2, 3]

x ?> a.append
a

