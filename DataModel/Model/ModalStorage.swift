//
//  ModalStorage.swift
//  Remote
//
//  Created by Jason Cardwell on 4/25/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(ModalStorage)
final class ModalStorage: ModelObject {

  typealias Mode = RemoteElement.Mode

  @NSManaged private var imageViewSet: Set<ImageView>
  @NSManaged private var jSONStorageSet: Set<JSONStorage>
  @NSManaged private var commandContainerSet: Set<CommandContainer>
  @NSManaged private var controlStateTitleSetSet: Set<ControlStateTitleSet>
  @NSManaged private var controlStateImageSetSet: Set<ControlStateImageSet>
  @NSManaged private var controlStateColorSetSet: Set<ControlStateColorSet>
  @NSManaged private var commandSet: Set<Command>
  private var storageType: StorageType {
    get {
      willAccessValueForKey("storageType")
      let storageType = primitiveValueForKey("storageType") as? String ?? ""
      didAccessValueForKey("storageType")
      return StorageType(rawValue: storageType) ?? .None
    }
    set {
      willChangeValueForKey("storageType")
      setPrimitiveValue(newValue.rawValue, forKey: "storageType")
      didChangeValueForKey("storageType")
    }
  }


  enum StorageType: String, Printable {
    case None                    = ""
    case ImageViewSet            = "imageViewSet"
    case JSONStorageSet          = "jSONStorageSet"
    case CommandContainerSet     = "commandContainerSet"
    case ControlStateTitleSetSet = "controlStateTitleSetSet"
    case ControlStateImageSetSet = "controlStateImageSetSet"
    case ControlStateColorSetSet = "controlStateColorSetSet"
    case CommandSet              = "commandSet"

    var description: String {
      switch self {
        case .None:                    return "None"
        case .ImageViewSet:            return "ImageViewSet"
        case .JSONStorageSet:          return "JSONStorageSet"
        case .CommandContainerSet:     return "CommandContainerSet"
        case .ControlStateTitleSetSet: return "ControlStateTitleSetSet"
        case .ControlStateImageSetSet: return "ControlStateImageSetSet"
        case .ControlStateColorSetSet: return "ControlStateColorSetSet"
        case .CommandSet:              return "CommandSet"
      }
    }
  }

  /**
  awakeFromSnapshotEvents:

  :param: flags NSSnapshotEventType
  */
  override func awakeFromSnapshotEvents(flags: NSSnapshotEventType) {
    super.awakeFromSnapshotEvents(flags)
    dictionary = convertedRawDictionary
  }

  /** willSave */
  override func willSave() {
    super.willSave()
    let mapped = map(dictionary) {$1.rawValue}
    setPrimitiveValue(mapped, forKey: "dictionary")
  }

  /** Accessors for CoreData compatible dictionary representation */
  private var rawDictionary: [String:String] {
    get {
      willAccessValueForKey("dictionary")
      let dictionary = primitiveValueForKey("dictionary") as! [String:String]
      didAccessValueForKey("dictionary")
      return dictionary
    }
    set {
      willChangeValueForKey("dictionary")
      setPrimitiveValue(newValue, forKey: "dictionary")
      didChangeValueForKey("dictionary")
    }
  }

  /** Maps dictionary values from `String` to `UUIDIndex` */
  private var convertedRawDictionary: [Mode:UUIDIndex] { return compressedMap(rawDictionary) {UUIDIndex(rawValue: $1)} }

  /** Used to map mode values to the uuid of an element in `elementSet` */
  lazy var dictionary: [Mode:UUIDIndex] = { return self.convertedRawDictionary }()

  private func validateStorageType(type: StorageType) -> Bool {
    if storageType == type { return true }
    else if storageType == .None { storageType = type; return true }
    else { return false }
  }

