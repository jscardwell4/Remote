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
final class Image: IndexedEditableModelObject, ModelCategoryItem {

  var assetName: String {
    get {
      var assetName: String!
      willAccessValueForKey("assetName")
      assetName = primitiveValueForKey("assetName") as? String
      didAccessValueForKey("assetName")
      return assetName
    }
    set {
      let img: UIImage? = UIImage(named: newValue)
      if img != nil {
        willChangeValueForKey("assetName")
        setPrimitiveValue(newValue, forKey: "assetName")
        didChangeValueForKey("assetName")
        size = img!.size
      }
    }

  }
  @NSManaged var leftCap: Int32
  var size: CGSize {
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

  @NSManaged var topCap: Int32
  @NSManaged var remoteElements: NSSet
  @NSManaged var views: NSSet
  @NSManaged var imageCategory: ImageCategory

  typealias CategoryType = ImageCategory
  var category: CategoryType? { get { return imageCategory } set { if newValue != nil { imageCategory = newValue! } } }

  override var index: ModelIndex { return imageCategory.index + "\(name)" }

  /**
  modelWithIndex:context:

  :param: index ModelIndex
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  override class func modelWithIndex(index: ModelIndex, context: NSManagedObjectContext) -> Image? {
    return ImageCategory.itemWithIndex(index, context: context)
  }

  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forKey: "imageCategory", lookupKey: "category")

    if let assetName = data["asset-name"] as? String { self.assetName = assetName }
    if let leftCap = data["left-cap"] as? NSNumber { self.leftCap = leftCap.intValue }
    if let topCap = data["top-cap"] as? NSNumber { self.topCap = topCap.intValue }
  }

  var image: UIImage? { return UIImage(named: assetName) }
  var templateImage: UIImage? { return image?.imageWithRenderingMode(.AlwaysTemplate) }
  override var commentedUUID: String {
    var uuidCopy: NSString = uuid
    uuidCopy.comment = " // \(assetName)"
    return uuidCopy as String
  }

  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()
    appendValueForKeyPath("imageCategory.index", forKey: "category.index", toDictionary: dictionary)
    appendValue(assetName, forKey: "asset-name", toDictionary: dictionary)
    appendValueForKey("leftCap", toDictionary: dictionary)
    appendValueForKey("topCap", toDictionary: dictionary)
    dictionary.compact()
    dictionary.compress()
    return dictionary
  }

  var stretchableImage: UIImage? { return image?.stretchableImageWithLeftCapWidth(Int(leftCap), topCapHeight: Int(topCap)) }

  var preview: UIImage { return image ?? UIImage() }
  var thumbnail: UIImage { return preview }

}
