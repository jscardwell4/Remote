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
public final class ImageView: ModelObject {

  @NSManaged public var color: UIColor?
  @NSManaged public var image: Image?
  @NSManaged public var alpha: Float

  @NSManaged public var buttonIcon: Button?
  @NSManaged public var buttonImage: Button?
  @NSManaged public var imageSetDisabled: ControlStateImageSet?
  @NSManaged public var imageSetDisabledSelected: ControlStateImageSet?
  @NSManaged public var imageSetHighlighted: ControlStateImageSet?
  @NSManaged public var imageSetHighlightedDisabled: ControlStateImageSet?
  @NSManaged public var imageSetHighlightedSelected: ControlStateImageSet?
  @NSManaged public var imageSetNormal: ControlStateImageSet?
  @NSManaged public var imageSetSelected: ControlStateImageSet?
  @NSManaged public var imageSetSelectedHighlightedDisabled: ControlStateImageSet?


  public var rawImage: UIImage? { return image?.image }

  public var colorImage: UIImage? {
    if let img = rawImage {
      if let imgColor = color { return UIImage(fromAlphaOfImage: img, color: imgColor) }
      else { return img }
    } else {
      return nil
    }
  }

  /**
  updateWithData:

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    updateRelationshipFromData(data, forAttribute: "image")
    if let color = UIColor(data["color"]) { self.color = color }

  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["color"] = color?.jsonValue
    return obj.jsonValue
  }



}
