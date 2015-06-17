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

  @NSManaged public var disabled:                    JSONStorage?
  @NSManaged public var selectedDisabled:            JSONStorage?
  @NSManaged public var highlighted:                 JSONStorage?
  @NSManaged public var highlightedDisabled:         JSONStorage?
  @NSManaged public var highlightedSelected:         JSONStorage?
  @NSManaged public var normal:                      JSONStorage?
  @NSManaged public var selected:                    JSONStorage?
  @NSManaged public var highlightedSelectedDisabled: JSONStorage?

  /**
  setTitleAttributes:forState:

  - parameter attributes: TitleAttributes?
  - parameter state: UIControlState
  */
  public func setTitleAttributes(attributes: TitleAttributes?, forState state: UIControlState) {
    var property: String?
    switch state {
      case UIControlState.Normal:                                                      property = "normal"
      case UIControlState.Highlighted:                                                 property = "highlighted"
      case UIControlState.Selected:                                                    property = "selected"
      case UIControlState.Disabled:                                                    property = "disabled"
      case [UIControlState.Highlighted, UIControlState.Selected]:                         property = "highlightedSelected"
      case [UIControlState.Highlighted, UIControlState.Disabled]:                         property = "highlightedDisabled"
      case [UIControlState.Selected, UIControlState.Disabled]:                            property = "selectedDisabled"
      case [UIControlState.Highlighted, UIControlState.Selected, UIControlState.Disabled]: property = "highlightedSelectedDisabled"
      default:                                                                         break
    }

    var storage: JSONStorage?
    if property != nil {
      if attributes == nil { setValue(nil, forKey: property!) }
      else {
        storage = valueForKey(property!) as? JSONStorage
        if storage == nil {
          storage = JSONStorage(context: managedObjectContext)
          setValue(storage, forKey: property!)
        }
        assert(storage != nil, "what happened? we should have created storage if it didn't exist")
        storage?.dictionary = attributes!.storage
      }
    }

  }

  /**
  titleAttributesForState:

  - parameter state: UIControlState

  - returns: TitleAttributes?
  */
  public func titleAttributesForState(state: UIControlState) -> TitleAttributes? {
    var property: String?
    switch state {
      case UIControlState.Normal:                                                      property = "normal"
      case UIControlState.Highlighted:                                                 property = "highlighted"
      case UIControlState.Selected:                                                    property = "selected"
      case UIControlState.Disabled:                                                    property = "disabled"
      case [UIControlState.Highlighted, UIControlState.Selected]:                         property = "highlightedSelected"
      case [UIControlState.Highlighted, UIControlState.Disabled]:                         property = "highlightedDisabled"
      case [UIControlState.Selected, UIControlState.Disabled]:                            property = "selectedDisabled"
      case [UIControlState.Highlighted, UIControlState.Selected, UIControlState.Disabled]: property = "highlightedSelectedDisabled"
      default:
        break
    }
    if property != nil,
    let storage = valueForKey(property!) as? JSONStorage {
        return TitleAttributes(storage: storage.dictionary)
    } else { return nil }
  }

  public func attributedStringForState(state: UIControlState) -> NSAttributedString? {
    var string: NSAttributedString?
    if let indexedAttributes = self[state.rawValue] as? JSONStorage {
      let attributes = TitleAttributes(storage: indexedAttributes.dictionary)
      if state == UIControlState.Normal {
        string = attributes.string
      } else {
        var normalAttributes: TitleAttributes?
        if normal != nil { normalAttributes = TitleAttributes(normal!.jsonValue) }
        string = normalAttributes == nil ? attributes.string : attributes.stringWithFillers(normalAttributes!.attributes)
      }
    }
    return string
  }

  /**
  updateWithData:

  - parameter data: ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    for (_, stateKey, dictionary) in data {

      if let controlState = UIControlState(stateKey.jsonValue), json = ObjectJSONValue(dictionary) {
        setTitleAttributes(TitleAttributes(storage: json.value), forState: controlState)
      }
    }
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    UIControlState.enumerate {
      if let attributes = self.titleAttributesForState($0) { obj[$0.jsonValue.value as! String] = attributes.jsonValue }
    }
    return obj.jsonValue
  }

}
