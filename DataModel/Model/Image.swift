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
final public class Image: EditableModelObject, CollectedModel {

  /**
  Create a new `Image` object with a data-backed asset

  :param: image UIImage
  :param: context NSManagedObjectContext?
  */
  public convenience init(image: UIImage, context: NSManagedObjectContext?) {
    self.init(context: context)
    asset = Asset(context: context)
    asset?.data = UIImagePNGRepresentation(image)
  }

  static var resourceRegistration: [String:NSBundle] = [:]

  /**
  Public api for registering a bundle for a corresponding `Asset.location` value so that `Image` objects may use
  bundle-based resources not representable by a file url, i.e. 'Assets.car'

  :param: bundle NSBundle?
  :param: locationValue String
  */
  public class func registerBundle(bundle: NSBundle?, forLocationValue locationValue: String) {
    resourceRegistration[locationValue] = bundle
  }

  @NSManaged public var asset: Asset?

  @NSManaged public var leftCap: Int32
  @NSManaged public var topCap: Int32

  public var size: CGSize {
    get {
      willAccessValueForKey("size")
      let size = (primitiveValueForKey("size") as! NSValue).CGSizeValue()
      didAccessValueForKey("size")
      return size
    }
    set {
      willChangeValueForKey("size")
      setPrimitiveValue(NSValue(CGSize:newValue), forKey: "size")
      didChangeValueForKey("size")
    }
  }

  @NSManaged public var remoteElements: Set<RemoteElement>
  @NSManaged public var views: Set<ImageView>

  private var insideImageCategorySetter = false
  public var imageCategory: ImageCategory! {
    get {
      willAccessValueForKey("imageCategory")
      var category = primitiveValueForKey("imageCategory") as? ImageCategory
      didAccessValueForKey("imageCategory")
      if category == nil && !insideImageCategorySetter {
        category = ImageCategory.defaultCollectionInContext(managedObjectContext!)
        setPrimitiveValue(category, forKey: "imageCategory")
      }
      return category
    }
    set {
      insideImageCategorySetter = true
      willChangeValueForKey("imageCategory")
      setPrimitiveValue(newValue, forKey: "imageCategory")
      didChangeValueForKey("imageCategory")
      insideImageCategorySetter = false
    }
  }

  public var collection: ModelCollection? { return imageCategory }

  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forAttribute: "imageCategory", lookupKey: "category")
    updateRelationshipFromData(data, forAttribute: "asset")
    if let leftCap = Int32(data["leftCap"]) { self.leftCap = leftCap }
    if let topCap = Int32(data["topCap"]) { self.topCap = topCap }
  }

  public var image: UIImage? {
    var img: UIImage? = nil
    if let asset = asset {
      switch asset.storageType {
        case .File:
          if let path = asset.path { img = UIImage(contentsOfFile: path) }
        case .Bundle:
          if let name = asset.name, path = asset.path, bundle = Image.resourceRegistration[path] {
            img = UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil)
          }
        case .Data:
          if let data = asset.data { img = UIImage(data: data) }
        default:
          break
      }
    }
    return img
  }

  public var templateImage: UIImage? { return image?.imageWithRenderingMode(.AlwaysTemplate) }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["category.index"] = imageCategory.index.jsonValue
    obj["asset"] = asset?.jsonValue
    obj["leftCap"] = leftCap.jsonValue
    obj["topCap"] = topCap.jsonValue
    return obj.jsonValue
  }

  public var stretchableImage: UIImage? {
    return image?.stretchableImageWithLeftCapWidth(Int(leftCap), topCapHeight: Int(topCap))
  }

  public var preview: UIImage? { return image }
  public var thumbnail: UIImage? { return preview }

  override public var description: String {
    return "\(super.description)\n\t" + "\n\t".join(
      "asset = \(toString(asset))",
      "left cap = \(leftCap)",
      "top cap = \(topCap)",
      "category = \(imageCategory.index)"
    )
  }

  public override var pathIndex: PathIndex { return imageCategory.pathIndex + indexedName }

  /**
  modelWithIndex:context:

  :param: index PathIndex
  :param: context NSManagedObjectContext

  :returns: Image?
  */
  public override static func modelWithIndex(var index: PathIndex, context: NSManagedObjectContext) -> Image? {
    if index.count < 2 { return nil }
    let imageName = index.removeLast().pathDecoded
    return findFirst(ImageCategory.modelWithIndex(index, context: context)?.images, {$0.name == imageName})
  }
}