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

  var attributes: PresetAttributes {
    get {
      willAccessValueForKey("attributes")
      let attributes = PresetAttributes(storage: storage.dictionary as [String:AnyObject], context: managedObjectContext)
      didAccessValueForKey("attributes")
      return attributes
    }
    set {
      willChangeValueForKey("attributes")
      storage.dictionary = newValue.dictionaryValue
      didChangeValueForKey("attributes")
    }
  }

  @NSManaged var storage: DictionaryStorage

  override var editable: Bool { return user }
  override class func isEditable() -> Bool { return true }
  override class func isPreviewable() -> Bool { return true }

  /** awakeFromInsert */
  override func awakeFromInsert() {
    super.awakeFromInsert()
    storage = DictionaryStorage(context: managedObjectContext!)
  }

  /**
  detailController

  :returns: UIViewController
  */
  override func detailController() -> UIViewController {
    switch attributes.baseType {
      case .Remote:      return RemotePresetDetailController(item: self)!
      case .ButtonGroup: return ButtonGroupPresetDetailController(item: self)!
      case .Button:      return ButtonPresetDetailController(item: self)!
      case .Undefined:   return PresetDetailController(item: self)!
    }
  }

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
    if let jsonData = data as? [String:AnyObject] { storage.dictionary = jsonData }
  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()
    safeSetValueForKeyPath("presetCategory.commentedUUID", forKey: "category", inDictionary: dictionary)
    dictionary.setValuesForKeysWithDictionary(storage.dictionary)
    return dictionary
  }

}
