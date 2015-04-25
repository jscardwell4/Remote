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

/** Maps `Element` type to the name of a relationship */
private let elementTypeKeys = [
  NSStringFromClass(ImageView.self)  : "imageViewSet",
  NSStringFromClass(JSONStorage.self): "jSONStorageSet"
]

protocol ModalStorageElementType: Model {}

extension ImageView: ModalStorageElementType {}
extension JSONStorage: ModalStorageElementType {}

@objc(ModalStorage)
final class ModalStorage: ModelObject {

  typealias Mode = RemoteElement.Mode

  @NSManaged private var imageViewSet: Set<ImageView>?
  @NSManaged private var jSONStorageSet: Set<JSONStorage>?

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
    setPrimitiveValue(dictionary.map {$2.rawValue} as MSDictionary, forKey: "dictionary")
  }

  /** Accessors for CoreData compatible dictionary representation */
  private var rawDictionary: OrderedDictionary<String, String> {
    get {
      willAccessValueForKey("dictionary")
      let dictionary = primitiveValueForKey("dictionary") as! MSDictionary
      didAccessValueForKey("dictionary")
      return dictionary as? OrderedDictionary<String, String> ?? [:]
    }
    set {
      willChangeValueForKey("dictionary")
      setPrimitiveValue(newValue as MSDictionary, forKey: "dictionary")
      didChangeValueForKey("dictionary")
    }
  }

  /** Maps dictionary values from `String` to `UUIDIndex` */
  private var convertedRawDictionary: OrderedDictionary<Mode, UUIDIndex> {
    return rawDictionary.compressedMap {UUIDIndex(rawValue: $2)}
  }

  /** Used to map mode values to the uuid of an element in `elementSet` */
  lazy var dictionary: OrderedDictionary<Mode, UUIDIndex> = { return self.convertedRawDictionary }()

  /** Accessors for an `ImageView` keyed by `Mode` value */
  subscript(key: Mode) -> ImageView? {
    @objc(imageViewForKeyedSubscript:)
    get {
      if let uuid = dictionary[key] { return findFirst(imageViewSet, {$0.uuid == uuid.rawValue}) }
      else { return nil }
    }
    @objc(setImageView:forKeyedSubscript:)
    set {
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
      if let uuid = dictionary[key] { return findFirst(jSONStorageSet, {$0.uuid == uuid.rawValue}) }
      else { return nil }
    }
    @objc(setJSONStorage:forKeyedSubscript:)
    set {
      if let element = newValue, uuid = UUIDIndex(rawValue: element.uuid) {
        dictionary[key] = uuid
        mutableSetValueForKey("jSONStorageSet").addObject(element)
      } else if newValue == nil, let existingElement: JSONStorage = self[key] {
        mutableSetValueForKey("jSONStorageSet").removeObject(existingElement)
        dictionary[key] = nil
      }
    }
  }


}
