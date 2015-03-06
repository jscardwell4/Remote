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
class ControlStateImageSet: ControlStateSet {

  @NSManaged var normal: ImageView?
  @NSManaged var disabled: ImageView?
  @NSManaged var selected: ImageView?
  @NSManaged var highlighted: ImageView?
  @NSManaged var highlightedDisabled: ImageView?
  @NSManaged var highlightedSelected: ImageView?
  @NSManaged var highlightedSelectedDisabled: ImageView?
  @NSManaged var selectedDisabled: ImageView?

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    if let jsonData = data as? [String:[String:AnyObject]], let moc = managedObjectContext {
      for (stateKey, dictionary) in jsonData {
        if let controlState = UIControlState(JSONValue: stateKey),
          let imageView = ImageView.importObjectFromData(dictionary, context: moc) {
            self[controlState.rawValue] = imageView
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
      if let imageView = self[$0.rawValue] as? ImageView {
        dictionary[$0.JSONValue] = imageView.JSONDictionary()
      }
    }

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }


}
