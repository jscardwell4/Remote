//
//  ControlStateImageSet.swift
//  Remote
//
//  Created by Jason Cardwell on 3/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(ControlStateImageSet)
public final class ControlStateImageSet: ControlStateSet {

  @NSManaged public var normal: ImageView?
  @NSManaged public var disabled: ImageView?
  @NSManaged public var selected: ImageView?
  @NSManaged public var highlighted: ImageView?
  @NSManaged public var highlightedDisabled: ImageView?
  @NSManaged public var highlightedSelected: ImageView?
  @NSManaged public var highlightedSelectedDisabled: ImageView?
  @NSManaged public var selectedDisabled: ImageView?

  /**
  updateWithData:

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    if let moc = managedObjectContext {
      for (_, stateKey, jsonValue) in data {
        if let dictionary = ObjectJSONValue(jsonValue),
          controlState = UIControlState(stateKey.jsonValue),
          imageView = ImageView.importObjectWithData(dictionary, context: moc)
        {
          self[controlState.rawValue] = imageView
        }
      }
    }
  }

  /**
  imageViewForState:

  :param: state UIControlState

  :returns: ImageView?
  */
  public func imageViewForState(state: UIControlState) -> ImageView? { return self[state.rawValue] as? ImageView }


  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!

    UIControlState.enumerate {
      if let imageView = self[$0.rawValue] as? ImageView {
        obj[String($0.jsonValue)!] = imageView.jsonValue
      }
    }
    return obj.jsonValue
  }


}
