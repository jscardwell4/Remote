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

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forAttribute: "parentCategory", lookupKey: "category")
    updateRelationshipFromData(data, forAttribute: "images")
    updateRelationshipFromData(data, forAttribute: "childCategories", lookupKey: "subcategories")
  }

  override public var jsonValue: JSONValue {
    var dict = super.jsonValue.value as! JSONValue.ObjectValue

    appendValueForKeyPath("parentCategory.index", forKey: "category.index", toDictionary: &dict)
    appendValueForKey("images", toDictionary: &dict)
    appendValueForKey("childCategories", forKey: "subcategories", toDictionary: &dict)
    return .Object(dict)
  }

  /**
  objectWithIndex:context:

  :param: index PathIndex
  :param: context NSManagedObjectContext

  :returns: Image?
  */
  @objc(objectWithPathIndex:context:)
  public override class func objectWithIndex(index: PathIndex, context: NSManagedObjectContext) -> ImageCategory? {
    return modelWithIndex(index, context: context)
  }

  override public var description: String {
    let description = "\(super.description)\n\t" + "\n\t".join(
      "image count = \(images.count)",
      "subcategories = [" + ", ".join(map(childCategories, {$0.name})) + "]",
      "parent = " + (toString(parentCategory?.name))
    )
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
    if index.isEmpty { return nil }
    else if index.count == 1 {
      return objectMatchingPredicate(∀"parentCategory == NULL && name == '\(index.rawValue.pathDecoded)'", context: context)
    } else {
      let name = index.removeLast().pathDecoded
      return findFirst(modelWithIndex(index, context: context)?.childCategories, {$0.name == name})
    }
  }
}

extension ImageCategory: ModelCollection {
  public var items: [NamedModel] { return sortedByName(images) }
}

extension ImageCategory: NestingModelCollection {
  public var collections: [ModelCollection] { return sortedByName(childCategories) }
}

extension ImageCategory: DefaultingModelCollection {
  public static func defaultCollectionInContext(context: NSManagedObjectContext) -> ImageCategory {
    let categoryName = "Uncategorized"
    if let category = modelWithIndex(PathIndex(categoryName)!, context: context) { return category }
    else {
      let category = self(context: context)
      category.name = categoryName
      return category
    }
  }
}

