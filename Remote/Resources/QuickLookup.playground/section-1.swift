// Playground - noun: a place where people can play

import Foundation
import UIKit

typealias GestureBoolResponse = (UIGestureRecognizer) -> Bool
typealias GestureTouchBoolResponse = (UIGestureRecognizer, UITouch) -> Bool
typealias GestureGestureBoolResponse = (UIGestureRecognizer, UIGestureRecognizer) -> Bool

let shouldBegin: ((Void) -> Bool) -> GestureBoolResponse = { p in {_ in p()} }
let shouldReceiveTouch: ((UITouch) -> Bool) -> GestureTouchBoolResponse = {
  p in { gesture, touch in p(touch)}
}
let shouldRecognize: ((UIGestureRecognizer) -> Bool) -> GestureGestureBoolResponse = {
  p in {_, gesture in p(gesture)}
}

func curryShouldBegin()(gesture: UIGestureRecognizer) -> Bool {
  return false
}

let wtf = curryShouldBegin()

let wtfRange = 0...5
wtfRange
let inWTFRange: Bool = contains(wtfRange,8)

let s = "what-the-fuck"
let sMapped = map(s){
  (c:Character) -> Character in c == "-" ? " " : c
}
String(sMapped)

protocol JSONValue {
  typealias JSONValueType
  var JSONKey: String { get }
  init?(JSONValue: JSONValueType)
}

enum BaseType: Int, JSONValue  {
  case Undefined, Remote, ButtonGroup, Button
  var JSONKey: String {
    switch self {
    case .Undefined:   return "undefined"
    case .Remote:      return "remote"
    case .ButtonGroup: return "button-group"
    case .Button:      return "button"
    }
  }
  init?(JSONValue: String) {
    switch JSONValue {
      case BaseType.Remote.JSONKey: self = .Remote
      case BaseType.ButtonGroup.JSONKey: self = .ButtonGroup
      case BaseType.Button.JSONKey: self = .Button
      default: self = .Undefined
    }
  }
}

let t = BaseType.Remote

t.JSONKey
BaseType.init(JSONValue: "button")?.JSONKey ?? "wtf"

let huh = split("what the fuck"){$0 == " "}
huh
