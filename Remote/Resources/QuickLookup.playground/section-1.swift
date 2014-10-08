// Playground - noun: a place where people can play

import Foundation
import UIKit

let string = "abcdefghijklmnopqrstuvwxyz"

string[advance(string.startIndex, 6)]

string[advance(string.endIndex, -6)]


string[string.startIndex..<advance(string.endIndex, -6)]

let json =   "{\"@include\": \"Manufacturer_LG.json\"}"
find(json, "}")
let r = indices(json)
r

let rstart = r.startIndex
let rend = r.endIndex
let rdistance = distance(rstart, rend)
let newrstart = advance(rstart, 20)
let newrend = advance(rstart, rdistance)


let wtf = newrstart.getMirror()
wtf.value
wtf.disposition

string.utf16[6..<9]
let wtffuck = string.utf16
let somewtffuck = wtffuck[6..<8]


"\(UICollectionViewCell.self)"

class PureSwiftClass {
}

var myvar0 = NSString() // Objective-C class
var myvar1 = PureSwiftClass()
var myvar2 = 42
var myvar3 = "Hans"

println( "TypeName0 = \(_stdlib_getDemangledTypeName(myvar0))")
println( "TypeName1 = \(_stdlib_getDemangledTypeName(myvar1))")
println( "TypeName2 = \(_stdlib_getDemangledTypeName(myvar2))")
println( "TypeName3 = \(_stdlib_getDemangledTypeName(myvar3))")

