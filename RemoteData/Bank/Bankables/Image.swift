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
class Image: IndexedBankCategoryItemObject, PreviewableCategoryItem, Detailable {

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

  override var indexedCategory: IndexedBankCategory {
    get { return imageCategory }
    set { if let category = newValue as? ImageCategory { imageCategory = category } }
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
  override var commentedUUID: String { var uuidCopy: NSString = uuid; uuidCopy.comment = " // \(assetName)"; return uuidCopy as String }

  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()
    safeSetValueForKeyPath("imageCategory.index", forKey: "category.index", inDictionary: dictionary)
    safeSetValue(assetName, forKey: "asset-name", inDictionary: dictionary)
    setIfNotDefault("leftCap", inDictionary: dictionary)
    setIfNotDefault("topCap", inDictionary: dictionary)
    dictionary.compact()
    dictionary.compress()
    return dictionary
  }

  var stretchableImage: UIImage? { return image?.stretchableImageWithLeftCapWidth(Int(leftCap), topCapHeight: Int(topCap)) }


  class var rootCategory: BankRootCategory<BankCategory,BankModel> {
    var categories = ImageCategory.findAllMatchingPredicate(∀"parentCategory == nil", context: DataManager.rootContext) as! [ImageCategory]
    categories.sort{$0.0.name < $0.1.name}
    return BankRootCategory(label: "Images",
                             icon: UIImage(named: "926-photos")!,
                             subcategories: categories,
                             editableItems: true,
                             previewableItems: true)
  }

  func detailController() -> UIViewController { return ImageDetailController(model: self) }
  var preview: UIImage { return image ?? UIImage() }
  var thumbnail: UIImage { return preview }

}
