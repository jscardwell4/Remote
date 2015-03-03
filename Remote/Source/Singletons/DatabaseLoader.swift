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

  /** loadData */
  class func loadData(completion: ((Bool, NSError?) -> Void)? = nil) {

    let moc = DataManager.rootContext

    moc.performBlock {
      self.loadPresets(moc)
      self.loadImages(moc)
      self.loadManufacturers(moc)
      self.loadComponentDevices(moc)
      self.loadActivityController(moc)
      self.loadActivities(moc)
      self.loadRemotes(moc)
      var error: NSError?
      MSLogDebug("saving context…")
      let success = moc.save(&error)
      if success { MSLogDebug("context saved successfully") }
      else { MSLogDebug("context failed to save") }
      completion?(success, error)
    }

/*    DataManager.saveContext(DataManager.rootContext, withBlock: {
        self.loadPresets($0)
        self.loadImages($0)
        self.loadManufacturers($0)
        self.loadComponentDevices($0)
//        self.loadNetworkDevices($0)
        self.loadActivityController($0)
        self.loadActivities($0)
        self.loadRemotes($0)
      },
      nonBlocking: true,
      completion: completion)	*/
  }

  /**
  loadRemotes:

  :param: context NSManagedObjectContext
  */
  private class func loadRemotes(context: NSManagedObjectContext) {
    MSLogDebug("loading remotes...")
    var error: NSError?
    if let filePath = NSBundle.mainBundle().pathForResource("Remote_Demo", ofType: "json"),
      let importData = JSONSerialization.objectByParsingFile(filePath, options:1, error:&error) as? NSArray {
      assert(MSHandleError(error) == false)
      let importedObjects = Remote.importObjectsFromData(importData, context: context)
      MSLogDebug("\(importedObjects.count ?? 0) remotes imported")
    }
  }

  /**
  loadActivityController:

  :param: context NSManagedObjectContext
  */
  private class func loadActivityController(context: NSManagedObjectContext) {
    MSLogDebug("loading activity controller...")
    var error: NSError?
    if let filePath = NSBundle.mainBundle().pathForResource("ActivityController", ofType: "json") {
      let importData = JSONSerialization.objectByParsingFile(filePath, options:1, error:&error) as? NSDictionary
      assert(MSHandleError(error) == false)
      let importedObject = ActivityController.importObjectFromData(importData as! [NSObject:AnyObject], context: context)
      MSLogDebug("activity controller imported? \(importedObject != nil)")
    }
  }


  /**
  loadPresets:

  :param: context NSManagedObjectContext
  */
  private class func loadPresets(context: NSManagedObjectContext) {
    MSLogDebug("loading presets...")
    var error: NSError?
    if let filePath = NSBundle.mainBundle().pathForResource("Preset", ofType: "json"),
      let importData = JSONSerialization.objectByParsingFile(filePath, options:1, error:&error) as? NSArray {
      assert(MSHandleError(error) == false)
      let importedObjects = PresetCategory.importObjectsFromData(importData, context: context) as? [PresetCategory]
      MSLogDebug("\(reduce(importedObjects?.map({$0.totalItemCount}) ?? [], 0, {$0 + $1})) presets imported")
    }
  }

  /**
  loadActivities:

  :param: context NSManagedObjectContext
  */
  private class func loadActivities(context: NSManagedObjectContext) {
    MSLogDebug("loading activities...")
    var error: NSError?
    if let filePath = NSBundle.mainBundle().pathForResource("Activity", ofType: "json"),
      let importData = JSONSerialization.objectByParsingFile(filePath, options:1, error:&error) as? NSArray {
      assert(MSHandleError(error) == false)
      let importedObjects = Activity.importObjectsFromData(importData, context: context)
      MSLogDebug("\(importedObjects.count ?? 0) activities imported")
    }
  }

  /**
  loadManufacturers:

  :param: context NSManagedObjectContext
  */
  private class func loadManufacturers(context: NSManagedObjectContext) {
    MSLogDebug("loading manufacturers...")
    var error: NSError?
    if let filePath = NSBundle.mainBundle().pathForResource("Manufacturer_Test", ofType: "json"),
      let importData = JSONSerialization.objectByParsingFile(filePath, options:1, error:&error) as? NSArray {
      assert(MSHandleError(error) == false)
      let importedObjects = Manufacturer.importObjectsFromData(importData, context: context)
      MSLogDebug("\(importedObjects.count ?? 0) manufacturers imported")
    }
  }

  /**
  loadComponentDevices:

  :param: context NSManagedObjectContext
  */
  private class func loadComponentDevices(context: NSManagedObjectContext) {
    MSLogDebug("loading component devices...")
    var error: NSError?
    if let filePath = NSBundle.mainBundle().pathForResource("ComponentDevice", ofType: "json"),
      let importData = JSONSerialization.objectByParsingFile(filePath, options:1, error:&error) as? NSArray {
      assert(MSHandleError(error) == false)
      let importedObjects = ComponentDevice.importObjectsFromData(importData, context: context)
      MSLogDebug("\(importedObjects.count ?? 0) component devices imported")
    }
  }

  /**
  loadNetworkDevices:

  :param: context NSManagedObjectContext
  */
  private class func loadNetworkDevices(context: NSManagedObjectContext) {
    MSLogDebug("loading network devices...")
    var error: NSError?
    if let filePath = NSBundle.mainBundle().pathForResource("NetworkDevice", ofType: "json"),
      let importData = JSONSerialization.objectByParsingFile(filePath, options:1, error:&error) as? NSArray {
      assert(MSHandleError(error) == false)
      let importedObjects = NetworkDevice.importObjectsFromData(importData, context: context)
      MSLogDebug("\(importedObjects.count ?? 0) network devices imported")
    }
  }

  /**
  loadImages:

  :param: context NSManagedObjectContext
  */
  private class func loadImages(context: NSManagedObjectContext) {
    MSLogDebug("loading images...")
    var error: NSError?
    if let filePath = NSBundle.mainBundle().pathForResource("Glyphish", ofType: "json"),
      let importData = JSONSerialization.objectByParsingFile(filePath, options:1, error:&error) as? NSArray {
      assert(MSHandleError(error) == false)
      let importedObjects = ImageCategory.importObjectsFromData(importData, context: context) as! [ImageCategory]
      MSLogDebug("\(reduce(importedObjects.map({$0.totalItemCount}) ?? [], 0, {$0 + $1})) images imported")
    }
  }


}
