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

  private enum LoadFlag: String, EnumerableType {
    case Presets           = "loadPresets"
    case Images            = "loadImages"
    case Manufacturers     = "loadManufacturers"
    case ComponentDevices  = "loadComponentDevices"
    case NetworkDevices    = "loadNetworkDevices"
    case Controller        = "loadController"
    case Activities        = "loadActivities"
    case Remotes           = "loadRemotes"

    var isSet: Bool { return fileName != nil }
    var fileName: String? { return NSUserDefaults.standardUserDefaults().stringForKey(rawValue) }
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

    static var all: [LoadFlag] {
      return [.Presets, .Images, .Manufacturers, .ComponentDevices, .NetworkDevices, .Controller, .Activities, .Remotes]
    }

    static var allSet: [LoadFlag] { return all.filter{$0.isSet} }

    static func enumerate(block: (LoadFlag) -> Void) { apply(all, block) }
    static func enumerateSet(block: (LoadFlag) -> Void) { apply(allSet, block) }

  }

//  static let importFiles: [(file: String, type: ModelObject.Type, include: Bool, log: Bool)] = [
//    ("Preset",             PresetCategory.self,     true, false),
//    ("Glyphish",           ImageCategory.self,      true, false),
//    ("Manufacturer_Test",  Manufacturer.self,       true, false),
//    ("ComponentDevice",    ComponentDevice.self,    true, false),
//    ("NetworkDevice",      NetworkDevice.self,      true, false),
//    ("ActivityController", ActivityController.self, false, false),
//    ("Activity",           Activity.self,           false, false),
//    ("Remote_Demo",        Remote.self,             false, false)
//  ]

  /** loadData */
  class func loadData(completion: ((Bool, NSError?) -> Void)? = nil) {

    let moc = DataManager.rootContext
    let log = NSUserDefaults.standardUserDefaults().boolForKey("logImportedObjects")

    moc.performBlock {

      LoadFlag.enumerateSet {
        (flag: LoadFlag) -> Void in

        moc.deleteObjects(Set(flag.modelType.findAllInContext(moc)))
        if let fileName = flag.fileName {
          self.loadDataFromFile(fileName, type: flag.modelType, context: moc, log: log)
        }
      }

//      apply(self.importFiles.filter {_, _, i, _ in i}) {f, t, _, l in self.loadDataFromFile(f, type: t, context: moc, log: l)}

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
