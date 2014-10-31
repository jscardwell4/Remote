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
