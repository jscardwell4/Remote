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
final public class Preset: EditableModelObject {

  public var preview: UIImage { return UIImage() }
  public var thumbnail: UIImage { return preview }

  private(set) public var storage: JSONStorage {
    get {
      var storage: JSONStorage!
      willAccessValueForKey("storage")
      storage = primitiveValueForKey("storage") as? JSONStorage
      didAccessValueForKey("storage")
      if storage == nil {
        storage = JSONStorage(context: managedObjectContext)
        setPrimitiveValue(storage, forKey: "storage")
      }
      return storage
    }
    set {
      willChangeValueForKey("storage")
      setPrimitiveValue(newValue, forKey: "storage")
      didChangeValueForKey("storage")
    }
  }
  @NSManaged public var presetCategory: PresetCategory
  @NSManaged public var subelements: NSOrderedSet?
  @NSManaged public var parentPreset: Preset?

  public subscript(key: String) -> AnyObject? {
    get { return storage[key] }
    set { storage[key] = newValue }
  }

  /**
  updateWithData:

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forAttribute: "subelements")
    // FIXME: Broken with change to data type
//    storage.dictionary = data - "subelements"
  }

  override public var jsonValue: JSONValue {
    var dict = super.jsonValue.value as! JSONValue.ObjectValue
    appendValueForKeyPath("presetCategory.index", toDictionary: &dict)
    let storageDict = storage.jsonValue.value as! JSONValue.ObjectValue
    dict += storageDict
    return .Object(dict)
  }

  public var baseType: RemoteElement.BaseType {
    get { return RemoteElement.BaseType(jsonValue: (storage["base-type"] as? String ?? "undefined").jsonValue) }
    set { storage["base-type"] = newValue.jsonValue.objectValue }
  }

  public var role: RemoteElement.Role {
    get { return RemoteElement.Role(jsonValue: (storage["role"] as? String ?? "undefined").jsonValue) }
    set { storage["role"] = newValue.jsonValue.objectValue }
  }

  public var shape: RemoteElement.Shape {
    get { return RemoteElement.Shape(jsonValue: (storage["shape"] as? String ?? "undefined").jsonValue) }
    set { storage["shape"] = newValue.jsonValue.objectValue }
  }

  public var style: RemoteElement.Style {
    get { return RemoteElement.Style(jsonValue: (storage["style"] as? String ?? "undefined").jsonValue) }
    set { storage["style"] = newValue.jsonValue.objectValue }
  }

  public var backgroundImage: Image? {
    get {
      if let moc = managedObjectContext, path = storage["backgroundImage"] as? String {
        return Image.objectWithIndex(PathIndex(path)!, context: moc)
      } else { return nil }
    }
    set { storage["background-image"] = newValue }
  }

  public var backgroundImageAlpha: Float? {
    get { return storage["background-image-alpha"] as? Float }
    set { storage["background-image-alpha"] = newValue }
  }

  public var backgroundColor: UIColor? {
    get { return UIColor(string: storage["background-color"] as? String ?? "") }
    set { storage["background-color"] = newValue?.string }
  }

  public var constraints: String? {
    get {
      if let constraintsArray = storage["constraints"] as? [String] {
        return "\n".join(constraintsArray)
      } else {
        return storage["constraints"] as? String
      }
    }
    set { storage["constraints"] = newValue }
  }

  /// MARK: - Remote attributes
  ////////////////////////////////////////////////////////////////////////////////


  public var topBarHidden: Bool? {
    get { return (storage["top-bar-hidden"] as? NSNumber)?.boolValue }
    set { storage["top-bar-hidden"] = newValue }
  }

  // panels?


  /// MARK: - ButtonGroup attributes
  ////////////////////////////////////////////////////////////////////////////////


  public var autohide: Bool? {
    get { return (storage["autohide"] as? NSNumber)?.boolValue }
    set { storage["autohide"] = newValue }
  }

  public var label: NSAttributedString? {
    get { return storage["label"] as? NSAttributedString }
    set { storage["label"] = newValue }
  }

  public var labelAttributes: [String:AnyObject]? {
    get { return storage["label-attributes"] as? [String:AnyObject] }
    set { storage["label-attributes"] = newValue }
  }

  public var labelConstraints: String? {
    get { return storage["label-constraints"] as? String }
    set { storage["label-constraints"] = newValue }
  }

  public var panelAssignment: ButtonGroup.PanelAssignment? {
    get { return ButtonGroup.PanelAssignment(jsonValue: (storage["panel-assignment"] as? String ?? "").jsonValue) }
    set { storage["panel-assignment"] = newValue?.jsonValue.objectValue }
  }

  /// MARK: - Button attributes
  ////////////////////////////////////////////////////////////////////////////////


  /** titles data stored in format ["state":["attribute":"value"]] */
  public var titles: JSONValue? {
    get { return JSONValue(rawValue: storage["titles"] as? String ?? "") }
    set { storage["titles"] = newValue?.rawValue }
  }

  /** icons data stored in format ["state":["image/color":"value"]] */
  public var icons: JSONValue? {
    get { return JSONValue(rawValue: storage["icons"] as? String ?? "") }
    set { storage["icons"] = newValue?.rawValue }
  }

