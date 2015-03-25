//
//  ControlStateColorSet.swift
//  Remote
//
//  Created by Jason Cardwell on 3/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(ControlStateColorSet)
public final class ControlStateColorSet: ControlStateSet {

  @NSManaged public var normal: UIColor?
  @NSManaged public var disabled: UIColor?
  @NSManaged public var selected: UIColor?
  @NSManaged public var highlighted: UIColor?
  @NSManaged public var highlightedDisabled: UIColor?
  @NSManaged public var highlightedSelected: UIColor?
  @NSManaged public var highlightedSelectedDisabled: UIColor?
  @NSManaged public var selectedDisabled: UIColor?

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    if let jsonData = data as? [String: String] {
      for (stateKey, colorJSON) in jsonData {
        if let state = UIControlState(controlStateSetProperty: stateKey.camelcaseString), let color = UIColor(JSONValue: colorJSON) {
          self[state.rawValue] = color
        }
      }
    }
  }

  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override public func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    UIControlState.enumerate {
      if let color = self[$0.rawValue] as? UIColor {
        dictionary[$0.JSONValue] = color.JSONValue
      }
    }

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }


}
