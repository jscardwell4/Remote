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

  // MARK: - Setup

  /** initialize */
  class func initialize() {
    MSLogDebug("bundle path: '\(dataModelBundle.bundlePath)'")
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

  /** Stores a reference to the `DataModel` bundle */
  private static let dataModelBundle = NSBundle(forClass: DataManager.self)

  /** Database operation flags parsed from command line */
  static public let dataFlag: DataFlag = DataFlag()

  /** Model flags parsed from command line */
  static public let modelFlags: [ModelFlag] = ModelFlag.all

  // MARK: - Stack

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
      let identifier = dataModelBundle.bundleIdentifier
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
  private static let databaseBundleURL: NSURL = {
    if let url = dataModelBundle.URLForResource(DataManager.resourceBaseName, withExtension: "sqlite") {
      return url
    } else { fatalError("Unable to locate database bundle resource") }
  }()


  /** The core data stack, if this is nil we may as well shutdown */
  private static let stack: CoreDataStack = {
    if let modelURL = dataModelBundle.URLForResource(DataManager.resourceBaseName, withExtension: "momd"),
      mom = NSManagedObjectModel(contentsOfURL: modelURL),
      stack = CoreDataStack(managedObjectModel: DataManager.augmentModel(mom),
                            persistentStoreURL: dataFlag.inMemory ? nil : databaseStoreURL,
                            options: [NSMigratePersistentStoresAutomaticallyOption: true,
                                      NSInferMappingModelAutomaticallyOption: true])
    {
      MSLogDebug("persistent store url: '\(databaseStoreURL)'")
      if dataFlag.logModel { MSLogDebug("managed object model:\n\(stack.managedObjectModel.description)") }
      return stack
    } else { fatalError("failed to instantiate core data stack, aborting…") }

  }()

  static private let resourceBaseName = "Remote"

  static public var managedObjectModel: NSManagedObjectModel { return stack.managedObjectModel }
  /**
  Creates a new main queue context as a child of the `rootContext` (via `stack`)

  :returns: NSManagedObjectContext
  */
  public class func mainContext() -> NSManagedObjectContext { return stack.mainContext() }

  /**
  isolatedContext

  :returns: NSManagedObjectContext
  */
  public class func isolatedContext() -> NSManagedObjectContext { return stack.isolatedContext() }

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

    // Create common `uuid` attribute
    let uuid: Void -> NSAttributeDescription = {
      let uuid = NSAttributeDescription()
      uuid.name = "uuid"
      uuid.attributeType = .StringAttributeType
      uuid.optional = false
      uuid.setValidationPredicates([∀"SELF MATCHES '(?:[A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-Z0-9]{12})?'"],
            withValidationWarnings: [NSValidationStringPatternMatchingError])
      return uuid
    }

    // Process each entity for common operations
    for entity in augmentedModel.entities as! [NSEntityDescription] {
      if entity.superentity == nil { entity.properties.append(uuid()) }
      (entity.attributesByName.values.array as! [NSAttributeDescription]).filter({$0.userInfo != nil}) ➤ {
        (attribute: NSAttributeDescription) -> Void in
        if let n = attribute.userInfo?["attributeValueClassName"] as? String {
          attribute.attributeValueClassName = n
          if !attribute.optional {
            switch n {
              case "MSDictionary": attribute.defaultValue = MSDictionary()
              case "NSDictionary": attribute.defaultValue = NSDictionary()
              case "UIColor": attribute.defaultValue = UIColor.clearColor()
              case "NSAttributedString": attribute.defaultValue = NSAttributedString()
              case "NSURL": attribute.defaultValue = NSURL(string: "http://about:blank")
              case "NSValue":
                if let valueType = attribute.userInfo?["NSValueType"] as? String {
                  switch valueType {
                    case "CGSize": attribute.defaultValue = NSValue(CGSize: CGSize.zeroSize)
                    case "UIEdgeInsets": attribute.defaultValue = NSValue(UIEdgeInsets: UIEdgeInsets.zeroInsets)
                    default: break
                  }
                }
              default: break
            }
          }
        }
      }
    }


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
      for attribute in compressedMap(attributes, {entity.attributesByName[$0] as? NSAttributeDescription}) {
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

    return augmentedModel
  }

  // MARK: - Marker type

  /** The type of action marked by a flag */
  public enum Marker: Printable, Equatable {
    case Copy
    case Load
    case Remove
    case InMemory
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
        case .InMemory:        return "inMemory"
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
        case "inMemory":
          self = Marker.InMemory
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
        case .Copy, .Load, .Dump, .Remove, .InMemory: return key
        case .Log(let values): return "\(key): " + ", ".join(values.map({$0.rawValue}))
        case .LoadFile(let file): return "\(key): \(file)"
      }
    }
  }

  // MARK: - DataFlag type

  /**
  Type for parsing database operations command line arguments
  */
  public struct DataFlag: Printable {
    let load: Bool
    let dump: Bool
    let remove: Bool
    let inMemory: Bool
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
        inMemory = markers ∋ .InMemory
      } else {
        load = false
        dump = false
        logModel = false
        copy = false
        remove = false
        inMemory = false
      }
    }

    public var description: String {
      return "database operations:\n\tload: \(load)\n\tdump: \(dump)\n\tremove: \(remove)\n\tinMemory: \(inMemory)\n\tlog model: \(logModel)"
    }
  }

  // MARK: - ModelFlag type

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

  // MARK: - Data operations

  /**
  Load data from files parsed from command line arguments and save the root context

  :param: completion ((Bool, NSError?) -> Void)? = nil
  */
  private class func loadData(completion: ((Bool, NSError?) -> Void)? = nil) {

    // TODO: Check if this is broken due to race condition/asynchronous calls
    rootContext.performBlock {[rootContext = self.rootContext] in

      self.modelFlags ➤ {
        var fileName: String?
        var logFlags = LogFlags.Default
        var logFile = false
        var logParsed = false
        var logImported = false
        var removeExisting = false
        for marker in $0.markers {
          switch marker {
            case .Remove: removeExisting = true
            case .LoadFile(let f): fileName = f
            case .Log(let values):
              if values ∋ .Parsed { logFlags |= LogFlags.Parsed }
              if values ∋ .Imported { logFlags |= LogFlags.Imported }
              if values ∋ .File { logFlags |= LogFlags.File }
          default: break
          }
        }
        if removeExisting { rootContext.deleteObjects(Set($0.modelType.objectsInContext(rootContext))) }
        if fileName != nil {
          self.loadJSONFileNamed(fileName!, forModel: $0.modelType, context: rootContext, logFlags: logFlags)
        }
      }
    }

    saveRootContext(completion: completion)

  }

  /** 
  Save the root context 
  
  :param: completion ((Bool, NSError?) -> Void)? = nil
  */
  public class func saveRootContext(completion: ((Bool, NSError?) -> Void)? = nil) {
    rootContext.performBlock {
      var error: NSError?
      MSLogDebug("saving context…")
      if self.rootContext.save(&error) && !MSHandleError(error, message: "error occurred while saving context") {
        MSLogDebug("context saved successfully")
        completion?(true, nil)
      } else {
        MSHandleError(error, message: "failed to save context")
        completion?(false, error)
      }
    }
  }

  /** dumpData */
  private class func dumpData(completion: ((Void) -> Void)? = nil ) {
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
  public class func dumpJSONForModelType(modelType: ModelObject.Type, context: NSManagedObjectContext = rootContext) {
    let className = (modelType.self as AnyObject).className
    let objects: [ModelObject]
    switch className {
    case "ImageCategory", "PresetCategory":
      objects = modelType.objectsMatchingPredicate(∀"parentCategory = NULL", context: context)
    default:
      objects = modelType.objectsInContext(context)
    }
    if objects.isEmpty { MSLogWarn("fetch turned up empty for '\(modelType)'") }
    let json: JSONValue = .Array(objects.map({$0.jsonValue}))
    MSLogDebug("\(className) objects: \n\(json.prettyRawValue)\n")
  }

  public struct LogFlags: RawOptionSetType {
    private(set) public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public init(nilLiteral: ()) { rawValue = 0 }
    public static var allZeros: LogFlags { return LogFlags.Default }
    public static var Default: LogFlags = LogFlags(rawValue: 0b0000)
    public static var File: LogFlags = LogFlags(rawValue: 0b0001)
    public static var Parsed: LogFlags = LogFlags(rawValue: 0b0010)
    public static var Imported: LogFlags = LogFlags(rawValue: 0b0100)
  }

  public class func loadResourceForURL(url: NSURL) {
    let fm = NSFileManager.defaultManager()

    if let path = url.path where fm.isReadableFileAtPath(path) {

    }
  }



  /**
  loadJSONFileAtPath:forModel:context:logFlags:completion:

  :param: path String
  :param: type T.Type
  :param: context NSManagedObjectContext
  :param: logFlags LogFlags = .Default
  :param: completion ((Bool, NSError?) -> Void)? = nil
  */
  public class func loadJSONFileAtPath<T:ModelObject>(path: String,
                                             forModel type: T.Type,
                                              context: NSManagedObjectContext,
                                             logFlags: LogFlags = .Default,
                                           completion: ((Bool, NSError?) -> Void)? = nil)
  {
    MSLogDebug("parsing file '\(path)'")

    var error: NSError?
    context.performBlockAndWait {
      if let json = JSONSerialization.objectByParsingFile(path, options: .InflateKeypaths, error: &error)
        where MSHandleError(error) == false
      {
        if isOptionSet(LogFlags.File, logFlags) {
          MSLogDebug("content of file to parse:\n" + (String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil) ?? ""))
        }

        if isOptionSet(LogFlags.Parsed, logFlags) { MSLogDebug("json objects from parsed file:\n\(json)") }

        if let data = ObjectJSONValue(json), importedObject = type(data: data, context: context) {

          MSLogDebug("imported \(type.className()) from file '\(path)'")

          if isOptionSet(LogFlags.Imported, logFlags) { MSLogDebug("json output for imported object:\n\(importedObject.jsonValue)") }

        } else if let data = ArrayJSONValue(json) {

          let importedObjects = type.importObjectsWithData(data, context: context)

          MSLogDebug("\(importedObjects.count) \(type.className()) objects imported from file '\(path)'")

          if isOptionSet(LogFlags.Imported, logFlags) {
            MSLogDebug("json output for imported object:\n\(JSONValue.Array(importedObjects.map({$0.jsonValue})).prettyRawValue)")
          }

        } else { MSLogError("file content must resolve into [String:AnyObject] or [[String:AnyObject]]") }

      } else { MSLogError("failed to parse file '\(path)'") }

    }
    completion?(error == nil, error)
  }

  /**
  loadJSONFileNamed:forModel:context:logFlags:completion:

  :param: name String
  :param: type T.Type
  :param: context NSManagedObjectContext
  :param: logFlags LogFlags = .Default
  :param: completion ((Bool, NSError?) -> Void)? = nil
  */
  public class func loadJSONFileNamed<T:ModelObject>(var name: String,
                                             forModel type: T.Type,
                                             context: NSManagedObjectContext,
                                            logFlags: LogFlags = .Default,
                                          completion: ((Bool, NSError?) -> Void)? = nil)
  {
    var error: NSError?
    if name.hasSuffix(".json") { name = name.stringByDeletingPathExtension }
    var path: String?
    if let p = self.dataModelBundle.pathForResource(name, ofType: "json") { path = p }
    else if let p = NSBundle.mainBundle().pathForResource(name, ofType: "json") { path = p }
    else {
      MSLogError("unable to resolve the name '\(name)' into a bundled file path")
      error = NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: nil)
    }

    if path != nil { loadJSONFileAtPath(path!, forModel: type, context: context, logFlags: logFlags, completion: completion) }
    else { completion?(false, error) }
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