  /** images data stored in format ["state":["image/color":"value"]] */
  public var images: JSONValue? {
    get { return JSONValue(rawValue: storage["images"] as? String ?? "") }
    set { storage["images"] = newValue?.rawValue }
  }

  /** backgroundColors data stored in format ["state":"color"] */
  public var backgroundColors: JSONValue? {
    get { return JSONValue(rawValue: storage["background-colors"] as? String ?? "") }
    set { storage["background-colors"] = newValue?.rawValue }
  }

  public var titleEdgeInsets: UIEdgeInsets {
    get { return (storage["title-edge-insets"] as? NSValue)?.UIEdgeInsetsValue() ?? UIEdgeInsets.zeroInsets }
    set { storage["title-edge-insets"] = NSValue(UIEdgeInsets: newValue) }
  }

  public var contentEdgeInsets: UIEdgeInsets {
    get { return (storage["content-edge-insets"] as? NSValue)?.UIEdgeInsetsValue() ?? UIEdgeInsets.zeroInsets }
    set { storage["contentEdgeInsets"] = NSValue(UIEdgeInsets: newValue) }
  }

  public var imageEdgeInsets: UIEdgeInsets {
    get { return (storage["image-edge-insets"] as? NSValue)?.UIEdgeInsetsValue() ?? UIEdgeInsets.zeroInsets }
    set { storage["image-edge-insets"] = NSValue(UIEdgeInsets: newValue) }
  }

  public var command: JSONValue? {
    get { return JSONValue(rawValue: storage["command"] as? String ?? "") }
    set { storage["command"] = newValue?.rawValue }
  }

  /**
  objectWithIndex:context:

  :param: index PathIndex
  :param: context NSManagedObjectContext

  :returns: Image?
  */
  @objc(objectWithPathIndex:context:)
  public override class func objectWithIndex(index: PathIndex, context: NSManagedObjectContext) -> Preset? {
    if let object = modelWithIndex(index, context: context) {
      MSLogDebug("located preset with name '\(object.name)'")
      return object
    } else { return nil }
  }

  override public var description: String {
    return "\(super.description)\n\t" + "\n\t".join(
      "category = \(presetCategory.index.rawValue)",
      "parent = \(parentPreset?.index.rawValue ?? nil)",
      "base type = \(baseType)",
      "role = \(role)",
      "shape = \(shape)",
      "style = \(style)",
      "background image = \(backgroundImage?.index ?? nil)",
      "background image alpha = \(backgroundImageAlpha ?? nil)",
      "background color = \(backgroundColor ?? nil)",
      "constraints = \(constraints ?? nil)",
      {
        switch self.baseType {
        case .Remote:
          return "top bar hidden = \(self.topBarHidden)"
        case .ButtonGroup:
          let labelAttributesString: String
          if let labelAttributes = self.labelAttributes {
            labelAttributesString = "\n" + labelAttributes.description.indentedBy(4)
          } else {
            labelAttributesString = "nil"
          }
          let labelConstraintsString: String
          if let labelConstraints = self.labelConstraints {
            labelConstraintsString = "\n" + labelConstraints.indentedBy(4)
          } else {
            labelConstraintsString = "nil"
          }
          return "\n\t".join(
            "autohide = \(self.autohide ?? nil)",
            "panel assignment = \(self.panelAssignment)",
            "label attributes = \(labelAttributesString)",
            "label constraints = \(labelConstraintsString)"
          )
        case .Button:
          let titlesString: String
          if let titles = self.titles {
            titlesString = "\n" + titles.description.indentedBy(4)
          } else { titlesString = "nil" }
          let iconsString: String
          if let icons = self.icons {
            iconsString = "\n" + icons.description.indentedBy(4)
          } else { iconsString = "nil" }
          let imagesString: String
          if let images = self.images {
            imagesString = "\n" + images.description.indentedBy(4)
          } else { imagesString = "nil" }
          let backgroundColorsString: String
          if let backgroundColors = self.backgroundColors {
            backgroundColorsString = "\n" + backgroundColors.description.indentedBy(4)
          } else { backgroundColorsString = "nil" }

          return "\n\t".join(
            "title edge insets = \(self.titleEdgeInsets)",
            "content edge insets = \(self.contentEdgeInsets)",
            "image edge insets = \(self.imageEdgeInsets)",
            "titles = \(titlesString)",
            "icons = \(iconsString)",
            "images = \(imagesString)",
            "background colors = \(backgroundColorsString)"
          )
        default: break
        }
        return ""
      }()
    )
  }

}

extension Preset: PathIndexedModel {
  public var pathIndex: PathIndex { return presetCategory.pathIndex + indexedName }

  /**
  modelWithIndex:context:

  :param: index PathIndex
  :param: context NSManagedObjectContext

  :returns: Preset?
  */
  public static func modelWithIndex(index: PathIndex, context: NSManagedObjectContext) -> Preset? {
    if index.count < 1 { return nil }
    let presetName = index.removeLast()
    if let presetCategory = PresetCategory.modelWithIndex(index, context: context) {
      return findFirst(presetCategory.presets, {$0.name == presetName})
    } else { return nil }

  }
}