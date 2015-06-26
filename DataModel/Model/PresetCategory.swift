//
//  PresetCategory.swift
//  Remote
//
//  Created by Jason Cardwell on 9/27/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(PresetCategory)
final public class PresetCategory: EditableModelObject, CollectedModel {

  @NSManaged public var presets: Set<Preset>
  @NSManaged public var childCategories: Set<PresetCategory>
  @NSManaged public var parentCategory: PresetCategory?

  public var collection: ModelCollection? { return parentCategory }

  /**
  updateWithData:

  - parameter data: ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forAttribute: "parentCategory", lookupKey: "category")
    updateRelationshipFromData(data, forAttribute: "presets")
    updateRelationshipFromData(data, forAttribute: "childCategories", lookupKey: "subcategories")
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["category.index"] = parentCategory?.index.jsonValue
    obj["presets"] = JSONValue(presets)
    obj["subcategories"] = JSONValue(childCategories)
    return obj.jsonValue
  }

  override public var description: String {
    let description = "\(super.description)\n\t" + "\n\t".join(
      "presets count = \(presets.count)",
      "subcategories = [" + ", ".join(childCategories.map({$0.name})) + "]",
      "parent = \(String(parentCategory?.index))"
    )
    return description
  }

  public override var pathIndex: PathIndex { return parentCategory?.pathIndex + PathIndex(indexedName) }

  /**
  modelWithIndex:context:

  - parameter index: PathIndex
  - parameter context: NSManagedObjectContext

  - returns: PresetCategory?
  */
  public override static func modelWithIndex(var index: PathIndex, context: NSManagedObjectContext) -> PresetCategory? {
    if index.isEmpty { return nil }
    else if index.count == 1 {
      return objectMatchingPredicate(∀"parentCategory == NULL && name == '\(index.rawValue.pathDecoded)'", context: context)
    } else {
      let name = index.removeLast().pathDecoded
      return findFirst(modelWithIndex(index, context: context)?.childCategories, {$0.name == name})
    }
  }
}

extension PresetCategory: ModelCollection {
  public var items: [CollectedModel] { return sortedByName(presets) }
}

extension PresetCategory: NestingModelCollection {
  public var collections: [ModelCollection] { return sortedByName(childCategories) }
}

extension PresetCategory: DefaultingModelCollection {
  public static func defaultCollectionInContext(context: NSManagedObjectContext) -> PresetCategory {
    let categoryName = "Uncategorized"
    if let category = modelWithIndex(PathIndex(categoryName), context: context) { return category }
    else {
      let category = self.init(context: context)
      category.name = categoryName
      return category
    }
  }
}
