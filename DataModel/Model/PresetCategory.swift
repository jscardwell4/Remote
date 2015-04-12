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
final public class PresetCategory: EditableModelObject {

  @NSManaged public var presets: Set<Preset>
  @NSManaged public var childCategories: Set<PresetCategory>
  @NSManaged public var parentCategory: PresetCategory?

  /**
  updateWithData:

  :param: data ObjectJSONValue
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


  /**
  objectWithIndex:context:

  :param: index PathIndex
  :param: context NSManagedObjectContext

  :returns: Image?
  */
  @objc(objectWithPathIndex:context:)
  public override class func objectWithIndex(index: PathIndex, context: NSManagedObjectContext) -> PresetCategory? {
    if let object = modelWithIndex(index, context: context) {
      MSLogDebug("located preset category with name '\(object.name)'")
      return object
    } else { return nil }
  }

  override public var description: String {
    var description = "\(super.description)\n\t" + "\n\t".join(
      "presets count = \(presets.count)",
      "subcategories = [" + ", ".join(map(childCategories, {$0.name})) + "]",
      "parent = \(toString(parentCategory?.index))"
    )
    return description
  }

}

extension PresetCategory: PathIndexedModel {
  public var pathIndex: PathIndex { return parentCategory != nil ? parentCategory!.pathIndex + PathIndex(indexedName)! : PathIndex(indexedName)! }

  /**
  modelWithIndex:context:

  :param: index PathIndex
  :param: context NSManagedObjectContext

  :returns: PresetCategory?
  */
  public static func modelWithIndex(index: PathIndex, context: NSManagedObjectContext) -> PresetCategory? {
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

extension PresetCategory: ModelCollection {
  public var items: [NamedModel] { return sortedByName(presets) }
}

extension PresetCategory: NestingModelCollection {
  public var collections: [ModelCollection] { return sortedByName(childCategories) }
}

extension PresetCategory: DefaultingModelCollection {
  public static func defaultCollectionInContext(context: NSManagedObjectContext) -> PresetCategory {
    let categoryName = "Uncategorized"
    if let category = modelWithIndex(PathIndex(categoryName)!, context: context) { return category }
    else {
      let category = self(context: context)
      category.name = categoryName
      return category
    }
  }
}
