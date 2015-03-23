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
class ModelObject: NSManagedObject, Model, MSJSONExport, Hashable, Equatable {


  /// MARK: - Initializers
  ////////////////////////////////////////////////////////////////////////////////

  /**
  initWithEntity:insertIntoManagedObjectContext:

  :param: entity NSEntityDescription
  :param: context NSManagedObjectContext?
  */
  override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
    super.init(entity: entity, insertIntoManagedObjectContext: context)
    setPrimitiveValue(uuid, forKey: "uuid")
 }

  /**
  initWithContext:

  :param: context NSManagedObjectContext
  */
  init(context: NSManagedObjectContext?) {
    super.init(entity: self.dynamicType.entityDescription, insertIntoManagedObjectContext: context)
    setPrimitiveValue(uuid, forKey: "uuid")
 }

  /**
  initWithUuid:context:

  :param: uuid String
  :param: context NSManagedObjectContext
  */
  init?(uuid: String, context: NSManagedObjectContext) {
    super.init(entity: self.dynamicType.entityDescription, insertIntoManagedObjectContext: nil)
    if self.dynamicType.objectWithUUID(uuid, context: context) == nil && self.dynamicType.isValidUUID(uuid) {
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
      if self.dynamicType.objectWithUUID(uuid, context: context) == nil && self.dynamicType.isValidUUID(uuid) {
        context.insertObject(self)
        setPrimitiveValue(uuid, forKey: "uuid")
      } else { return nil }
    } else {
      super.init(entity: self.dynamicType.entityDescription, insertIntoManagedObjectContext: context)
    }
    updateWithData(data)
  }
  

  // MARK: - Properties


  /** 
  The one property all core data entities need to have in the model to be representable as a `ModelObject`. The value
  of an object's `uuid` attribute serves as a unique identifier for the lifetime of the object.
  */
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


  /// MARK: - Validation
  ////////////////////////////////////////////////////////////////////////////////


  /**
  isValidUUID:

  :param: uuid String

  :returns: Bool
  */
  class func isValidUUID(uuid: String) -> Bool { return uuid ~= "[A-F0-9]{8}-(?:[A-F0-9]{4}-){3}[A-Z0-9]{12}" }


  /// MARK: - Fetching existing objects
  ////////////////////////////////////////////////////////////////////////////////


  /**
  objectWithUUID:context:

  :param: uuid String
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  class func objectWithUUID(uuid: String, context: NSManagedObjectContext) -> Self? {
    if isValidUUID(uuid) { return objectWithValue(uuid, forAttribute: "uuid", context: context) } else { return nil }
  }

  /**
  Returns the existing object matched by `data` or nil if no match exists

  :param: data [String AnyObject]
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  class func objectWithData(data: [String:AnyObject], context: NSManagedObjectContext) -> Self? {
    if let uuid = data["uuid"] as? String, object = objectWithUUID(uuid, context: context) { return object }
    else { return nil }
  }

  /**
  Returns the first object found with a matching `value` for `attribute` or nil if none exists

  :param: value AnyObject
  :param: attribute String
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  class func objectWithValue(value: AnyObject, forAttribute attribute: String, context: NSManagedObjectContext) -> Self? {
    return objectMatchingPredicate(NSPredicate(format: "%K == %@", argumentArray: [attribute, value]), context: context)
  }

  /**
  objectMatchingPredicate:context:

  :param: predicate NSPredicate
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  class func objectMatchingPredicate(predicate: NSPredicate, context: NSManagedObjectContext) -> Self? {
    return typeCast(objectsMatchingPredicate(predicate, fetchLimit: 1, context: context).first, self)
  }

  /**
  objectsMatchingPredicate:fetchLimit:sortBy:ascending:context:

  :param: predicate NSPredicate
  :param: fetchLimit Int = 0
  :param: sortBy String? = nil
  :param: ascending Bool = true
  :param: context NSManagedObjectContext

  :returns: [ModelObject]
  */
  class func objectsMatchingPredicate(predicate: NSPredicate,
                           fetchLimit: Int = 0,
                             sortBy: String? = nil,
                            ascending: Bool = true,
                              context: NSManagedObjectContext) -> [ModelObject]
  {
    let request = NSFetchRequest(entityName: entityName, predicate: predicate)
    request.fetchLimit = fetchLimit
    if sortBy != nil {
      request.sortDescriptors = ",".split(sortBy!).map{NSSortDescriptor(key: $0, ascending: ascending)}
    }
    var error: NSError?
    let results = context.executeFetchRequest(request, error: &error) as? [ModelObject]
    MSHandleError(error)
    return results ?? []
  }

  /**
  objectsInContext:sortBy:ascending:

  :param: context NSManagedObjectContext
  :param: sortBy String? = nil
  :param: ascending Bool = true

  :returns: [ModelObject]
  */
  class func objectsInContext(context: NSManagedObjectContext,
                       sortBy: String? = nil,
                    ascending: Bool = true) -> [ModelObject]
  {
    return objectsMatchingPredicate(∀"TRUEPREDICATE", sortBy: sortBy, ascending: ascending, context: context)
  }

  /**
  objectsInContext:groupedBy:withPredicate:sortedBy:ascending:

  :param: context NSManagedObjectContext
  :param: groupBy String
  :param: predicate NSPredicate = (default)
  :param: sortBy String
  :param: ascending Bool = true

  :returns: NSFetchedResultsController
  */
  class func objectsInContext(context: NSManagedObjectContext,
                    groupedBy groupBy: String,
                withPredicate predicate: NSPredicate = ∀"TRUEPREDICATE",
                     sortedBy sortBy: String,
                    ascending: Bool = true) -> NSFetchedResultsController
  {
    let request = NSFetchRequest(entityName: entityName, predicate: predicate)
    request.propertiesToGroupBy = ",".split(groupBy)
    request.sortDescriptors = ",".split(sortBy).map{NSSortDescriptor(key: $0, ascending: ascending)}
    return NSFetchedResultsController(fetchRequest: request,
      managedObjectContext: context,
      sectionNameKeyPath: nil,
      cacheName: nil)
  }

  /// MARK: - Fetching attribute values for existing objects
  ////////////////////////////////////////////////////////////////////////////////


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
    let results = context.executeFetchRequest(request, error: &error)
    MSHandleError(error)
    return results ?? []
  }
  

  /// MARK: - Importing
  ////////////////////////////////////////////////////////////////////////////////


  /**
  Attempts to fetch an existing object using `data` and if that fails a new object is created

  :param: data [String:AnyObject]
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  class func importObjectWithData(data: [String:AnyObject], context: NSManagedObjectContext) -> Self? {
    if let object = objectWithData(data, context: context) { return object }
    else { return self(data: data, context: context) }
  }

  /**
  importObjectsFromData:context:

  :param: data AnyObject
  :param: context NSManagedObjectContext

  :returns: [ModelObject]
  */
  class func importObjectsFromData(data: AnyObject, context: NSManagedObjectContext) -> [ModelObject] {
    if let dataArray = data as? [[String:AnyObject]] {
      return compressed(dataArray.map{self.importObjectWithData($0, context: context)})
    } else { return [] }
  }


  /// MARK: - Updating
  ////////////////////////////////////////////////////////////////////////////////


  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  func updateWithData(data: [String:AnyObject]) {}

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
      object = type.importObjectWithData(objectData, context: moc)
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


  /// MARK: - Counting
  ////////////////////////////////////////////////////////////////////////////////


  /**
  countInContext:predicate:

  :param: context NSManagedObjectContext
  :param: predicate NSPredicate

  :returns: Int
  */
  class func countInContext(context: NSManagedObjectContext, predicate: NSPredicate = ∀"TRUEPREDICATE") -> Int {
    let request = NSFetchRequest(entityName: entityName, predicate: predicate)
    var error: NSError?
    let result = context.countForFetchRequest(request, error: &error)
    MSHandleError(error)
    return result
  }


  /// MARK: - Deleting
  ////////////////////////////////////////////////////////////////////////////////


  /**
  deleteObjectsInContext:

  :param: context NSManagedObjectContext
  */
  class func deleteObjectsInContext(context: NSManagedObjectContext) {
    deleteObjectsMatchingPredicate(∀"TRUEPREDICATE", context: context)
  }

  /**
  deleteObjectsMatchingPredicate:context:

  :param: predicate NSPredicate
  :param: context NSManagedObjectContext
  */
  class func deleteObjectsMatchingPredicate(predicate: NSPredicate, context: NSManagedObjectContext) {
    context.deleteObjects(Set(objectsMatchingPredicate(predicate, context: context)))
  }


  /// MARK: - Exporting
  ////////////////////////////////////////////////////////////////////////////////


  /**
  attributeValueIsDefault:

  :param: attribute String

  :returns: Bool
  */
  func attributeValueIsDefault(attribute: String) -> Bool {
    if let value: AnyObject = valueForKey(attribute),
      let defaultValue: AnyObject = defaultValueForAttribute(attribute) where value.isEqual(defaultValue) { return true }
    else { return valueForKey(attribute) == nil && defaultValueForAttribute(attribute) == nil }
  }

  /**
  appendValueForKey:forKey:ifNotDefault:inDictionary:

  :param: key String
  :param: forKey String? = nil
  :param: nonDefault Bool = true
  :param: dictionary MSDictionary
  */
  func appendValueForKey(key: String,
                  forKey: String? = nil,
            ifNotDefault nonDefault: Bool = true,
            toDictionary dictionary: MSDictionary)
  {
    if !(nonDefault && attributeValueIsDefault(key)), let value: AnyObject = valueForKey(key) {
      dictionary[(forKey ?? key).dashcaseString] = value
    }
  }

  /**
  appendValueForKeyPath:forKey:inDictionary:

  :param: keypath String
  :param: key String
  :param: dictionary MSDictionary
  */
  func appendValueForKeyPath(keypath: String, forKey key: String? = nil, toDictionary dictionary: MSDictionary) {
    dictionary[(key ?? keypath).dashcaseString] = NSNull.collectionSafeValue(valueForKeyPath(keypath))
  }

  /**
  appendValueForKeyPath:forKey:inDictionary:

  :param: keypath String
  :param: key String
  :param: dictionary MSDictionary
  */
  func appendValue(value: AnyObject?,
            forKey key: String,
      ifNotDefault nonDefault: Bool = true,
 toDictionary dictionary: MSDictionary)
  {
    if !(attributeValueIsDefault(key) && nonDefault) && value != nil { dictionary[key.dashcaseString] = value! }
  }

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


/**
`Equatable` support for `ModelObject`

:param: lhs ModelObject
:param: rhs ModelObject

:returns: Bool
*/
func ==(lhs: ModelObject, rhs: ModelObject) -> Bool { return lhs.isEqual(rhs) }
