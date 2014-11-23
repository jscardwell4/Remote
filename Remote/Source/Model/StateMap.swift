//
//  StateMap.swift
//  Remote
//
//  Created by Jason Cardwell on 11/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MoonKit

struct State: RawOptionSetType {
  private(set) var rawValue: UIControlState.RawValue
  init(rawValue: UIControlState.RawValue) { self.rawValue = rawValue }
  init(nilLiteral: ()) { rawValue = 0 }
  static var allZeros:    State { return State.Normal }
  static var Normal:      State = State(rawValue: UIControlState.Normal.rawValue)
  static var Highlighted: State = State(rawValue: UIControlState.Highlighted.rawValue)
  static var Selected:    State = State(rawValue: UIControlState.Selected.rawValue)
  static var Disabled:    State = State(rawValue: UIControlState.Disabled.rawValue)
}

@objc(StateMap)
class StateMap<T:AnyObject>: ModelObject {


  var storage: DictionaryStorage {
    get {
      willAccessValueForKey("storage")
      let dictionary = primitiveValueForKey("storage") as DictionaryStorage
      didAccessValueForKey("storage")
      return dictionary
    }
    set {
      willChangeValueForKey("storage")
      setPrimitiveValue(newValue, forKey: "storage")
      didChangeValueForKey("storage")
    }
  }

  /**
  subscript:

  :param: state State

  :returns: T?
  */
  subscript(state: State) -> T? {
    get {
      var s = state
      var obj: T? = storage[s.rawValue] as? T
      if obj == nil && (s & State.Selected != nil) { s &= ~State.Selected; obj = storage[s.rawValue] as? T }
      if obj == nil && (s & State.Highlighted != nil) { s &= ~State.Highlighted; obj = storage[s.rawValue] as? T }
      if obj == nil && s != State.Normal { obj = storage[State.Normal.rawValue] as? T}
      return obj
    }
    set { storage[state.rawValue] = newValue }
  }

}
