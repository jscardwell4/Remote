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

//  public subscript(key: String) -> AnyObject? {
//    get { return storage[key] }
//    set { storage[key] = newValue }
//  }

  /**
  updateWithData:

  :param: data ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forAttribute: "subelements")
    storage.dictionary = data.value - "subelements"
  }

  override public var jsonValue: JSONValue {
    var dict = super.jsonValue.value as! JSONValue.ObjectValue
    appendValueForKeyPath("presetCategory.index", toDictionary: &dict)
    dict += storage.dictionary
    return .Object(dict)
  }

  public var baseType: RemoteElement.BaseType {
    get { return RemoteElement.BaseType(storage["base-type"]) ?? .Undefined }
    set { storage["base-type"] = newValue.jsonValue }
  }

  public var role: RemoteElement.Role {
    get { return RemoteElement.Role(storage["role"]) ?? .Undefined }
    set { storage["role"] = newValue.jsonValue }
  }

  public var shape: RemoteElement.Shape {
    get { return RemoteElement.Shape(storage["shape"]) ?? .Undefined }
    set { storage["shape"] = newValue.jsonValue }
  }

  public var style: RemoteElement.Style {
    get { return RemoteElement.Style(storage["style"]) ?? .Undefined }
    set { storage["style"] = newValue.jsonValue }
  }

  public var backgroundImage: Image? {
    get {
      if let moc = managedObjectContext, path = String(storage["backgroundImage"]) {
        return Image.objectWithIndex(PathIndex(path)!, context: moc)
      } else { return nil }
    }
    set { storage["background-image"] = newValue?.index.jsonValue }
  }

  public var backgroundImageAlpha: Float? {
    get { return Float(storage["background-image-alpha"]) }
    set { storage["background-image-alpha"] = newValue?.jsonValue }
  }

  public var backgroundColor: UIColor? {
    get { return UIColor(storage["background-color"]) }
    set { storage["background-color"] = newValue?.jsonValue }
  }

  public var constraints: String? {
    get {
      if let constraintsArray = ArrayJSONValue(storage["constraints"]) {
        return "\n".join(compressedMap(constraintsArray, {String($0)}))
      } else {
        return String(storage["constraints"])
      }
    }
    set { storage["constraints"] = newValue?.jsonValue }
  }

  /// MARK: - Remote attributes
  ////////////////////////////////////////////////////////////////////////////////


  public var topBarHidden: Bool? {
    get { return Bool(storage["top-bar-hidden"]) }
    set { storage["top-bar-hidden"] = newValue?.jsonValue }
  }

  // panels?


  /// MARK: - ButtonGroup attributes
  ////////////////////////////////////////////////////////////////////////////////


  public var autohide: Bool? {
    get { return Bool(storage["autohide"]) }
    set { storage["autohide"] = newValue?.jsonValue }
  }

  public var label: NSAttributedString? {
    get { if let attributes = TitleAttributes(storage["label"]) { return attributes.string } else { return nil } }
    set { if let string = newValue { storage["label"] = TitleAttributes(attributedString: string).jsonValue } }
  }

  public var labelAttributes: TitleAttributes? {
    get { return TitleAttributes(storage["label-attributes"]) }
    set { storage["label-attributes"] = newValue?.jsonValue }
  }

  public var labelConstraints: String? {
    get { return String(storage["label-constraints"]) }
    set { storage["label-constraints"] = newValue?.jsonValue }
  }

  public var panelAssignment: ButtonGroup.PanelAssignment? {
    get { return ButtonGroup.PanelAssignment(storage["panel-assignment"]) }
    set { storage["panel-assignment"] = newValue?.jsonValue }
  }

  /// MARK: - Button attributes
  ////////////////////////////////////////////////////////////////////////////////


  /** titles data stored in format ["state":["attribute":"value"]] */
  public var titles: JSONValue? {
    get { return storage["titles"] }
    set { storage["titles"] = newValue }
  }

  /** icons data stored in format ["state":["image/color":"value"]] */
  public var icons: JSONValue? {
    get { return storage["icons"] }
    set { storage["icons"] = newValue }
  }

  /** images data stored in format ["state":["image/color":"value"]] */
  public var images: JSONValue? {
    get { return storage["images"] }
    set { storage["images"] = newValue }
  }

  /** backgroundColors data stored in format ["state":"color"] */
  public var backgroundColors: JSONValue? {
    get { return storage["background-colors"] }
    set { storage["background-colors"] = newValue }
  }

  public var titleEdgeInsets: UIEdgeInsets {
    get { return UIEdgeInsets(storage["title-edge-insets"]) ?? UIEdgeInsets.zeroInsets }
    set { storage["title-edge-insets"] = newValue.jsonValue }
  }

  public var contentEdgeInsets: UIEdgeInsets {
    get { return UIEdgeInsets(storage["content-edge-insets"]) ?? UIEdgeInsets.zeroInsets }
    set { storage["contentEdgeInsets"] = newValue.jsonValue }
  }

  public var imageEdgeInsets: UIEdgeInsets {
    get { return UIEdgeInsets(storage["image-edge-insets"]) ?? UIEdgeInsets.zeroInsets }
    set { storage["image-edge-insets"] = newValue.jsonValue }
  }

  public var command: JSONValue? {
    get { return storage["command"] }
    set { storage["command"] = newValue }
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
            labelAttributesString = "\n" + labelAttributes.storage.description.indentedBy(4)
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