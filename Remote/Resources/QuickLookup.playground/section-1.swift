// Playground - noun: a place where people can play

import Foundation
import UIKit
import MoonKit

let id = "'([^']+)'"
let name = "([a-zA-Z_][-_a-zA-Z0-9]*)"
let attribute = "([a-z]+[a-zA-Z]*)"
let number = "([0-9]+\\.?[0-9]*)"
let relation = "([=≥≤])"
let pattern = " *".join(
  "(?:\(id) )?",
  "\(name)\\.\(attribute) ",
  "\(relation)",
  "(?:\(name)\\.\(attribute)(?: +[x*] +\(number))?)?",
  "(?:([+-])? *\(number))?",
  "(?:@\(number))?"
)

"'id' item1.width = item2.width * 0.5 + 93 @250".matchFirst(pattern)
"'id' item1.width = 93 @250".matchFirst(pattern)
"'id' item1.width = item2.width".matchFirst(pattern)
"item1.width = item2.height - 93".matchFirst(pattern)
"item1.width = item2.width * 0.5".matchFirst(pattern)

var pseudo = NSLayoutPseudoConstraint(format: "'id' item1.width = item2.width * 0.5 + 93 @250")
pseudo?.description

let view1 = UIView()
let view2 = UIView()
let parentView = UIView()
parentView.addSubview(view1)
parentView.addSubview(view2)

let constraint = NSLayoutConstraint.constraintFromNSLayoutPseudoConstraint(pseudo!, views: ["item1": view1, "item2": view2])
constraint?.description