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

@objc(ModelObject)
public class ModelObject: NSManagedObject, Model, MSJSONExport, Hashable, Equatable {


  /// MARK: - Initializers
  ////////////////////////////////////////////////////////////////////////////////

  /**
  initWithEntity:insertIntoManagedObjectContext:

  :param: entity NSEntityDescription
  :param: context NSManagedObjectContext?
  */
  override public init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
    super.init(entity: entity, insertIntoManagedObjectContext: context)
    setPrimitiveValue(MSNonce(), forKey: "uuid")
 }

  /**
  initWithContext:

  :param: context NSManagedObjectContext
  */
  public init(context: NSManagedObjectContext?) {
    super.init(entity: self.dynamicType.entityDescription, insertIntoManagedObjectContext: context)
    setPrimitiveValue(MSNonce(), forKey: "uuid")
 }

  /**
  initWithUuid:context:

  :param: uuid String
  :param: context NSManagedObjectContext
  */
  public init?(uuid: String, context: NSManagedObjectContext) {
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
  required public init?(data: [String:AnyObject], context: NSManagedObjectContext) {
    if let uuid = data["uuid"] as? String {
      super.init(entity: self.dynamicType.entityDescription, insertIntoManagedObjectContext: nil)
      if self.dynamicType.objectWithUUID(uuid, context: context) == nil && self.dynamicType.isValidUUID(uuid) {
        context.insertObject(self)
        setPrimitiveValue(uuid, forKey: "uuid")
      } else { return nil }
    } else {
      super.init(entity: self.dynamicType.entityDescription, insertIntoManagedObjectContext: context)
      setPrimitiveValue(MSNonce(), forKey: "uuid")
    }
    updateWithData(data)
  }


  // MARK: - Properties


  /**
  The one property all core data entities need to have in the model to be representable as a `ModelObject`. The value
  of an object's `uuid` attribute serves as a unique identifier for the lifetime of the object.
  */
  private(set) public var uuid: String {
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

  /** Accessor for the model's `uuid` as a `UUIDIndex` */
  public var index: ModelIndex {
    if self is PathIndexedModel { return (self as! PathIndexedModel).pathIndex }
    else if let uuidIndex = UUIDIndex(rawValue: uuid) { return uuidIndex }
    else { fatalError("unable to generate uuid index for model, is uuid nil?") }
  }

  /** Entity description retrieved from the managed object model */
  public class var entityDescription: NSEntityDescription {
    let entities = DataManager.stack.managedObjectModel.entities as! [NSEntityDescription]
    if let entity = findFirst(entities, {$0.managedObjectClassName == self.className()}) { return  entity }
    else { fatalError("unable to locate entity for class '\(className())'") }
  }

  /**
  entityName:

  :param: context NSManagedObjectContext = DataManager.rootContext

  :returns: String
  */
  public class var entityName: String { return entityDescription.name! }
  public var entityName: String { return self.dynamicType.entityName }

  /// MARK: - Validation
  ////////////////////////////////////////////////////////////////////////////////


  /**
  isValidUUID:

  :param: uuid String

  :returns: Bool
  */
  public class func isValidUUID(uuid: String) -> Bool { return uuid ~= "[A-F0-9]{8}-(?:[A-F0-9]{4}-){3}[A-Z0-9]{12}" }


  /// MARK: - Fetching existing objects
  ////////////////////////////////////////////////////////////////////////////////


  /**
  objectWithUUID:context:

  :param: uuid String
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  public class func objectWithUUID(uuid: String, context: NSManagedObjectContext) -> Self? {
    if isValidUUID(uuid) { return objectWithValue(uuid, forAttribute: "uuid", context: context) } else { return nil }
  }

  /**
  objectWithIndex:context:

  :param: index ModelIndex
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  public class func objectWithIndex(index: UUIDIndex, context: NSManagedObjectContext) -> Self? {
    return objectWithUUID(index.rawValue, context: context)
  }

  /**
  objectWithIndex:context:

  :param: index PathIndex
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  @objc(objectWithPathIndex:context:)
  public class func objectWithIndex(index: PathIndex, context: NSManagedObjectContext) -> Self? {
    return nil
  }

  /**
  Returns the existing object matched by `data` or nil if no match exists

  :param: data [String AnyObject]
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  public class func objectWithData(data: [String:AnyObject], context: NSManagedObjectContext) -> Self? {
    if let uuid = data["uuid"] as? String, object = objectWithUUID(uuid, context: context) { return object }
    else if let rawIndex = data["index"] as? String {
      if let index = UUIDIndex(rawValue: rawIndex), object = objectWithIndex(index, context: context) {
//        println("object for index \(index.rawValue):\n\(object)")
        return object
      } else if let index = PathIndex(rawValue: rawIndex), object = objectWithIndex(index, context: context) {
//        println("object for index \(index.rawValue):\n\(object)")
        return object
      } else {
//        println("failed to locate object with index \(rawIndex)")
        return nil
      }
    }
    else { return nil }
  }

  /**
  Returns the first object found with a matching `value` for `attribute` or nil if none exists

  :param: value AnyObject
  :param: attribute String
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  public class func objectWithValue(value: AnyObject, forAttribute attribute: String, context: NSManagedObjectContext) -> Self? {
    return objectMatchingPredicate(NSPredicate(format: "%K == %@", argumentArray: [attribute, value]), context: context)
  }

  /**
  objectMatchingPredicate:context:

  :param: predicate NSPredicate
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  public class func objectMatchingPredicate(predicate: NSPredicate, context: NSManagedObjectContext) -> Self? {
    return typeCast(objectsMatchingPredicate(predicate, fetchLimit: 1, context: context).first, self)
  }

  /**
  objectsMatchingPredicate:fetchLimit:sortBy:ascending:context:error:

  :param: predicate NSPredicate
  :param: fetchLimit Int = 0
  :param: sortBy String? = nil
  :param: ascending Bool = true
  :param: context NSManagedObjectContext
  :param: error NSErrorPointer = nil

  :returns: [ModelObject]
  */
  public class func objectsMatchingPredicate(predicate: NSPredicate,
                                  fetchLimit: Int = 0,
                                      sortBy: String? = nil,
                                   ascending: Bool = true,
                                     context: NSManagedObjectContext,
                                       error: NSErrorPointer = nil) -> [ModelObject]
  {
    let request = NSFetchRequest(entityName: entityName, predicate: predicate)
    request.fetchLimit = fetchLimit
    if sortBy != nil {
      request.sortDescriptors = ",".split(sortBy!).map{NSSortDescriptor(key: $0, ascending: ascending)}
    }
    return context.executeFetchRequest(request, error: error) as? [ModelObject] ?? []
  }

  /**
  objectsInContext:sortBy:ascending:

  :param: context NSManagedObjectContext
  :param: sortBy String? = nil
  :param: ascending Bool = true

  :returns: [ModelObject]
  */
  public class func objectsInContext(context: NSManagedObjectContext,
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
  public class func objectsInContext(context: NSManagedObjectContext,
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
  public class func allValuesForAttribute(attribute: String, context: NSManagedObjectContext) -> [AnyObject] {
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
  public class func importObjectWithData(data: [String:AnyObject], context: NSManagedObjectContext) -> Self? {
    if let object = objectWithData(data, context: context) { return object }
    else { return self(data: data, context: context) }
  }

  /**
  importObjectsFromData:context:

  :param: data AnyObject
  :param: context NSManagedObjectContext

  :returns: [ModelObject]
  */
  public class func importObjectsFromData(data: AnyObject, context: NSManagedObjectContext) -> [ModelObject] {
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
  public func updateWithData(data: [String:AnyObject]) {}

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
  relatedObjectWithData:forKey:lookupKey:

  :param: data [String AnyObject]
  :param: key String
  :param: lookupKey String? = nil

  :returns: T?
  */
  public func relatedObjectWithData<T:ModelObject>(data: [String:AnyObject], forKey key: String, lookupKey: String? = nil) -> T? {
    if let relationshipDescription = entity.relationshipsByName[key] as? NSRelationshipDescription,
      relatedTypeName = relationshipDescription.destinationEntity?.managedObjectClassName,
      relatedType = NSClassFromString(relatedTypeName) as? ModelObject.Type,
      relatedObjectData = data[lookupKey ?? key.dashcaseString] as? [String:AnyObject],
      moc = managedObjectContext
    {
      let relatedObject = relatedType.objectWithData(relatedObjectData, context: moc)
//      println("relatedObject:n\(relatedObject ?? nil)")
      return relatedObject as? T
    } else { return nil }
  }

  /**
  updateRelationshipFromData:forKey:

  :param: data [String AnyObject]
  :param: key String

  :returns: Bool
  */
  public func updateRelationshipFromData(data: [String:AnyObject], forKey key: String, lookupKey: String? = nil) -> Bool {
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
  public class func countInContext(context: NSManagedObjectContext, predicate: NSPredicate = ∀"TRUEPREDICATE") -> Int {
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
  public class func deleteObjectsInContext(context: NSManagedObjectContext) {
    deleteObjectsMatchingPredicate(∀"TRUEPREDICATE", context: context)
  }

  /**
  deleteObjectsMatchingPredicate:context:

  :param: predicate NSPredicate
  :param: context NSManagedObjectContext
  */
  public class func deleteObjectsMatchingPredicate(predicate: NSPredicate, context: NSManagedObjectContext) {
    context.deleteObjects(Set(objectsMatchingPredicate(predicate, context: context)))
  }


  /// MARK: - Exporting
  ////////////////////////////////////////////////////////////////////////////////


  /**
  attributeValueIsDefault:

  :param: attribute String

  :returns: Bool
  */
  public func attributeValueIsDefault(attribute: String) -> Bool {
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
  public func appendValueForKey(key: String,
                  forKey: String? = nil,
            ifNotDefault nonDefault: Bool = false,
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
  public func appendValueForKeyPath(keypath: String, forKey key: String? = nil, toDictionary dictionary: MSDictionary) {
    dictionary[(key ?? keypath).dashcaseString] = NSNull.collectionSafeValue(valueForKeyPath(keypath))
  }

  /**
  appendValueForKeyPath:forKey:inDictionary:

  :param: keypath String
  :param: key String
  :param: dictionary MSDictionary
  */
  public func appendValue(value: AnyObject?,
            forKey key: String,
      ifNotDefault nonDefault: Bool = false,
 toDictionary dictionary: MSDictionary)
  {
    if !(nonDefault && attributeValueIsDefault(key)) && value != nil { dictionary[key.dashcaseString] = value! }
  }

  public var JSONString: String {
    return JSONDictionary().JSONString.stringByReplacingOccurrencesOfString("\\/", withString: "\\")
  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  public func JSONDictionary() -> MSDictionary { return MSDictionary(object: uuid, forKey: "uuid") }

  public var JSONObject: AnyObject { return JSONDictionary().JSONObject }

  override public var description: String {
    return "\(className):\n\t" + "\n\t".join(
      "entity = \(entityName)",
      "index = \(index.rawValue)" + (self is PathIndexedModel ? "\n\tuuid = \(uuid)" : "")
    )
  }
}

/**
`Equatable` support for `ModelObject`

:param: lhs ModelObject
:param: rhs ModelObject

:returns: Bool
*/
public func ==(lhs: ModelObject, rhs: ModelObject) -> Bool { return lhs.isEqual(rhs) }
