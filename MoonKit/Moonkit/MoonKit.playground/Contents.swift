//: Playground - noun: a place where people can play
import Foundation
import UIKit
import MoonKit

let wtfDict: [String: AnyObject] = [
  "huh": "something",
  "nothing": ["say": "what", "huh": "okay"],
  "what": "nothing"
]
//let huhWTF: [String] = valuesForKey("huh", wtfDict)

"Helvetica Neue@32".matchFirst("^([^@]*)@?([0-9]*\\.?[0-9]*)")
let s1 = ["Top", "Bottom", "Left", "Right"]
let s2 = [1, 2 , 3]
let s1CrossS2 = crossZip(s1, s2)

//
//let indicator = UIImageView.newForAutolayout()
//indicator.nametag = "indicator"
////indicator.constrain("self.width ≤ self.height :: self.height = 22")
//
//let deleteButton = UIButton()
//deleteButton.setTranslatesAutoresizingMaskIntoConstraints(false)
//deleteButton.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.75)
//deleteButton.setTitle("Delete", forState: .Normal)
//deleteButton.constrain("self.width = 100")
//
//var indicatorImage = UIImage(named: "1040-checkmark-toolbar")
//indicator.image = indicatorImage
//
//let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 34))
//label.setTranslatesAutoresizingMaskIntoConstraints(false)
//label.text = "Label Muthafucka!"
//label.font = UIFont.systemFontOfSize(20)
//
//let contentView = UIView()
//contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
//contentView.backgroundColor = UIColor.lightGrayColor().colorWithAlpha(0.5)
//contentView.addSubview(indicator)
//contentView.addSubview(label)
//contentView.addSubview(deleteButton)
//
//let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 38))
//view.backgroundColor = UIColor.whiteColor()
//view.addSubview(contentView)
//view.setNeedsLayout()
//view.layoutIfNeeded()
//view
//
//let identifier = createIdentifier(view, "Internal")
//
//// Refresh our constraints
//let format = "\n".join(
//  "H:|[content]|", "V:|[content]|",
//  "delete.right = self.right",
//  "delete.top = self.top",
//  "delete.bottom = self.bottom",
//  "H:|-[indicator]-[label]",
//  "label.centerY = content.centerY",
//  "indicator.centerY = content.centerY")
//let views = ["delete": deleteButton, "content": contentView, "indicator": indicator, "label": label]
//view.constrain(format, views: views, identifier: identifier)
//view.setNeedsLayout()
//view.layoutIfNeeded()
//
//
//view
//
//
//
//
//
//
//view.removeAllConstraints()
//view.setNeedsLayout()
//view.layoutIfNeeded()
//
//
//
//infix operator =|= {}
//infix operator =-= {}
//
//func =|=<V1:UIView, V2:UIView>(lhs: V1, rhs: V2) {
//  if lhs.isDescendantOfView(rhs) {
//    rhs.constrain("lhs.centerX = self.centerX", views: ["lhs": lhs])
//  } else if rhs.isDescendantOfView(lhs) {
//    lhs.constrain("rhs.centerX = self.centerX", views: ["rhs": rhs])
//  }
//}
//
//func =-=<V1:UIView, V2:UIView>(lhs: V1, rhs: V2) {
//  if lhs.isDescendantOfView(rhs) {
//    rhs.constrain("lhs.centerY = self.centerY", views: ["lhs": lhs])
//  } else if rhs.isDescendantOfView(lhs) {
//    lhs.constrain("rhs.centerY = self.centerY", views: ["rhs": rhs])
//  }
//}
//
//
//
//
//label =|= view
//label =-= view
//
//view.setNeedsLayout()
//view.layoutIfNeeded()
//
//view
//
//
//
//
//
//
//var scanner = NSScanner(string: "+ 20")
//var f: Float = 0.0
//let didScanFloatWithSpace = scanner.scanFloat(&f)
//scanner = NSScanner(string: "+20")
//let didScanFloatWithoutSpace = scanner.scanFloat(&f)
//let str = "+ 20"
//let filteredStr = String(filter(str, {$0 != " "}))
//filteredStr
//
//func takesAnInt(i: Int) {
//  println("takesAnInt(i = \(i))")
//}
//
//func takesAndReturnsAnInt(i: Int) -> Int? {
//  println("takesAndReturnsAnInt(i = \(i))")
//  return i
//}
//
//var anI: Int? = 4
//
//flatMap(anI, takesAndReturnsAnInt)
//anI ?>> takesAndReturnsAnInt
//anI ?>> takesAnInt
//anI = nil
//
//flatMap(anI, takesAndReturnsAnInt)
//anI ?>> takesAndReturnsAnInt
//anI ?>> takesAnInt
//
//typealias T = Int
//typealias U = Int
//anI = 6
//let curriedFlatMap: T? -> (T -> U?) -> U? = curry(flatMap)
//curriedFlatMap(anI)(takesAndReturnsAnInt)
//
//let actualRaw = "{ \"uuid\": \"FFD22B3B-55F5-4E69-BD11-F7E52F0A56A1\", \"name\": \"20.12.40.1\", \"flag\": 128, \"address\": \"20 12 40 1\", \"type\": \"1.58.193.0\", \"enabled\": true, \"pnode\": \"20 12 40 1\", \"propertyFormatted\": \"On\", \"propertyID\": \"ST\", \"propertyUOM\": \"%/on/off\", \"propertyValue\": 255 }"
//
//let expectedRaw = "{ \"name\": \"20.12.40.1\", \"flag\": 128, \"address\": \"20 12 40 1\", \"type\": \"1.58.193.0\", \"enabled\": true, \"pnode\": \"20 12 40 1\", \"propertyID\": \"ST\", \"propertyValue\": 255, \"propertyUOM\": \"%/on/off\", \"propertyFormatted\": \"On\", \"device.uuid\": \"6BAD3045-DC09-4D29-AEF3-4063D3590BDD\", \"groups\": [ \"CD2361AC-84C2-48D6-A0B4-9A0CB7B3A8D0\" ] }"
//
//let actualJSON = JSONValue(rawValue: actualRaw)
//let expectedJSON = JSONValue(rawValue: expectedRaw)
//let actualData = ObjectJSONValue(actualJSON)
//let expectedData = ObjectJSONValue(expectedJSON?.inflatedValue)?.filter({(k, _) in ["device", "groups"] ∌ k})
//
//actualData?.contains(expectedData!)
//
//let x: Int? = 4
//var a = [1, 2, 3]
//
//x ?>> a.append
//a
//
//println()
//let unflat1 = [ [1, 2], [3, [4, [5, 6, 7, [8, 9] ] ] ] ]
//println("unflat1 = \(unflat1)")
//let unflatFlattened1: [Int] = flattened(unflat1)
//println("unflatFlattened1 = \(unflatFlattened1)")
//
//let unflat2 = [ [1, "two"], [3, ["four", [5, 6, 7, [8, 9] ] ] ] ]
//println()
//println("unflat2 = \(unflat2)")
//let unflatFlattened2Any: [Any] = flattened(unflat2)
//println("unflatFlattened2Any = \(unflatFlattened2Any)")
//let unflatFlattened2Int: [Int] = flattened(unflat2)
//println("unflatFlattened2Int = \(unflatFlattened2Int)")
//let unflatFlattened2String: [String] = flattened(unflat2)
//println("unflatFlattened2String = \(unflatFlattened2String)")
//println()
//let s = "I am a String"
//let matchesSpace: Character -> Bool = {$0 == " "}
//let spaceSeparated = split(Array(s.generate()), isSeparator:matchesSpace).map({String($0)})
//println("spaceSeparated = \(spaceSeparated)")
//let anyButSpaceSeparated = split(Array(s.generate()), isSeparator: invert(matchesSpace)).map({String($0)})
//println("anyButSpaceSeparated = \(anyButSpaceSeparated)")
//
//
//
//func memoize1<T: Hashable, U>(body: ((T) -> U, T) -> U) -> (T) -> U {
//  var memo: [T:U] = [:]
//  var result: (T -> U)!
//  result = {
//    (t: T) -> U in
//    if let q = memo[t] { return q }
//    let r = body(result, t)
//    memo[t] = r
//    return r
//  }
//  return result
//}
//
//func memoize2<T:Hashable, U>(fn : ((T) -> U, T) -> U) -> (T -> U) {
//  var cache = Dictionary<T, U>()
//  var memoized: (T -> U)!
//  memoized = {
//    (t: T) -> U in
//    if cache.indexForKey(t) == nil {
//      cache[t] = fn(memoized, t)
//    }
//    return cache[t]!
//  }
//  return memoized
//}
//
//
//let fibonacci1 = memoize1 {
//  (fibonacci: (Double) -> Double, n: Double) -> Double in
//  n < 2 ? n : fibonacci(n-1) + fibonacci(n-2)
//}
//let fibonacci2 = memoize2 {
//  (fibonacci: (Double) -> Double, n: Double) -> Double in
//  n < 2 ? n : fibonacci(n-1) + fibonacci(n-2)
//}
//
//println(fibonacci1(45)/fibonacci1(44))
//println(fibonacci2(45)/fibonacci2(44))
