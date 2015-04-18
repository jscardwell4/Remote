//: Playground - noun: a place where people can play
import Foundation
import UIKit
import MoonKit

var scanner = NSScanner(string: "+ 20")
var f: Float = 0.0
let didScanFloatWithSpace = scanner.scanFloat(&f)
scanner = NSScanner(string: "+20")
let didScanFloatWithoutSpace = scanner.scanFloat(&f)
let str = "+ 20"
let filteredStr = String(filter(str, {$0 != " "}))
filteredStr

func takesAnInt(i: Int) {
  println("takesAnInt(i = \(i))")
}

func takesAndReturnsAnInt(i: Int) -> Int? {
  println("takesAndReturnsAnInt(i = \(i))")
  return i
}

var anI: Int? = 4

flatMap(anI, takesAndReturnsAnInt)
anI ?>> takesAndReturnsAnInt
anI ?>> takesAnInt
anI = nil

flatMap(anI, takesAndReturnsAnInt)
anI ?>> takesAndReturnsAnInt
anI ?>> takesAnInt

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

x ?>> a.append
a

println()
let unflat1 = [ [1, 2], [3, [4, [5, 6, 7, [8, 9] ] ] ] ]
println("unflat1 = \(unflat1)")
let unflatFlattened1: [Int] = flattened(unflat1)
println("unflatFlattened1 = \(unflatFlattened1)")

let unflat2 = [ [1, "two"], [3, ["four", [5, 6, 7, [8, 9] ] ] ] ]
println()
println("unflat2 = \(unflat2)")
let unflatFlattened2Any: [Any] = flattened(unflat2)
println("unflatFlattened2Any = \(unflatFlattened2Any)")
let unflatFlattened2Int: [Int] = flattened(unflat2)
println("unflatFlattened2Int = \(unflatFlattened2Int)")
let unflatFlattened2String: [String] = flattened(unflat2)
println("unflatFlattened2String = \(unflatFlattened2String)")
println()
let s = "I am a String"
let matchesSpace: Character -> Bool = {$0 == " "}
let spaceSeparated = split(Array(s.generate()), isSeparator:matchesSpace).map({String($0)})
println("spaceSeparated = \(spaceSeparated)")
let anyButSpaceSeparated = split(Array(s.generate()), isSeparator: invert(matchesSpace)).map({String($0)})
println("anyButSpaceSeparated = \(anyButSpaceSeparated)")

println()
let format = "$1.bottom = self.bottom"
let pseudo = PseudoConstraint(format)
println(pseudo!.description)
println(pseudo!.debugDescription)
