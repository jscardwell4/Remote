//
//  DataManager.swift
//  Remote
//
//  Created by Jason Cardwell on 12/19/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

////////////////////////////////////////////////////////////////////////////////
/// MARK: - Private globals
////////////////////////////////////////////////////////////////////////////////

/** URL for the user's persistent store */
private let databaseStoreURL: NSURL = {
  let fileManager = NSFileManager.defaultManager()
  var error: NSError?
  var url = fileManager.URLForDirectory(.ApplicationSupportDirectory,
                               inDomain: .UserDomainMask,
                      appropriateForURL: nil,
                                 create: true,
                                  error: &error)

  if MSHandleError(error, message: "failed to retrieve application support directory") { fatalError("aborting…") }

  url = url!.URLByAppendingPathComponent("com.moondeerstudios.Remote")

  fileManager.createDirectoryAtURL(url!, withIntermediateDirectories: true, attributes: nil, error: &error)

  if MSHandleError(error, message: "failed to create app directory under application support") { fatalError("aborting") }

  return url!.URLByAppendingPathComponent("Remote.sqlite")

}()

/** URL for the preloaded persistent store located in the bundle */
private let databaseBundleURL: NSURL! = NSBundle.mainBundle().URLForResource("Remote", withExtension: "sqlite")


/** The core data stack, if this is nil we may as well shutdown */
private let coreDataStack: CoreDataStack = {

  let modelURL = NSBundle.mainBundle().URLForResource("Remote", withExtension: "momd")
  if modelURL == nil { fatalError("failed to retrieve model url, aborting…") }

  let mom = NSManagedObjectModel(contentsOfURL: modelURL!)
  if mom == nil { fatalError("failed to instantiate model from model url, aborting…") }


  let stack = CoreDataStack(managedObjectModel: DataManager.augmentModel(mom!),
                            persistentStoreURL: databaseStoreURL,
                            options: [NSMigratePersistentStoresAutomaticallyOption: true,
                                      NSInferMappingModelAutomaticallyOption: true])
  if stack == nil { fatalError("failed to instantiate core data stack, aborting…") }

  return stack!

}()

private var databasePrepared = false

////////////////////////////////////////////////////////////////////////////////
/// MARK: - Data manager declaration
////////////////////////////////////////////////////////////////////////////////


@objc class DataManager {

  class func mainContext() -> NSManagedObjectContext { return coreDataStack.mainContext() }

  /** The primary, private-queue managed object context.  */
  class var rootContext: NSManagedObjectContext { return coreDataStack.rootContext }

  /**
  prepareDatabase:

  :param: completion (Void) -> Void
  */
  class func prepareDatabase(completion: ((Void) -> Void)? = nil) {

    if databasePrepared { completion?(); return }

    let userDefaults = NSUserDefaults.standardUserDefaults()
    let loadData = userDefaults.boolForKey("loadData")
    let replaceDatabase = userDefaults.boolForKey("replace")
    let fileManager = NSFileManager.defaultManager()

    let storeURL = databaseStoreURL

    let databaseStoreExists = databaseStoreURL.checkResourceIsReachableAndReturnError(nil)

    if databaseStoreExists && (loadData || replaceDatabase) {
      var error: NSError?
      fileManager.removeItemAtURL(storeURL, error: &error)
      if !MSHandleError(error) { MSLogDebug("previous database store has been removed") }
    }

    // Copy bundle resource to store destination if needed
    if !databaseStoreExists && replaceDatabase {
      var error: NSError?
      fileManager.copyItemAtURL(databaseBundleURL, toURL: storeURL, error: &error)
      if !MSHandleError(error) { MSLogDebug("bundle database store copied to destination successfully") }
    }

    databasePrepared = true

    completion?()

  }

  /**
  childContextOfType:

  :param: type NSManagedObjectConcurrencyType

  :returns: NSManagedObjectContext
  */
//  class func childContextOfType(type: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext {
//    let childContext = NSManagedObjectContext(concurrencyType: type)
//    switch type {
//      case .MainQueueConcurrencyType: childContext.parentContext = coreDataStack.mainContext
//      default: childContext.parentContext = coreDataStack.rootContext
//    }
//    return childContext
//  }

  /**
  childContextForContext:

  :param: context NSManagedObjectContext

  :returns: NSManagedObjectContext
  */
  class func childContextForContext(context: NSManagedObjectContext) -> NSManagedObjectContext {
    let childContext = NSManagedObjectContext(concurrencyType: context.concurrencyType)
    childContext.parentContext = context
    return childContext
  }

