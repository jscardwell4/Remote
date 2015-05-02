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
public final class ImageView: ModelObject, NSCopying {

  @NSManaged public var color: UIColor?
  @NSManaged public var image: Image?
  @NSManaged public var alpha: NSNumber?

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

  public func copyWithZone(zone: NSZone) -> AnyObject {
    let copiedImageView = ImageView(context: managedObjectContext)
    copiedImageView.color = color
    copiedImageView.image = image
    copiedImageView.alpha = alpha
    return copiedImageView
  }
  public var rawImage: UIImage? { return image?.image }

  /**
  imageWithColor:

  :param: color UIColor?

  :returns: UIImage?
  */
  public func imageWithColor(color: UIColor?) -> UIImage? {
    if let img = rawImage { return color == nil ? img : UIImage(fromAlphaOfImage: img, color: color) } else { return nil }
  }

  public var colorImage: UIImage? { return imageWithColor(color) }

  /**
  initWithImage:

  :param: image Image
  */
  public convenience init(image: Image) {
    self.init(context: image.managedObjectContext)
    self.image = image
  }

  /**
  updateWithData:

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)

    updateRelationshipFromData(data, forAttribute: "image")
    color = UIColor(data["color"])
    alpha = Float(data["alpha"])

  }

  override public var description: String {
    var result = super.description
    result += "\n\timage = \(toString(image?.index))"
    result += "\n\tcolor = \(toString(color?.string))"
    result += "\n\talpha = \(toString(alpha))"
    return result
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["color"] = color?.jsonValue
    obj["image.index"] = image?.index.jsonValue
    obj["alpha"] = alpha?.jsonValue
    return obj.jsonValue
  }

}

/**
`Equatable` support for `ImageView`

:param: lhs ImageView
:param: rhs ImageView

:returns: Bool
*/
public func ==(lhs: ImageView, rhs: ImageView) -> Bool { return lhs.isEqual(rhs) }

