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

  // MARK: - Relationships

  @NSManaged var imageViewSet:            Set<ImageView>
  @NSManaged var jSONStorageSet:          Set<JSONStorage>
  @NSManaged var commandContainerSet:     Set<CommandContainer>
  @NSManaged var controlStateTitleSetSet: Set<ControlStateTitleSet>
  @NSManaged var controlStateImageSetSet: Set<ControlStateImageSet>
  @NSManaged var controlStateColorSetSet: Set<ControlStateColorSet>
  @NSManaged var commandSet:              Set<Command>

  // MARK: - Storage type

  private(set) var storageType: StorageType {
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

    var property: String? { switch self { case .None: return nil; default: return rawValue } }

    /** Class type associated with the `StorageType` */
    var type: ModelObject.Type? {
      switch self {
        case .ImageViewSet:            return ImageView.self
        case .JSONStorageSet:          return JSONStorage.self
        case .CommandContainerSet:     return CommandContainer.self
        case .ControlStateTitleSetSet: return ControlStateTitleSet.self
        case .ControlStateImageSetSet: return ControlStateImageSet.self
        case .ControlStateColorSetSet: return ControlStateColorSet.self
        case .CommandSet:              return Command.self
        case .None:                    return nil
      }
    }

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

    /**
    Initialize with a compatible storage type class

    :param: type ModelObject.Type
    */
    init?(type: ModelObject.Type) {
      switch type {
        case let t where t === ImageView.self:            self = .ImageViewSet
        case let t where t === JSONStorage.self:          self = .JSONStorageSet
        case let t where t === CommandContainer.self:     self = .CommandContainerSet
        case let t where t === ControlStateTitleSet.self: self = .ControlStateTitleSetSet
        case let t where t === ControlStateImageSet.self: self = .ControlStateImageSetSet
        case let t where t === ControlStateColorSet.self: self = .ControlStateColorSetSet
        case let t where t === Command.self:              self = .CommandSet
        default:                                          return nil
      }
    }

  }

  /** Accessory for the relationship object being used for storage or nil if nothing is being stored */
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

  /**
  Returns the value for the specified `mode` if it exists and is of type `T`

  :param: mode Mode

  :returns: T?
  */
  func valueForMode<T: ModelObject>(mode: Mode) -> T? {
    if let uuidIndex = dictionary[mode],
      values = setInUse,
      v = findFirst(values, {$0.uuid == uuidIndex.rawValue})
    {
      return typeCast(v, T.self)
    } else { return nil }
  }

  enum SetValueResult { case NoAction, ValueAdded, ValueRemoved }

  /**
  Sets the specified value for `mode` if its type and `storageType` match, if `storageType` is `.None` and value is 
  of a compatible type than both the value and `storageType` are set

  :param: value T?
  :param: mode Mode

  :returns: SetValueResult
  */
  func setValue<T: ModelObject>(value: T?, forMode mode: Mode) -> SetValueResult {
    if value == nil, let existingValue: T = valueForMode(mode), property = storageType.property {
      mutableSetValueForKey(property).removeObject(existingValue)
      dictionary[mode] = nil
      return .ValueRemoved
    } else if storageType == .None, let v = value, storageType = StorageType(type: T.self), property = storageType.property {
      self.storageType = storageType
      mutableSetValueForKey(property).addObject(v)
      dictionary[mode] = v.uuidIndex
      return .ValueAdded
    } else if let type = storageType.type, v = typeCast(value, type), property = storageType.property {
      mutableSetValueForKey(property).addObject(v)
      dictionary[mode] = v.uuidIndex
      return .ValueAdded
    } else {
      return .NoAction
    }
  }


  // MARK: - Lifecycle

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

  // MARK: - Dictionary accessors

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
  lazy var dictionary: [Mode:UUIDIndex] = {
    self.willAccessValueForKey("dictionary")
    let d = self.convertedRawDictionary
    self.didAccessValueForKey("dictionary")
    return d
    }()

    // MARK: - Subscriptting

  /** Accessors for an `ImageView` keyed by `Mode` value */
  subscript(mode: Mode) -> ImageView? {
    @objc(imageViewForKeyedSubscript:) get { return storageType == .ImageViewSet ? valueForMode(mode) : nil }
    @objc(setImageView:forKeyedSubscript:) set { setValue(newValue, forMode: mode) }
  }

  /** Accessors for an `JSONStorage` keyed by `Mode` value */
  subscript(mode: Mode) -> JSONStorage? {
    @objc(jsonStorageForKeyedSubscript:) get { return storageType == .JSONStorageSet ? valueForMode(mode) : nil }
    @objc(setJSONStorage:forKeyedSubscript:) set { setValue(newValue, forMode: mode) }
  }

  /** Accessors for an `CommandContainer` keyed by `Mode` value */
  subscript(mode: Mode) -> CommandContainer? {
    @objc(commandContainerForKeyedSubscript:)
    get { return storageType == .CommandContainerSet ? valueForMode(mode) : nil }
    @objc(setCommandContainer:forKeyedSubscript:) set { setValue(newValue, forMode: mode) }
  }

  /** Accessors for an `ControlStateColorSet` keyed by `Mode` value */
  subscript(mode: Mode) -> ControlStateColorSet? {
    @objc(controlStateColorSetForKeyedSubscript:)
    get { return storageType == .ControlStateColorSetSet ? valueForMode(mode) : nil }
    @objc(setControlStateColorSet:forKeyedSubscript:) set { setValue(newValue, forMode: mode) }
  }

  /** Accessors for an `ControlStateImageSet` keyed by `Mode` value */
  subscript(mode: Mode) -> ControlStateImageSet? {
    @objc(controlStateImageSetForKeyedSubscript:)
    get { return storageType == .ControlStateImageSetSet ? valueForMode(mode) : nil }
    @objc(setControlStateImageSet:forKeyedSubscript:) set { setValue(newValue, forMode: mode) }
  }

  /** Accessors for an `ControlStateTitleSet` keyed by `Mode` value */
  subscript(mode: Mode) -> ControlStateTitleSet? {
    @objc(controlStateTitleSetForKeyedSubscript:)
    get { return storageType == .ControlStateTitleSetSet ? valueForMode(mode) : nil }
    @objc(setControlStateTitleSet:forKeyedSubscript:) set { setValue(newValue, forMode: mode) }
  }

  /** Accessors for an `Command` keyed by `Mode` value */
  subscript(mode: Mode) -> Command? {
    @objc(commandForKeyedSubscript:) get { return storageType == .CommandSet ? valueForMode(mode) : nil }
    @objc(setCommand:forKeyedSubscript:) set { setValue(newValue, forMode: mode) }
  }

  // MARK: - Descriptions

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
