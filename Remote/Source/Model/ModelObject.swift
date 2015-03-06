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
  entityName:

  :param: context NSManagedObjectContext = DataManager.rootContext

  :returns: String
  */
  class func entityName(context: NSManagedObjectContext = DataManager.rootContext) -> String {
    return entityDescription(context)?.name ?? className()
  }

  /**
  isValidUUID:

  :param: uuid String

  :returns: Bool
  */
  class func isValidUUID(uuid: String) -> Bool { return uuid ~= "[A-F0-9]{8}-(?:[A-F0-9]{4}-){3}[A-Z0-9]{12}" }

  /**
  objectWithUUID:context:

  :param: uuid String
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  class func objectWithUUID(uuid: String, context: NSManagedObjectContext) -> Self? {
    if isValidUUID(uuid) && existingObjectWithUUID(uuid, context: context) == nil {
      let modelObject = self.init(context: context)
      modelObject.primitiveUUID = uuid
      return modelObject
    } else { return nil }
  }

  /**
  existingObjectWithUUID:context:

  :param: uuid String
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  class func existingObjectWithUUID(uuid: String, context: NSManagedObjectContext) -> Self? {
    if isValidUUID(uuid) { return findFirstByAttribute("uuid", withValue: uuid, context: context) } else { return nil }
  }

  /**
  importObjectFromData:context:

  :param: data [String:AnyObject]
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  class func importObjectFromData(data: [String:AnyObject], context: NSManagedObjectContext) -> Self? {
    if let uuid = data["uuid"] as? String {
      if let object = existingObjectWithUUID(uuid, context: context) {
        object.updateWithData(data)
        return object
      } else if let object = objectWithUUID(uuid, context: context) {
        object.updateWithData(data)
        return object
      } else {
        return nil
      }
    } else {
      let object = self.init(context: context)
      object.updateWithData(data)
      return object
    }
  }

  /**
  importObjectsFromData:context:

  :param: data AnyObject
  :param: context NSManagedObjectContext

  :returns: [ModelObject]
  */
  class func importObjectsFromData(data: AnyObject, context: NSManagedObjectContext) -> [ModelObject] {
    if let dataArray = data as? [[String:AnyObject]] {
      return compressed(dataArray.map{self.importObjectFromData($0, context: context)})
    } else { return [] }
  }

  /**
  findFirstByAttribute:withValue:context:

  :param: attribute String
  :param: value AnyObject
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  class func findFirstByAttribute(attribute: String,
                        withValue value: AnyObject,
                          context: NSManagedObjectContext) -> Self?
  {
    let predicate = NSPredicate(format: "%K == %@", argumentArray: [attribute, value])
    let request = NSFetchRequest(entityName: entityName(), predicate: predicate)
    request.fetchLimit = 1

    var error: NSError?
    if let results = context.executeFetchRequest(request, error: &error), let object = results.first as? ModelObject {
      return unsafeBitCast(object, self)
    }

    return nil
  }

  /**
  allValuesForAttribute:context:

  :param: attribute String
  :param: context NSManagedObjectContext

  :returns: [AnyObject]
  */
  class func allValuesForAttribute(attribute: String, context: NSManagedObjectContext) -> [AnyObject] {
    let request = NSFetchRequest(entityName: entityName())
    request.resultType = .DictionaryResultType
    request.returnsDistinctResults = true
    request.propertiesToFetch = [attribute]

    var error: NSError?
    if let results = context.executeFetchRequest(request, error: &error) {
      return results
    } else {
      MSHandleError(error)
      return []
    }
  }

  /**
  findFirstMatchingPredicate:context:

  :param: predicate NSPredicate
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  class func findFirstMatchingPredicate(predicate: NSPredicate, context: NSManagedObjectContext) -> Self? {
    if let object = findAllMatchingPredicate(predicate, context: context).first {
      return unsafeBitCast(object, self)
    } else { return nil }
  }

  /**
  findAllMatchingPredicate:context:

  :param: predicate NSPredicate
  :param: context NSManagedObjectContext

  :returns: [Self]
  */
  class func findAllMatchingPredicate(predicate: NSPredicate, context: NSManagedObjectContext) -> [ModelObject] {
    let request = NSFetchRequest(entityName: entityName(), predicate: predicate)
    var error: NSError?
    if let results = context.executeFetchRequest(request, error: &error) as? [ModelObject] {
      return results
    } else {
      MSHandleError(error)
      return []
    }
  }

  /**
  findAllInContext:

  :param: context NSManagedObjectContext

  :returns: [ModelObject]
  */
  class func findAllInContext(context: NSManagedObjectContext) -> [ModelObject] {
    let request = NSFetchRequest(entityName: entityName())
    var error: NSError?
    if let results = context.executeFetchRequest(request, error: &error) as? [ModelObject] {
      return results
    } else {
      MSHandleError(error)
      return []
    }
  }

  /**
  findAllSortedBy:ascending:context:

  :param: sortBy String
  :param: ascending Bool
  :param: context NSManagedObjectContext

  :returns: [ModelObject]
  */
  class func findAllSortedBy(sortBy: String, ascending: Bool, context: NSManagedObjectContext) -> [ModelObject] {
    let request = NSFetchRequest(entityName: entityName())
    request.sortDescriptors = ",".split(sortBy).map{NSSortDescriptor(key: $0, ascending: ascending)}
    var error: NSError?
    if let results = context.executeFetchRequest(request, error: &error) as? [ModelObject] {
      return results
    } else {
      MSHandleError(error)
      return []
    }
  }

  /**
  countOfObjectsInContext:

  :param: context NSManagedObjectContext

  :returns: Int
  */
  class func countOfObjectsInContext(context: NSManagedObjectContext) -> Int {
    let request = NSFetchRequest(entityName: entityName())
    var error: NSError?
    let result = context.countForFetchRequest(request, error: &error)
    MSHandleError(error)
    return result
  }

  /**
  countOfObjectsMatchingPredicate:context:

  :param: predicate NSPredicate
  :param: context NSManagedObjectContext

  :returns: Int
  */
  class func countOfObjectsMatchingPredicate(predicate: NSPredicate, context: NSManagedObjectContext) -> Int {
    let request = NSFetchRequest(entityName: entityName(), predicate: predicate)
    var error: NSError?
    let result = context.countForFetchRequest(request, error: &error)
    MSHandleError(error)
    return result
  }

  /**
  deleteAllMatchingPredicate:context:

  :param: predicate NSPredicate
  :param: context NSManagedObjectContext
  */
  class func deleteAllMatchingPredicate(predicate: NSPredicate, context: NSManagedObjectContext) {
    context.deleteObjects(Set(findAllMatchingPredicate(predicate, context: context)))
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
    let request = NSFetchRequest(entityName: entityName(), predicate: predicate)
    request.propertiesToGroupBy = ",".split(groupBy)
    request.sortDescriptors = ",".split(sortBy).map{NSSortDescriptor(key: $0, ascending: ascending)}
    return NSFetchedResultsController(fetchRequest: request,
                                      managedObjectContext: context,
                                      sectionNameKeyPath: nil,
                                      cacheName: nil)
  }

  /**
  fetchAllGroupedBy:sortedBy:context:

  :param: groupBy String
  :param: sortBy String
  :param: context NSManagedObjectContext

  :returns: NSFetchedResultsController
  */
  class func fetchAllGroupedBy(groupBy: String,
                      sortedBy sortBy: String,
                       context: NSManagedObjectContext) -> NSFetchedResultsController
  {
    let request = NSFetchRequest(entityName: entityName())
    request.propertiesToGroupBy = ",".split(groupBy)
    request.sortDescriptors = ",".split(sortBy).map{NSSortDescriptor(key: $0, ascending: true)}
    return NSFetchedResultsController(fetchRequest: request,
                                      managedObjectContext: context,
                                      sectionNameKeyPath: nil,
                                      cacheName: nil)
  }

  /**
  existingObjectForEntity:withUUID:context:

  :param: entityName String
  :param: uuid String
  :param: context NSManagedObjectContext

  :returns: ModelObject?
  */
  class func existingObjectForEntity(entityName: String,
                            withUUID uuid: String,
                             context: NSManagedObjectContext) -> ModelObject?
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
  :param: context NSManagedObjectContext

  :returns: ModelObject?
  */
  class func objectForEntity(entityName: String,
                    withUUID uuid: String,
                      ofType type: ModelObject.Type,
                     context: NSManagedObjectContext) -> ModelObject?
  {
    var model: ModelObject?
    if isValidUUID(uuid) {
      if existingObjectForEntity(entityName, withUUID: uuid, context: context) != nil {
        MSRaiseException(NSInvalidArgumentException, "object already exists with specified uuid")
      } else {
        if let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context) {
          model = type(context: context)
          model?.setPrimitiveValue(uuid, forKey: "uuid")
        }
      }
    } else { MSRaiseException(NSInvalidArgumentException, "invalid uuid") }
    return model
  }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  func updateWithData(data: [String:AnyObject]) {}

  /**
  initWithContext:

  :param: context NSManagedObjectContext
  */
  required init(context: NSManagedObjectContext, insert: Bool = true) {
    super.init(entity: self.dynamicType.entityDescription(context)!, insertIntoManagedObjectContext: insert ? context : nil)
  }

  /**
  initWithUuid:context:

  :param: uuid String
  :param: context NSManagedObjectContext
  */
  convenience init?(uuid: String, context: NSManagedObjectContext) {
    self.init(context: context, insert: false)
    if self.dynamicType.existingObjectWithUUID(uuid, context: context) == nil && self.dynamicType.isValidUUID(uuid) {
      context.insertObject(self)
      primitiveUUID = uuid
    } else { return nil }
  }

  /**
  initWithData:context:

  :param: data [String AnyObject]
  :param: context NSManagedObjectContext
  */
  convenience init?(data: [String:AnyObject], context: NSManagedObjectContext) {
    if let uuid = data["uuid"] as? String {
      self.init(uuid: uuid, context: context)
    } else {
      self.init(context: context)
    }
    updateWithData(data)
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
  :param: data [String:AnyObject]
  :param: context NSManagedObjectContext

  :returns: ModelObject?
  */
  class func importObjectForEntity(entityName: String,
                           forType type: ModelObject.Type,
                          fromData data: [String:AnyObject],
                           context: NSManagedObjectContext) -> ModelObject?
  {
    var model: ModelObject?
    if let uuid = data["uuid"] as? String {
      model = existingObjectForEntity(entityName, withUUID: uuid, context: context)
      if model == nil { model = objectForEntity(entityName, withUUID: uuid, ofType: type, context: context) }
      model?.updateWithData(data)
    }
    return model
  }

  /**
  attributeValueIsDefault:

  :param: attribute String

  :returns: Bool
  */
  func attributeValueIsDefault(attribute: String) -> Bool {
    if let value: AnyObject = valueForKey(attribute),
      let defaultValue: AnyObject = defaultValueForAttribute(attribute) where value.isEqual(defaultValue) { return true }
    else {
      return valueForKey(attribute) == nil && defaultValueForAttribute(attribute) == nil
    }
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
    return JSONDictionary().JSONString.stringByReplacingOccurrencesOfString("\\/", withString: "\\")
  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  func JSONDictionary() -> MSDictionary { return MSDictionary(object: uuid, forKey: "uuid") }

  var JSONObject: AnyObject { return JSONDictionary().JSONObject }

}

/// MARK: - Convenience functions
////////////////////////////////////////////////////////////////////////////////

func sortedByName<T: Nameable>(array: [T]) -> [T] { return array.sorted{$0.0.name < $0.1.name} }
func sortedByName<T: Nameable>(array: [T]?) -> [T]? { return array?.sorted{$0.0.name < $0.1.name} }
func sortByName<T: Nameable>(inout array: [T]) { array.sort{$0.0.name < $0.1.name} }
func sortByName<T: Nameable>(inout array: [T]?) { array?.sort{$0.0.name < $0.1.name} }


