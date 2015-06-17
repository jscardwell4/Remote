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

  - parameter image: UIImage
  - parameter context: NSManagedObjectContext?
  */
  public convenience init(image: UIImage, context: NSManagedObjectContext?) {
    self.init(context: context)
    size = image.size
    asset = Asset(context: context)
    asset?.data = UIImagePNGRepresentation(image)
  }

  static var resourceRegistration: [String:NSBundle] = [:]

  /**
  Public api for registering a bundle for a corresponding `Asset.location` value so that `Image` objects may use
  bundle-based resources not representable by a file url, i.e. 'Assets.car'

  - parameter bundle: NSBundle?
  - parameter locationValue: String
  */
  public class func registerBundle(bundle: NSBundle?, forLocationValue locationValue: String) {
    resourceRegistration[locationValue] = bundle
  }

  public var asset: Asset? {
    get {
      willAccessValueForKey("asset")
      let asset = primitiveValueForKey("asset") as? Asset
      didAccessValueForKey("asset")
      return asset
    }
    set {
      if let asset = newValue, image = imageFromAsset(asset) { size = image.size }
      else if newValue != nil { managedObjectContext?.deleteObject(newValue!); return }
      willChangeValueForKey("asset")
      setPrimitiveValue(newValue, forKey: "asset")
      didChangeValueForKey("asset")
    }
  }

  public var capInsets: UIEdgeInsets {
    get {
      willAccessValueForKey("capInsets")
      let insets = primitiveValueForKey("capInsets") as! NSValue
      didAccessValueForKey("capInsets")
      return insets.UIEdgeInsetsValue()
    }
    set {
      willChangeValueForKey("capInsets")
      setPrimitiveValue(NSValue(UIEdgeInsets: newValue), forKey: "capInsets")
      didChangeValueForKey("capInsets")
    }
  }

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
    if let capInsets = UIEdgeInsets(data["capInsets"]) { self.capInsets = capInsets }
  }

  /**
  imageFromFileAsset:

  - parameter asset: Asset

  - returns: UIImage?
  */
  private func imageFromFileAsset(asset: Asset) -> UIImage? {
    if let path = asset.path { return UIImage(contentsOfFile: path) } else { return nil }
  }

  /**
  imageFromBundleAsset:

  - parameter asset: Asset

  - returns: UIImage?
  */
  private func imageFromBundleAsset(asset: Asset) -> UIImage? {
    if let name = asset.name, path = asset.path, bundle = Image.resourceRegistration[path] {
      return UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil)
    } else { return nil }
  }

  /**
  imageFromDataAsset:

  - parameter asset: Asset

  - returns: UIImage?
  */
  private func imageFromDataAsset(asset: Asset) -> UIImage? {
    if let data = asset.data { return UIImage(data: data) } else { return nil }
  }

  /**
  imageFromAsset:

  - parameter asset: Asset

  - returns: UIImage?
  */
  private func imageFromAsset(asset: Asset) -> UIImage? {
    switch asset.storageType {
      case .File:      return imageFromFileAsset(asset)
      case .Bundle:    return imageFromBundleAsset(asset)
      case .Data:      return imageFromDataAsset(asset)
      case .Undefined: return nil
    }
  }

  public var image: UIImage? { if let asset = asset { return imageFromAsset(asset) } else { return nil } }

  public var templateImage: UIImage? { return image?.imageWithRenderingMode(.AlwaysTemplate) }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["category.index"] = imageCategory.index.jsonValue
    obj["asset"] = asset?.jsonValue
    obj["capInsets"] = capInsets.jsonValue
    return obj.jsonValue
  }

  public var stretchableImage: UIImage? { return image?.resizableImageWithCapInsets(capInsets) }

  public var preview: UIImage? { return image }
  public var thumbnail: UIImage? { return preview }

  override public var description: String {
    return "\(super.description)\n\t" + "\n\t".join(
      "asset = \(String(asset))",
      "cap insets = \(capInsets)",
      "category = \(imageCategory.index)"
    )
  }

  public override var pathIndex: PathIndex { return imageCategory.pathIndex + indexedName }

  /**
  modelWithIndex:context:

  - parameter index: PathIndex
  - parameter context: NSManagedObjectContext

  - returns: Image?
  */
  public override static func modelWithIndex(var index: PathIndex, context: NSManagedObjectContext) -> Image? {
    if index.count < 2 { return nil }
    let imageName = index.removeLast().pathDecoded
    return findFirst(ImageCategory.modelWithIndex(index, context: context)?.images, {$0.name == imageName})
  }
}