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
class ControlStateColorSet: ControlStateSet {

  @NSManaged var normal: UIColor?
  @NSManaged var disabled: UIColor?
  @NSManaged var selected: UIColor?
  @NSManaged var highlighted: UIColor?
  @NSManaged var highlightedDisabled: UIColor?
  @NSManaged var highlightedSelected: UIColor?
  @NSManaged var highlightedSelectedDisabled: UIColor?
  @NSManaged var selectedDisabled: UIColor?

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
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
  override func JSONDictionary() -> MSDictionary {
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
