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

  /** Process any arguments passed in via the command line */
  class func initialize() {
    MSLogDebug("bundle path: '\(dataModelBundle.bundlePath)'\nperforming \(dataFlag)\nwith model flags…\n"
                + "\n".join(modelFlags.map({$0.description})))
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.addObserverForName(NSManagedObjectContextObjectsDidChangeNotification, object: nil, queue: nil) {
      DataManager.contextDidChangeNotification($0)
    }
    notificationCenter.addObserverForName(NSManagedObjectContextWillSaveNotification, object: nil, queue: nil) {
      DataManager.contextWillSaveNotification($0)
    }
    notificationCenter.addObserverForName(NSManagedObjectContextDidSaveNotification, object: nil, queue: nil) {
      DataManager.contextDidSaveNotification($0)
    }
    initializeDatabase()
  }

  /** initializeDatabase */
  private static func initializeDatabase() {
    if databaseInitialized { return }

    // Check for remove operation
    if dataFlag.remove {
      do {
        try databaseStoreURL.checkResourceIsReachableAndReturnError()
        var error: NSError?
        do {
          try NSFileManager.defaultManager().removeItemAtURL(databaseStoreURL)
        } catch var error1 as NSError {
          error = error1
        }
        if !MSHandleError(error) { MSLogDebug("previous database store has been removed") }
      } catch _ {
      }
      dataFlag.remove = false
    }

    // Check for copy operation
    if dataFlag.copy {
      copyBundledDatabase()
      dataFlag.copy = false
    }

    // Force lazy instatiation of stack here
    if stack == nil { fatalError("failed to instantiate core data stack, aborting…") }

    // Check for model logging operation
    if dataFlag.logModel {
      MSLogDebug("managed object model:\n\(stack.managedObjectModel.description)")
      dataFlag.logModel = false
    }

    // Check for load operation and wrap check for data dump operation inside the completion block
    if dataFlag.load {
      loadData {
        MSHandleError($1, message: "data load failed")
        DataManager.dataFlag.load = false
        if DataManager.dataFlag.dump {
          DataManager.dumpData()
          DataManager.dataFlag.dump = false
          DataManager.databaseInitialized = true
        } else {
          DataManager.databaseInitialized = true
        }
      }
    }

    // Otherwise check and dump data now
    else if dataFlag.dump {
      dumpData()
      dataFlag.dump = false
      databaseInitialized = true
    }

    else {
      databaseInitialized = true
    }
  }

  public static let DatabaseInitializedNotificationName = "DataManagerDatabaseInitializedNotificationName"

  private(set) public static var databaseInitialized = false {
    didSet {
      if databaseInitialized && !oldValue {
        assert(!(dataFlag.remove || dataFlag.load || dataFlag.logModel || dataFlag.dump || dataFlag.copy))
        MSLogDebug("posting database initialized notification")
        NSNotificationCenter.defaultCenter().postNotificationName(DatabaseInitializedNotificationName, object: self)
      }
    }
  }

  /** Stores a reference to the `DataModel` bundle */
  private static let dataModelBundle = NSBundle(forClass: DataManager.self)

  public static let databaseOperations: DataFlag = DataFlag()

  /** Database operation flags parsed from command line */
  static private(set) public var dataFlag = DataManager.databaseOperations

  /** Model flags parsed from command line */
  static public let modelFlags: [ModelFlag] = ModelFlag.all

   /** URL for the user's persistent store */
  public static let databaseStoreURL: NSURL = {
    let fileManager = NSFileManager.defaultManager()
    var error: NSError?
    if let supportDirectoryURL = fileManager.URLForDirectory(.ApplicationSupportDirectory,
                                                    inDomain: .UserDomainMask,
                                           appropriateForURL: nil,
                                                      create: true)
      where !MSHandleError(error, message: "failed to retrieve application support directory"),
      let identifier = dataModelBundle.bundleIdentifier
    {
      let bundleSupportDirectoryURL = supportDirectoryURL.URLByAppendingPathComponent(identifier)

      if fileManager.createDirectoryAtURL(bundleSupportDirectoryURL,
              withIntermediateDirectories: true,
                               attributes: nil)
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

  /**
  The method programatically modifies the specified model to add more detail to various attributes,
  i.e. default values, class names, etc. The model passed to this method must be as-of-yet unused or
  an internal inconsistency will be introduced and the application will crash.

  - parameter model: NSManagedObjectModel The model to modify
  - returns: NSManagedObjectModel The augmented model
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
    for entity in augmentedModel.entities as [NSEntityDescription] {
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
              case "NSSet":
                if let valueType = attribute.userInfo?["NSSetValueType"] as? String,
                  defaultValues = attribute.userInfo?["NSSetDefaultValues"] as? String
                {
                  switch valueType {
                    case "String": attribute.defaultValue = Set(",".split(defaultValues))
                    default:       attribute.defaultValue = NSSet()
                  }
                } else { attribute.defaultValue = NSSet() }
              default: break
            }
          }
        }
      }
    }

    return augmentedModel
  }

  /** The core data stack, if this is nil we may as well shutdown */
  private static let stack: CoreDataStack! = {
    if let modelURL = dataModelBundle.URLForResource(DataManager.resourceBaseName, withExtension: "momd"),
      mom = NSManagedObjectModel(contentsOfURL: modelURL),
      stack = CoreDataStack(managedObjectModel: DataManager.augmentModel(mom),
                            persistentStoreURL: dataFlag.inMemory ? nil : databaseStoreURL,
                            options: [NSMigratePersistentStoresAutomaticallyOption: true,
                                      NSInferMappingModelAutomaticallyOption: true])
    {
      MSLogDebug("persistent store url: '\(databaseStoreURL)'")
      stack.rootContext.nametag = "root"
      return stack
    } else { return nil }

  }()

  static private let resourceBaseName = "Remote"

  // MARK: - Data operations

  /** Attempts to copy sqlite resources from the main bundle to the database store location */
  private static func copyBundledDatabase() {
    let fileManager = NSFileManager.defaultManager()
    let mainBundle = NSBundle.mainBundle()
    let storeBaseNameURL: NSURL! = databaseStoreURL.URLByDeletingPathExtension
    assert(storeBaseNameURL != nil)
    let storeURL = databaseStoreURL
    let storeShmURL: NSURL! = storeBaseNameURL.URLByAppendingPathExtension("sqlite-shm")
    assert(storeShmURL != nil)
    let storeWalURL: NSURL! = storeBaseNameURL.URLByAppendingPathExtension("sqlite-wal")
    assert(storeWalURL != nil)

    var error: NSError?
    // Try getting and copying the resources to copy from the main bundle
    if let sqliteURL = mainBundle.URLForResource(resourceBaseName, withExtension: "sqlite"),
      sqliteShmURL = mainBundle.URLForResource(resourceBaseName, withExtension: "sqlite-shm"),
      sqliteWalURL = mainBundle.URLForResource(resourceBaseName, withExtension: "sqlite-wal")
      where (fileManager.copyItemAtURL(sqliteURL, toURL: databaseStoreURL)
        || !MSHandleError(error, message: "copy from \(sqliteURL) to \(databaseStoreURL) failed")) == true,
      let databaseStoreShmURL = databaseStoreURL.URLByDeletingPathExtension?.URLByAppendingPathExtension("sqlite-shm")
      where (fileManager.copyItemAtURL(sqliteShmURL, toURL: databaseStoreShmURL)
        || !MSHandleError(error, message: "copy from \(sqliteShmURL) to \(databaseStoreShmURL) failed")) == true,
      let databaseStoreWalURL = databaseStoreURL.URLByDeletingPathExtension?.URLByAppendingPathExtension("sqlite-wal")
      where (fileManager.copyItemAtURL(sqliteWalURL, toURL: databaseStoreWalURL)
        || !MSHandleError(error, message: "copy from \(sqliteWalURL) to \(databaseStoreWalURL) failed")) == true
    {
      MSLogDebug("sqlite(-shm/-wal) files copied successfully")
    }

    // Failed to get resources
    else {
      MSLogError("sqlite(-shm/-wal) file copy operation unsuccessful")
    }

  }

  /**
  loadJSONFileAtPath:forModel:context:logFlags:completion:

  - parameter path: String
  - parameter type: T.Type
  - parameter context: NSManagedObjectContext
  - parameter logFlags: LogFlags = .Default
  - parameter completion: ((Bool, NSError?) -> Void)? = nil
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

      if hasOption(LogFlags.File, logFlags),
        let contents = String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
      {
        MSLogDebug("content of file to parse:\n\(contents)")
      }

      let json: JSONValue?
      if hasOption(LogFlags.Preparsed, logFlags) {
        let preparsedString: String?
        do {
          preparsedString = try JSONSerialization.stringByParsingDirectivesForFile(path, options: .InflateKeypaths)
        } catch var error1 as NSError {
          error = error1
          preparsedString = nil
        } catch {
          fatalError()
        }
        if preparsedString != nil && MSHandleError(error) == false {
          MSLogDebug("preparsed content of file to parse:\n\(preparsedString!)")
          do {
            json = try JSONSerialization.objectByParsingString(preparsedString, options: .InflateKeypaths)
          } catch var error1 as NSError {
            error = error1
            json = nil
          } catch {
            fatalError()
          }
        } else {
          json = nil
        }
      } else {
        do {
          json = try JSONSerialization.objectByParsingFile(path, options: .InflateKeypaths)
        } catch var error1 as NSError {
          error = error1
          json = nil
        } catch {
          fatalError()
        }
      }

      if MSHandleError(error) == false && json != nil
      {
        if hasOption(LogFlags.Parsed, logFlags) { MSLogDebug("json objects from parsed file:\n\(json)") }

        if let data = ObjectJSONValue(json), importedObject = type(data: data, context: context) {

          MSLogDebug("imported \(type.className()) from file '\(path)'")

          if hasOption(LogFlags.Imported, logFlags) {
            MSLogDebug("json output for imported object:\n\(importedObject.jsonValue)")
          }

        } else if let data = ArrayJSONValue(json) {

          let importedObjects = type.importObjectsWithData(data, context: context)

          MSLogDebug("\(importedObjects.count) \(type.className()) objects imported from file '\(path)'")

          if hasOption(LogFlags.Imported, logFlags) {
            MSLogDebug("json output for imported object:\n\(JSONValue.Array(importedObjects.map({$0.jsonValue})).prettyRawValue)")
          }

        } else { MSLogError("file content must resolve into [String:AnyObject] or [[String:AnyObject]]") }

      } else { MSLogError("failed to parse file '\(path)'") }

    }
    completion?(error == nil, error)
  }

  /**
  loadJSONFileNamed:forModel:context:logFlags:completion:

  - parameter name: String
  - parameter type: T.Type
  - parameter context: NSManagedObjectContext
  - parameter logFlags: LogFlags = .Default
  - parameter completion: ((Bool, NSError?) -> Void)? = nil
  */
  public class func loadJSONFileNamed<T:ModelObject>(var name: String,
                                             forModel type: T.Type,
                                             context: NSManagedObjectContext,
                                            logFlags: LogFlags = .Default,
                                          completion: ((Bool, NSError?) -> Void)? = nil)
  {
    var error: NSError?
    var path: String?

    // Check if we are given an absolute path
    if name.hasPrefix("/") && name.hasSuffix(".json") { path = name }

    // Otherwise, treat as a bundle resource
    else {
      if name.hasSuffix(".json") { name = name.stringByDeletingPathExtension }
      if let p = self.dataModelBundle.pathForResource(name, ofType: "json") { path = p }
      else if let p = NSBundle.mainBundle().pathForResource(name, ofType: "json") { path = p }
      else {
        MSLogError("unable to resolve the name '\(name)' into a bundled file path")
        error = NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: nil)
      }
    }

    if path != nil { loadJSONFileAtPath(path!, forModel: type, context: context, logFlags: logFlags, completion: completion) }
    else { completion?(false, error) }
  }

  /**
  Load data from files parsed from command line arguments and save the root context

  - parameter completion: ((Bool, NSError?) -> Void)? = nil
  */
  private class func loadData(completion: ((Bool, NSError?) -> Void)? = nil) {

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

    saveRootContext(completion)

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

  - parameter modelType: ModelObject.Type
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

  // MARK: - Data stack related accessors and methods

  static public var managedObjectModel: NSManagedObjectModel { return stack.managedObjectModel }

  /**
  Creates a new main queue context as a child of the `rootContext` (via `stack`)

  - returns: NSManagedObjectContext
  */
  public class func mainContext() -> NSManagedObjectContext { return stack.mainContext() }

  /**
  isolatedContext

  - returns: NSManagedObjectContext
  */
  public class func isolatedContext() -> NSManagedObjectContext { return stack.isolatedContext() }

  /** The primary, private-queue managed object context maintained by `stack`.  */
  public class var rootContext: NSManagedObjectContext { return stack.rootContext }

  // MARK: Managed object context notifications

  /*
  NSManagedObjectContextObjectsDidChangeNotification

  Posted when values of properties of objects contained in a managed object context are changed.
  The notification is posted during processPendingChanges, after the changes have been processed, but before it is
  safe to call save: again (if you try, you will generate an infinite loop).

  The notification object is the managed object context. The userInfo dictionary contains the following keys:
  NSInsertedObjectsKey, NSUpdatedObjectsKey, and NSDeletedObjectsKey.

  Note that this notification is posted only when managed objects are changed; it is not posted when managed
  objects are added to a context as the result of a fetch.
  */
  private static func contextDidChangeNotification(notification: NSNotification) {
    MSLogDebug("context did change '\(toString((notification.object as! NSManagedObjectContext).nametag))")
  }

  /*
  NSManagedObjectContextWillSaveNotification
  Posted whenever a managed object context is about to perform a save operation.
  The notification object is the managed object context. There is no userInfo dictionary.
  */
  private static func contextWillSaveNotification(notification: NSNotification) {
    MSLogDebug("context will save '\(toString((notification.object as! NSManagedObjectContext).nametag))")
  }

  /*
  NSManagedObjectContextDidSaveNotification
  Posted whenever a managed object context completes a save operation.

  The notification object is the managed object context. The userInfo dictionary contains the following keys:
  NSInsertedObjectsKey, NSUpdatedObjectsKey, and NSDeletedObjectsKey.

  You can only use the managed objects in this notification on the same thread on which it was posted.

  You can pass the notification object to mergeChangesFromContextDidSaveNotification: on another thread, however
  you must not use the managed object in the user info dictionary directly on another thread. For more details,
  see Concurrency with Core Data.
  */
  private static func contextDidSaveNotification(notification: NSNotification) {
    MSLogDebug("context did save '\(toString((notification.object as! NSManagedObjectContext).nametag))")
  }

  // Mark: Saving contexts

  public typealias PerformBlock = (NSManagedObjectContext) -> Void
  public typealias CompletionCallback = (Bool, NSError?) -> Void

  /**
  Wraps save action with error handling, only to be called from within an appropriate 'perform' block

  - parameter context: NSManagedObjectContext
  
  - returns: (Bool, NSError?)
  */
  private class func saveContext(context: NSManagedObjectContext) -> (Bool, NSError?) {
    let error: NSError?
    return (context.save(), error)
  }

  /**
  Invokes `performBlockAndWait:` on the specified context, within which the optional block is invoked followed by a save

  - parameter context: NSManagedObjectContext
  - parameter block: PerformBlock? = nil
  
  - returns: (Bool, NSError?)
  */
  public class func saveContext(context: NSManagedObjectContext,
               withBlockAndWait block: PerformBlock? = nil) -> (Bool, NSError?)
  {
    MSLogDebug("saving context \(toString(context.nametag))")
    var (success, error): (Bool, NSError?) = (false, nil)
    context.performBlockAndWait { block?(context); (success, error) = DataManager.saveContext(context) }
    return (success, error)
  }

  /**
  Invokes `performBlock:` on the specified context, within which the optional block is invoked followed by a save

  - parameter context: NSManagedObjectContext
  - parameter block: PerformBlock? = nil
  */
  public class func saveContext(context: NSManagedObjectContext,
                      withBlock block: PerformBlock? = nil,
                     completion: CompletionCallback? = nil)
  {
    MSLogDebug("saving context \(toString(context.nametag))")
    context.performBlock {
      block?(context)
      let (success, error) = DataManager.saveContext(context)
      completion?(success, error)
    }
  }

  /**
  saveContext:withBlock::propagate:nonBlocking:completion:

  - parameter moc: NSManagedObjectContext
  - parameter block: ((NSManagedObjectContext) -> Void)? = nil
  - parameter propagate: Bool = false
  - parameter nonBlocking: Bool = false
  - parameter completion: ((Bool, NSError?) -> Void)? = nil
  */
  public class func saveContext(context: NSManagedObjectContext,
               withBlock block: PerformBlock? = nil,
               propagate: Bool = false,
             nonBlocking: Bool = false,
     backgroundExecution: Bool = false,
              completion: ((Bool, NSError?) -> Void)? = nil)
  {
    MSLogDebug("saving context '\(toString(context.nametag))")
    stack.saveContext(context,
                    withBlock: block,
                    propagate: propagate,
                  nonBlocking: nonBlocking,
          backgroundExecution: backgroundExecution,
                   completion: completion)
  }

  public class func propagatingSaveFromContext(context: NSManagedObjectContext) {
    MSLogDebug("starting context = \(toString(context.nametag))")
    var currentContext = context
    while let parentContext = currentContext.parentContext {
      MSLogDebug("saving context \(toString(parentContext.nametag))")
      parentContext.performBlockAndWait {DataManager.saveContext(parentContext)}
      currentContext = parentContext
    }
  }


  /**
  Save the root context

  - parameter completion: ((Bool, NSError?) -> Void)? = nil
  */
  public class func saveRootContext(completion: ((Bool, NSError?) -> Void)? = nil) {
    rootContext.performBlock {
      var error: NSError?
      MSLogDebug("saving context '\(String(self.rootContext.nametag))'")
      if self.rootContext.save() && !MSHandleError(error, message: "error occurred while saving context") {
        MSLogDebug("context saved successfully")
        completion?(true, nil)
      } else {
        MSHandleError(error, message: "failed to save context")
        completion?(false, error)
      }
    }
  }

  // MARK: - Marker type

  /** The type of action marked by a flag */
  public enum Marker: CustomStringConvertible, Equatable, Hashable {
    case Copy
    case Load
    case Remove
    case InMemory
    case LoadFile (String)
    case Dump
    case Log ([LogValue])

    /** Function to parse markers out of a string */
    public static func markersFromString(string: String) -> [Marker] {
      let maybeMarkers = ",".split(string).map({Marker(argValue: $0)})
      let markers = compressed(maybeMarkers)
      return markers
    }

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

    - parameter argValue: String
    */
    init?(argValue: String) {
      switch argValue {
        case "copy":
          self = Marker.Copy
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

    public var hashValue: Int {
      switch self {
        case .Copy, .Remove, .InMemory, .Dump, .Load: return key.hashValue
        case .LoadFile(let s): return s.hashValue
        case .Log(let logValues): return logValues.reduce(0, combine: {$0 + $1.rawValue.hashValue})
      }
    }
  }

  // MARK: - DataFlag type

  /**
  Type for parsing database operations command line arguments
  */
  public struct DataFlag: CustomStringConvertible {
    public var load: Bool
    public var dump: Bool
    public var remove: Bool
    public var inMemory: Bool
    public var copy: Bool
    public var logModel: Bool

    static let key = "databaseOperations"

    /** Initializes a new flag using command line argument if present */
    init() {
      var load = false
      var dump = false
      var remove = false
      var inMemory = false
      var copy = false
      var logModel = false

      if let env = String.fromCString(getenv(DataFlag.key)) {
        let markers = Marker.markersFromString(env)
        load =  markers ∋ .Load
        dump =  markers ∋ .Dump
        logModel =  markers ∋ .Log([.Model])
        copy = markers ∋ .Copy
        remove =  markers ∋ .Remove
        inMemory = markers ∋ .InMemory
      }

      if let arg = NSUserDefaults.standardUserDefaults().volatileDomainForName(NSArgumentDomain)[DataFlag.key] as? String {
        let markers = Marker.markersFromString(arg)
        load =  load || markers ∋ .Load
        dump = dump ||  markers ∋ .Dump
        logModel = logModel || markers ∋ .Log([.Model])
        copy = copy || markers ∋ .Copy
        remove = remove || markers ∋ .Remove
        inMemory = inMemory || markers ∋ .InMemory
      }

      self.load = load
      self.dump = dump
      self.remove = remove
      self.inMemory = inMemory
      self.copy = copy
      self.logModel = logModel
    }

    public var description: String {
      return "database operations:\n\t" + "\n\t".join(
        "load: \(load)",
        "dump: \(dump)",
        "remove: \(remove)",
        "inMemory: \(inMemory)",
        "copy: \(copy)",
        "log model: \(logModel)"
      )
    }
  }

  // MARK: - ModelFlag type

  /** Flags used as the base of a supported command line argument whose value should resolve into a valid `Marker` */
  public enum ModelFlag: String, EnumerableType, CustomStringConvertible {
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
        return Marker.markersFromString(argValue)
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
                                   .NetworkDevices, .Presets, .Remotes, .Controller].filter {
                                    ModelFlag.arguments[$0.rawValue] != nil
                                  }

    /**
    `EnumerableType` support, applies `block` to `all`

    - parameter block: (ModelFlag) -> Void
    */
    static public func enumerate(block: (ModelFlag) -> Void) { all ➤ block }


    public var description: String { return "\(rawValue):\n\t" + "\n\t".join(markers.map({$0.description})) }
  }

  // MARK: - LogFlags type

  public struct LogFlags: RawOptionSetType {
    private(set) public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public init(nilLiteral: ()) { rawValue = 0 }
    public static var allZeros: LogFlags { return LogFlags.Default }
    public static var Default: LogFlags = LogFlags(rawValue: 0b0000)
    public static var File: LogFlags = LogFlags(rawValue: 0b0001)
    public static var Parsed: LogFlags = LogFlags(rawValue: 0b0010)
    public static var Preparsed: LogFlags = LogFlags(rawValue: 0b0100)
    public static var Imported: LogFlags = LogFlags(rawValue: 0b1000)
  }

  public class func loadResourceForURL(url: NSURL) {
    let fm = NSFileManager.defaultManager()

    if let path = url.path where fm.isReadableFileAtPath(path) {

    }
  }

}

// MARK: - Support functions

/**
Equatable operator for `DataManager.Marker`

- parameter lhs: DataManager.Marker
- parameter rhs: DataManager.Marker

- returns: Bool
*/
public func ==(lhs: DataManager.Marker, rhs: DataManager.Marker) -> Bool {
  switch (lhs, rhs) {
    case (.Load, .Load), (.Copy, .Copy), (.InMemory, .InMemory), (.Dump, .Dump), (.Remove, .Remove): return true
    case (.LoadFile(let f1), .LoadFile(let f2)) where f1 == f2: return true
    case (.Log(let v1), .Log(let v2)) where v1 == v2: return true
    default: return false
  }
}
