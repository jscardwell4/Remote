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

@objc public final class DataManager {

  /** initialize */
  class func initialize() {
    MSLogDebug("preparing database…")
    prepareDatabase()
  }

  /** URL for the user's persistent store */
  public static let databaseStoreURL: NSURL = {
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
  public static let databaseBundleURL: NSURL = NSBundle.mainBundle().URLForResource("Remote", withExtension: "sqlite")!


  /** The core data stack, if this is nil we may as well shutdown */
  public static let coreDataStack: CoreDataStack = {

//    let modelURL = NSBundle.mainBundle().URLForResource("Remote", withExtension: "momd")
    let modelURL = NSBundle(forClass:DataManager.self).URLForResource("Remote", withExtension: "momd")
    if modelURL == nil { fatalError("failed to retrieve model url from bundle, aborting…") }

    let mom = NSManagedObjectModel(contentsOfURL: modelURL!)
    if mom == nil { fatalError("failed to instantiate model from model url, aborting…") }


    let stack = CoreDataStack(managedObjectModel: DataManager.augmentModel(mom!),
                              persistentStoreURL: databaseStoreURL,
                              options: [NSMigratePersistentStoresAutomaticallyOption: true,
                                        NSInferMappingModelAutomaticallyOption: true])
    if stack == nil { fatalError("failed to instantiate core data stack, aborting…") }
    else if NSUserDefaults.standardUserDefaults().boolForKey("logManagedObjectModel") {
      MSLogDebug("managed object model:\n\(stack!.managedObjectModel.description)")
    }
    return stack!

  }()

  static private var databasePrepared = false

  public class func mainContext() -> NSManagedObjectContext { return coreDataStack.mainContext() }

  /** The primary, private-queue managed object context.  */
  public class var rootContext: NSManagedObjectContext { return coreDataStack.rootContext }

  /**
  prepareDatabase:

  :param: completion (Void) -> Void
  */
  public class func prepareDatabase(completion: ((Bool, NSError?) -> Void)? = nil) {

    if databasePrepared { completion?(true, nil); return }

    if databaseStoreURL.checkResourceIsReachableAndReturnError(nil)
      && NSUserDefaults.standardUserDefaults().boolForKey("removeExistingDatabase")
    {
      var error: NSError?
      NSFileManager.defaultManager().removeItemAtURL(databaseStoreURL, error: &error)
      if !MSHandleError(error) { MSLogDebug("previous database store has been removed") }
    }

    databasePrepared = true

    if NSUserDefaults.standardUserDefaults().boolForKey("loadData") {
      DatabaseLoader.loadData(completion: completion)
    } else { completion?(true, nil) }

  }

  /**
  childContextForContext:

  :param: context NSManagedObjectContext

  :returns: NSManagedObjectContext
  */
  public class func childContextForContext(context: NSManagedObjectContext) -> NSManagedObjectContext {
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
  public class func saveContext(moc: NSManagedObjectContext,
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

    let augmentedModel = model.mutableCopy() as! NSManagedObjectModel
    let entities = augmentedModel.entitiesByName as! [String:NSEntityDescription]

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
      for attribute in attributes.map({entity.attributesByName[$0] as? NSAttributeDescription})‽ {
        if valueClassName != nil { attribute.attributeValueClassName = valueClassName }
        if defaultValue != nil { attribute.defaultValue = defaultValue }
        if userInfo != nil { var info = attribute.userInfo ?? [:]; extend(&info, userInfo!); attribute.userInfo = info }
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
          var subentities = superentity!.subentities as! [NSEntityDescription]
          while subentities.count > 0 {
            apply(subentities) { _ = ($0.attributesByName[attribute] as? NSAttributeDescription)?.userInfo = userInfo }
            subentities = flattened(subentities.map{$0.subentities as! [NSEntityDescription]})
          }

          superentity!.setValue(userInfo, forKeyPath: keypath) // ???: Pretty sure this is redundant
        }

    }

    let componentDevice      = entities["ComponentDevice"]!
    let manufacturer         = entities["Manufacturer"]!
    let imageCategory        = entities["ImageCategory"]!
    let presetCategory       = entities["PresetCategory"]!
    let iRCodeSet            = entities["IRCodeSet"]!
    let image                = entities["Image"]!
    let remoteElement        = entities["RemoteElement"]!
    let remote               = entities["Remote"]!
    let buttonGroup          = entities["ButtonGroup"]!
    let button               = entities["Button"]!
    let preset               = entities["Preset"]!
    let dictionaryStorage    = entities["DictionaryStorage"]!
    let commandContainer     = entities["CommandContainer"]!
    let commandSet           = entities["CommandSet"]!
    let commandSetCollection = entities["CommandSetCollection"]!
    let hTTPCommand          = entities["HTTPCommand"]!
    let controlStateColorSet = entities["ControlStateColorSet"]!
    let imageView            = entities["ImageView"]!
    let activityCommand      = entities["ActivityCommand"]!

    // set `user` default value
    modifyAttribute("user", forEntities: [componentDevice], defaultValue: true)

    // indicator attribute on activity commands
    overrideDefaultValueOfAttribute("indicator", forSubentity: activityCommand, withValue: true)

    // create some default sets
    modifyAttribute("devices", forEntities: [manufacturer, iRCodeSet], defaultValue: NSSet())
    modifyAttribute("childCategories", forEntities: [imageCategory, presetCategory], defaultValue: NSSet())
    modifyAttribute("codeSets", forEntities: [manufacturer], defaultValue: NSSet())
    modifyAttribute("codes", forEntities: [iRCodeSet], defaultValue: NSSet())
    modifyAttribute("images", forEntities: [imageCategory], defaultValue: NSSet())
    modifyAttribute("presets", forEntities: [presetCategory], defaultValue: NSSet())

    // size attributes on images
    modifyAttribute("size",
        forEntities: [image],
     valueClassName: "NSValue",
       defaultValue: NSValue(CGSize: CGSize.zeroSize))


    // background color attributes on remote elements
    modifyAttribute("backgroundColor",
        forEntities: [remoteElement, remote, buttonGroup, button],
     valueClassName: "UIColor",
       defaultValue: UIColor.clearColor())

    // edge insets attributes on buttons
    modifyAttributes(["titleEdgeInsets", "contentEdgeInsets", "imageEdgeInsets"],
           forEntity: button,
      valueClassName: "NSValue",
        defaultValue: NSValue(UIEdgeInsets: UIEdgeInsets.zeroInsets))

    // configurations attribute on remote elements
    modifyAttribute("configurations",
        forEntities: [remoteElement, remote, buttonGroup, button],
     valueClassName: "NSDictionary",
       defaultValue: NSDictionary())

    // panels for RERemote
    modifyAttribute("panels", forEntities: [remote], valueClassName: "NSDictionary", defaultValue: NSDictionary())

    // label attribute on button groups
    modifyAttribute("label", forEntities: [buttonGroup], valueClassName: "NSAttributedString")

     modifyAttribute("title", forEntities: [button], valueClassName: "NSAttributedString")

    // settings attribute on Preset
    modifyAttribute("attributes", forEntities: [preset], valueClassName: "NSDictionary", defaultValue: NSDictionary())

    modifyAttribute("dictionary",
      forEntities: [dictionaryStorage],
   valueClassName: "NSDictionary",
     defaultValue: NSDictionary())

    // index attribute on command containers
    modifyAttribute("index",
        forEntities: [commandContainer, commandSet, commandSetCollection],
     valueClassName: "MSDictionary",
       defaultValue: MSDictionary())

    // url attribute on http command
    modifyAttribute("url",
        forEntities: [hTTPCommand],
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
           forEntity: controlStateColorSet,
      valueClassName: "UIColor")

    // color attribute on image view
    modifyAttribute("color", forEntities: [imageView], valueClassName: "UIColor")

    return augmentedModel
  }

}


////////////////////////////////////////////////////////////////////////////////
/// MARK: - Removing objects from the database at startup
////////////////////////////////////////////////////////////////////////////////

//extension DataManager {
//
//  struct StartupObjectRemovalOptions: RawOptionSetType {
//    private(set) var rawValue: Int
//
//    init(rawValue: Int) { self.rawValue = rawValue }
//
//    init(nilLiteral: ()) { rawValue = 0 }
//
//    static var allZeros: StartupObjectRemovalOptions { return StartupObjectRemovalOptions.None }
//
//    static var None       = StartupObjectRemovalOptions(rawValue: 0b0000)
//    static var Presets    = StartupObjectRemovalOptions(rawValue: 0b0001)
//    static var Remotes    = StartupObjectRemovalOptions(rawValue: 0b0010)
//    static var Controller = StartupObjectRemovalOptions(rawValue: 0b0100)
//    static var All        = StartupObjectRemovalOptions(rawValue: 0b1000)
//  }
//
//}
