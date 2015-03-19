//
//  ImageView.swift
//  Remote
//
//  Created by Jason Cardwell on 10/3/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(ImageView)
class ImageView: ModelObject {

  @NSManaged var color: UIColor?
  @NSManaged var image: Image
  @NSManaged var imagePath: String

  @NSManaged var buttonIcon: Button?
  @NSManaged var buttonImage: Button?
  @NSManaged var imageSetDisabled: ControlStateImageSet?
  @NSManaged var imageSetDisabledSelected: ControlStateImageSet?
  @NSManaged var imageSetHighlighted: ControlStateImageSet?
  @NSManaged var imageSetHighlightedDisabled: ControlStateImageSet?
  @NSManaged var imageSetHighlightedSelected: ControlStateImageSet?
  @NSManaged var imageSetNormal: ControlStateImageSet?
  @NSManaged var imageSetSelected: ControlStateImageSet?
  @NSManaged var imageSetSelectedHighlightedDisabled: ControlStateImageSet?


  var rawImage: UIImage? { return image.image }

  var colorImage: UIImage? {
    if let img = rawImage {
      if let imgColor = color { return UIImage(fromAlphaOfImage: img, color: imgColor) }
      else { return img }
    } else {
      return nil
    }
  }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    updateRelationshipFromData(data, forKey: "image")

    if let colorJSON = data["color"] as? String, color = UIColor(JSONValue: colorJSON) {
      self.color = color
    }

  }

  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    dictionary["image"] = image.commentedUUID
    if let color = self.color { dictionary["color"] = color.JSONValue }

    dictionary.compact()
    dictionary.compress()

    return dictionary
  }



}
