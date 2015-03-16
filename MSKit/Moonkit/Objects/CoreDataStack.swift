//
//  CoreDataStack.swift
//  Remote
//
//  Created by Jason Cardwell on 12/18/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataStack {

  public let managedObjectModel: NSManagedObjectModel
  public let persistentStore: NSPersistentStore
  public let persistentStoreCoordinator: NSPersistentStoreCoordinator
  public let rootContext: NSManagedObjectContext

  /**
  initWithManagedObjectModel:persistentStoreURL:options:

  :param: managedObjectModel NSManagedObjectModel
  :param: persistentStoreURL NSURL
  :param: options [NSObject:AnyObject]? = nil
  */
  public init?(managedObjectModel: NSManagedObjectModel, persistentStoreURL: NSURL, options: [NSObject:AnyObject]? = nil) {
    self.managedObjectModel = managedObjectModel
    persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    rootContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    rootContext.persistentStoreCoordinator = persistentStoreCoordinator
    rootContext.nametag = "root"

    var error: NSError?
    if let store = persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                                                           configuration: nil,
                                                                     URL: persistentStoreURL,
                                                                 options: options,
                                                                   error: &error)
    {
      persistentStore = store
      MSLogDebug("core data stack initialized")
    }

    else { MSHandleError(error); persistentStore = NSPersistentStore(); return nil }
  }

  /**
  mainContext

  :returns: NSManagedObjectContext
  */
  public func mainContext() -> NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    context.parentContext = rootContext
    return context
  }

  /**
  privateContext

  :returns: NSManagedObjectContext
  */
  public func privateContext() -> NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    context.parentContext = rootContext
    return context
  }


  /**
  saveContext:withBlock::propagate:nonBlocking:completion:

  :param: moc NSManagedObjectContext
  :param: block ((NSManagedObjectContext) -> Void)? = nil
  :param: propagate Bool = false
  :param: nonBlocking Bool = false
  :param: completion ((Bool, NSError?) -> Void)? = nil
  */
  public func saveContext(moc: NSManagedObjectContext,
                withBlock block: ((NSManagedObjectContext) -> Void)? = nil,
                propagate: Bool = false,
              nonBlocking: Bool = false,
      backgroundExecution: Bool = false,
               completion: ((Bool, NSError?) -> Void)? = nil)
  {

    // Initialize variables for passing to completion block
    var error: NSError?
    var success = true

    // Capture context passed in a variable so we can update the reference iteratively
    var currentContext: NSManagedObjectContext? = moc

    // Create a closure that calls the appropriate `perform` variation
    let performWork: (NSManagedObjectContext?, (NSManagedObjectContext) -> Void) -> Void = {
      context, work in
      if context != nil {
        let doIt = nonBlocking ? context!.performBlock : context!.performBlockAndWait
        doIt({ work(context!) })
      }
    }

    // Create a child context if flagged for background execution
    if backgroundExecution {
      let childContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
      childContext.nametag = "child of \((currentContext?.nametag ?? nil) ?? nil)"
      childContext.parentContext = currentContext
      childContext.undoManager = nil
      currentContext = childContext
    }

    // Create a closure for performing the save operation on the current context
    let save: (NSManagedObjectContext?) -> Void = {
      $0?.processPendingChanges()
      if $0?.hasChanges == true {
        MSLogDebug("saving context '\(($0?.nametag ?? nil) ?? nil)'")
        success = $0?.save(&error) == true
      }
    }


    // Wrap execution in a perform block for the leaf context
    performWork(currentContext) {
      leafContext in
      block?(leafContext)
      save(leafContext)
      if propagate || leafContext !== moc {
        do {
          performWork(currentContext){ save($0) }
          currentContext = currentContext?.parentContext
        } while propagate && currentContext != nil
      }
    }

    completion?(success, error)
  }

}
