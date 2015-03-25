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

@objc(ControlStateTitleSet)
public final class ControlStateTitleSet: ControlStateSet {

  @NSManaged public var disabled:                    DictionaryStorage?
  @NSManaged public var selectedDisabled:            DictionaryStorage?
  @NSManaged public var highlighted:                 DictionaryStorage?
  @NSManaged public var highlightedDisabled:         DictionaryStorage?
  @NSManaged public var highlightedSelected:         DictionaryStorage?
  @NSManaged public var normal:                      DictionaryStorage?
  @NSManaged public var selected:                    DictionaryStorage?
  @NSManaged public var highlightedSelectedDisabled: DictionaryStorage?

  /**
  setTitleAttributes:forState:

  :param: attributes TitleAttributes?
  :param: state UIControlState
  */
  public func setTitleAttributes(attributes: TitleAttributes?, forState state: UIControlState) {
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
        storage?.dictionary = attributes!.dictionaryValue as [NSObject:AnyObject]
      }
    }

  }

  /**
  titleAttributesForState:

  :param: state UIControlState

  :returns: TitleAttributes?
  */
  public func titleAttributesForState(state: UIControlState) -> TitleAttributes? {
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
    return storage == nil ? nil : TitleAttributes(storage: storage!.dictionary as! [String:AnyObject])
  }

  public func attributedStringForState(state: UIControlState) -> NSAttributedString? {
    var string: NSAttributedString?
    if let indexedAttributes = self[state.rawValue] as? DictionaryStorage {
      let attributes = TitleAttributes(storage: indexedAttributes.dictionary as! [String:AnyObject])
      if state == UIControlState.Normal {
        string = attributes.string
      } else {
        var normalAttributes: TitleAttributes?
        if normal != nil { normalAttributes = TitleAttributes(storage: normal!.dictionary as! [String:AnyObject]) }
        string = normalAttributes == nil ? attributes.string : attributes.stringWithFillers(normalAttributes!.attributes)
      }
    }
    return string
  }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override public func updateWithData(data: [String:AnyObject]) {
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
  override public func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()
    UIControlState.enumerate {
      if let attributes = self.titleAttributesForState($0) { dictionary[$0.JSONValue] = attributes.JSONValue }
    }


    dictionary.compact()
    dictionary.compress()

    return dictionary
  }

}
