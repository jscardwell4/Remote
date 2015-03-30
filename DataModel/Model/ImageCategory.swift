//
//  ImageCategory.swift
//  Remote
//
//  Created by Jason Cardwell on 9/27/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(ImageCategory)
final public class ImageCategory: EditableModelObject {

  @NSManaged public var images: Set<Image>
  @NSManaged public var childCategories: Set<ImageCategory>
  @NSManaged public var parentCategory: ImageCategory?

  public let previewableItems = true
  public let editableItems = true

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forKey: "parentCategory", lookupKey: "category")
    updateRelationshipFromData(data, forKey: "images")
    updateRelationshipFromData(data, forKey: "childCategories", lookupKey: "subcategories")
  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  override public func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    appendValueForKeyPath("parentCategory.index", forKey: "category.index", toDictionary: dictionary)
    appendValueForKeyPath("images.JSONDictionary", forKey: "images", toDictionary: dictionary)
    appendValueForKeyPath("childCategories.JSONDictionary", forKey: "subcategories", toDictionary: dictionary)
    
    dictionary.compact()
    dictionary.compress()

    return dictionary
  }

  /**
  objectWithIndex:context:

  :param: index PathIndex
  :param: context NSManagedObjectContext

  :returns: Image?
  */
  @objc(objectWithPathIndex:context:)
  public override class func objectWithIndex(index: PathIndex, context: NSManagedObjectContext) -> ImageCategory? {
    if let object = modelWithIndex(index, context: context) {
      MSLogDebug("located image category with name '\(object.name)'")
      return object
    } else { return nil }
  }

  override public var description: String {
    var description = "\(super.description)\n\t" + "\n\t".join(
      "image count = \(images.count)",
      "subcategories = [" + ", ".join(map(childCategories, {$0.name})) + "]")
    description += "\nparent = " + (parentCategory?.name ?? "nil")
    return description
  }
}

extension ImageCategory: PathIndexedModel {
  public var pathIndex: PathIndex { return parentCategory != nil ? parentCategory!.pathIndex + indexedName : PathIndex(indexedName)! }

  /**
  modelWithIndex:context:

  :param: index PathIndex
  :param: context NSManagedObjectContext

  :returns: ImageCategory?
  */
  public static func modelWithIndex(index: PathIndex, context: NSManagedObjectContext) -> ImageCategory? {
    if index.count < 1 { return nil }
    var pathComponents = index.pathComponents.reverse()
    var name = pathComponents.removeLast()
    var currentCategory = objectMatchingPredicate(∀"parentCategory == NULL AND name == '\(name.pathDecoded)'", context: context)

    while currentCategory != nil && pathComponents.count > 0 {
      name = pathComponents.removeLast().pathDecoded
      currentCategory = findFirst(currentCategory!.childCategories, {$0.name == name})
    }
    return currentCategory
  }
}

extension ImageCategory: ModelCollection {
  public var items: [NamedModel] { return sortedByName(images) }
}

extension ImageCategory: NestingModelCollection {
  public var collections: [ModelCollection] { return sortedByName(childCategories) }
}
