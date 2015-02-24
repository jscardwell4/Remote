//
//  ModelObject.swift
//  Remote
//
//  Created by Jason Cardwell on 9/30/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

extension ModelObject {

  class func existingObjectForEntity(entityName: String,
                            withUUID uuid: String,
                            context: NSManagedObjectContext = DataManager.mainContext()) -> ModelObject?
  {
    var model: ModelObject?
    if isValidUUID(uuid) {
      let request = NSFetchRequest(entityName: entityName, predicate: NSPredicate(format: "uuid == %@", uuid))
      request.fetchLimit = 1
      var error: NSError?
      let results = context.executeFetchRequest(request, error: &error)
      if !MSHandleError(error, message: "error fetching model with uuid") { model = results?.first as? ModelObject }
    } else { MSRaiseException(NSInvalidArgumentException, "invalid uuid") }
    return model
  }

  class func objectForEntity(entityName: String,
                    withUUID uuid: String,
                      ofType type: ModelObject.Type,
                     context: NSManagedObjectContext = DataManager.mainContext()) -> ModelObject?
  {
    var model: ModelObject?
    if isValidUUID(uuid) {
      if existingObjectForEntity(entityName, withUUID: uuid, context: context) != nil {
        MSRaiseException(NSInvalidArgumentException, "object already exists with specified uuid")
      } else {
        if let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context) {
          model = type(entity: entity, insertIntoManagedObjectContext: context)
          model?.setPrimitiveValue(uuid, forKey: "uuid")
        }
      }
    } else { MSRaiseException(NSInvalidArgumentException, "invalid uuid") }
    return model
  }

  class func importObjectForEntity(entityName: String,
                           forType type: ModelObject.Type,
                          fromData data: [NSObject : AnyObject]?,
                           context: NSManagedObjectContext = DataManager.mainContext()) -> ModelObject?
  {
    var model: ModelObject?
    if data != nil {
      if let uuid = data?["uuid"] as? NSString {
        model = existingObjectForEntity(entityName, withUUID: uuid, context: context)
        if model == nil { model = objectForEntity(entityName, withUUID: uuid, ofType: type, context: context) }
        model?.updateWithData(data)
      }
    }
    return model
  }

  /**
  setIfNotDefault:forKey:inDictionary:

  :param: value AnyObject?
  :param: key String
  :param: dictionary MSDictionary
  */
  func setIfNotDefault(key: String, inDictionary dictionary: MSDictionary) {
    if !attributeValueIsDefault(key) { if let value: AnyObject = valueForKey(key) { dictionary[key] = value } }
  }

  /**
  setIfNotDefault:forKey:inDictionary:

  :param: value AnyObject?
  :param: key String
  :param: forKey String
  :param: dictionary MSDictionary
  */
  func setIfNotDefault(key: String, forKey: String, inDictionary dictionary: MSDictionary) {
    if !attributeValueIsDefault(key) { if let value: AnyObject = valueForKey(key) { dictionary[forKey] = value } }
  }

  /**
  safeSetValueForKeyPath:forKey:inDictionary:

  :param: keypath String
  :param: key String
  :param: dictionary MSDictionary
  */
  func safeSetValueForKeyPath(keypath: String, forKey key: String, inDictionary dictionary: MSDictionary) {
    dictionary[key] = NSNull.collectionSafeValue(valueForKeyPath(keypath))
  }

  /**
  safeSetValueForKeyPath:forKey:inDictionary:

  :param: keypath String
  :param: key String
  :param: dictionary MSDictionary
  */
  func safeSetValue(value: AnyObject?, forKey key: String, inDictionary dictionary: MSDictionary) {
    dictionary[key] = NSNull.collectionSafeValue(value)
  }

}
