//
//  JSONStorage.swift
//  Remote
//
//  Created by Jason Cardwell on 4/7/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(JSONStorage)
public final class JSONStorage: ModelObject, ModelStorage {

  override public func awakeFromSnapshotEvents(flags: NSSnapshotEventType) {
    super.awakeFromSnapshotEvents(flags)
    dictionary = convertedRawDictionary
  }

  override public func willSave() {
    super.willSave()
    setPrimitiveValue(dictionary.map {$2.rawValue} as MSDictionary, forKey: "dictionary")
  }

  private var convertedRawDictionary: OrderedDictionary<String, JSONValue> {
    return rawDictionary.compressedMap {JSONValue(rawValue: $2)}
  }

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

  public lazy var dictionary: OrderedDictionary<String, JSONValue> = { return self.convertedRawDictionary }()

  public subscript(key: String) -> JSONValue? { get { return dictionary[key] } set { dictionary[key] = newValue } }

  override public var jsonValue: JSONValue { return (ObjectJSONValue(super.jsonValue)! + ObjectJSONValue(dictionary)).jsonValue }
}

