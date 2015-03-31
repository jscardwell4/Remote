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

  :param: data [String:AnyObject]
  */
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    //TODO: Fill in stub
  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  override public func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    //TODO: Fill in stub

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
  public override class func objectWithIndex(index: PathIndex, context: NSManagedObjectContext) -> PresetCategory? {
    if let object = modelWithIndex(index, context: context) {
      MSLogDebug("located preset category with name '\(object.name)'")
      return object
    } else { return nil }
  }

  override public var description: String {
    var description = "\(super.description)\n\t" + "\n\t".join(
      "presets count = \(presets.count)",
      "subcategories = [" + ", ".join(map(childCategories, {$0.name})) + "]")
    description += "\nparent = " + (parentCategory?.index.rawValue ?? "nil")
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
