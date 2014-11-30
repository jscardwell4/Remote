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
  public var JSONValue: String {
    var flags: [String] = []
    if self & UIControlState.Highlighted != nil { flags.append("highlighted") }
    if self & UIControlState.Selected    != nil { flags.append("selected")    }
    if self & UIControlState.Disabled    != nil { flags.append("disabled")    }
    if flags.count == 0 { flags.append("normal") }
    return " ".join(flags)
  }
  public init?(JSONValue: String) {
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

extension UIControlState: EnumerableType {
  public static var all: [UIControlState] {
    return [.Normal, .Highlighted, .Selected, .Disabled,
      .Highlighted | .Selected, .Highlighted | .Disabled,
      .Highlighted | .Selected | .Disabled]
  }
  public static func enumerate(block: (UIControlState) -> Void) { apply(all, block) }
}

@objc(ControlStateTitleSet)
class ControlStateTitleSet: ControlStateSet {

  @NSManaged var disabled:                    DictionaryStorage?
  @NSManaged var selectedDisabled:            DictionaryStorage?
  @NSManaged var highlighted:                 DictionaryStorage?
  @NSManaged var highlightedDisabled:         DictionaryStorage?
  @NSManaged var highlightedSelected:         DictionaryStorage?
  @NSManaged var normal:                      DictionaryStorage?
  @NSManaged var selected:                    DictionaryStorage?
  @NSManaged var highlightedSelectedDisabled: DictionaryStorage?

  /**
  setTitleAttributes:forState:

  :param: attributes TitleAttributes?
  :param: state UIControlState
  */
  func setTitleAttributes(attributes: TitleAttributes?, forState state: UIControlState) {
    var property: String?
    switch state {
      case UIControlState.Normal:                                                      property = "normal"
      case UIControlState.Highlighted:                                                 property = "highlighted"
      case UIControlState.Selected:                                                    property = "selected"
      case UIControlState.Disabled:                                                    property = "disabled"
      case UIControlState.Highlighted|UIControlState.Selected:                         property = "highlightedSelected"
      case UIControlState.Highlighted|UIControlState.Disabled:                         property = "highlightedDisabled"
      case UIControlState.Selected|UIControlState.Disabled:                            property = "selectedDisabled"
      case UIControlState.Highlighted|UIControlState.Selected|UIControlState.Disabled: property = "highlightedSelectedDisabled"
      default:                                                                         break
    }

    var storage: DictionaryStorage?
    if property != nil {
      if attributes == nil { setValue(nil, forKey: property!) }
      else {
        storage = valueForKey(property!) as? DictionaryStorage
        if storage == nil {
          storage = DictionaryStorage(context: managedObjectContext)
          setValue(storage, forKey: property!)
        }
        assert(storage != nil, "what happened? we should have created storage if it didn't exist")
        storage?.dictionary = attributes!.dictionaryValue
      }
    }

  }

  /**
  titleAttributesForState:

  :param: state UIControlState

  :returns: TitleAttributes?
  */
  func titleAttributesForState(state: UIControlState) -> TitleAttributes? {
    var property: String?
    switch state {
      case UIControlState.Normal:                                                      property = "normal"
      case UIControlState.Highlighted:                                                 property = "highlighted"
      case UIControlState.Selected:                                                    property = "selected"
      case UIControlState.Disabled:                                                    property = "disabled"
      case UIControlState.Highlighted|UIControlState.Selected:                         property = "highlightedSelected"
      case UIControlState.Highlighted|UIControlState.Disabled:                         property = "highlightedDisabled"
      case UIControlState.Selected|UIControlState.Disabled:                            property = "selectedDisabled"
      case UIControlState.Highlighted|UIControlState.Selected|UIControlState.Disabled: property = "highlightedSelectedDisabled"
      default:                                                                         break
    }
    var storage: DictionaryStorage?
    if property != nil { storage = valueForKey(property!) as? DictionaryStorage }
    return storage == nil ? nil : TitleAttributes(storage: storage!.dictionary as [String:AnyObject])
  }

  func attributedStringForState(state: UIControlState) -> NSAttributedString? {
    var string: NSAttributedString?
    if let indexedAttributes = self[state.rawValue] as? DictionaryStorage {
      let attributes = TitleAttributes(storage: indexedAttributes.dictionary as [String:AnyObject])
      if state == UIControlState.Normal {
        string = attributes.string
      } else {
        var normalAttributes: TitleAttributes?
        if normal != nil { normalAttributes = TitleAttributes(storage: normal!.dictionary as [String:AnyObject]) }
        string = normalAttributes == nil ? attributes.string : attributes.stringWithFillers(normalAttributes!.attributes)
      }
    }
    return string
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
          setTitleAttributes(TitleAttributes(JSONValue: dictionary), forState: controlState)
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
    UIControlState.enumerate {
      if let attributes = self.titleAttributesForState($0) { dictionary[$0.JSONValue] = attributes.JSONValue }
      else { dictionary.removeObjectForKey($0.JSONValue) }
    }
    return dictionary
  }

}
