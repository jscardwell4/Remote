//
//  Preset.swift
//  Remote
//
//  Created by Jason Cardwell on 9/30/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(Preset)
class Preset: BankableModelObject {

  @NSManaged var presetCategory: PresetCategory?

  @NSManaged var primitiveAttributes: NSDictionary
  var attributes: PresetAttributes {
    get {
      willAccessValueForKey("attributes")
      let attributes = primitiveAttributes as? [String:AnyObject]
      didAccessValueForKey("attributes")
      return PresetAttributes(storage: attributes ?? [:], context: managedObjectContext)
    }
    set {
      willChangeValueForKey("attributes")
      primitiveAttributes = newValue.dictionaryValue
      didChangeValueForKey("attributes")
    }
  }

  override var editable: Bool { return user }
  override class func isEditable() -> Bool { return true }
  override class func isPreviewable() -> Bool { return true }

  /**
  detailController

  :returns: UIViewController
  */
  override func detailController() -> UIViewController { return PresetDetailController(item: self)! }

  class var rootCategory: Bank.RootCategory {
    var categories = PresetCategory.findAllMatchingPredicate(∀"parentCategory == nil") as [PresetCategory]
    categories.sort{$0.0.title < $0.1.title}

    return Bank.RootCategory(label: "Presets",
                             icon: UIImage(named: "1059-sliders")!,
                             subcategories: categories,
                             editableItems: true,
                             previewableItems: true)
  }

  /**
  generateElement

  :returns: RemoteElement?
  */
  func generateElement() -> RemoteElement? {
    return managedObjectContext != nil
             ? RemoteElement.remoteElementFromPreset(attributes, context: managedObjectContext!)
             : nil
  }

  /**
  updateWithData:

  :param: data [NSObject AnyObject]!
  */
  override func updateWithData(data: [NSObject:AnyObject]) {
    super.updateWithData(data)

    if let jsonData = data as? [String:AnyObject] {
      attributes = PresetAttributes(storage:jsonData, context: managedObjectContext)
    }

  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()
    dictionary.setValuesForKeysWithDictionary(attributes.dictionaryValue)
    return dictionary
  }


}