  /**
  saveContext:withBlock::propagate:nonBlocking:completion:

  :param: moc NSManagedObjectContext
  :param: block ((NSManagedObjectContext) -> Void)? = nil
  :param: propagate Bool = false
  :param: nonBlocking Bool = false
  :param: completion ((Bool, NSError?) -> Void)? = nil
  */
  class func saveContext(moc: NSManagedObjectContext,
               withBlock block: ((NSManagedObjectContext) -> Void)? = nil,
               propagate: Bool = false,
             nonBlocking: Bool = false,
     backgroundExecution: Bool = false,
              completion: ((Bool, NSError?) -> Void)? = nil)
  {
    coreDataStack.saveContext(moc,
                    withBlock: block,
                    propagate: propagate,
                  nonBlocking: nonBlocking,
          backgroundExecution: backgroundExecution,
                   completion: completion)
  }

  /**
  The method programatically modifies the specified model to add more detail to various attributes,
  i.e. default values, class names, etc. The model passed to this method must be as-of-yet unused or
  an internal inconsistency will be introduced and the application will crash.

  :param: model NSManagedObjectModel The model to modify
  :returns: NSManagedObjectModel The augmented model
  */
  class func augmentModel(model: NSManagedObjectModel) -> NSManagedObjectModel {

    /**
    Helper for modifiying the class and default value for the same attribute on multiple entities

    :param: attribute String Name of attribute to modify
    :param: entities [NSEntityDescription] An array of `NSEntityDescription *` whose attribute shall be modified
    :param: className String? = nil Class name for the value of the attribute to modify
    :param: defaultValue AnyObject? = nil The default value for the attribute to modify
    :param: info [NSObject:AnyObject]? = nil Entries to add to the user info dictionary of attribute to modify
     */
     func modifyAttribute(attribute: String,
             forEntities entities: [NSEntityDescription],
          valueClassName: String? = nil,
            defaultValue: AnyObject? = nil,
                userInfo: [NSObject:AnyObject]? = nil)
    {
      for entity in entities {
        if let attributeDescription = entity.attributesByName[attribute] as? NSAttributeDescription {
          if valueClassName != nil  { attributeDescription.attributeValueClassName = valueClassName }
          if defaultValue != nil { attributeDescription.defaultValue = defaultValue }
          if userInfo != nil {
            var info = attributeDescription.userInfo ?? [:]
            extend(&info, userInfo!)
            attributeDescription.userInfo = info
          }
        }
      }
    }
    /**
    Helper for modifying the class and default value of multiple attributes on the same entity

    :param: attributes [String] An array of `NSAttributeDescription *` objects to modify
    :param: entity NSEntityDescription The entity to modify
    :param: className String? = nil The class name of the value type of attributes to modify
    :param: defaultValue AnyObject? = nil The default value of the attributes to modify
    :param: info [NSObject:AnyObject]? = nil Entries to add to the user info dictionary of attributes to modify
    */
    func modifyAttributes(attributes: [String],
                forEntity entity: NSEntityDescription,
          valueClassName: String? = nil,
            defaultValue: AnyObject? = nil,
                userInfo: [NSObject:AnyObject]? = nil)
    {
      for attribute in attributes {
        if let attributeDescription = entity.attributesByName[attribute] as? NSAttributeDescription {
          if valueClassName != nil { attributeDescription.attributeValueClassName = valueClassName }
          if defaultValue != nil { attributeDescription.defaultValue = defaultValue }
          if userInfo != nil {
            var info = attributeDescription.userInfo ?? [:]
            extend(&info, userInfo!)
            attributeDescription.userInfo = info
          }
        }
      }
    }

    /**
    Helper for setting a different default value for an attribute of an entity than is set for its parent

    :param: attribute String The name of the attribute of the entity whose attribute shall be modified.
    :param: entity NSEntityDescription The entity whose attribute shall have its default value set.
    :param: defaultValue AnyObject? The value to set as default for the specified attribute of the entity.
    */
    func overrideDefaultValueOfAttribute(attribute: String,
                            forSubentity entity: NSEntityDescription,
                               withValue defaultValue: AnyObject?)
    {
        var superentity: NSEntityDescription? = entity
        do { superentity = entity.superentity } while superentity?.superentity != nil

        if let attributeDescription = superentity?.attributesByName[attribute] as? NSAttributeDescription {
          var userInfo = attributeDescription.userInfo ?? [:]
          userInfo["\(MSDefaultValueForContainingClassKey).\(entity.name)"] = defaultValue ?? NSNull()
          attributeDescription.userInfo = userInfo
          let keypath = "attributesByName.\(attribute).userInfo"
          var subentities = superentity!.subentities as [NSEntityDescription]
          while subentities.count > 0 {
            apply(subentities) { _ = ($0.attributesByName[attribute] as? NSAttributeDescription)?.userInfo = userInfo }
            subentities = flattened(subentities.map{$0.subentities as [NSEntityDescription]})
          }

          superentity!.setValue(userInfo, forKeyPath: keypath) // ???: Pretty sure this is redundant
        }

    }


