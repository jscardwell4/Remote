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

  /**
  Type for parsing database-related arguments passed to application

  :example: -manufacturers load=Manufacturer_Test,dump,log=parsed-imported
  */

  /** The type of action marked by a flag */
  private enum Marker: Printable {

    case Load (String)
    case Dump
    case Log ([LogValue])

    /** Type of value marked for logging */
    enum LogValue: String {
      case Parsed   = "parsed"
      case Imported = "imported"
    }

    /** 'Raw' string value for the marker */
    var key: String {
      switch self {
      case .Load: return "load"
      case .Dump: return "dump"
      case .Log:  return "log"
      }
    }

    var value: AnyObject? {
      switch self {
      case .Load(let fileName): return fileName
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
      case "dump": self = Marker.Dump
      case ~/"load=.+": self = Marker.Load(argValue[5..<argValue.length])
      case ~/"log=.+": self = Marker.Log(compressed("-".split(argValue[4..<argValue.length]).map({LogValue(rawValue: $0)})))
      default: return nil
      }
    }

    var description: String {
      switch self {
      case .Dump: return "dump"
      case .Log(let values): return "log: " + ", ".join(values.map({$0.rawValue}))
      case .Load(let file): return "load: \(file)"
      }
    }
  }

  /** Flags used as the base of a supported command line argument whose value should resolve into a valid `Marker` */
  private enum Flag: String, EnumerableType {
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
      return Flag(rawValue: k as? String ?? "") != nil
    })

    /** Array of markers created by parsing associated command line argument */
    var markers: [Marker]? {
      if let argValue = Flag.arguments[rawValue] as? String {
        return compressed(",".split(argValue).map({Marker(argValue: $0)}))
      } else { return nil }
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

    /** An array of all possible flag keys */
    static var all: [Flag] = [.Manufacturers, .ComponentDevices, .Images, .Activities,
      .NetworkDevices, .Controller, .Presets, .Remotes]

    /** An array of all flag keys for which an argument has been passed */
    static var allPassed: [Flag] { return all.filter{self.arguments[$0.rawValue] != nil} }

    /**
    Specialized enumerate function which adds the option to enumerate only flag keys passed

    :param: #passedOnly Bool
    :param: block (Flag) -> Void
    */
    static func enumerate(#passedOnly: Bool, block: (Flag) -> Void) { apply((passedOnly ? allPassed : all), block) }

    /**
    `EnumerableType` support, calles `enumeratePassedOnly:block` with `passedOnly = true`

    :param: block (Flag) -> Void
    */
    static func enumerate(block: (Flag) -> Void) { enumerate(passedOnly: true, block: block) }

    var description: String {
      var description = rawValue
      if let markers = self.markers { description += ":\n\t" + "\n\t".join(markers.map({$0.description})) }
      return description
    }
  }

  /** loadData */
  class func loadData(completion: ((Bool, NSError?) -> Void)? = nil) {

    let moc = DataManager.rootContext
    let log = NSUserDefaults.standardUserDefaults().boolForKey("logImportedObjects")

    moc.performBlock {

      let flags = Flag.allPassed
      MSLogDebug("parsed flags…\n" + "\n".join(flags.map({$0.description})))

      flags ➤ {
        if let markers = $0.markers {
          var fileName: String?
          var logParsed = false
          var logImported = false
          for marker in markers {
            switch marker {
            case .Load(let f): fileName = f
            case .Log(let values): logParsed = values ∋ .Parsed; logImported = values ∋ .Imported
            default: break
            }
          }
          if fileName != nil {
            self.loadDataFromFile(fileName!,
                             type: $0.modelType,
                          context: moc,
                        logParsed: logParsed,
                      logImported: logImported)
          }
        }
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
/*
    Flag.enumerateDumpFlags {
      println("\(($0.self as AnyObject).className) objects:\n\(($0.objectsInContext(DataManager.rootContext) as NSArray).JSONString)\n")
    }

*/  }

  /**
  loadDataFromFile:type:context:

  :param: file String
  :param: type T.Type
  :param: context NSManagedObjectContext
  */
  private class func loadDataFromFile<T:ModelObject>(file: String,
                                                type: T.Type,
                                             context: NSManagedObjectContext,
                                           logParsed: Bool,
                                         logImported: Bool)
  {
    MSLogDebug("parsing file '\(file).json'")

    var error: NSError?
    if let filePath = NSBundle(forClass: self).pathForResource(file, ofType: "json"),
      data: AnyObject = JSONSerialization.objectByParsingFile(filePath, options: 1, error: &error)
      where MSHandleError(error) == false
    {

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
