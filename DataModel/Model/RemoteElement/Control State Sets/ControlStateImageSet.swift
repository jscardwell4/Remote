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

  :param: data [String:AnyObject]
  */
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    if let jsonData = data as? [String:[String:AnyObject]], let moc = managedObjectContext {
      for (stateKey, dictionary) in jsonData {
        if let controlState = UIControlState(JSONValue: stateKey),
          let imageView = ImageView.importObjectWithData(dictionary, context: moc) {
            self[controlState.rawValue] = imageView
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
      if let imageView = self[$0.rawValue] as? ImageView {
        dictionary[$0.JSONValue] = imageView.JSONDictionary()
      }
    }

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }


}
