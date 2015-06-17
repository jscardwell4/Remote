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
final public class ImageCategory: EditableModelObject, CollectedModel {

  @NSManaged public var images: Set<Image>
  @NSManaged public var childCategories: Set<ImageCategory>
  @NSManaged public var parentCategory: ImageCategory?

  public var collection: ModelCollection? { return parentCategory }

  public let previewableItems = true
  public let editableItems = true

  /**
  updateWithData:

  - parameter data: ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forAttribute: "parentCategory", lookupKey: "category")
    updateRelationshipFromData(data, forAttribute: "images")
    updateRelationshipFromData(data, forAttribute: "childCategories", lookupKey: "subcategories")
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["category.index"] = parentCategory?.index.jsonValue
    obj["images"] = Optional(JSONValue(images))
    obj["subcategories"] = Optional(JSONValue(childCategories))
    return obj.jsonValue
  }

  override public var description: String {
    let description = "\(super.description)\n\t" + "\n\t".join(
      "image count = \(images.count)",
      "subcategories = [" + ", ".join(childCategories.map({$0.name})) + "]",
      "parent = " + (String(parentCategory?.name))
    )
    return description
  }
  public override var pathIndex: PathIndex { return parentCategory?.pathIndex + indexedName }

  /**
  modelWithIndex:context:

  - parameter index: PathIndex
  - parameter context: NSManagedObjectContext

  - returns: ImageCategory?
  */
  public override static func modelWithIndex(var index: PathIndex, context: NSManagedObjectContext) -> ImageCategory? {
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
  public var items: [CollectedModel] { return sortedByName(images) }
}

extension ImageCategory: NestingModelCollection {
  public var collections: [ModelCollection] { return sortedByName(childCategories) }
}

extension ImageCategory: DefaultingModelCollection {
  public static func defaultCollectionInContext(context: NSManagedObjectContext) -> ImageCategory {
    let categoryName = "Uncategorized"
    if let category = modelWithIndex(PathIndex(categoryName), context: context) { return category }
    else {
      let category = self(context: context)
      category.name = categoryName
      return category
    }
  }
}

