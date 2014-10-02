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
class Image: BankableModelObject {

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
      return sizeValue?.CGSizeValue() ?? CGSizeZero
    }
    set {
      willChangeValueForKey("size")
      setPrimitiveValue(NSValue(CGSize:newValue), forKey: "size")
      didChangeValueForKey("size")
    }
  }

  @NSManaged var topCap: Int32
  @NSManaged var imageCategory: ImageCategory!
  @NSManaged var remoteElements: NSSet
  @NSManaged var views: NSSet

  override func updateWithData(data: [NSObject : AnyObject]!) {
    super.updateWithData(data)
    imageCategory = ImageCategory.importObjectFromData(data["category"] as? NSDictionary, context: managedObjectContext)
      ?? imageCategory
    assetName = data["asset-name"] as? NSString
      ?? assetName
    leftCap = (data["left-cap"] as? NSNumber)?.intValue
      ?? leftCap
    topCap = (data["top-cap"] as? NSNumber)?.intValue
      ?? topCap
  }

  var image: UIImage { return UIImage(named: assetName) }
  override var commentedUUID: String { var uuidCopy: NSString = uuid!; uuidCopy.comment = " // \(assetName)"; return uuidCopy }
  override var preview: UIImage { return image }

  override func JSONDictionary() -> MSDictionary! {
    let dictionary = super.JSONDictionary()
    safeSetValueForKeyPath("imageCategory.commentedUUID", forKey: "category", inDictionary: dictionary)
    safeSetValue(assetName, forKey: "asset-name", inDictionary: dictionary)
    setIfNotDefault("leftCap", inDictionary: dictionary)
    setIfNotDefault("topCap", inDictionary: dictionary)
    dictionary.compact()
    dictionary.compress()
    return dictionary
  }

  var stretchableImage: UIImage { return image.stretchableImageWithLeftCapWidth(Int(leftCap), topCapHeight: Int(topCap)) }

}

extension Image: BankDisplayItem {

  class var label: String   { return "Images"                     }
  class var icon:  UIImage? { return UIImage(named: "926-photos") }

  class var isThumbnailable: Bool { return true }
  class var isDetailable:    Bool { return true }
  class var isEditable:      Bool { return true }
  class var isPreviewable:   Bool { return true }

}

extension Image: BankDisplayItemModel {

  var detailController: BankDetailController { return ImageDetailController(item: self, editing: false) }


}
