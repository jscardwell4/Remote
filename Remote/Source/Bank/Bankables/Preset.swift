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

  @NSManaged var primitiveBaseType: NSNumber
  var baseType: RemoteElement.BaseType {
    get {
      willAccessValueForKey("baseType")
      let baseType = RemoteElement.BaseType(rawValue: primitiveBaseType.integerValue)
      didAccessValueForKey("baseType")
      return baseType
    }
    set {
      willChangeValueForKey("baseType")
      primitiveBaseType = newValue.rawValue
      didChangeValueForKey("baseType")
    }
  }

  @NSManaged var primitiveRole: NSNumber
  var role: RemoteElement.Role {
    get {
      willAccessValueForKey("role")
      let role = RemoteElement.Role(rawValue: primitiveRole.integerValue)
      didAccessValueForKey("role")
      return role
    }
    set {
      willChangeValueForKey("role")
      primitiveRole = newValue.rawValue
      didChangeValueForKey("role")
    }
  }

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
  override class func isEditable()      -> Bool { return true }
  override class func isPreviewable()   -> Bool { return true }

  override func detailController() -> UIViewController { return PresetDetailController(item: self)! }

  class var rootCategory: Bank.RootCategory {
    return Bank.RootCategory(label: "Presets",
                             icon: UIImage(named: "1059-sliders")!,
                             editableItems: true,
                             previewableItems: true)
  }

  /**
  generateElement

  :returns: RemoteElement?
  */
  func generateElement() -> RemoteElement? {
    return managedObjectContext != nil ? RemoteElement.remoteElementFromPreset(attributes, context: managedObjectContext!) : nil
  }

}
