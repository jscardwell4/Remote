//
//  ControlStateSet.swift
//  Remote
//
//  Created by Jason Cardwell on 3/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MoonKit

/** Add JSON conversion to `UIControlState` */
extension UIControlState: JSONValueConvertible {
  public var jsonValue: JSONValue {
    var flags: [String] = []
    if self & UIControlState.Highlighted != nil { flags.append("highlighted") }
    if self & UIControlState.Selected    != nil { flags.append("selected")    }
    if self & UIControlState.Disabled    != nil { flags.append("disabled")    }
    if flags.count == 0 { flags.append("normal") }
    return .String(" ".join(flags))
  }

  public init?(jsonValue: JSONValue) {
    let flags = split(jsonValue.value as? String ?? ""){$0 == " "}
    if !contains(1...3, flags.count) { return nil }
    var state = UIControlState.Normal
    for flag in flags {
      switch flag {
      case "highlighted": state |= UIControlState.Highlighted
      case "selected":    state |= UIControlState.Selected
      case "disabled":    state |= UIControlState.Disabled
      case "normal":      if state != UIControlState.Normal { return nil }
      default:            return nil
      }
    }
    self = state
  }
}

/** Add type enumeration to `UIControlState` */
extension UIControlState: EnumerableType {
  public static var all: [UIControlState] {
    return [.Normal, .Highlighted, .Selected, .Disabled,
      .Highlighted | .Selected, .Highlighted | .Disabled,
      .Highlighted | .Selected | .Disabled]
  }
  public static func enumerate(block: (UIControlState) -> Void) { apply(all, block) }
}

/** Add `ControlStateSet` specific methods and properties to `UIControlState` */
extension UIControlState {

  /** Corresponding property name suitable for use in methods such as `valueForKey:` */
  public var controlStateSetProperty: String? {
    let string = jsonValue.value as! String
    return count(string) > 0 ? string.camelcaseString : nil
  }

  /**
  Initialize the state using a `ControlStateSet` property name

  :param: controlStateSetProperty String
  */
  public init?(controlStateSetProperty: String) {
    switch controlStateSetProperty {
      case "normal":                      self = .Normal
      case "disabled":                    self = .Disabled
      case "selected":                    self = .Selected
      case "highlighted":                 self = .Highlighted
      case "highlightedDisabled":         self = .Highlighted | .Disabled
      case "highlightedSelected":         self = .Highlighted | .Selected
      case "highlightedSelectedDisabled": self = .Highlighted | .Selected | .Disabled
      case "selectedDisabled":            self = .Selected | .Disabled
      default:                            return nil
    }
  }
}

@objc(ControlStateSet)
public class ControlStateSet: ModelObject {

  public var dictionary: [String:AnyObject] {
    var dict: [String:AnyObject] = [:]
    UIControlState.enumerate {
      if let key = $0.controlStateSetProperty, let value: AnyObject = self.valueForKey(key) {
        dict[key] = value
      }
    }
    return dict
  }

  public var allValues: [AnyObject] { return Array(dictionary.values) }

  public var isEmpty: Bool { return dictionary.isEmpty }

  /**
  Accessor employs fallthrough logic for properties with nil values

  :param: idx UInt

  :returns: AnyObject?
  */
  public subscript(idx: UInt) -> AnyObject? {
    get {
      let state = UIControlState(rawValue: idx)
      if let property = state.controlStateSetProperty, let value: AnyObject = self[property] {
        return value
      }
      if let property = (state & .Selected).controlStateSetProperty, let value: AnyObject = self[property] {
        return value
      }
      if let property = (state & .Highlighted).controlStateSetProperty, let value: AnyObject = self[property] {
        return value
      }
      return self["normal"]
    }
    set { if let property = UIControlState(rawValue: UInt(idx)).controlStateSetProperty { self[property] = newValue } }
  }

  /**
  Provides raw property access

  :param: property String

  :returns: AnyObject?
  */
  public subscript(property: String) -> AnyObject? {
    get { return UIControlState(controlStateSetProperty: property) != nil ? valueForKey(property) : nil }
    set { if UIControlState(controlStateSetProperty: property) != nil { setValue(newValue, forKey: property) } }
  }

}
