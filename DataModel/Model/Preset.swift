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
import UIKit

@objc(Preset)
final public class Preset: EditableModelObject, CollectedModel {

  public var preview: UIImage? {
    get { return previewData?.image }
    set {
      if let image = newValue {
        if let data = previewData { data.image = image }
        else {
          let data = PNG(context: managedObjectContext)
          data.image = image
          previewData = data
        }
      } else {
        previewData = nil
      }
    }
  }
  public var thumbnail: UIImage? { return preview }

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

  public var presetCategory: PresetCategory {
    get {
      willAccessValueForKey("presetCategory")
      var category = primitiveValueForKey("presetCategory") as? PresetCategory
      didAccessValueForKey("presetCategory")
      if category == nil {
        category = PresetCategory.defaultCollectionInContext(managedObjectContext!)
        setPrimitiveValue(category, forKey: "presetCategory")
      }
      return category!
    }
    set {
      willChangeValueForKey("presetCategory")
      setPrimitiveValue(newValue, forKey: "presetCategory")
      didChangeValueForKey("presetCategory")
    }
  }

  public var collection: ModelCollection? { return presetCategory }

  public var subelements: OrderedSet<Preset>? {
    get {
      willAccessValueForKey("subelements")
      let subelements = primitiveValueForKey("subelements") as? NSOrderedSet
      didAccessValueForKey("subelements")
      return subelements as? OrderedSet<Preset>
    }
    set {
      willChangeValueForKey("subelements")
      setPrimitiveValue(newValue?._bridgeToObjectiveC(), forKey: "subelements")
      didChangeValueForKey("subelements")
    }
  }
  @NSManaged public var parentPreset: Preset?
  @NSManaged var previewData: PNG?

//  public subscript(key: String) -> AnyObject? {
//    get { return storage[key] }
//    set { storage[key] = newValue }
//  }

  /**
  updateWithData:

  - parameter data: ObjectJSONValue
  */
  override public func updateWithData(data: ObjectJSONValue) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forAttribute: "subelements")
    storage.dictionary = data.value - "subelements"
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["presetCategory.index"] = presetCategory.index.jsonValue
    obj.extend(ObjectJSONValue(storage.jsonValue)!)
    return obj.jsonValue
  }

  public var baseType: RemoteElement.BaseType {
    get { return RemoteElement.BaseType(storage["baseType"]) ?? .Undefined }
    set { storage["baseType"] = newValue.jsonValue }
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
    get { return RemoteElement.Style(storage["style"]) ?? .None }
    set { storage["style"] = newValue.jsonValue }
  }

  public var backgroundImage: Image? {
    get {
      if let moc = managedObjectContext, path = String(storage["backgroundImage"]) {
        return Image.objectWithIndex(ModelIndex(path), context: moc)
      } else { return nil }
    }
    set { storage["backgroundImage"] = newValue?.index.jsonValue }
  }

  public var backgroundImageAlpha: Float? {
    get { return Float(storage["backgroundImage-alpha"]) }
    set { storage["backgroundImage-alpha"] = newValue?.jsonValue }
  }

  public var backgroundColor: UIColor? {
    get { return UIColor(storage["backgroundColor"]) }
    set { storage["backgroundColor"] = newValue?.jsonValue }
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
    get { return Bool(storage["topBarHidden"]) }
    set { storage["topBarHidden"] = newValue?.jsonValue }
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
    get { return TitleAttributes(storage["labelAttributes"]) }
    set { storage["labelAttributes"] = newValue?.jsonValue }
  }

  public var labelConstraints: String? {
    get { return String(storage["labelConstraints"]) }
    set { storage["labelConstraints"] = newValue?.jsonValue }
  }

  public var panelAssignment: Remote.PanelAssignment? {
    get { return Remote.PanelAssignment(storage["panelAssignment"]) }
    set { storage["panelAssignment"] = newValue?.jsonValue }
  }

  /// MARK: - Button attributes
  ////////////////////////////////////////////////////////////////////////////////


  /** titles data stored in format ["state":["attribute":"value"]] */
  public var titles: ObjectJSONValue? {
    get { return ObjectJSONValue(storage["titles"]) }
    set { storage["titles"] = newValue?.jsonValue }
  }

  /** icons data stored in format ["state":["image/color":"value"]] */
  public var icons: ObjectJSONValue? {
    get { return ObjectJSONValue(storage["icons"]) }
    set { storage["icons"] = newValue?.jsonValue }
  }

  /** images data stored in format ["state":["image/color":"value"]] */
  public var images: ObjectJSONValue? {
    get { return ObjectJSONValue(storage["images"]) }
    set { storage["images"] = newValue?.jsonValue }
  }

  /** backgroundColors data stored in format ["state":"color"] */
  public var backgroundColors: ObjectJSONValue? {
    get { return ObjectJSONValue(storage["backgroundColors"]) }
    set { storage["backgroundColors"] = newValue?.jsonValue }
  }

  public var titleEdgeInsets: UIEdgeInsets {
    get { return UIEdgeInsets(storage["titleEdgeInsets"]) ?? UIEdgeInsets.zeroInsets }
    set { storage["titleEdgeInsets"] = newValue.jsonValue }
  }

  public var contentEdgeInsets: UIEdgeInsets {
    get { return UIEdgeInsets(storage["contentEdgeInsets"]) ?? UIEdgeInsets.zeroInsets }
    set { storage["contentEdgeInsets"] = newValue.jsonValue }
  }

  public var imageEdgeInsets: UIEdgeInsets {
    get { return UIEdgeInsets(storage["imageEdgeInsets"]) ?? UIEdgeInsets.zeroInsets }
    set { storage["imageEdgeInsets"] = newValue.jsonValue }
  }

  public var command: ObjectJSONValue? {
    get { return ObjectJSONValue(storage["command"]) }
    set { storage["command"] = newValue?.jsonValue }
  }

  // MARK: Printable

  override public var description: String {
    var description = "\(super.description)\n\t" + "\n\t".join(
      "category = \(presetCategory.index)",
      "parent = \(String(parentPreset?.index))",
      "baseType = \(baseType)",
      "role = \(role)",
      "shape = \(shape)",
      "style = \(style)",
      "background image = \(String(backgroundImage?.index))",
      "background image alpha = \(String(backgroundImageAlpha))",
      "background color = \(String(backgroundColor))",
      "constraints = " + "\n".join(map("\n".split(String(constraints)).enumerate(), {$0 > 0 ? $1.indentedBy(17) : $1})),
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
            "autohide = \(toString(self.autohide))",
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
    if var subelementDescriptions = subelements?.map({$0.description}) where subelementDescriptions.count > 0 {
      description += "\n\tsubelements = " + subelementDescriptions.removeAtIndex(0)
      if subelementDescriptions.count > 0 {
        description += "\n" + "\n\t".join(Array(subelementDescriptions)).indentedBy(17)
      }
    } else {
      description += "\n\tsubelements = nil"
    }
    return description
  }

  public override var pathIndex: PathIndex { return presetCategory.pathIndex + indexedName }

  /**
  modelWithIndex:context:

  - parameter index: PathIndex
  - parameter context: NSManagedObjectContext

  - returns: Preset?
  */
  public override static func modelWithIndex(var index: PathIndex, context: NSManagedObjectContext) -> Preset? {
    if index.count < 1 { return nil }
    let presetName = index.removeLast().pathDecoded
    if let presetCategory = PresetCategory.modelWithIndex(index, context: context) {
      return findFirst(presetCategory.presets, {$0.name == presetName})
    } else { return nil }

  }
}