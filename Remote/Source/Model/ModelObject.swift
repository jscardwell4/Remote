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

@objc protocol Model {
  var uuid: String { get }
}

@objc(ModelObject)
class ModelObject: NSManagedObject {

  @NSManaged var primitiveUUID: String
  private(set) var uuid: String {
    get {
      willAccessValueForKey("uuid")
      let uuid = primitiveUUID
      didAccessValueForKey("uuid")
      return uuid
    }
    set {
      if primitiveValueForKey("uuid") == nil {
        willChangeValueForKey("uuid")
        primitiveUUID = newValue
        didChangeValueForKey("uuid")
      }
    }
  }

  /**
  isValidUUID:

  :param: uuid String

  :returns: Bool
  */
  class func isValidUUID(uuid: String) -> Bool { return uuid.matchesRegEx("[A-F0-9]{8}-(?:[A-F0-9]{4}-){3}[A-Z0-9]{12}") }

  /**
  objectWithUUID:context:

  :param: uuid String
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  class func objectWithUUID(uuid: String, context: NSManagedObjectContext) -> Self? {
    //TODO: Fill out stub
    return nil
  }

  /**
  existingObjectWithUUID:context:

  :param: uuid String
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  class func existingObjectWithUUID(uuid: String, context: NSManagedObjectContext) -> Self? {
    //TODO: Fill out stub
    if isValidUUID(uuid) { return nil } else { return nil }
  }

  /**
  importObjectFromData:context:

  :param: data [NSObject AnyObject]
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  class func importObjectFromData(data: [NSObject:AnyObject], context: NSManagedObjectContext) -> Self? {
    //TODO: Fill out stub
    return nil
  }

  /**
  importObjectsFromData:context:

  :param: data AnyObject
  :param: context NSManagedObjectContext

  :returns: [ModelObject]
  */
  class func importObjectsFromData(data: AnyObject, context: NSManagedObjectContext) -> [ModelObject] {
    //TODO: Fill out stub
     return []
  }

  /**
  findFirstByAttribute:withValue:context:

  :param: attribute String
  :param: value AnyObject
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  class func findFirstByAttribute(attribute: String, withValue value: AnyObject, context: NSManagedObjectContext) -> Self? {
    //TODO: Fill out stub
    return nil
  }

  /**
  allValuesForAttribute:context:

  :param: attribute String
  :param: context NSManagedObjectContext

  :returns: [AnyObject]
  */
  class func allValuesForAttribute(attribute: String, context: NSManagedObjectContext) -> [AnyObject] {
    //TODO: Fill out stub
    return []
  }

  /**
  findFirstMatchingPredicate:context:

  :param: predicate NSPredicate
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  class func findFirstMatchingPredicate(predicate: NSPredicate, context: NSManagedObjectContext) -> Self? {
    //TODO: Fill out stub
    return nil
  }

  /**
  findAllMatchingPredicate:context:

  :param: predicate NSPredicate
  :param: context NSManagedObjectContext

  :returns: [Self]
  */
  class func findAllMatchingPredicate(predicate: NSPredicate, context: NSManagedObjectContext) -> [ModelObject] {
    //TODO: Fill out stub
    return []
  }

  /**
  findAllInContext:

  :param: context NSManagedObjectContext

  :returns: [ModelObject]
  */
  class func findAllInContext(context: NSManagedObjectContext) -> [ModelObject] {
    //TODO: Fill out stub
    return []
  }

  /**
  findAllSortedBy:ascending:context:

  :param: sortBy String
  :param: ascending Bool
  :param: context NSManagedObjectContext

  :returns: [ModelObject]
  */
  class func findAllSortedBy(sortBy: String, ascending: Bool, context: NSManagedObjectContext) -> [ModelObject] {
    //TODO: Fill out stub
    return []
  }

  /**
  countOfObjectsInContext:

  :param: context NSManagedObjectContext

  :returns: Int
  */
  class func countOfObjectsInContext(context: NSManagedObjectContext) -> Int {
    //TODO: Fill out stub
    return 0
  }

  /**
  countOfObjectsMatchingPredicate:context:

  :param: predicate NSPredicate
  :param: context NSManagedObjectContext

  :returns: Int
  */
  class func countOfObjectsMatchingPredicate(predicate: NSPredicate, context: NSManagedObjectContext) -> Int {
    //TODO: Fill out stub
    return 0
  }

