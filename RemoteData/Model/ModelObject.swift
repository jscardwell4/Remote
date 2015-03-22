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

  /**
  initWithEntity:insertIntoManagedObjectContext:

  :param: entity NSEntityDescription
  :param: context NSManagedObjectContext?
  */
  override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
    super.init(entity: entity, insertIntoManagedObjectContext: context)
  }

  /**
  initWithContext:

  :param: context NSManagedObjectContext
  */
  required init(context: NSManagedObjectContext?) {
    super.init(entity: self.dynamicType.entityDescription, insertIntoManagedObjectContext: context)
  }

  /**
  initWithUuid:context:

  :param: uuid String
  :param: context NSManagedObjectContext
  */
  init?(uuid: String, context: NSManagedObjectContext) {
    super.init(entity: self.dynamicType.entityDescription, insertIntoManagedObjectContext: nil)
    if self.dynamicType.existingObjectWithUUID(uuid, context: context) == nil && self.dynamicType.isValidUUID(uuid) {
      context.insertObject(self)
      setPrimitiveValue(uuid, forKey: "uuid")
    } else { return nil }
  }

  /**
  initWithData:context:

  :param: data [String AnyObject]
  :param: context NSManagedObjectContext
  */
  required init?(data: [String:AnyObject], context: NSManagedObjectContext) {
    if let uuid = data["uuid"] as? String {
      super.init(entity: self.dynamicType.entityDescription, insertIntoManagedObjectContext: nil)
      if self.dynamicType.existingObjectWithUUID(uuid, context: context) == nil && self.dynamicType.isValidUUID(uuid) {
        context.insertObject(self)
        setPrimitiveValue(uuid, forKey: "uuid")
      } else { return nil }
    } else {
      super.init(entity: self.dynamicType.entityDescription, insertIntoManagedObjectContext: context)
    }
    updateWithData(data)
  }

  private(set) var uuid: String {
    get {
      willAccessValueForKey("uuid")
      let uuid = primitiveValueForKey("uuid") as? String
      didAccessValueForKey("uuid")
      return uuid ?? ""
    }
    set {
      if primitiveValueForKey("uuid") == nil {
        willChangeValueForKey("uuid")
        setPrimitiveValue(newValue, forKey: "uuid")
        didChangeValueForKey("uuid")
      }
    }
  }

  class var entityDescription: NSEntityDescription {
    let entities = DataManager.stack.managedObjectModel.entities as! [NSEntityDescription]
    if let entity = findFirst(entities, {$0.managedObjectClassName == self.className()}) { return  entity }
    else { assertionFailure("unable to locate entity for class '\(className())'") }
  }

  /**
  entityName:

  :param: context NSManagedObjectContext = DataManager.rootContext

  :returns: String
  */
  class var entityName: String { return entityDescription.name! }

  /**
  isValidUUID:

  :param: uuid String

  :returns: Bool
  */
  class func isValidUUID(uuid: String) -> Bool { return uuid ~= "[A-F0-9]{8}-(?:[A-F0-9]{4}-){3}[A-Z0-9]{12}" }

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
  fetchOrImportObjectWithData:context:

  :param: data [String:AnyObject]
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  class func fetchOrImportObjectWithData(data: [String:AnyObject], context: NSManagedObjectContext) -> Self? {
    if let object = fetchObjectWithData(data, context: context) { return object }
    else { return self(data: data, context: context) }
  }

  /**
  fetchObjectWithData:context:

  :param: data [String AnyObject]
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  class func fetchObjectWithData(data: [String:AnyObject], context: NSManagedObjectContext) -> Self? {
    if let uuid = data["uuid"] as? String, object = existingObjectWithUUID(uuid, context: context) { return object }
    else { return nil }
  }

  /**
  updateRelationshipFromData:forKey:ofType:

  :param: data [String AnyObject]
  :param: key String
  :param: type ModelObject.Type

  :returns: Bool
  */
  private func updateRelationshipFromData(data: [String:AnyObject],
                                   forKey key: String,
                                lookupKey: String? = nil,
                                   ofType type: ModelObject.Type) -> Bool
  {
    if let moc = managedObjectContext,
      objectData = data[lookupKey ?? key.dashcaseString] as? [String:AnyObject],
      object = type.fetchOrImportObjectWithData(objectData, context: moc)
    {
      setValue(object, forKey: key)
      return true
    } else { return false }
  }

  /**
  updateToManyRelationshipFromData:forKey:ofType:

  :param: data [String AnyObject]
  :param: key String
  :param: type ModelObject.Type

  :returns: Bool
  */
  private func updateToManyRelationshipFromData(data: [String:AnyObject],
                                         forKey key: String,
                                      lookupKey: String? = nil,
                                         ofType type: ModelObject.Type,
                                        ordered: Bool = false) -> Bool
  {
    if let moc = managedObjectContext, objectData = data[lookupKey ?? key.dashcaseString] as? [[String:AnyObject]] {
      let objects = type.importObjectsFromData(objectData, context: moc)
      setValue(ordered ? NSOrderedSet(array: objects) : NSSet(array: objects), forKey: key)
      return true
    } else { return false }
  }

  /**
  updateRelationshipFromData:forKey:

  :param: data [String AnyObject]
  :param: key String

  :returns: Bool
  */
  func updateRelationshipFromData(data: [String:AnyObject], forKey key: String, lookupKey: String? = nil) -> Bool {
    if let relationshipDescription = entity.relationshipsByName[key] as? NSRelationshipDescription,
      relatedTypeName = relationshipDescription.destinationEntity?.managedObjectClassName,
      relatedType = NSClassFromString(relatedTypeName) as? ModelObject.Type
    {
      return relationshipDescription.toMany
        ? updateToManyRelationshipFromData(data,
                                    forKey: key,
                                 lookupKey: lookupKey,
                                    ofType: relatedType,
                                   ordered: relationshipDescription.ordered)
        : updateRelationshipFromData(data, forKey: key, lookupKey: lookupKey, ofType: relatedType)
    } else { return false }
  }

  /**
  importObjectsFromData:context:

  :param: data AnyObject
  :param: context NSManagedObjectContext

  :returns: [ModelObject]
  */
  class func importObjectsFromData(data: AnyObject, context: NSManagedObjectContext) -> [ModelObject] {
    if let dataArray = data as? [[String:AnyObject]] {
      return compressed(dataArray.map{self.fetchOrImportObjectWithData($0, context: context)})
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
    let request = NSFetchRequest(entityName: entityName, predicate: predicate)
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
    let request = NSFetchRequest(entityName: entityName)
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
    let request = NSFetchRequest(entityName: entityName, predicate: predicate)
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
    let request = NSFetchRequest(entityName: entityName)
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
    let request = NSFetchRequest(entityName: entityName)
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
    let request = NSFetchRequest(entityName: entityName)
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
    let request = NSFetchRequest(entityName: entityName, predicate: predicate)
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
    let request = NSFetchRequest(entityName: entityName, predicate: predicate)
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
    let request = NSFetchRequest(entityName: entityName)
    request.propertiesToGroupBy = ",".split(groupBy)
    request.sortDescriptors = ",".split(sortBy).map{NSSortDescriptor(key: $0, ascending: true)}
    return NSFetchedResultsController(fetchRequest: request,
                                      managedObjectContext: context,
                                      sectionNameKeyPath: nil,
                                      cacheName: nil)
  }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  func updateWithData(data: [String:AnyObject]) {}


  /** awakeFromInsert */
  override func awakeFromInsert() {
    super.awakeFromInsert()
    uuid = MSNonce()
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

extension ModelObject: Equatable {}
func ==(lhs: ModelObject, rhs: ModelObject) -> Bool { return lhs.isEqual(rhs) }

extension ModelObject: Hashable {}
