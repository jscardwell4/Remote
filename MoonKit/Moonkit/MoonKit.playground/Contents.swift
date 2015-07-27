//: Playground - noun: a place where people can play
import Foundation
import UIKit
import MoonKit

let fullRange = 0 ..< 296

var removalRanges: Queue<Range<Int>> = [23 ..< 47, 96 ..< 108, 175 ..< 192, 222 ..< 225]

//removalRanges.reverse()
//removalRanges.peek

var inverted: [Range<Int>] = []

var n = fullRange.startIndex

while let r = removalRanges.dequeue() {

  switch r.startIndex {
    case n: n = r.endIndex
    case let s where s > n: inverted.append(n ..< s); n = r.endIndex
    default: break
  }

}

if n < fullRange.endIndex { inverted.append(n ..< fullRange.endIndex) }

fullRange.split([23 ..< 47, 96 ..< 108, 175 ..< 192, 222 ..< 225])

let wtf = "This12String54524is325Fucked5234up"

wtf.split(~/"[0-9]+")
wtf.split(~/"(?=[0-9][0-9]*+)")

let matches = (~/"(?=[0-9]++)").match(wtf)
print(matches)

let wtf2 = "IRCodeSet muthafucka!!!"
wtf2.isCamelCase
wtf2.camelCaseString.isCamelCase
"IRCodeSet muthafucka!!!".camelCaseString
let components = "IRCodeSet muthafucka!!!".split(~/"(?<=\\p{Ll})(?=\\p{Lu})|(?<=\\p{Lu})(?=\\p{Lu})|(\\p{Z}|\\p{P})")

"IRCodeSet Muthafucka!!!".camelCaseString

wtf2.dashCaseString
wtf2.dashCaseString.isDashCase

"IRCodeSet".isCamelCase
"IRCodeSet".isPascalCase
let wtf3 = "IRCodeSet".camelCaseString.sub(~/"^(\\p{Ll}+)", {
  (match: RegularExpression.Match) -> String in
  match.description

  return match.captures[1]!.string.uppercaseString
  }
)
wtf3
"IRCodeSet".camelCaseString.pascalCaseString
"irCodeSet".pascalCaseString

"IRCodeSet".split(~/"(?=\\p{Lu}\\p{Ll})")

