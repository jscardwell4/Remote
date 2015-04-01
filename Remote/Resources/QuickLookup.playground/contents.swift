// Playground - noun: a place where people can play
import Foundation
import UIKit

let string = "wtf"
String(Array(string)[0..<2])

let s: String.Index = string.startIndex
s.getMirror().disposition
let m = s.getMirror()
m.value
m.valueType
m.summary

dropLast(string)


