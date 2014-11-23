//
//  ControlStateTitleSet.swift
//  Remote
//
//  Created by Jason Cardwell on 11/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MoonKit

extension UIControlState: JSONValueConvertible {
  var JSONValue: String {
    var flags: [String] = []
    if self & UIControlState.Highlighted != nil { flags.append("highlighted") }
    if self & UIControlState.Selected    != nil { flags.append("selected")    }
    if self & UIControlState.Disabled    != nil { flags.append("disabled")    }
    if flags.count == 0 { flags.append("normal") }
    return " ".join(flags)
  }
  init?(JSONValue: String) {
    let flags = split(JSONValue){$0 == " "}
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

class ControlStateTitleSet: ControlStateSet {

  @NSManaged var disabled:                    TitleAttributes?
  @NSManaged var selectedDisabled:            TitleAttributes?
  @NSManaged var highlighted:                 TitleAttributes?
  @NSManaged var highlightedDisabled:         TitleAttributes?
  @NSManaged var highlightedSelected:         TitleAttributes?
  @NSManaged var normal:                      TitleAttributes?
  @NSManaged var selected:                    TitleAttributes?
  @NSManaged var highlightedSelectedDisabled: TitleAttributes?

  /**
  setTitleAttributes:forState:

  :param: attributes TitleAttributes?
  :param: state UIControlState
  */
  func setTitleAttributes(attributes: TitleAttributes?, forState state: UIControlState) {
    switch state {
      case UIControlState.Normal:                                                      normal                      = newValue
      case UIControlState.Highlighted:                                                 highlighted                 = newValue
      case UIControlState.Selected:                                                    selected                    = newValue
      case UIControlState.Disabled:                                                    disabled                    = newValue
      case UIControlState.Highlighted|UIControlState.Selected:                         highlightedSelected         = newValue
      case UIControlState.Highlighted|UIControlState.Disabled:                         highlightedDisabled         = newValue
      case UIControlState.Selected|UIControlState.Disabled:                            selectedDisabled            = newValue
      case UIControlState.Highlighted|UIControlState.Selected|UIControlState.Disabled: highlightedSelectedDisabled = newValue
      default:                                                                         break
    }
  }

  /**
  titleAttributesForState:

  :param: state UIControlState

  :returns: TitleAttributes?
  */
  func titleAttributesForState(state: UIControlState) -> TitleAttributes? {
    switch state {
      case UIControlState.Normal:                                                      return normal
      case UIControlState.Highlighted:                                                 return highlighted
      case UIControlState.Selected:                                                    return selected
      case UIControlState.Disabled:                                                    return disabled
      case UIControlState.Highlighted|UIControlState.Selected:                         return highlightedSelected
      case UIControlState.Highlighted|UIControlState.Disabled:                         return highlightedDisabled
      case UIControlState.Selected|UIControlState.Disabled:                            return selectedDisabled
      case UIControlState.Highlighted|UIControlState.Selected|UIControlState.Disabled: return highlightedSelectedDisabled
      default:                                                                         return nil
    }
  }

  func attributedStringForState(state: UIControlState) -> NSAttributedString {
    let defaultAttributes = normal?.attributes ?? MSDictionary()
    if let attributes = titleAttributesForState(state) {

    }
  }

  /**
  updateWithData:

  :param: data [NSObject AnyObject]
  */
  override func updateWithData(data: [NSObject:AnyObject]) {
    super.updateWithData(data)

    if let jsonData = data as? [String:[String:AnyObject]] {
      for (stateKey, dictionary) in jsonData {
        if let controlState = UIControlState(JSONValue: stateKey) {
          setTitleAttributes(TitleAttributes.importObjectFromData(dictionary)), forState: controlState)
        }
      }
    }
  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()
    dictionary.removeObjectsForKeys((0...7).map{UIControlState(rawValue: UInt($0))!.JSONValue})
    for i in 0...7 {
      let state = UIControlState(rawValue: UInt(i))!
      if let attributes = titleAttributesForState(state) { dictionary[state.JSONValue] = attributes.JSONDictionary() }
    }
    return dictionary
  }

}
