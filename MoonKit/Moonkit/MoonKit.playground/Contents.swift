//: Playground - noun: a place where people can play
import Foundation
import UIKit
import MoonKit

let url = "http://10.0.0.14"

do {
  let detector = try NSDataDetector(types: NSTextCheckingType.Link.rawValue)
  let result = detector.firstMatchInString(url, options: [], range: url.range)
  print(result)
  result?.range
}