  /** Accessors for an `ImageView` keyed by `Mode` value */
  subscript(key: Mode) -> ImageView? {
    @objc(imageViewForKeyedSubscript:)
    get {
      if !validateStorageType(.ImageViewSet) { return nil }
      if let uuid = dictionary[key] { return findFirst(imageViewSet, {$0.uuid == uuid.rawValue}) }
      else { return nil }
    }
    @objc(setImageView:forKeyedSubscript:)
    set {
      if !validateStorageType(.ImageViewSet) { return }
      if let element = newValue, uuid = UUIDIndex(rawValue: element.uuid) {
        dictionary[key] = uuid
        mutableSetValueForKey("imageViewSet").addObject(element)
      } else if newValue == nil, let existingElement: ImageView = self[key] {
        mutableSetValueForKey("imageViewSet").removeObject(existingElement)
        dictionary[key] = nil
      }
    }
  }

  /** Accessors for an `JSONStorage` keyed by `Mode` value */
  subscript(key: Mode) -> JSONStorage? {
    @objc(jsonStorageForKeyedSubscript:)
    get {
      if !validateStorageType(.JSONStorageSet) { return nil }
      if let uuid = dictionary[key] { return findFirst(jSONStorageSet, {$0.uuid == uuid.rawValue}) }
      else { return nil }
    }
    @objc(setJSONStorage:forKeyedSubscript:)
    set {
      if !validateStorageType(.JSONStorageSet) { return }
      if let element = newValue, uuid = UUIDIndex(rawValue: element.uuid) {
        dictionary[key] = uuid
        mutableSetValueForKey("jSONStorageSet").addObject(element)
      } else if newValue == nil, let existingElement: JSONStorage = self[key] {
        mutableSetValueForKey("jSONStorageSet").removeObject(existingElement)
        dictionary[key] = nil
      }
    }
  }

  /** Accessors for an `CommandContainer` keyed by `Mode` value */
  subscript(key: Mode) -> CommandContainer? {
    @objc(commandContainerForKeyedSubscript:)
    get {
      if !validateStorageType(.CommandContainerSet) { return nil }
      if let uuid = dictionary[key] { return findFirst(commandContainerSet, {$0.uuid == uuid.rawValue}) }
      else { return nil }
    }
    @objc(setCommandContainer:forKeyedSubscript:)
    set {
      if !validateStorageType(.CommandContainerSet) { return }
      if let element = newValue, uuid = UUIDIndex(rawValue: element.uuid) {
        dictionary[key] = uuid
        mutableSetValueForKey("commandContainerSet").addObject(element)
      } else if newValue == nil, let existingElement: JSONStorage = self[key] {
        mutableSetValueForKey("commandContainerSet").removeObject(existingElement)
        dictionary[key] = nil
      }
    }
  }

  /** Accessors for an `ControlStateColorSet` keyed by `Mode` value */
  subscript(key: Mode) -> ControlStateColorSet? {
    @objc(controlStateColorSetForKeyedSubscript:)
    get {
      if !validateStorageType(.ControlStateColorSetSet) { return nil }
      if let uuid = dictionary[key] { return findFirst(controlStateColorSetSet, {$0.uuid == uuid.rawValue}) }
      else { return nil }
    }
    @objc(setControlStateColorSet:forKeyedSubscript:)
    set {
      if !validateStorageType(.ControlStateColorSetSet) { return }
      if let element = newValue, uuid = UUIDIndex(rawValue: element.uuid) {
        dictionary[key] = uuid
        mutableSetValueForKey("controlStateColorSetSet").addObject(element)
      } else if newValue == nil, let existingElement: JSONStorage = self[key] {
        mutableSetValueForKey("controlStateColorSetSet").removeObject(existingElement)
        dictionary[key] = nil
      }
    }
  }

