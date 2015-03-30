//
//  Image.swift
//  Remote
//
//  Created by Jason Cardwell on 9/30/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(Image)
final public class Image: EditableModelObject {

  public var assetName: String {
    get {
      var assetName: String!
      willAccessValueForKey("assetName")
      assetName = primitiveValueForKey("assetName") as? String
      didAccessValueForKey("assetName")
      return assetName
    }
    set {
//      let img: UIImage? = UIImage(named: newValue)
//      if img != nil {
        willChangeValueForKey("assetName")
        setPrimitiveValue(newValue, forKey: "assetName")
        didChangeValueForKey("assetName")
//        size = img!.size
//      }
    }

  }
  @NSManaged public var leftCap: Int32
  public var size: CGSize {
    get {
      var sizeValue: NSValue?
      willAccessValueForKey("size")
      sizeValue = primitiveValueForKey("size") as? NSValue
      didAccessValueForKey("size")
      return sizeValue?.CGSizeValue() ?? CGSize.zeroSize
    }
    set {
      willChangeValueForKey("size")
      setPrimitiveValue(NSValue(CGSize:newValue), forKey: "size")
      didChangeValueForKey("size")
    }
  }

  @NSManaged public var topCap: Int32
  @NSManaged public var remoteElements: NSSet
  @NSManaged public var views: NSSet
  @NSManaged public var imageCategory: ImageCategory

  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forKey: "imageCategory", lookupKey: "category")

    if let assetName = data["asset-name"] as? String { self.assetName = assetName }
    if let leftCap = data["left-cap"] as? NSNumber { self.leftCap = leftCap.intValue }
    if let topCap = data["top-cap"] as? NSNumber { self.topCap = topCap.intValue }
  }

  public var image: UIImage? { return UIImage(named: assetName) }
  public var templateImage: UIImage? { return image?.imageWithRenderingMode(.AlwaysTemplate) }
  override public var commentedUUID: String {
    var uuidCopy: NSString = uuid
    uuidCopy.comment = " // \(assetName)"
    return uuidCopy as String
  }

  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override public func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()
    appendValueForKeyPath("imageCategory.index", forKey: "category.index", toDictionary: dictionary)
    appendValue(assetName, forKey: "asset-name", toDictionary: dictionary)
    appendValueForKey("leftCap", toDictionary: dictionary)
    appendValueForKey("topCap", toDictionary: dictionary)
    dictionary.compact()
    dictionary.compress()
    return dictionary
  }

  public var stretchableImage: UIImage? { return image?.stretchableImageWithLeftCapWidth(Int(leftCap), topCapHeight: Int(topCap)) }

  public var preview: UIImage { return image ?? UIImage() }
  public var thumbnail: UIImage { return preview }

  /**
  objectWithIndex:context:

  :param: index PathIndex
  :param: context NSManagedObjectContext

  :returns: Image?
  */
  @objc(objectWithPathIndex:context:)
  public override class func objectWithIndex(index: PathIndex, context: NSManagedObjectContext) -> Image? {
    if let object = modelWithIndex(index, context: context) {
      MSLogDebug("located image with name '\(object.name)'")
      return object
    } else { return nil }
  }

  override public var description: String {
    return "\(super.description)\n\t" + "\n\t".join(
      "asset name = \(assetName)",
      "left cap = \(leftCap)",
      "top cap = \(topCap)",
      "catgegory = \(imageCategory.index.rawValue)"
    )
  }

}

extension Image: PathIndexedModel {
  public var pathIndex: PathIndex { return imageCategory.pathIndex + indexedName }

  /**
  modelWithIndex:context:

  :param: index PathIndex
  :param: context NSManagedObjectContext

  :returns: Image?
  */
  public static func modelWithIndex(index: PathIndex, context: NSManagedObjectContext) -> Image? {
    if index.count < 1 { return nil }
    let imageName = index.removeLast().pathDecoded
    if let imageCategory = ImageCategory.modelWithIndex(index, context: context) {
      return findFirst(imageCategory.images, {$0.name == imageName})
    } else { return nil }
  }
}