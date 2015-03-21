//
//  DatabaseLoader.swift
//  Remote
//
//  Created by Jason Cardwell on 12/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc class DatabaseLoader {

  private enum FlagBase: String, EnumerableType {
    case Presets           = "Presets"
    case Images            = "Images"
    case Manufacturers     = "Manufacturers"
    case ComponentDevices  = "ComponentDevices"
    case NetworkDevices    = "NetworkDevices"
    case Controller        = "Controller"
    case Activities        = "Activities"
    case Remotes           = "Remotes"

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

    static var all: [FlagBase] {
      return [.Presets, .Images, .Manufacturers, .ComponentDevices, .NetworkDevices, .Controller, .Activities, .Remotes]
    }

    static func enumerate(block: (FlagBase) -> Void) { apply(all, block) }
  }

  private enum Flag {
    case Load (FlagBase)
    case Dump (FlagBase)

    var value: Any? {
      switch self {
      case .Load(let base): return NSUserDefaults.standardUserDefaults().stringForKey("load\(base.rawValue)")
      case .Dump(let base): return NSUserDefaults.standardUserDefaults().boolForKey("dump\(base.rawValue)")
      }
    }
    var isSet: Bool {
      switch self {
        case .Load: if let file = value as? String { return true } else { false }
        case .Dump: if let value = self.value as? Bool where value == true { return true } else { return false }
      }
      return false
    }

    var modelType: ModelObject.Type {
      switch self {
      case .Load(let base): return base.modelType
      case .Dump(let base): return base.modelType
      }
    }

    static func enumerateLoadFlags(block: (ModelObject.Type, String) -> Void) {
      FlagBase.enumerate {
        let flag = Flag.Load($0)
        if let fileName = flag.value as? String { block(flag.modelType, fileName) }
      }
    }

    static func enumerateDumpFlags(block: (ModelObject.Type) -> Void) {
      FlagBase.enumerate {
        let flag = Flag.Dump($0)
        if flag.isSet { block(flag.modelType) }
      }
    }
  }


  /** loadData */
  class func loadData(completion: ((Bool, NSError?) -> Void)? = nil) {

    let moc = DataManager.rootContext
    let log = NSUserDefaults.standardUserDefaults().boolForKey("logImportedObjects")

    moc.performBlock {

      Flag.enumerateLoadFlags {
        (type: ModelObject.Type, file: String) -> Void in

        moc.deleteObjects(Set(type.findAllInContext(moc)))
        self.loadDataFromFile(file, type: type, context: moc, log: log)
      }

      var error: NSError?
      MSLogDebug("saving context…")
      if moc.save(&error) && !MSHandleError(error, message: "error occurred while saving context") {
        MSLogDebug("context saved successfully")
        completion?(true, nil)
      } else {
        MSHandleError(error, message: "failed to save context")
        completion?(false, error)
      }
    }
  }

  /** dumpData */
  class func dumpData(completion: ((Bool, NSError?) -> Void)? = nil ) {
    Flag.enumerateDumpFlags {
      println("\(($0.self as AnyObject).className) objects:\n\(($0.findAllInContext(DataManager.rootContext) as NSArray).JSONString)\n")
    }
  }

  /**
  loadDataFromFile:type:context:

  :param: file String
  :param: type T.Type
  :param: context NSManagedObjectContext
  */
  private class func loadDataFromFile<T:ModelObject>(file: String, type: T.Type, context: NSManagedObjectContext, log: Bool) {
    MSLogDebug("parsing file '\(file).json'")

    var error: NSError?
    if let filePath = NSBundle(forClass: self).pathForResource(file, ofType: "json"),
      data: AnyObject = JSONSerialization.objectByParsingFile(filePath, options: 1, error: &error)
      where MSHandleError(error) == false
    {

      if log { MSLogDebug("json objects from parsed file:\n\(data)") }

      if let dataDictionary = data as? [String:AnyObject],
        importedObject = type(data: dataDictionary, context: context) {

        MSLogDebug("imported \(type.className()) from file '\(file).json'")

        if log { MSLogDebug("json output for imported object:\n\(importedObject.JSONString)") }

      } else if let dataArray = data as? [[String:AnyObject]] {

        let importedObjects = type.importObjectsFromData(dataArray, context: context)

        MSLogDebug("\(importedObjects.count) \(type.className()) objects imported from file '\(file).json'")

        if log { MSLogDebug("json output for imported object:\n\((importedObjects as NSArray).JSONString)") }

      } else { MSLogError("file content must resolve into [String:AnyObject] or [[String:AnyObject]]") }

    } else { MSLogError("failed to parse file '\(file).json'") }
  }

}
