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

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    for (stateKey, colorJSON) in data {
      if let state = UIControlState(controlStateSetProperty: stateKey.camelcaseString), color = UIColor(jsonValue: colorJSON)
      {
        self[state.rawValue] = color
      }
    }
  }

  override public var jsonValue: JSONValue {
    var dict = super.jsonValue.value as! JSONValue.ObjectValue

    UIControlState.enumerate {
      if let color = self[$0.rawValue] as? UIColor {
        dict[$0.jsonValue.value as! String] = color.jsonValue
      }
    }
    return .Object(dict)
  }


}