  /**
  deleteAllMatchingPredicate:context:

  :param: predicate NSPredicate
  :param: context NSManagedObjectContext
  */
  class func deleteAllMatchingPredicate(predicate: NSPredicate, context: NSManagedObjectContext) {
    //TODO: Fill out stub
  }

  /**
  fetchAllGroupedBy:withPredicate:sortedBy:ascending:context:

  :param: groupBy String
  :param: predicate NSPredicate
  :param: sortBy String
  :param: ascending Bool
  :param: context NSManagedObjectContext

  :returns: NSFetchedResultsController
  */
  class func fetchAllGroupedBy(groupBy: String,
                 withPredicate predicate: NSPredicate,
                      sortedBy sortBy: String,
                     ascending: Bool,
                       context: NSManagedObjectContext) -> NSFetchedResultsController
  {
    //TODO: Fill out stub
    return NSFetchedResultsController()
  }

  class func fetchAllGroupedBy(groupBy: String,
                      sortedBy sortBy: String,
                       context: NSManagedObjectContext) -> NSFetchedResultsController
  {
    //TODO: Fill out stub
    return NSFetchedResultsController()
  }

  /**
  existingObjectForEntity:withUUID:context:

  :param: entityName String
  :param: uuid String
  :param: context NSManagedObjectContext = DataManager.mainContext()

  :returns: ModelObject?
  */
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

  /**
  objectForEntity:withUUID:ofType:context:

  :param: entityName String
  :param: uuid String
  :param: type ModelObject.Type
  :param: context NSManagedObjectContext = DataManager.mainContext()

  :returns: ModelObject?
  */
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

  /**
  updateWithData:

  :param: data [NSObject:AnyObject]!
  */
  func updateWithData(data: [NSObject:AnyObject]!) {
    //TODO: Fill out stub
  }

  /**
  initWithContext:

  :param: context NSManagedObjectContext
  */
  init(context: NSManagedObjectContext) {
    //TODO: Fill out stub
    let className = NSStringFromClass(self.dynamicType)
    super.init(entity: NSEntityDescription.entityForName(className, inManagedObjectContext: context)!,
               insertIntoManagedObjectContext: context)
  }

  /**
  initWithEntity:insertIntoManagedObjectContext:

  :param: entity NSEntityDescription
  :param: context NSManagedObjectContext?
  */
  override required init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
    super.init(entity: entity, insertIntoManagedObjectContext: context)
  }

  /** awakeFromInsert */
  override func awakeFromInsert() {
    super.awakeFromInsert()
    primitiveUUID = MSNonce()
  }

  /**
  importObjectForEntity:forType:fromData:context:

  :param: entityName String
  :param: type ModelObject.Type
  :param: data [NSObject
  :param: context NSManagedObjectContext = DataManager.mainContext()

  :returns: ModelObject?
  */
  class func importObjectForEntity(entityName: String,
                           forType type: ModelObject.Type,
                          fromData data: [NSObject:AnyObject]?,
                           context: NSManagedObjectContext = DataManager.mainContext()) -> ModelObject?
  {
    var model: ModelObject?
    if data != nil {
      if let uuid = data?["uuid"] as? NSString {
        model = existingObjectForEntity(entityName, withUUID: uuid as String, context: context)
        if model == nil { model = objectForEntity(entityName, withUUID: uuid as String, ofType: type, context: context) }
        model?.updateWithData(data)
      }
    }
    return model
  }

  /**
  attributeValueIsDefault:

  :param: attribute String

  :returns: Bool
  */
  func attributeValueIsDefault(attribute: String) -> Bool {
    //TODO: Fill out stub
    return true
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

extension ModelObject: MSJSONExport {
  var JSONString: String {
    //TODO: Fill out stub
    return ""
  }

  func JSONDictionary() -> MSDictionary {
    //TODO: Fill out stub
    return MSDictionary()
  }

  var JSONObject: AnyObject { return JSONDictionary().JSONObject }


}

/// MARK: - Convenience functions
////////////////////////////////////////////////////////////////////////////////

func sortedByName<T: Nameable>(array: [T]) -> [T] { return array.sorted{$0.0.name < $0.1.name} }
func sortedByName<T: Nameable>(array: [T]?) -> [T]? { return array?.sorted{$0.0.name < $0.1.name} }
func sortByName<T: Nameable>(inout array: [T]) { array.sort{$0.0.name < $0.1.name} }
func sortByName<T: Nameable>(inout array: [T]?) { array?.sort{$0.0.name < $0.1.name} }


