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

  public var imageCategory: ImageCategory {
    get {
      willAccessValueForKey("imageCategory")
      var category = primitiveValueForKey("imageCategory") as? ImageCategory
      didAccessValueForKey("imageCategory")
      if category == nil {
        category = ImageCategory.defaultCollectionInContext(managedObjectContext!)
        setPrimitiveValue(category, forKey: "imageCategory")
      }
      return category!
    }
    set {
      willChangeValueForKey("imageCategory")
      setPrimitiveValue(newValue, forKey: "imageCategory")
      didChangeValueForKey("imageCategory")
    }
  }

  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forAttribute: "imageCategory", lookupKey: "category")

    if let assetName = String(data["asset-name"]) { self.assetName = assetName }
    if let leftCap = Int32(data["left-cap"]) { self.leftCap = leftCap }
    if let topCap = Int32(data["top-cap"]) { self.topCap = topCap }
  }
  // FIXME: Move UIImage retrieval to bank module?
  public var image: UIImage? { return UIImage(named: assetName) }
  public var templateImage: UIImage? { return image?.imageWithRenderingMode(.AlwaysTemplate) }
  override public var commentedUUID: String {
    var uuidCopy: NSString = uuid
    uuidCopy.comment = " // \(assetName)"
    return uuidCopy as String
  }

  override public var jsonValue: JSONValue {
    var dict = super.jsonValue.value as! JSONValue.ObjectValue
    appendValueForKeyPath("imageCategory.index", forKey: "category.index", toDictionary: &dict)
    dict["asset-name"] = assetName.jsonValue
    appendValueForKey("leftCap", toDictionary: &dict)
    appendValueForKey("topCap", toDictionary: &dict)
    return .Object(dict)
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
    return modelWithIndex(index, context: context)
  }

  override public var description: String {
    return "\(super.description)\n\t" + "\n\t".join(
      "asset name = \(assetName)",
      "left cap = \(leftCap)",
      "top cap = \(topCap)",
      "category = \(imageCategory.index)"
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
    return findFirst(ImageCategory.modelWithIndex(index, context: context)?.images, {$0.name == imageName})
  }
}