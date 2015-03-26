//
//  IRCodeSet.swift
//  Remote
//
//  Created by Jason Cardwell on 9/27/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(IRCodeSet)
final public class IRCodeSet: IndexedEditableModelObject, ModelCollection, ModelCollectionItem {


  @NSManaged public var devices: Set<ComponentDevice>
  @NSManaged public var codes: Set<IRCode>
  @NSManaged public var manufacturer: Manufacturer

  public typealias ItemType = IRCode
  public var items: [ItemType] { get { return Array(codes) } set { codes = Set(newValue) } }
  public func itemWithIndex(index: PathModelIndex) -> ItemType? { return findByIndex(codes, index) }

  public typealias CollectionType = Manufacturer
  public var collection: CollectionType? { get { return manufacturer } set { if newValue != nil { manufacturer = newValue! } } }

  override public var pathIndex: PathModelIndex { return manufacturer.pathIndex + "\(name)" }

  /**
  modelWithIndex:context:

  :param: index PathModelIndex
  :param: context NSManagedObjectContext

  :returns: IRCodeSet?
  */
  override public class func modelWithIndex(index: PathModelIndex, context: NSManagedObjectContext) -> IRCodeSet? {
    return Manufacturer.itemWithIndex(index, context: context)
  }


  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)

    updateRelationshipFromData(data, forKey: "codes")
    updateRelationshipFromData(data, forKey: "devices")
    updateRelationshipFromData(data, forKey: "manufacturer")
  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  override public func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    appendValue(manufacturer.index.rawValue, forKey: "manufacturer.index", ifNotDefault: false, toDictionary: dictionary)
    appendValueForKeyPath("codes.JSONDictionary", forKey: "codes", toDictionary: dictionary)
    appendValueForKeyPath("devices.commentedUUID", forKey: "devices", toDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()
    
    return dictionary
  }


}
