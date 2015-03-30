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
    MSLogDebug("performing \(dataFlag)\nmodel flags…\n" + "\n".join(modelFlags.map({$0.description})))

    if databaseStoreURL.checkResourceIsReachableAndReturnError(nil)
      && dataFlag.remove
    {
      var error: NSError?
      NSFileManager.defaultManager().removeItemAtURL(databaseStoreURL, error: &error)
      if !MSHandleError(error) { MSLogDebug("previous database store has been removed") }
    }

    if dataFlag.load {
      loadData { if !MSHandleError($1, message: "data load failed") && self.dataFlag.dump { self.dumpData() } }
    } else if dataFlag.dump { dumpData() }
  }

  /** URL for the user's persistent store */
  public static let databaseStoreURL: NSURL = {
    let fileManager = NSFileManager.defaultManager()
    var error: NSError?
    if let supportDirectoryURL = fileManager.URLForDirectory(.ApplicationSupportDirectory,
                                                    inDomain: .UserDomainMask,
                                           appropriateForURL: nil,
                                                      create: true,
                                                       error: &error)
      where !MSHandleError(error, message: "failed to retrieve application support directory"),
      let identifier = NSBundle(forClass: DataManager.self).bundleIdentifier
    {
      let bundleSupportDirectoryURL = supportDirectoryURL.URLByAppendingPathComponent(identifier)

      if fileManager.createDirectoryAtURL(bundleSupportDirectoryURL,
              withIntermediateDirectories: true,
                               attributes: nil,
                                    error: &error)
        && !MSHandleError(error, message: "failed to create app directory under application support")
      {
        return bundleSupportDirectoryURL.URLByAppendingPathComponent("\(DataManager.resourceBaseName).sqlite")
      }
    }
    fatalError("aborting")
  }()

  /** URL for the preloaded persistent store located in the bundle */
  public static let databaseBundleURL: NSURL = {
    if let url = NSBundle(forClass: DataManager.self).URLForResource(DataManager.resourceBaseName, withExtension: "sqlite") {
      return url
    } else { fatalError("Unable to locate database bundle resource") }
  }()


  /** The core data stack, if this is nil we may as well shutdown */
  public static let stack: CoreDataStack = {
    if let modelURL = NSBundle(forClass:DataManager.self).URLForResource(DataManager.resourceBaseName, withExtension: "momd"),
      mom = NSManagedObjectModel(contentsOfURL: modelURL),
      stack = CoreDataStack(managedObjectModel: DataManager.augmentModel(mom),
                            persistentStoreURL: databaseStoreURL,
                            options: [NSMigratePersistentStoresAutomaticallyOption: true,
                                      NSInferMappingModelAutomaticallyOption: true])
    {
      if dataFlag.logModel { MSLogDebug("managed object model:\n\(stack.managedObjectModel.description)") }
      return stack
    } else { fatalError("failed to instantiate core data stack, aborting…") }

  }()

  static private let resourceBaseName = "Remote"
  static public let dataFlag: DataFlag = DataFlag()
  static public let modelFlags: [ModelFlag] = ModelFlag.all


  /**
  Creates a new main queue context as a child of the `rootContext` (via `stack`)

  :returns: NSManagedObjectContext
  */
  public class func mainContext() -> NSManagedObjectContext { return stack.mainContext() }

  /** The primary, private-queue managed object context maintained by `stack`.  */
  public class var rootContext: NSManagedObjectContext { return stack.rootContext }

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
    stack.saveContext(moc,
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
    let newtorkDevice        = entities["NetworkDevice"]!

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
    modifyAttribute("componentDevices", forEntities: [newtorkDevice], defaultValue: NSSet())

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

    // containerIndex attribute on command containers
    modifyAttribute("containerIndex",
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

  /**
  Type for parsing database-related arguments passed to application

  :example: -manufacturers load=Manufacturer_Test,dump,log=parsed-imported
  */

  /** The type of action marked by a flag */
  public enum Marker: Printable, Equatable {
    case Copy
    case Load
    case Remove
    case LoadFile (String)
    case Dump
    case Log ([LogValue])

    /** Type of value marked for logging */
    public enum LogValue: String {
      case File     = "file"
      case Model    = "model"
      case Parsed   = "parsed"
      case Imported = "imported"
    }

    /** 'Raw' string value for the marker */
    var key: String {
      switch self {
        case .Copy:            return "copy"
        case .Remove:          return "remove"
        case .Load, .LoadFile: return "load"
        case .Dump:            return "dump"
        case .Log:             return "log"
      }
    }

    var value: AnyObject? {
      switch self {
      case .LoadFile(let fileName): return fileName
      case .Log(let logValues): return logValues.map{$0.rawValue}
      default: return nil
      }
    }

    /**
    initWithArgValue:

    :param: argValue String
    */
    init?(argValue: String) {
      switch argValue {
        case "copy": self = .Copy
        case "load":
          self = Marker.Load
        case "remove":
          self = Marker.Remove
        case "dump":
          self = Marker.Dump
        case ~/"load=.+":
          self = Marker.LoadFile(argValue[5..<argValue.length])
        case ~/"log=.+":
          self = Marker.Log(compressed("-".split(argValue[4..<argValue.length]).map({LogValue(rawValue: $0)})))
        default:
          return nil
      }
    }

    public var description: String {
      switch self {
        case .Copy, .Load, .Dump, .Remove: return key
        case .Log(let values): return "\(key): " + ", ".join(values.map({$0.rawValue}))
        case .LoadFile(let file): return "\(key): \(file)"
      }
    }
  }

  /** 
  Type for parsing database operations command line arguments
  */
  public struct DataFlag: Printable {
    let load: Bool
    let dump: Bool
    let remove: Bool
    let copy: Bool
    let logModel: Bool

    static let key = "databaseOperations"

    /** Initializes a new flag using command line argument if present */
    init() {
      if let arg = NSUserDefaults.standardUserDefaults().volatileDomainForName(NSArgumentDomain)[DataFlag.key] as? String {
        let markers = compressed(",".split(arg).map({Marker(argValue: $0)}))
        load =  markers ∋ .Load
        dump =  markers ∋ .Dump
        logModel =  markers ∋ .Log([.Model])
        copy = markers ∋ .Copy
        remove =  markers ∋ .Remove
      } else {
        load = false
        dump = false
        logModel = false
        copy = false
        remove = false
      }
    }

    public var description: String {
      return "database operations:\n\tload: \(load)\n\tdump: \(dump)\n\tremove: \(remove)\n\tlog model: \(logModel)"
    }
  }


  /** Flags used as the base of a supported command line argument whose value should resolve into a valid `Marker` */
  public enum ModelFlag: String, EnumerableType, Printable {
    case Manufacturers    = "manufacturers"
    case ComponentDevices = "componentDevices"
    case Images           = "images"
    case NetworkDevices   = "networkDevices"
    case Controller       = "controller"
    case Presets          = "presets"
    case Remotes          = "remotes"
    case Activities       = "activities"

    /** Dictionary of parsed command line arguments where ∀ k in [k:v], Flag(rawValue: k) != nil */
    static let arguments = filter(NSUserDefaults.standardUserDefaults().volatileDomainForName(NSArgumentDomain), {
      (k, v) -> Bool in
      return ModelFlag(rawValue: k as? String ?? "") != nil
    })

    /** Array of markers created by parsing associated command line argument */
    var markers: [Marker] {
      if let argValue = ModelFlag.arguments[rawValue] as? String {
        return compressed(",".split(argValue).map({Marker(argValue: $0)}))
      } else { return [] }
    }

    /** The model object subclass demarcated by the flag */
    var modelType: ModelObject.Type {
      switch self {
      case .Presets:          return PresetCategory.self
      case .Images:           return ImageCategory.self
      case .Manufacturers:    return Manufacturer.self
      case .ComponentDevices: return ComponentDevice.self
      case .NetworkDevices:   return NetworkDevice.self
      case .Controller:       return ActivityController.self
      case .Activities:       return Activity.self
      case .Remotes:          return Remote.self
      }
    }

    /** An array of all possible flag keys for which an argument has been passed */
    static public var all: [ModelFlag] = [.Manufacturers, .ComponentDevices, .Images, .Activities,
                                   .NetworkDevices, .Controller, .Presets, .Remotes].filter {
                                    ModelFlag.arguments[$0.rawValue] != nil
                                  }

    /**
    `EnumerableType` support, applies `block` to `all`

    :param: block (ModelFlag) -> Void
    */
    static public func enumerate(block: (ModelFlag) -> Void) { all ➤ block }


    public var description: String { return "\(rawValue):\n\t" + "\n\t".join(markers.map({$0.description})) }
  }

  /** loadData */
  class func loadData(completion: ((Bool, NSError?) -> Void)? = nil) {

    rootContext.performBlock {[rootContext = self.rootContext] in

      self.modelFlags ➤ {
        var fileName: String?
        var logFile = false
        var logParsed = false
        var logImported = false
        var removeExisting = false
        for marker in $0.markers {
          switch marker {
            case .Remove: removeExisting = true
            case .LoadFile(let f): fileName = f
            case .Log(let values):
              logParsed = values ∋ .Parsed
              logImported = values ∋ .Imported
              logFile = values ∋ .File
          default: break
          }
        }
        if removeExisting { rootContext.deleteObjects(Set($0.modelType.objectsInContext(rootContext))) }
        if fileName != nil {
          self.loadDataFromFile(fileName!,
                           type: $0.modelType,
                        context: rootContext,
                        logFile: logFile,
                      logParsed: logParsed,
                    logImported: logImported)
        }
      }

      var error: NSError?
      MSLogDebug("saving context…")
      if rootContext.save(&error) && !MSHandleError(error, message: "error occurred while saving context") {
        MSLogDebug("context saved successfully")
        completion?(true, nil)
      } else {
        MSHandleError(error, message: "failed to save context")
        completion?(false, error)
      }
    }
  }

  /** dumpData */
  class func dumpData(completion: ((Void) -> Void)? = nil ) {
    rootContext.performBlock {

      self.modelFlags ➤ {
        for marker in $0.markers {
          switch marker {
          case .Dump: self.dumpJSONForModelType($0.modelType)
          default: break
          }
        }
      }
    }

    completion?()

  }

  /**
  dumpJSONForModelType:

  :param: modelType ModelObject.Type
  */
  public class func dumpJSONForModelType(modelType: ModelObject.Type) {
    let className = (modelType.self as AnyObject).className
    let objects: [ModelObject]
    switch className {
    case "ImageCategory", "PresetCategory":
      objects = modelType.objectsMatchingPredicate(∀"parentCategory = NULL", context: rootContext)
    default:
      objects = modelType.objectsInContext(rootContext)
    }
    let json = (objects as NSArray).JSONString
    MSLogDebug("\(className) objects: \n\(json)\n")
  }

  /**
  loadDataFromFile:type:context:

  :param: file String
  :param: type T.Type
  :param: context NSManagedObjectContext
  */
  private class func loadDataFromFile<T:ModelObject>(file: String,
                                                type: T.Type,
                                             context: NSManagedObjectContext,
                                             logFile: Bool,
                                           logParsed: Bool,
                                         logImported: Bool)
  {
    MSLogDebug("parsing file '\(file).json'")

    var error: NSError?
    if let filePath = NSBundle(forClass: self).pathForResource(file, ofType: "json"),
      data: AnyObject = JSONSerialization.objectByParsingFile(filePath, options: 1, error: &error)
      where MSHandleError(error) == false
    {
      if logFile {
        MSLogDebug("content of file to parse:\n" + (String(contentsOfFile: filePath,
                                                           encoding: NSUTF8StringEncoding,
                                                              error: nil) ?? "")) }
      if logParsed { MSLogDebug("json objects from parsed file:\n\(data)") }

      if let dataDictionary = data as? [String:AnyObject],
        importedObject = type(data: dataDictionary, context: context) {

        MSLogDebug("imported \(type.className()) from file '\(file).json'")

        if logImported { MSLogDebug("json output for imported object:\n\(importedObject.JSONString)") }

      } else if let dataArray = data as? [[String:AnyObject]] {

        let importedObjects = type.importObjectsFromData(dataArray, context: context)

        MSLogDebug("\(importedObjects.count) \(type.className()) objects imported from file '\(file).json'")

        if logImported { MSLogDebug("json output for imported object:\n\((importedObjects as NSArray).JSONString)") }

      } else { MSLogError("file content must resolve into [String:AnyObject] or [[String:AnyObject]]") }

    } else { MSLogError("failed to parse file '\(file).json'") }
  }

}

/**
Equatable operator for `DataManager.Marker`

:param: lhs DataManager.Marker
:param: rhs DataManager.Marker

:returns: Bool
*/
public func ==(lhs: DataManager.Marker, rhs: DataManager.Marker) -> Bool {
  switch (lhs, rhs) {
    case (.Load, .Load), (.Dump, .Dump), (.Remove, .Remove): return true
    case (.LoadFile(let f1), .LoadFile(let f2)) where f1 == f2: return true
    case (.Log(let v1), .Log(let v2)) where v1 == v2: return true
    default: return false
  }
}
