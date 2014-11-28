// Playground - noun: a place where people can play

import Foundation
import UIKit
import MoonKit

let u = UnicodeScalar("h")
u.description
u.debugDescription
u.escape(asASCII: false)
u.escape(asASCII: true)
//
//var utf8 = UTF8()
//var wtf = "wtf"
//var wtfGenerator = IndexingGenerator(wtf.utf8)
//var result: UnicodeDecodingResult = .EmptyInput
//outer: do {
// result = utf8.decode(&wtfGenerator)
//switch result {
//  case .Result(let u): println(u.description)
//  default: break outer
//  }
//} while true

//for c in "abcdefghijklmnopqrstuvwxyz".unicodeScalars {
//
//  println(c.value, c)
//  let C = UnicodeScalar(c.value - 32)
//  println(C.value, C)
//}

//let s = "what the fuck hoppuse?"
//compressed(s.rangesForCapture(1, byMatching: "(\\b\\w+\\b)"))
//var camelS = s
//for r in compressed(s.rangesForCapture(1, byMatching: "(\\b\\w+\\b)")) {
//  let segment = s[r]
//
//  let u = String(segment[segment.startIndex]).uppercaseString
//  let theRest = String(dropFirst(segment)).lowercaseString
//  let replacement = u + theRest
//  let index: String.Index = advance(camelS.startIndex, r.startIndex)
//  let index2: String.Index = advance(index, r.endIndex - r.startIndex)
//  camelS.replaceRange(index..<index2, with: replacement)
//}
//camelS
//

//~/"^\\p{Lu}\\p{Ll}*(\\P{L}+\\p{Lu}\\p{Ll}*)*$" ~= "A Fucking Table"
//UnicodeScalar("-")

let camel = "camelCaseString"
let dash = "dash-case-string"
let title = "Title Case String"

camel.dashcaseString
camel.camelcaseString
camel.titlecaseString

dash.camelcaseString
dash.dashcaseString
dash.titlecaseString

title.camelcaseString
title.dashcaseString
title.titlecaseString