    let augmentedModel = model.mutableCopy() as NSManagedObjectModel
    let entities = augmentedModel.entitiesByName as [String:NSEntityDescription]


    // set `user` default value
    modifyAttribute("user", forEntities: [entities["ComponentDevice"]!], defaultValue: true)

    // indicator attribute on activity commands
    overrideDefaultValueOfAttribute("indicator", forSubentity: entities["ActivityCommand"]!, withValue: true)

    // size attributes on images
    modifyAttribute("size",
        forEntities: [entities["Image"]!],
     valueClassName: "NSValue",
       defaultValue: NSValue(CGSize: CGSize.zeroSize))


    // background color attributes on remote elements
    modifyAttribute("backgroundColor",
        forEntities: ["RemoteElement", "Remote", "ButtonGroup", "Button"].map{entities[$0]!},
     valueClassName: "UIColor",
       defaultValue: UIColor.clearColor())

    // edge insets attributes on buttons
    modifyAttributes(["titleEdgeInsets", "contentEdgeInsets", "imageEdgeInsets"],
           forEntity: entities["Button"]!,
      valueClassName: "NSValue",
        defaultValue: NSValue(UIEdgeInsets: UIEdgeInsets.zeroInsets))

    // configurations attribute on remote elements
    modifyAttribute("configurations",
        forEntities: ["RemoteElement", "Remote", "ButtonGroup", "Button"].map{entities[$0]!},
     valueClassName: "NSDictionary",
       defaultValue: NSDictionary())

    // panels for RERemote
    modifyAttribute("panels",
        forEntities: [entities["Remote"]!],
     valueClassName: "NSDictionary",
       defaultValue: NSDictionary())

    // label attribute on button groups
    modifyAttribute("label",
        forEntities: [entities["ButtonGroup"]!],
     valueClassName: "NSAttributedString")

     modifyAttribute("title",
        forEntities: [entities["Button"]!],
     valueClassName: "NSAttributedString")

    // settings attribute on Preset
    modifyAttribute("attributes",
        forEntities: [entities["Preset"]!],
     valueClassName: "NSDictionary",
       defaultValue: NSDictionary())

    modifyAttribute("dictionary",
      forEntities: [entities["DictionaryStorage"]!],
   valueClassName: "NSDictionary",
     defaultValue: NSDictionary())

    // index attribute on command containers
    modifyAttribute("index",
        forEntities: ["CommandContainer", "CommandSet", "CommandSetCollection"].map{entities[$0]!},
     valueClassName: "MSDictionary",
       defaultValue: MSDictionary())

    // url attribute on http command
    modifyAttribute("url",
        forEntities: [entities["HTTPCommand"]!],
     valueClassName: "NSURL",
       defaultValue: NSURL(string: "http://about:blank"))

    // color attributes on control state color set
    modifyAttributes(["disabled",
                      "selectedDisabled",
                      "highlighted",
                      "highlightedDisabled",
                      "highlightedSelected",
                      "normal",
                      "selected",
                      "highlightedSelectedDisabled"],
           forEntity: entities["ControlStateColorSet"]!,
      valueClassName: "UIColor")

    // color attribute on image view
    modifyAttribute("color",
        forEntities: [entities["ImageView"]!],
     valueClassName: "UIColor")

    return augmentedModel
  }

}


////////////////////////////////////////////////////////////////////////////////
/// MARK: - Removing objects from the database at startup
////////////////////////////////////////////////////////////////////////////////

extension DataManager {

  struct StartupObjectRemovalOptions: RawOptionSetType {
    private(set) var rawValue: Int

    init(rawValue: Int) { self.rawValue = rawValue }

    init(nilLiteral: ()) { rawValue = 0 }

    static var allZeros: StartupObjectRemovalOptions { return StartupObjectRemovalOptions.None }

    static var None:       StartupObjectRemovalOptions = StartupObjectRemovalOptions(rawValue: 0b0000)
    static var Presets:    StartupObjectRemovalOptions = StartupObjectRemovalOptions(rawValue: 0b0001)
    static var Remotes:    StartupObjectRemovalOptions = StartupObjectRemovalOptions(rawValue: 0b0010)
    static var Controller: StartupObjectRemovalOptions = StartupObjectRemovalOptions(rawValue: 0b0100)
    static var All:        StartupObjectRemovalOptions = StartupObjectRemovalOptions(rawValue: 0b1000)
  }

}
