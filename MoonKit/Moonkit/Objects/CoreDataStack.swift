//
//  CoreDataStack.swift
//  Remote
//
//  Created by Jason Cardwell on 12/18/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData

private var stackInstanceCount = 0
private var stackInstances: [ObjectIdentifier:Int] = [:]

private var mainContextCount = 0
private var isolatedContextCount = 0
private var privateContextCount = 0

public class CoreDataStack {

  public let managedObjectModel: NSManagedObjectModel
  public let persistentStore: NSPersistentStore
  public let persistentStoreCoordinator: NSPersistentStoreCoordinator
  public let rootContext: NSManagedObjectContext
  public var nametag: String { return "<stack\(toString(stackInstances[ObjectIdentifier(self)]))>" }

  /**
  initWithManagedObjectModel:persistentStoreURL:options:

  - parameter managedObjectModel: NSManagedObjectModel
  - parameter persistentStoreURL: NSURL
  - parameter options: [NSObject:AnyObject]? = nil
  */
  public init?(managedObjectModel: NSManagedObjectModel, persistentStoreURL: NSURL?, options: [NSObject:AnyObject]? = nil) {
    self.managedObjectModel = managedObjectModel
    persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

    let storeType = persistentStoreURL == nil ? NSInMemoryStoreType : NSSQLiteStoreType
    var error: NSError?
    do {
      let store = try persistentStoreCoordinator.addPersistentStoreWithType(storeType,
                                                             configuration: nil,
                                                                       URL: persistentStoreURL,
                                                                   options: options)
      persistentStore = store
      rootContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
      stackInstances[ObjectIdentifier(self)] = ++stackInstanceCount
      rootContext.persistentStoreCoordinator = persistentStoreCoordinator
      rootContext.nametag = "\(nametag)<root>"
      MSLogDebug("\(nametag) initialized")
    } catch var error1 as NSError { error = error1; MSHandleError(error); rootContext = NSManagedObjectContext(); persistentStore = NSPersistentStore(); return nil }
  }

  /**
  mainContext

  - returns: NSManagedObjectContext
  */
  public func mainContext() -> NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    context.parentContext = rootContext
    context.nametag = "\(nametag)<main\(++mainContextCount)>"
    MSLogDebug("context created: \(toString(context.nametag))")
    return context
  }

  /**
  isolatedContext

  - returns: NSManagedObjectContext
  */
  public func isolatedContext() -> NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    context.persistentStoreCoordinator = persistentStoreCoordinator
    context.nametag = "\(nametag)<isolated\(++isolatedContextCount)>"
    MSLogDebug("context created: \(toString(context.nametag))")
    return context
  }
  /**
  privateContext

  - returns: NSManagedObjectContext
  */
  public func privateContext() -> NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    context.parentContext = rootContext
    context.nametag = "\(nametag)<private\(++privateContextCount)>"
    MSLogDebug("context created: \(toString(context.nametag))")
    return context
  }


  /**
  saveContext:withBlock::propagate:nonBlocking:completion:

  - parameter moc: NSManagedObjectContext
  - parameter block: ((NSManagedObjectContext) -> Void)? = nil
  - parameter propagate: Bool = false
  - parameter nonBlocking: Bool = false
  - parameter completion: ((Bool, NSError?) -> Void)? = nil
  */
  public func saveContext(context: NSManagedObjectContext,
                withBlock block: ((NSManagedObjectContext) -> Void)? = nil,
                propagate: Bool = false,
              nonBlocking: Bool = false,
      backgroundExecution: Bool = false,
               completion: ((Bool, NSError?) -> Void)? = nil)
  {

    // Initialize variables for passing to completion block
    var error: NSError?
    var success = true

    // Create a closure that calls the appropriate `perform` variation
    let perform: (NSManagedObjectContext?, (NSManagedObjectContext) -> Void) -> Void = {
      context, work in if let moc = context { (nonBlocking ? moc.performBlock : moc.performBlockAndWait)({work(moc)}) }
    }

    // Create a closure for performing the save operation on the current context
    let save: (NSManagedObjectContext?) -> Void = {
      context in
      if let moc = context {
        moc.processPendingChanges()
        if moc.hasChanges == true {
          MSLogDebug("saving context '\(toString(moc.nametag))'")
          success = moc.save() == true
        }
      }
    }

    let propagateSave: (NSManagedObjectContext) -> Void = {
      context in
      var currentContext = context
      while let parentContext = currentContext.parentContext {
        save(parentContext)
        currentContext = parentContext
      }
    }

    // Create a child context if flagged for background execution
    if backgroundExecution {
      let childContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
      childContext.nametag = "child of \(toString(context.nametag))"
      childContext.parentContext = context
      childContext.undoManager = nil
      perform(childContext) {
        context in
        block?(context)
        save(context)
        let parentContext = context.parentContext!
        save(parentContext)
        if propagate { propagateSave(parentContext) }
        completion?(success, error)
      }
    } else {
      perform(context) {
        context in
        block?(context)
        save(context)
        if let parentContext = context.parentContext where propagate { propagateSave(parentContext) }
        completion?(success, error)
      }
    }

  }

}