  /** Accessors for an `ControlStateImageSet` keyed by `Mode` value */
  subscript(key: Mode) -> ControlStateImageSet? {
    @objc(controlStateImageSetForKeyedSubscript:)
    get {
      if !validateStorageType(.ControlStateImageSetSet) { return nil }
      if let uuid = dictionary[key] { return findFirst(controlStateImageSetSet, {$0.uuid == uuid.rawValue}) }
      else { return nil }
    }
    @objc(setControlStateImageSet:forKeyedSubscript:)
    set {
      if !validateStorageType(.ControlStateImageSetSet) { return }
      if let element = newValue, uuid = UUIDIndex(rawValue: element.uuid) {
        dictionary[key] = uuid
        mutableSetValueForKey("controlStateImageSetSet").addObject(element)
      } else if newValue == nil, let existingElement: JSONStorage = self[key] {
        mutableSetValueForKey("controlStateImageSetSet").removeObject(existingElement)
        dictionary[key] = nil
      }
    }
  }

  /** Accessors for an `ControlStateTitleSet` keyed by `Mode` value */
  subscript(key: Mode) -> ControlStateTitleSet? {
    @objc(controlStateTitleSetForKeyedSubscript:)
    get {
      if !validateStorageType(.ControlStateTitleSetSet) { return nil }
      if let uuid = dictionary[key] { return findFirst(controlStateTitleSetSet, {$0.uuid == uuid.rawValue}) }
      else { return nil }
    }
    @objc(setControlStateTitleSet:forKeyedSubscript:)
    set {
      if !validateStorageType(.ControlStateTitleSetSet) { return }
      if let element = newValue, uuid = UUIDIndex(rawValue: element.uuid) {
        dictionary[key] = uuid
        mutableSetValueForKey("controlStateTitleSetSet").addObject(element)
      } else if newValue == nil, let existingElement: JSONStorage = self[key] {
        mutableSetValueForKey("controlStateTitleSetSet").removeObject(existingElement)
        dictionary[key] = nil
      }
    }
  }

  /** Accessors for an `Command` keyed by `Mode` value */
  subscript(key: Mode) -> Command? {
    @objc(commandForKeyedSubscript:)
    get {
      if !validateStorageType(.CommandSet) { return nil }
      if let uuid = dictionary[key] { return findFirst(commandSet, {$0.uuid == uuid.rawValue}) }
      else { return nil }
    }
    @objc(setCommand:forKeyedSubscript:)
    set {
      if !validateStorageType(.CommandSet) { return }
      if let element = newValue, uuid = UUIDIndex(rawValue: element.uuid) {
        dictionary[key] = uuid
        mutableSetValueForKey("commandSet").addObject(element)
      } else if newValue == nil, let existingElement: JSONStorage = self[key] {
        mutableSetValueForKey("commandSet").removeObject(existingElement)
        dictionary[key] = nil
      }
    }
  }

  private var setInUse: Set<ModelObject>? {
    switch storageType {
      case .None:                    return nil
      case .ImageViewSet:            return imageViewSet
      case .JSONStorageSet:          return jSONStorageSet
      case .CommandContainerSet:     return commandContainerSet
      case .ControlStateTitleSetSet: return controlStateTitleSetSet
      case .ControlStateImageSetSet: return controlStateImageSetSet
      case .ControlStateColorSetSet: return controlStateColorSetSet
      case .CommandSet:              return commandSet
    }
  }

  override var description: String {
    var result = super.description
    result += "\n\tstorageType = \(storageType)"
    result += "\n\tdictionary = {"
    let dictionaryEntries = keyValuePairs(dictionary)
    if dictionaryEntries.count == 0 { result += "}" }
    else { result += "\n\t\t" + "\n\t\t".join(dictionaryEntries.map({"\($0) = \($1.rawValue)"})) + "\n\t}"}
    let values = setInUse
    if values == nil { result += "\n\tsetInUse = nil" }
    else if values!.count == 0 { result += "\n\tsetInUse = {}" }
    else {
      result += "\n\tsetInUse = {\n"
      result += ",\n".join(map(values!) {"{\n\($0.description.indentedBy(8))\n}".indentedBy(4)})
      result += "\n\t}"
    }
    return result
  }

}
